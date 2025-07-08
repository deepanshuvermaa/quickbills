import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart'; // Temporarily disabled
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../billing/data/models/bill_model.dart';
import '../../../inventory/data/models/product_model.dart';
import '../../../customers/data/models/customer_model.dart';
import '../models/export_history_model.dart';
import 'package:intl/intl.dart';

class ExportService {
  static const String exportHistoryBox = 'export_history';
  
  // Paper sizes in millimeters
  static const Map<String, PdfPageFormat> paperSizes = {
    'A4': PdfPageFormat.a4,
    '58mm': PdfPageFormat(58 * PdfPageFormat.mm, 297 * PdfPageFormat.mm),
    '78mm': PdfPageFormat(78 * PdfPageFormat.mm, 297 * PdfPageFormat.mm),
    '80mm': PdfPageFormat(80 * PdfPageFormat.mm, 297 * PdfPageFormat.mm),
  };

  Future<ExportHistoryModel?> exportData({
    required String dataType,
    required String format,
    required String paperSize,
    DateTimeRange? dateRange,
  }) async {
    try {
      final historyBox = await Hive.openBox<ExportHistoryModel>(exportHistoryBox);
      
      switch (dataType) {
        case 'products':
          return await _exportProducts(format, paperSize, historyBox);
        case 'customers':
          return await _exportCustomers(format, paperSize, historyBox);
        case 'sales':
          return await _exportSales(format, paperSize, dateRange, historyBox);
        case 'reports':
          return await _exportReports(format, paperSize, dateRange, historyBox);
        case 'all':
          return await _exportAllData(format, paperSize, dateRange, historyBox);
        default:
          throw Exception('Unknown data type: $dataType');
      }
    } catch (e) {
      print('Export error: $e');
      return null;
    }
  }

  Future<ExportHistoryModel> _exportProducts(
    String format,
    String paperSize,
    Box<ExportHistoryModel> historyBox,
  ) async {
    final productsBox = await Hive.openBox<ProductModel>(AppConstants.productsBox);
    final products = productsBox.values.toList();
    
    String filePath;
    if (format == 'csv') {
      filePath = await _generateProductsCSV(products);
    } else if (format == 'pdf') {
      filePath = await _generateProductsPDF(products, paperSize);
    } else {
      filePath = await _generateProductsExcel(products);
    }
    
    final export = ExportHistoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'Products',
      format: format.toUpperCase(),
      paperSize: paperSize,
      date: DateTime.now(),
      status: 'completed',
      records: products.length,
      filePath: filePath,
    );
    
