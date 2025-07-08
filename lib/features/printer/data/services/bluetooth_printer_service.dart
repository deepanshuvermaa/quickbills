import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../models/printer_model.dart';
import '../models/receipt_model.dart';
import '../../../billing/data/models/bill_model.dart';
import '../../../billing/presentation/widgets/tax_settings_dialog.dart';

final bluetoothPrinterServiceProvider = Provider<BluetoothPrinterService>((ref) {
  return BluetoothPrinterService();
});

class BluetoothPrinterService {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  bool _isConnected = false;
  
  Future<bool> checkPermissions() async {
    // For Android 12 and above
    if (await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted) {
      return true;
    }
    
    // For older Android versions
    if (await Permission.bluetooth.isGranted) {
      return true;
    }
    
    // Request permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse, // Required for Bluetooth scanning on some devices
    ].request();
    
    // Check if all required permissions are granted
    bool bluetoothGranted = statuses[Permission.bluetooth]?.isGranted ?? false;
    bool scanGranted = statuses[Permission.bluetoothScan]?.isGranted ?? false;
    bool connectGranted = statuses[Permission.bluetoothConnect]?.isGranted ?? false;
    bool locationGranted = statuses[Permission.locationWhenInUse]?.isGranted ?? false;
    
    // For newer Android versions, we need scan and connect permissions
    // For older versions, we need bluetooth and location permissions
    return (scanGranted && connectGranted) || (bluetoothGranted && locationGranted);
  }
  
  Future<List<PrinterModel>> scanPrinters() async {
    final hasPermission = await checkPermissions();
    if (!hasPermission) {
      throw Exception('Bluetooth permissions not granted. Please enable Bluetooth permissions in app settings.');
    }
    
    try {
      // Check if Bluetooth is available
      if (!await FlutterBluePlus.isAvailable) {
        throw Exception('Bluetooth is not available on this device');
      }
      
      // Check if Bluetooth is enabled
      if (!await FlutterBluePlus.isOn) {
        throw Exception('Bluetooth is turned off. Please enable Bluetooth.');
      }
      
      // Stop any ongoing scan
      await FlutterBluePlus.stopScan();
      
      final printers = <PrinterModel>[];
      final seenDevices = <String>{};
      
      // Get already connected devices first
      try {
        final connectedDevices = await FlutterBluePlus.connectedDevices;
        for (final device in connectedDevices) {
          // Add all devices, even those without names
          final deviceName = device.name.isEmpty ? 'Unknown Device (${device.id.toString().substring(0, 8)})' : device.name;
          if (!seenDevices.contains(device.id.toString())) {
            printers.add(PrinterModel(
              name: deviceName,
              address: device.id.toString(),
              isConnected: true,
            ));
            seenDevices.add(device.id.toString());
          }
        }
      } catch (e) {
        print('Error getting connected devices: $e');
      }
      
      // Set up scan result listener before starting scan
      final scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (final result in results) {
          if (!seenDevices.contains(result.device.id.toString())) {
            // Include ALL devices, showing their MAC address if no name
            final deviceName = result.device.name.isEmpty 
                ? 'Device ${result.device.id.toString().substring(0, 8)}' 
                : result.device.name;
            
            // Add ALL devices to the list - the app will connect to ANY Bluetooth device
            printers.add(PrinterModel(
              name: deviceName,
              address: result.device.id.toString(),
              isConnected: false,
            ));
            seenDevices.add(result.device.id.toString());
          }
        }
      });
      
      // Start scanning with extended timeout
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidScanMode: AndroidScanMode.lowLatency,
      );
      
      // Wait for scan to complete
      await FlutterBluePlus.isScanning.where((val) => val == false).first;
      
      // Cancel subscription
      await scanSubscription.cancel();
      
      // Sort printers: connected first, then by name
      printers.sort((a, b) {
        if (a.isConnected && !b.isConnected) return -1;
        if (!a.isConnected && b.isConnected) return 1;
        return a.name.compareTo(b.name);
      });
      
      return printers;
    } catch (e) {
      // Stop scanning in case of error
      try {
        await FlutterBluePlus.stopScan();
      } catch (_) {}
      
      throw Exception('Failed to scan printers: ${e.toString()}');
    }
  }
  
  Future<bool> connectPrinter(String address) async {
    try {
      // Find device by address
      final devices = await FlutterBluePlus.connectedDevices;
      BluetoothDevice? device;
      
      // Check if already connected
      for (final d in devices) {
        if (d.id.toString() == address) {
          device = d;
          break;
        }
      }
      
      // If not connected, scan and connect
      if (device == null) {
        await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
        final results = await FlutterBluePlus.scanResults.first;
        
        for (final result in results) {
          if (result.device.id.toString() == address) {
            device = result.device;
            break;
          }
        }
        
        if (device == null) {
          throw Exception('Device not found');
        }
        
        await device.connect();
      }
      
      // Discover services
      final services = await device.discoverServices();
      
      // Find write characteristic (usually SPP service)
      for (final service in services) {
        for (final characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            _writeCharacteristic = characteristic;
            break;
          }
        }
        if (_writeCharacteristic != null) break;
      }
      
      if (_writeCharacteristic == null) {
        throw Exception('No write characteristic found');
      }
      
      _connectedDevice = device;
      _isConnected = true;
      return true;
    } catch (e) {
      _isConnected = false;
      throw Exception('Failed to connect: $e');
    }
  }
  
  Future<void> disconnect() async {
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    _writeCharacteristic = null;
    _isConnected = false;
  }
  
  Future<void> printReceipt(ReceiptModel receipt, {PrinterSize size = PrinterSize.mm80}) async {
    if (!_isConnected || _writeCharacteristic == null) {
      throw Exception('Printer not connected');
    }
    
    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(
        size == PrinterSize.mm80 ? PaperSize.mm80 : PaperSize.mm58, 
        profile,
      );
      
      List<int> bytes = [];
      
      // Initialize printer
      bytes += generator.reset();
      
      // Business Info
      bytes += generator.text(
        receipt.businessName,
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: true,
        ),
      );
      
      if (receipt.businessAddress != null) {
        bytes += generator.text(
          receipt.businessAddress!,
          styles: const PosStyles(align: PosAlign.center),
        );
      }
      
      if (receipt.businessPhone != null) {
        bytes += generator.text(
          'Tel: ${receipt.businessPhone}',
          styles: const PosStyles(align: PosAlign.center),
        );
      }
      
      if (receipt.taxNumber != null) {
        bytes += generator.text(
          'Tax No: ${receipt.taxNumber}',
          styles: const PosStyles(align: PosAlign.center),
        );
      }
      
      bytes += generator.hr();
      
      // Receipt Info
      bytes += generator.row([
        PosColumn(text: 'Bill No:', width: 6),
        PosColumn(text: receipt.invoiceNumber, width: 6, styles: const PosStyles(align: PosAlign.right)),
      ]);
      
      bytes += generator.row([
        PosColumn(text: 'Date:', width: 6),
        PosColumn(text: receipt.date, width: 6, styles: const PosStyles(align: PosAlign.right)),
      ]);
      
      if (receipt.customerName != null) {
        bytes += generator.row([
          PosColumn(text: 'Customer:', width: 6),
          PosColumn(text: receipt.customerName!, width: 6, styles: const PosStyles(align: PosAlign.right)),
        ]);
      }
      
      bytes += generator.hr();
      
      // Items Header
      bytes += generator.row([
        PosColumn(text: 'Item', width: 6),
        PosColumn(text: 'Qty', width: 2, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(text: 'Amount', width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]);
      
      bytes += generator.hr(ch: '-');
      
      // Items
      for (final item in receipt.items) {
        bytes += generator.row([
          PosColumn(text: item.name, width: 6),
          PosColumn(text: '${item.quantity}', width: 2, styles: const PosStyles(align: PosAlign.center)),
          PosColumn(text: '${item.total.toStringAsFixed(2)}', width: 4, styles: const PosStyles(align: PosAlign.right)),
        ]);
        
        bytes += generator.row([
          PosColumn(text: '  @${item.price}', width: 8),
          PosColumn(text: '', width: 4),
        ]);
      }
      
      bytes += generator.hr();
      
      // Totals
      bytes += generator.row([
        PosColumn(text: 'Subtotal:', width: 8, styles: const PosStyles(align: PosAlign.right)),
        PosColumn(text: receipt.subtotal.toStringAsFixed(2), width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]);
      
      if (receipt.discount > 0) {
        bytes += generator.row([
          PosColumn(text: 'Discount:', width: 8, styles: const PosStyles(align: PosAlign.right)),
          PosColumn(text: '-${receipt.discount.toStringAsFixed(2)}', width: 4, styles: const PosStyles(align: PosAlign.right)),
        ]);
      }
      
      if (receipt.tax > 0) {
        bytes += generator.row([
          PosColumn(text: 'Tax:', width: 8, styles: const PosStyles(align: PosAlign.right)),
          PosColumn(text: receipt.tax.toStringAsFixed(2), width: 4, styles: const PosStyles(align: PosAlign.right)),
        ]);
      }
      
      bytes += generator.hr();
      
      bytes += generator.row([
        PosColumn(
          text: 'Total:',
          width: 6,
          styles: const PosStyles(height: PosTextSize.size2, bold: true),
        ),
        PosColumn(
          text: receipt.total.toStringAsFixed(2),
          width: 6,
          styles: const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size2,
            bold: true,
          ),
        ),
      ]);
      
      bytes += generator.hr();
      
      // Payment Method
      bytes += generator.text(
        'Payment: ${receipt.paymentMethod}',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      // Footer
      if (receipt.footerText != null) {
        bytes += generator.text('');
        bytes += generator.text(
          receipt.footerText!,
          styles: const PosStyles(align: PosAlign.center),
        );
      }
      
      bytes += generator.text(
        'Thank you for your business!',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      
      // Cut paper
      bytes += generator.cut();
      
      // Send data in chunks
      final chunk = 100;
      for (var i = 0; i < bytes.length; i += chunk) {
        final end = (i + chunk < bytes.length) ? i + chunk : bytes.length;
        await _writeCharacteristic!.write(bytes.sublist(i, end), withoutResponse: true);
        await Future.delayed(const Duration(milliseconds: 50));
      }
      
    } catch (e) {
      throw Exception('Failed to print: $e');
    }
  }
  
  bool get isConnected => _isConnected;
  
  String? get connectedDeviceName => _connectedDevice?.name;
  
  Future<void> printTestReceipt() async {
    final testReceipt = ReceiptModel(
      businessName: 'QuickBills Test',
      businessAddress: '123 Test Street',
      businessPhone: '+1234567890',
      taxNumber: 'TEST123456',
      invoiceNumber: 'TEST-001',
      date: DateTime.now().toString().split(' ')[0],
      customerName: 'Test Customer',
      customerPhone: '+0987654321',
      items: [
        ReceiptItem(
          name: 'Test Item 1',
          quantity: 2,
          price: 100.00,
          total: 200.00,
        ),
        ReceiptItem(
          name: 'Test Item 2',
          quantity: 1,
          price: 50.00,
          total: 50.00,
        ),
      ],
      subtotal: 250.00,
      discount: 0,
      tax: 25.00,
      taxRate: 10.0,
      total: 275.00,
      paymentMethod: 'Cash',
      footerText: 'This is a test receipt',
    );
    
    await printReceipt(testReceipt);
  }
  
  Future<void> printBill(BillModel bill, {PrinterSize size = PrinterSize.mm80}) async {
    // Convert BillModel to ReceiptModel
    final receipt = ReceiptModel(
      businessName: 'QuickBills', // You can fetch this from business settings
      businessAddress: 'Your Business Address', // You can fetch this from business settings
      businessPhone: 'Your Phone Number', // You can fetch this from business settings
      taxNumber: 'Your Tax Number', // You can fetch this from business settings
      invoiceNumber: bill.invoiceNumber,
      date: DateFormat('dd/MM/yyyy HH:mm').format(bill.createdAt),
      customerName: bill.customerName,
      customerPhone: null, // Add customer phone if available
      items: bill.items.map((item) => ReceiptItem(
        name: item.productName,
        quantity: item.quantity,
        price: item.price,
        total: item.quantity * item.price,
      )).toList(),
      subtotal: bill.subtotal,
      discount: bill.discountAmount,
      tax: bill.tax,
      taxRate: bill.taxType == TaxType.cgstSgst 
          ? (bill.cgstRate + bill.sgstRate) 
          : bill.igstRate,
      total: bill.total,
      paymentMethod: bill.paymentMethod,
      footerText: bill.notes,
    );
    
    await printReceipt(receipt, size: size);
  }
}

enum PrinterSize { mm58, mm80 }