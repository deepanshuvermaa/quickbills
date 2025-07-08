import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/invoice_preview_widget.dart';
import '../providers/invoice_settings_provider.dart';
import 'invoice_preview_screen.dart';

class InvoiceSettingsScreen extends ConsumerStatefulWidget {
  const InvoiceSettingsScreen({super.key});

  @override
  ConsumerState<InvoiceSettingsScreen> createState() => _InvoiceSettingsScreenState();
}

class _InvoiceSettingsScreenState extends ConsumerState<InvoiceSettingsScreen> {
  bool _autoGenerateInvoiceNumber = true;
  bool _showTaxBreakdown = true;
  bool _showPaymentTerms = true;
  bool _showNotes = true;
  String _invoicePrefix = 'INV-';
  String _defaultPaymentTerms = 'Net 30';
  String _defaultCurrency = 'INR';
  double _defaultTaxRate = 18.0;
  String _footerText = 'Thank you for your business!';
  Map<String, String> _bankDetails = {};
  String _termsConditions = '';
  int _nextInvoiceNumber = 1;
  int? _brandColor;
  
  final List<String> _currencies = ['INR', 'USD', 'EUR', 'GBP', 'CAD', 'AUD'];
  final List<String> _paymentTermsList = [
    'Due on Receipt',
    'Net 7',
    'Net 14',
    'Net 30',
    'Net 45',
    'Net 60',
    'Net 90',
  ];