    await historyBox.put(export.id, export);
    return export;
  }

  Future<ExportHistoryModel> _exportCustomers(
    String format,
    String paperSize,
    Box<ExportHistoryModel> historyBox,
  ) async {
    final customersBox = await Hive.openBox<CustomerModel>(AppConstants.customersBox);
    final customers = customersBox.values.toList();
    
    String filePath;
    if (format == 'csv') {
      filePath = await _generateCustomersCSV(customers);
    } else if (format == 'pdf') {
      filePath = await _generateCustomersPDF(customers, paperSize);
    } else {
      filePath = await _generateCustomersExcel(customers);
    }
    
    final export = ExportHistoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'Customers',
      format: format.toUpperCase(),
      paperSize: paperSize,
      date: DateTime.now(),
      status: 'completed',
      records: customers.length,
      filePath: filePath,
    );
    
    await historyBox.put(export.id, export);
    return export;
  }

  Future<ExportHistoryModel> _exportSales(
    String format,
    String paperSize,
    DateTimeRange? dateRange,
    Box<ExportHistoryModel> historyBox,
  ) async {
    final billsBox = await Hive.openBox<BillModel>(AppConstants.billsBox);
    var bills = billsBox.values.toList();
    
    // Filter by date range if provided
    if (dateRange != null) {
      bills = bills.where((bill) {
        final billDate = bill.createdAt;
        return billDate.isAfter(dateRange.start) && 
               billDate.isBefore(dateRange.end.add(const Duration(days: 1)));
      }).toList();
    }
    
    String filePath;
    if (format == 'csv') {
      filePath = await _generateSalesCSV(bills);
    } else if (format == 'pdf') {
      filePath = await _generateSalesPDF(bills, paperSize);
    } else {
      filePath = await _generateSalesExcel(bills);
    }
    
    final export = ExportHistoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'Sales/Bills',
      format: format.toUpperCase(),
      paperSize: paperSize,
      date: DateTime.now(),
      status: 'completed',
      records: bills.length,
      filePath: filePath,
      dateRangeStart: dateRange?.start,
      dateRangeEnd: dateRange?.end,
    );
    
    await historyBox.put(export.id, export);
    return export;
  }

  Future<ExportHistoryModel> _exportReports(
    String format,
    String paperSize,
    DateTimeRange? dateRange,
    Box<ExportHistoryModel> historyBox,
  ) async {
    // Generate comprehensive reports
    final billsBox = await Hive.openBox<BillModel>(AppConstants.billsBox);
    final productsBox = await Hive.openBox<ProductModel>(AppConstants.productsBox);
    final customersBox = await Hive.openBox<CustomerModel>(AppConstants.customersBox);
    
    var bills = billsBox.values.toList();
    if (dateRange != null) {
      bills = bills.where((bill) {
        final billDate = bill.createdAt;
        return billDate.isAfter(dateRange.start) && 
               billDate.isBefore(dateRange.end.add(const Duration(days: 1)));
      }).toList();
    }
    
    String filePath;
    if (format == 'pdf') {
      filePath = await _generateReportsPDF(
        bills: bills,
        products: productsBox.values.toList(),
        customers: customersBox.values.toList(),
        paperSize: paperSize,
        dateRange: dateRange,
      );
    } else {
      // For CSV/Excel, generate sales report
      filePath = format == 'csv' 
          ? await _generateSalesCSV(bills)
          : await _generateSalesExcel(bills);
    }
    
    final export = ExportHistoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'Reports',
      format: format.toUpperCase(),
      paperSize: paperSize,
      date: DateTime.now(),
      status: 'completed',
      records: bills.length,
      filePath: filePath,
      dateRangeStart: dateRange?.start,
      dateRangeEnd: dateRange?.end,
    );
    
    await historyBox.put(export.id, export);
    return export;
  }

  Future<ExportHistoryModel> _exportAllData(
    String format,
    String paperSize,
    DateTimeRange? dateRange,
    Box<ExportHistoryModel> historyBox,
  ) async {
    // For all data, we'll create a comprehensive report
    return await _exportReports(format, paperSize, dateRange, historyBox);
  }

  // CSV Generation Methods
  Future<String> _generateProductsCSV(List<ProductModel> products) async {
    List<List<dynamic>> rows = [];
    
    // Header
    rows.add([
      'ID',
      'Name',
      'Category',
      'Barcode',
      'SKU',
      'Purchase Price',
      'Selling Price',
      'Current Stock',
      'Min Stock',
      'Unit',
      'Tax Rate',
      'Active',
    ]);
    
    // Data
    for (var product in products) {
      rows.add([
        product.id,
        product.name,
        product.category,
        product.barcode,
        product.sku ?? '',
        product.purchasePrice,
        product.sellingPrice,
        product.currentStock,
        product.minStock,
        product.unit,
        product.taxRate ?? 0,
        product.isActive ? 'Yes' : 'No',
      ]);
    }
    
    String csv = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/products_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv);
    return file.path;
  }

  Future<String> _generateCustomersCSV(List<CustomerModel> customers) async {
    List<List<dynamic>> rows = [];
    
    // Header
    rows.add([
      'ID',
      'Name',
      'Phone',
      'Email',
      'Address',
      'GST Number',
      'Created Date',
      'Total Purchases',
    ]);
    
    // Data
    for (var customer in customers) {
      rows.add([
        customer.id,
        customer.name,
        customer.phone,
        customer.email ?? '',
        customer.address ?? '',
        customer.gstNumber ?? '',
        DateFormat('dd/MM/yyyy').format(customer.createdAt),
        customer.totalPurchases,
      ]);
    }
    
    String csv = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/customers_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv);
    return file.path;
  }

  Future<String> _generateSalesCSV(List<BillModel> bills) async {
    List<List<dynamic>> rows = [];
    
    // Header
    rows.add([
      'Bill No',
      'Date',
      'Customer',
      'Items',
      'Subtotal',
      'Tax',
      'Discount',
      'Total',
      'Payment Method',
      'Status',
    ]);
    
    // Data
    for (var bill in bills) {
      rows.add([
        bill.invoiceNumber,
        DateFormat('dd/MM/yyyy HH:mm').format(bill.createdAt),
        bill.customerName ?? 'Walk-in Customer',
        bill.items.length,
        bill.subtotal,
        bill.tax,
        bill.discountAmount,
        bill.total,
        bill.paymentMethod,
        bill.status,
      ]);
    }
    
    String csv = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/sales_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv);
    return file.path;
  }

  // PDF Generation Methods
  Future<String> _generateProductsPDF(List<ProductModel> products, String paperSize) async {
    final pdf = pw.Document();
    final pageFormat = paperSizes[paperSize] ?? PdfPageFormat.a4;
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: _getPDFMargins(paperSize),
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Products Report',
                style: pw.TextStyle(fontSize: _getTitleFontSize(paperSize)),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              context: context,
              cellStyle: pw.TextStyle(fontSize: _getBodyFontSize(paperSize)),
              headerStyle: pw.TextStyle(
                fontSize: _getBodyFontSize(paperSize),
                fontWeight: pw.FontWeight.bold,
              ),
              data: <List<String>>[
                <String>['Name', 'Category', 'Price', 'Stock'],
                ...products.map((p) => [
                  p.name,
                  p.category,
                  '₹${p.sellingPrice.toStringAsFixed(2)}',
                  '${p.currentStock} ${p.unit}',
                ]),
              ],
            ),
          ];
        },
      ),
    );
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/products_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  Future<String> _generateCustomersPDF(List<CustomerModel> customers, String paperSize) async {
    final pdf = pw.Document();
    final pageFormat = paperSizes[paperSize] ?? PdfPageFormat.a4;
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: _getPDFMargins(paperSize),
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Customers Report',
                style: pw.TextStyle(fontSize: _getTitleFontSize(paperSize)),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              context: context,
              cellStyle: pw.TextStyle(fontSize: _getBodyFontSize(paperSize)),
              headerStyle: pw.TextStyle(
                fontSize: _getBodyFontSize(paperSize),
                fontWeight: pw.FontWeight.bold,
              ),
              data: <List<String>>[
                <String>['Name', 'Phone', 'Total Purchases'],
                ...customers.map((c) => [
                  c.name,
                  c.phone ?? '',
                  '₹${c.totalPurchases.toStringAsFixed(2)}',
                ]),
              ],
            ),
          ];
        },
      ),
    );
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/customers_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  Future<String> _generateSalesPDF(List<BillModel> bills, String paperSize) async {
    final pdf = pw.Document();
    final pageFormat = paperSizes[paperSize] ?? PdfPageFormat.a4;
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: _getPDFMargins(paperSize),
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Sales Report',
                style: pw.TextStyle(fontSize: _getTitleFontSize(paperSize)),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              context: context,
              cellStyle: pw.TextStyle(fontSize: _getBodyFontSize(paperSize)),
              headerStyle: pw.TextStyle(
                fontSize: _getBodyFontSize(paperSize),
                fontWeight: pw.FontWeight.bold,
              ),
              columnWidths: _getColumnWidths(paperSize),
              data: <List<String>>[
                <String>['Date', 'Bill No', 'Customer', 'Total'],
                ...bills.map((b) => [
                  DateFormat('dd/MM').format(b.createdAt),
                  b.invoiceNumber,
                  b.customerName ?? 'Walk-in',
                  '₹${b.total.toStringAsFixed(0)}',
                ]),
              ],
            ),
          ];
        },
      ),
    );
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/sales_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  Future<String> _generateReportsPDF({
    required List<BillModel> bills,
    required List<ProductModel> products,
    required List<CustomerModel> customers,
    required String paperSize,
    DateTimeRange? dateRange,
  }) async {
    final pdf = pw.Document();
    final pageFormat = paperSizes[paperSize] ?? PdfPageFormat.a4;
    
    // Calculate totals
    double totalSales = bills.fold(0, (sum, bill) => sum + bill.total);
    double totalTax = bills.fold(0, (sum, bill) => sum + bill.tax);
    double totalDiscount = bills.fold(0, (sum, bill) => sum + bill.discountAmount);
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: _getPDFMargins(paperSize),
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Business Report',
                style: pw.TextStyle(fontSize: _getTitleFontSize(paperSize)),
              ),
            ),
            if (dateRange != null)
              pw.Text(
                '${DateFormat('dd/MM/yyyy').format(dateRange.start)} - ${DateFormat('dd/MM/yyyy').format(dateRange.end)}',
                style: pw.TextStyle(fontSize: _getBodyFontSize(paperSize)),
              ),
            pw.SizedBox(height: 20),
            
            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Summary', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  pw.Text('Total Sales: ₹${totalSales.toStringAsFixed(2)}'),
                  pw.Text('Total Tax: ₹${totalTax.toStringAsFixed(2)}'),
                  pw.Text('Total Discount: ₹${totalDiscount.toStringAsFixed(2)}'),
                  pw.Text('Total Bills: ${bills.length}'),
                  pw.Text('Total Products: ${products.length}'),
                  pw.Text('Total Customers: ${customers.length}'),
                ],
              ),
            ),
          ];
        },
      ),
    );
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  // Excel generation placeholder methods
  Future<String> _generateProductsExcel(List<ProductModel> products) async {
    // For now, generate CSV as Excel functionality requires additional package
    return await _generateProductsCSV(products);
  }

  Future<String> _generateCustomersExcel(List<CustomerModel> customers) async {
    return await _generateCustomersCSV(customers);
  }

  Future<String> _generateSalesExcel(List<BillModel> bills) async {
    return await _generateSalesCSV(bills);
  }

  // Helper methods for PDF formatting
  pw.EdgeInsets _getPDFMargins(String paperSize) {
    switch (paperSize) {
      case '58mm':
        return const pw.EdgeInsets.all(5);
      case '78mm':
      case '80mm':
        return const pw.EdgeInsets.all(8);
      default:
        return const pw.EdgeInsets.all(20);
    }
  }

  double _getTitleFontSize(String paperSize) {
    switch (paperSize) {
      case '58mm':
        return 12;
      case '78mm':
      case '80mm':
        return 14;
      default:
        return 20;
    }
  }

  double _getBodyFontSize(String paperSize) {
    switch (paperSize) {
      case '58mm':
        return 7;
      case '78mm':
      case '80mm':
        return 8;
      default:
        return 10;
    }
  }

  Map<int, pw.TableColumnWidth>? _getColumnWidths(String paperSize) {
    if (paperSize == '58mm' || paperSize == '78mm' || paperSize == '80mm') {
      return {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(3),
        3: const pw.FlexColumnWidth(2),
      };
    }
    return null;
  }

  // Print functionality
  Future<void> printExport(ExportHistoryModel export) async {
    // Temporarily disabled due to printing package issue
    throw UnimplementedError('Printing is temporarily disabled');
    
    // final file = File(export.filePath);
    // if (!await file.exists()) {
    //   throw Exception('Export file not found');
    // }

    // if (export.format == 'PDF') {
    //   final bytes = await file.readAsBytes();
    //   await Printing.layoutPdf(
    //     onLayout: (PdfPageFormat format) async => bytes,
    //     format: paperSizes[export.paperSize] ?? PdfPageFormat.a4,
    //   );
    // } else {
    //   // For CSV/Excel, convert to PDF first then print
    //   final pdf = await _convertToPDF(export);
    //   await Printing.layoutPdf(
    //     onLayout: (PdfPageFormat format) async => pdf,
    //     format: paperSizes[export.paperSize] ?? PdfPageFormat.a4,
    //   );
    // }
  }

  Future<Uint8List> _convertToPDF(ExportHistoryModel export) async {
    // Convert CSV/Excel to PDF for printing
    final file = File(export.filePath);
    final content = await file.readAsString();
    
    final pdf = pw.Document();
    final pageFormat = paperSizes[export.paperSize] ?? PdfPageFormat.a4;
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: _getPDFMargins(export.paperSize),
        build: (context) {
          return [
            pw.Text(
              '${export.type} Export',
              style: pw.TextStyle(fontSize: _getTitleFontSize(export.paperSize)),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              content,
              style: pw.TextStyle(fontSize: _getBodyFontSize(export.paperSize)),
            ),
          ];
        },
      ),
    );
    
    return pdf.save();
  }
}