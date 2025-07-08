import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tax_settings_provider.dart';

class TaxSettingsScreen extends ConsumerStatefulWidget {
  const TaxSettingsScreen({super.key});

  @override
  ConsumerState<TaxSettingsScreen> createState() => _TaxSettingsScreenState();
}

class _TaxSettingsScreenState extends ConsumerState<TaxSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Tax settings
  bool _isGSTEnabled = true;
  double _cgstRate = 9.0;
  double _sgstRate = 9.0;
  double _igstRate = 18.0;
  bool _taxInclusivePricing = false;
  String _gstNumber = '';
  
  @override
  void initState() {
    super.initState();
    // Load current settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsAsync = ref.read(taxSettingsProvider);
      settingsAsync.whenData((settings) {
        setState(() {
          _isGSTEnabled = settings.isGSTEnabled;
          _cgstRate = settings.cgstRate;
          _sgstRate = settings.sgstRate;
          _igstRate = settings.igstRate;
          _taxInclusivePricing = settings.taxInclusivePricing;
          _gstNumber = settings.gstNumber;
        });
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Configuration'),
        actions: [
          TextButton(
            onPressed: _saveTaxSettings,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // GST Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'GST Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: _isGSTEnabled,
                          onChanged: (value) {
                            setState(() {
                              _isGSTEnabled = value;
                            });
                          },
                        ),
                      ],
                    ),
                    if (_isGSTEnabled) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _gstNumber,
                        decoration: const InputDecoration(
                          labelText: 'GST Number',
                          hintText: 'Enter your GST number',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => _gstNumber = value,
                        validator: (value) {
                          if (_isGSTEnabled && (value == null || value.isEmpty)) {
                            return 'Please enter GST number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Intra-state Tax Rates'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _cgstRate.toString(),
                              decoration: const InputDecoration(
                                labelText: 'CGST %',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  _cgstRate = double.tryParse(value) ?? 0;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              initialValue: _sgstRate.toString(),
                              decoration: const InputDecoration(
                                labelText: 'SGST %',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  _sgstRate = double.tryParse(value) ?? 0;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _igstRate.toString(),
                        decoration: const InputDecoration(
                          labelText: 'IGST % (Inter-state)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _igstRate = double.tryParse(value) ?? 0;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Pricing Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pricing Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Tax Inclusive Pricing'),
                      subtitle: const Text('Product prices include tax'),
                      value: _taxInclusivePricing,
                      onChanged: (value) {
                        setState(() {
                          _taxInclusivePricing = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Common Tax Rates
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Tax Rates',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [5.0, 12.0, 18.0, 28.0].map((rate) {
                        return ChoiceChip(
                          label: Text('${rate.toStringAsFixed(0)}%'),
                          selected: (_cgstRate + _sgstRate) == rate,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _cgstRate = rate / 2;
                                _sgstRate = rate / 2;
                                _igstRate = rate;
                              });
                            }
                          },
                        );
                      }).toList(),
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
  
  void _saveTaxSettings() async {
    if (_formKey.currentState!.validate()) {
      final settings = TaxSettings(
        isGSTEnabled: _isGSTEnabled,
        cgstRate: _cgstRate,
        sgstRate: _sgstRate,
        igstRate: _igstRate,
        taxInclusivePricing: _taxInclusivePricing,
        gstNumber: _gstNumber,
      );
      
      await ref.read(taxSettingsProvider.notifier).updateSettings(settings);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tax settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }
}