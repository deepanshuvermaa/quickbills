import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/export_provider.dart';
import '../../data/models/export_history_model.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class ImportExportScreen extends ConsumerStatefulWidget {
  const ImportExportScreen({super.key});

  @override
  ConsumerState<ImportExportScreen> createState() => _ImportExportScreenState();
}

class _ImportExportScreenState extends ConsumerState<ImportExportScreen> {
  String _selectedExportType = 'all';
  String _selectedFormat = 'csv';
  String _selectedPaperSize = 'A4';
  DateTimeRange? _dateRange;
  bool _isExporting = false;
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Import/Export Data'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Export', icon: Icon(Icons.upload_file)),
              Tab(text: 'Import', icon: Icon(Icons.download)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildExportTab(),
            _buildImportTab(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Export Options
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Export Options',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Data Type Selection
                  const Text('Select Data Type'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedExportType,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Data')),
                      DropdownMenuItem(value: 'products', child: Text('Products')),
                      DropdownMenuItem(value: 'customers', child: Text('Customers')),
                      DropdownMenuItem(value: 'sales', child: Text('Sales/Bills')),
                      DropdownMenuItem(value: 'expenses', child: Text('Expenses')),
                      DropdownMenuItem(value: 'reports', child: Text('Reports')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedExportType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Format Selection
                  const Text('Export Format'),
                  const SizedBox(height: 8),
                  Wrap(
                    children: [
                      SizedBox(
                        width: 120,
                        child: RadioListTile<String>(
                          title: const Text('CSV'),
                          value: 'csv',
                          groupValue: _selectedFormat,
                          dense: true,
                          onChanged: (value) {
                            setState(() {
                              _selectedFormat = value!;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: RadioListTile<String>(
                          title: const Text('PDF'),
                          value: 'pdf',
                          groupValue: _selectedFormat,
                          dense: true,
                          onChanged: (value) {
                            setState(() {
                              _selectedFormat = value!;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: RadioListTile<String>(
                          title: const Text('Excel'),
                          value: 'excel',
                          groupValue: _selectedFormat,
                          dense: true,
                          onChanged: (value) {
                            setState(() {
                              _selectedFormat = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Paper Size Selection (for PDF)
                  if (_selectedFormat == 'pdf') ...[
                    const Text('Paper Size'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedPaperSize,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'A4', child: Text('A4')),
                        DropdownMenuItem(value: '58mm', child: Text('58mm (Thermal)')),
                        DropdownMenuItem(value: '78mm', child: Text('78mm (Thermal)')),
                        DropdownMenuItem(value: '80mm', child: Text('80mm (Thermal)')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedPaperSize = value!;
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  
                  // Date Range Selection
                  ListTile(
                    title: const Text('Date Range'),
                    subtitle: Text(
                      _dateRange == null
                          ? 'All time'
                          : '${DateFormat('dd/MM/yyyy').format(_dateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_dateRange!.end)}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _selectDateRange,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  
                  // Export Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isExporting ? null : _startExport,
                      icon: _isExporting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload_file),
                      label: Text(_isExporting ? 'Exporting...' : 'Export Data'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Export History
          const Text(
            'Export History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, child) {
              final exportHistoryAsync = ref.watch(exportHistoryProvider);
              
              return exportHistoryAsync.when(
                data: (exports) {
                  if (exports.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.history, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No export history',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  
                  return Column(
                    children: exports.map((export) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.withOpacity(0.1),
                          child: const Icon(Icons.check_circle, color: Colors.green),
                        ),
                        title: Text('${export.type} (${export.format})'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${export.records} records • ${DateFormat('dd MMM yyyy, HH:mm').format(export.date)}',
                            ),
                            if (export.paperSize.isNotEmpty)
                              Text(
                                'Paper: ${export.paperSize}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            if (export.dateRangeStart != null && export.dateRangeEnd != null)
                              Text(
                                'Period: ${DateFormat('dd/MM/yy').format(export.dateRangeStart!)} - ${DateFormat('dd/MM/yy').format(export.dateRangeEnd!)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (export.format == 'PDF')
                              IconButton(
                                icon: const Icon(Icons.print),
                                onPressed: () => _printExport(export),
                                tooltip: 'Print',
                              ),
                            IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () => _shareExport(export),
                              tooltip: 'Share',
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Error loading export history'),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildImportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Import Instructions
          Card(
            color: Colors.blue.withOpacity(0.1),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Import Guidelines',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '• Use our templates for best results\n'
                          '• CSV files should be comma-separated\n'
                          '• First row must contain column headers\n'
                          '• Maximum file size: 10MB',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Download Templates
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Download Templates',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTemplateItem('Products Template', 'products_template.csv'),
                  _buildTemplateItem('Customers Template', 'customers_template.csv'),
                  _buildTemplateItem('Inventory Template', 'inventory_template.csv'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Import File
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Import File',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: _selectFile,
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload,
                            size: 64,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Click to select file',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'or drag and drop here',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'CSV, Excel (max 10MB)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTemplateItem(String name, String filename) {
    return ListTile(
      leading: const Icon(Icons.file_download),
      title: Text(name),
      subtitle: Text(filename),
      trailing: TextButton(
        onPressed: () => _downloadTemplate(filename),
        child: const Text('Download'),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
  
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }
  
  Future<void> _startExport() async {
    setState(() {
      _isExporting = true;
    });
    
    try {
      final exportService = ref.read(exportServiceProvider);
      final export = await exportService.exportData(
        dataType: _selectedExportType,
        format: _selectedFormat,
        paperSize: _selectedPaperSize,
        dateRange: _dateRange,
      );
      
      if (export != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh export history
        ref.invalidate(exportHistoryProvider);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
  
  Future<void> _shareExport(ExportHistoryModel export) async {
    try {
      final file = File(export.filePath);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(export.filePath)],
          text: '${export.type} export from QuickBills',
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Export file not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Share error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _printExport(ExportHistoryModel export) async {
    try {
      final exportService = ref.read(exportServiceProvider);
      await exportService.printExport(export);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Print error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _downloadTemplate(String filename) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading $filename...'),
      ),
    );
  }
  
  void _selectFile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening file picker...'),
      ),
    );
    // TODO: Implement file picker
  }
}