  @override
  void initState() {
    super.initState();
    // Load existing settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsAsync = ref.read(invoiceSettingsProvider);
      settingsAsync.whenData((settings) {
        setState(() {
          _autoGenerateInvoiceNumber = settings.autoGenerateInvoiceNumber;
          _showTaxBreakdown = settings.showTaxBreakdown;
          _showPaymentTerms = settings.showPaymentTerms;
          _showNotes = settings.showNotes;
          _invoicePrefix = settings.invoicePrefix;
          _defaultPaymentTerms = settings.defaultPaymentTerms;
          _defaultCurrency = settings.defaultCurrency;
          _defaultTaxRate = settings.defaultTaxRate;
          _footerText = settings.footerText;
          _bankDetails = settings.bankDetails;
          _termsConditions = settings.termsConditions;
          _nextInvoiceNumber = settings.nextInvoiceNumber;
          _brandColor = settings.brandColor;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.preview),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InvoicePreviewScreen(),
                ),
              );
            },
            tooltip: 'Preview Invoice',
          ),
          TextButton(
            onPressed: _saveSettings,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice Number Settings
            _buildSectionHeader(context, 'Invoice Numbering'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Auto-generate Invoice Numbers'),
                    subtitle: const Text('Automatically assign numbers to new invoices'),
                    value: _autoGenerateInvoiceNumber,
                    onChanged: (value) {
                      setState(() {
                        _autoGenerateInvoiceNumber = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Invoice Prefix'),
                    subtitle: Text(_invoicePrefix),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _editInvoicePrefix(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Next Invoice Number'),
                    subtitle: const Text('2024001'),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _editNextInvoiceNumber(context),
                  ),
                ],
              ),
            ),
            
            // Display Settings
            _buildSectionHeader(context, 'Display Settings'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Show Tax Breakdown'),
                    subtitle: const Text('Display detailed tax information on invoices'),
                    value: _showTaxBreakdown,
                    onChanged: (value) {
                      setState(() {
                        _showTaxBreakdown = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Show Payment Terms'),
                    subtitle: const Text('Display payment terms on invoices'),
                    value: _showPaymentTerms,
                    onChanged: (value) {
                      setState(() {
                        _showPaymentTerms = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Show Notes Section'),
                    subtitle: const Text('Include notes/comments section on invoices'),
                    value: _showNotes,
                    onChanged: (value) {
                      setState(() {
                        _showNotes = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            // Default Values
            _buildSectionHeader(context, 'Default Values'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Default Currency'),
                    subtitle: Text(_defaultCurrency),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: () => _selectCurrency(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Default Payment Terms'),
                    subtitle: Text(_defaultPaymentTerms),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: () => _selectPaymentTerms(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Default Tax Rate'),
                    subtitle: const Text('10%'),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _editTaxRate(context),
                  ),
                ],
              ),
            ),
            
            // Logo & Branding
            _buildSectionHeader(context, 'Logo & Branding'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.image,
                        color: Colors.grey,
                      ),
                    ),
                    title: const Text('Company Logo'),
                    subtitle: const Text('Upload your company logo'),
                    trailing: const Icon(Icons.upload),
                    onTap: () => _uploadLogo(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Brand Color'),
                    subtitle: const Text('Choose your brand color'),
                    trailing: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onTap: () => _selectBrandColor(context),
                  ),
                ],
              ),
            ),
            
            // Footer Information
            _buildSectionHeader(context, 'Footer Information'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Footer Text'),
                    subtitle: const Text('Thank you for your business!'),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _editFooterText(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Bank Details'),
                    subtitle: const Text('Add your bank account information'),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _editBankDetails(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Terms & Conditions'),
                    subtitle: const Text('Add standard terms and conditions'),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _editTermsConditions(context),
                  ),
                ],
              ),
            ),
            
            // Template Preview
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _previewInvoiceTemplate(context),
                  icon: const Icon(Icons.preview),
                  label: const Text('Preview Invoice Template'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  void _editInvoicePrefix(BuildContext context) {
    final controller = TextEditingController(text: _invoicePrefix);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Invoice Prefix'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Prefix',
            hintText: 'e.g., INV-, BILL-',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _invoicePrefix = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editNextInvoiceNumber(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Next Invoice Number'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Next Number',
            hintText: 'e.g., 2024001',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invoice number updated'),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _selectCurrency(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Currency',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ..._currencies.map((currency) => ListTile(
                  title: Text(currency),
                  trailing: _defaultCurrency == currency
                      ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                      : null,
                  onTap: () {
                    setState(() {
                      _defaultCurrency = currency;
                    });
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _selectPaymentTerms(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Payment Terms',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ..._paymentTermsList.map((terms) => ListTile(
                  title: Text(terms),
                  trailing: _defaultPaymentTerms == terms
                      ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                      : null,
                  onTap: () {
                    setState(() {
                      _defaultPaymentTerms = terms;
                    });
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _editTaxRate(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Default Tax Rate'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Tax Rate (%)',
            hintText: 'e.g., 10',
            suffixText: '%',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tax rate updated'),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _uploadLogo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening file picker...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _selectBrandColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Brand Color'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 16,
            itemBuilder: (context, index) {
              final colors = [
                Colors.red,
                Colors.pink,
                Colors.purple,
                Colors.deepPurple,
                Colors.indigo,
                Colors.blue,
                Colors.lightBlue,
                Colors.cyan,
                Colors.teal,
                Colors.green,
                Colors.lightGreen,
                Colors.lime,
                Colors.yellow,
                Colors.amber,
                Colors.orange,
                Colors.deepOrange,
              ];
              return InkWell(
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Brand color updated'),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: colors[index],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _editFooterText(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Footer Text'),
        content: TextField(
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Footer Text',
            hintText: 'e.g., Thank you for your business!',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Footer text updated'),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editBankDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bank Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: _bankDetails['bankName'] ?? ''),
              decoration: const InputDecoration(
                labelText: 'Bank Name',
                hintText: 'e.g., ABC Bank',
              ),
              onChanged: (value) => _bankDetails['bankName'] = value,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: TextEditingController(text: _bankDetails['accountName'] ?? ''),
              decoration: const InputDecoration(
                labelText: 'Account Name',
                hintText: 'e.g., QuickBill Inc.',
              ),
              onChanged: (value) => _bankDetails['accountName'] = value,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: TextEditingController(text: _bankDetails['accountNumber'] ?? ''),
              decoration: const InputDecoration(
                labelText: 'Account Number',
                hintText: 'e.g., 1234567890',
              ),
              onChanged: (value) => _bankDetails['accountNumber'] = value,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: TextEditingController(text: _bankDetails['ifscCode'] ?? ''),
              decoration: const InputDecoration(
                labelText: 'IFSC Code / SWIFT Code',
                hintText: 'e.g., ABCD0123456',
              ),
              onChanged: (value) => _bankDetails['ifscCode'] = value,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bank details updated'),
                        ),
                      );
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _editTermsConditions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms & Conditions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Terms & Conditions',
                hintText: 'Enter your standard terms and conditions...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Terms & conditions updated'),
                        ),
                      );
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _previewInvoiceTemplate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Invoice Preview'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sharing invoice template...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: InvoicePreviewWidget(
              invoicePrefix: _invoicePrefix,
              companyName: 'QuickBills Store',
              showTaxBreakdown: _showTaxBreakdown,
              showPaymentTerms: _showPaymentTerms,
              showNotes: _showNotes,
              currency: _defaultCurrency,
              paymentTerms: _defaultPaymentTerms,
              taxRate: _defaultTaxRate,
              footerText: _footerText,
              bankDetails: {
                'bankName': _bankDetails['bankName'] ?? 'ABC Bank',
                'accountName': _bankDetails['accountName'] ?? 'QuickBills Inc.',
                'accountNumber': _bankDetails['accountNumber'] ?? '1234567890',
                'ifscCode': _bankDetails['ifscCode'] ?? 'ABCD0123456',
              },
              termsConditions: _termsConditions.isNotEmpty ? _termsConditions : 'All sales are final. Payment due as per terms.',
            ),
          ),
        ),
      ),
    );
  }

  void _saveSettings() async {
    final settings = InvoiceSettings(
      autoGenerateInvoiceNumber: _autoGenerateInvoiceNumber,
      showTaxBreakdown: _showTaxBreakdown,
      showPaymentTerms: _showPaymentTerms,
      showNotes: _showNotes,
      invoicePrefix: _invoicePrefix,
      defaultPaymentTerms: _defaultPaymentTerms,
      defaultCurrency: _defaultCurrency,
      defaultTaxRate: _defaultTaxRate,
      footerText: _footerText,
      bankDetails: _bankDetails,
      termsConditions: _termsConditions,
      nextInvoiceNumber: _nextInvoiceNumber,
      brandColor: _brandColor,
    );
    
    await ref.read(invoiceSettingsProvider.notifier).updateSettings(settings);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoice settings saved successfully'),
        ),
      );
    }
  }
}