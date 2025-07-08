import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/services/bluetooth_printer_service.dart';
import '../../data/models/printer_model.dart';

class PrinterSettingsScreen extends ConsumerStatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  ConsumerState<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends ConsumerState<PrinterSettingsScreen> {
  List<PrinterModel> _printers = [];
  PrinterModel? _selectedPrinter;
  bool _isScanning = false;
  PaperSize _paperSize = PaperSize.mm58;
  
  @override
  void initState() {
    super.initState();
    // Check Bluetooth status on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBluetoothStatus();
    });
  }
  
  Future<void> _checkBluetoothStatus() async {
    try {
      if (!await FlutterBluePlus.isAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bluetooth is not available on this device'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (!await FlutterBluePlus.isOn) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bluetooth is turned off. Please enable it to use printer.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      // Ignore errors during initial check
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final printerService = ref.watch(bluetoothPrinterServiceProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Printer Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isScanning ? null : _scanPrinters,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Card(
              color: Colors.blue.withOpacity(0.1),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'QuickBills can connect to ANY Bluetooth device with printing capability. All paired and nearby Bluetooth devices will be shown.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bluetooth, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Available Devices',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (_isScanning)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_printers.isEmpty && !_isScanning)
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.print_disabled, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No printers found',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _scanPrinters,
                              icon: const Icon(Icons.search),
                              label: const Text('Scan for Printers'),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _printers.length,
                        itemBuilder: (context, index) {
                          final printer = _printers[index];
                          final isSelected = _selectedPrinter?.address == printer.address;
                          
                          return Card(
                            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                            child: ListTile(
                              leading: Icon(
                                Icons.print,
                                color: isSelected ? Theme.of(context).primaryColor : null,
                              ),
                              title: Text(printer.name),
                              subtitle: Text(printer.address),
                              trailing: isSelected
                                  ? printerService.isConnected
                                      ? const Chip(
                                          label: Text('Connected'),
                                          backgroundColor: Colors.green,
                                          labelStyle: TextStyle(color: Colors.white),
                                        )
                                      : ElevatedButton(
                                          onPressed: () => _connectPrinter(printer),
                                          child: const Text('Connect'),
                                        )
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedPrinter = printer;
                                });
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paper Size',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<PaperSize>(
                            title: const Text('58mm'),
                            value: PaperSize.mm58,
                            groupValue: _paperSize,
                            onChanged: (value) {
                              setState(() {
                                _paperSize = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<PaperSize>(
                            title: const Text('80mm'),
                            value: PaperSize.mm80,
                            groupValue: _paperSize,
                            onChanged: (value) {
                              setState(() {
                                _paperSize = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Print',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: printerService.isConnected ? _printTest : null,
                        icon: const Icon(Icons.print),
                        label: const Text('Print Test Receipt'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _scanPrinters() async {
    setState(() {
      _isScanning = true;
      _printers = []; // Clear existing printers while scanning
    });
    
    try {
      final printerService = ref.read(bluetoothPrinterServiceProvider);
      
      // Check if Bluetooth is available and enabled
      if (!await FlutterBluePlus.isAvailable) {
        throw Exception('Bluetooth is not available on this device');
      }
      
      if (!await FlutterBluePlus.isOn) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable Bluetooth to scan for printers'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        }
        setState(() {
          _isScanning = false;
        });
        return;
      }
      
      final printers = await printerService.scanPrinters();
      
      setState(() {
        _printers = printers;
        _isScanning = false;
      });
      
      if (printers.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No printers found. Make sure your printer is powered on and in pairing mode.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      
      if (mounted) {
        String errorMessage = 'Failed to scan for printers';
        if (e.toString().contains('permissions')) {
          errorMessage = 'Bluetooth permissions not granted. Please enable permissions in settings.';
        } else if (e.toString().contains('Bluetooth')) {
          errorMessage = 'Bluetooth error. Please check Bluetooth settings.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () {
                openAppSettings();
              },
              textColor: Colors.white,
            ),
          ),
        );
      }
    }
  }
  
  Future<void> _connectPrinter(PrinterModel printer) async {
    try {
      final printerService = ref.read(bluetoothPrinterServiceProvider);
      final connected = await printerService.connectPrinter(printer.address);
      
      if (connected && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Printer connected successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _printTest() async {
    try {
      final printerService = ref.read(bluetoothPrinterServiceProvider);
      await printerService.printTestReceipt();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test receipt printed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to print: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}