import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/invoice_settings_provider.dart';
import '../providers/business_info_provider.dart';

class InvoicePreviewScreen extends ConsumerStatefulWidget {
  const InvoicePreviewScreen({super.key});

  @override
  ConsumerState<InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends ConsumerState<InvoicePreviewScreen> {
  String _selectedSize = '80mm';
  
  final Map<String, Size> paperSizes = {
    '58mm': const Size(58, 200), // 58mm width, variable height
    '78mm': const Size(78, 200), // 78mm width, variable height
    '80mm': const Size(80, 200), // 80mm width, variable height
    'A4': const Size(210, 297),   // A4 size in mm
  };

  @override
  Widget build(BuildContext context) {
    final invoiceSettingsAsync = ref.watch(invoiceSettingsProvider);
    final businessInfoAsync = ref.watch(businessInfoProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Preview'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.pageview),
            onSelected: (value) {
              setState(() {
                _selectedSize = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: '58mm',
                child: Text('58mm Receipt'),
              ),
              const PopupMenuItem(
                value: '78mm',
                child: Text('78mm Receipt'),
              ),
              const PopupMenuItem(
                value: '80mm',
                child: Text('80mm Receipt'),
              ),
              const PopupMenuItem(
                value: 'A4',
                child: Text('A4 Invoice'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Paper Size: $_selectedSize',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              invoiceSettingsAsync.when(
                data: (settings) => businessInfoAsync.when(
                  data: (businessInfo) => Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _buildInvoicePreview(settings, businessInfo),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoicePreview(InvoiceSettings settings, BusinessInfo? businessInfo) {
    final size = paperSizes[_selectedSize]!;
    final scale = _getScale();
    
    return Transform.scale(
      scale: scale,
      child: Container(
        width: size.width * 3.78, // Convert mm to pixels (approximately)
        constraints: BoxConstraints(
          minHeight: _selectedSize == 'A4' ? size.height * 3.78 : 0,
        ),
        padding: EdgeInsets.all(_selectedSize == 'A4' ? 40 : 16),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            if (settings.logoPath != null) ...[
              Center(
                child: Container(
                  width: _selectedSize == 'A4' ? 120 : 60,
                  height: _selectedSize == 'A4' ? 120 : 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.business, size: 40, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Company Details
            Center(
              child: Column(
                children: [
                  Text(
                    businessInfo?.businessName ?? 'Your Business Name',
                    style: TextStyle(
                      fontSize: _selectedSize == 'A4' ? 24 : 16,
                      fontWeight: FontWeight.bold,
                      color: settings.brandColor != null ? Color(settings.brandColor!) : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (businessInfo?.address != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      businessInfo!.address!,
                      style: TextStyle(
                        fontSize: _selectedSize == 'A4' ? 12 : 10,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (businessInfo?.phone != null) ...[
                    Text(
                      'Phone: ${businessInfo!.phone}',
                      style: TextStyle(
                        fontSize: _selectedSize == 'A4' ? 12 : 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  if (businessInfo?.email != null) ...[
                    Text(
                      'Email: ${businessInfo!.email}',
                      style: TextStyle(
                        fontSize: _selectedSize == 'A4' ? 12 : 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  if (businessInfo?.gstNumber != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'GSTIN: ${businessInfo!.gstNumber}',
                      style: TextStyle(
                        fontSize: _selectedSize == 'A4' ? 12 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            Divider(thickness: _selectedSize == 'A4' ? 2 : 1),
            const SizedBox(height: 16),
            
            // Invoice Details
            Center(
              child: Text(
                'TAX INVOICE',
                style: TextStyle(
                  fontSize: _selectedSize == 'A4' ? 20 : 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Invoice Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice No: ${settings.invoicePrefix}${settings.nextInvoiceNumber.toString().padLeft(4, '0')}',
                      style: TextStyle(
                        fontSize: _selectedSize == 'A4' ? 12 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Date: ${DateTime.now().toString().split(' ')[0]}',
                      style: TextStyle(fontSize: _selectedSize == 'A4' ? 12 : 10),
                    ),
                  ],
                ),
                if (_selectedSize == 'A4') ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Bill To:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Customer Name',
                        style: TextStyle(fontSize: 12),
                      ),
                      const Text(
                        'Customer Address',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            
            if (_selectedSize != 'A4') ...[
              const SizedBox(height: 8),
              const Text(
                'Customer: Walk-in Customer',
                style: TextStyle(fontSize: 10),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Items Table
            _buildItemsTable(settings),
            
            const SizedBox(height: 16),
            
            // Summary
            _buildSummary(settings),
            
            const SizedBox(height: 16),
            Divider(thickness: _selectedSize == 'A4' ? 2 : 1),
            
            // Payment Terms
            if (settings.showPaymentTerms) ...[
              const SizedBox(height: 8),
              Text(
                'Payment Terms: ${settings.defaultPaymentTerms}',
                style: TextStyle(
                  fontSize: _selectedSize == 'A4' ? 12 : 10,
                ),
              ),
            ],
            
            // Footer
            if (settings.footerText.isNotEmpty) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  settings.footerText,
                  style: TextStyle(
                    fontSize: _selectedSize == 'A4' ? 10 : 8,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            
            // Terms
            if (settings.termsConditions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Terms & Conditions:',
                style: TextStyle(
                  fontSize: _selectedSize == 'A4' ? 10 : 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                settings.termsConditions,
                style: TextStyle(
                  fontSize: _selectedSize == 'A4' ? 10 : 8,
                  color: Colors.grey[600],
                ),
              ),
            ],
            
            // Bank Details
            if (settings.bankDetails.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Bank Details:',
                style: TextStyle(
                  fontSize: _selectedSize == 'A4' ? 10 : 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...settings.bankDetails.entries.map((e) => Text(
                '${e.key}: ${e.value}',
                style: TextStyle(
                  fontSize: _selectedSize == 'A4' ? 10 : 8,
                  color: Colors.grey[600],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemsTable(InvoiceSettings settings) {
    if (_selectedSize == 'A4') {
      return Table(
        border: TableBorder.all(color: Colors.grey[300]!),
        columnWidths: const {
          0: FlexColumnWidth(0.5),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(1),
          4: FlexColumnWidth(1),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[100]),
            children: const [
              TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('#', style: TextStyle(fontWeight: FontWeight.bold)))),
              TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold)))),
              TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold)))),
              TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold)))),
              TableCell(child: Padding(padding: EdgeInsets.all(8), child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)))),
            ],
          ),
          ..._getSampleItems().map((item) => TableRow(
            children: [
              TableCell(child: Padding(padding: const EdgeInsets.all(8), child: Text(item['no'].toString()))),
              TableCell(child: Padding(padding: const EdgeInsets.all(8), child: Text(item['name']))),
              TableCell(child: Padding(padding: const EdgeInsets.all(8), child: Text(item['qty'].toString()))),
              TableCell(child: Padding(padding: const EdgeInsets.all(8), child: Text('${settings.defaultCurrency}${item['rate']}'))),
              TableCell(child: Padding(padding: const EdgeInsets.all(8), child: Text('${settings.defaultCurrency}${item['amount']}'))),
            ],
          )),
        ],
      );
    } else {
      // Simplified table for receipt formats
      return Column(
        children: [
          const Divider(),
          ..._getSampleItems().map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['name'],
                        style: const TextStyle(fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item['qty']} x ${settings.defaultCurrency}${item['rate']}',
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                    Text(
                      '${settings.defaultCurrency}${item['amount']}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          )),
          const Divider(),
        ],
      );
    }
  }

  Widget _buildSummary(InvoiceSettings settings) {
    final subtotal = 1500.0;
    final tax = subtotal * (settings.defaultTaxRate / 100);
    final total = subtotal + tax;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subtotal:',
              style: TextStyle(fontSize: _selectedSize == 'A4' ? 12 : 10),
            ),
            Text(
              '${settings.defaultCurrency}${subtotal.toStringAsFixed(2)}',
              style: TextStyle(fontSize: _selectedSize == 'A4' ? 12 : 10),
            ),
          ],
        ),
        if (settings.showTaxBreakdown) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tax (${settings.defaultTaxRate}%):',
                style: TextStyle(fontSize: _selectedSize == 'A4' ? 12 : 10),
              ),
              Text(
                '${settings.defaultCurrency}${tax.toStringAsFixed(2)}',
                style: TextStyle(fontSize: _selectedSize == 'A4' ? 12 : 10),
              ),
            ],
          ),
        ],
        const SizedBox(height: 4),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total:',
              style: TextStyle(
                fontSize: _selectedSize == 'A4' ? 16 : 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${settings.defaultCurrency}${total.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: _selectedSize == 'A4' ? 16 : 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getSampleItems() {
    return [
      {'no': 1, 'name': 'Product Item 1', 'qty': 2, 'rate': 250, 'amount': 500},
      {'no': 2, 'name': 'Product Item 2', 'qty': 1, 'rate': 500, 'amount': 500},
      {'no': 3, 'name': 'Product Item 3', 'qty': 5, 'rate': 100, 'amount': 500},
    ];
  }

  double _getScale() {
    switch (_selectedSize) {
      case '58mm':
        return 0.7;
      case '78mm':
        return 0.8;
      case '80mm':
        return 0.85;
      case 'A4':
        return MediaQuery.of(context).size.width > 600 ? 0.6 : 0.4;
      default:
        return 0.85;
    }
  }
}