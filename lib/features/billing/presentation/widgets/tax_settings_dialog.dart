import 'package:flutter/material.dart';

class TaxSettingsDialog extends StatefulWidget {
  final double currentTaxRate;
  final Function(TaxType, double) onTaxChanged;
  
  const TaxSettingsDialog({
    super.key,
    required this.currentTaxRate,
    required this.onTaxChanged,
  });

  @override
  State<TaxSettingsDialog> createState() => _TaxSettingsDialogState();
}

class _TaxSettingsDialogState extends State<TaxSettingsDialog> {
  late TaxType _selectedTaxType;
  late double _cgstRate;
  late double _sgstRate;
  late double _igstRate;
  
  @override
  void initState() {
    super.initState();
    // Default to CGST + SGST (9% each = 18% total)
    _selectedTaxType = TaxType.cgstSgst;
    _cgstRate = 9.0;
    _sgstRate = 9.0;
    _igstRate = 18.0;
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tax Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Tax Type Selection
            RadioListTile<TaxType>(
              title: const Text('CGST + SGST (Intra-state)'),
              subtitle: Text('Total: ${(_cgstRate + _sgstRate).toStringAsFixed(1)}%'),
              value: TaxType.cgstSgst,
              groupValue: _selectedTaxType,
              onChanged: (value) {
                setState(() {
                  _selectedTaxType = value!;
                });
              },
            ),
            
            if (_selectedTaxType == TaxType.cgstSgst) ...[
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTaxField(
                        label: 'CGST %',
                        value: _cgstRate,
                        onChanged: (value) {
                          setState(() {
                            _cgstRate = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTaxField(
                        label: 'SGST %',
                        value: _sgstRate,
                        onChanged: (value) {
                          setState(() {
                            _sgstRate = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            RadioListTile<TaxType>(
              title: const Text('IGST (Inter-state)'),
              subtitle: Text('${_igstRate.toStringAsFixed(1)}%'),
              value: TaxType.igst,
              groupValue: _selectedTaxType,
              onChanged: (value) {
                setState(() {
                  _selectedTaxType = value!;
                });
              },
            ),
            
            if (_selectedTaxType == TaxType.igst) ...[
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: _buildTaxField(
                  label: 'IGST %',
                  value: _igstRate,
                  onChanged: (value) {
                    setState(() {
                      _igstRate = value;
                    });
                  },
                ),
              ),
            ],
            
            RadioListTile<TaxType>(
              title: const Text('No Tax'),
              value: TaxType.none,
              groupValue: _selectedTaxType,
              onChanged: (value) {
                setState(() {
                  _selectedTaxType = value!;
                });
              },
            ),
            
            const SizedBox(height: 24),
            
            // Common tax rates
            const Text(
              'Quick Select:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [5.0, 12.0, 18.0, 28.0].map((rate) {
                return ChoiceChip(
                  label: Text('${rate.toStringAsFixed(0)}%'),
                  selected: _getTotalRate() == rate,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        if (_selectedTaxType == TaxType.cgstSgst) {
                          _cgstRate = rate / 2;
                          _sgstRate = rate / 2;
                        } else if (_selectedTaxType == TaxType.igst) {
                          _igstRate = rate;
                        }
                      });
                    }
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: ElevatedButton(
                    onPressed: () {
                      final totalRate = _getTotalRate();
                      widget.onTaxChanged(_selectedTaxType, totalRate);
                      Navigator.pop(context);
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTaxField({
    required String label,
    required double value,
    required Function(double) onChanged,
  }) {
    final controller = TextEditingController(text: value.toStringAsFixed(1));
    
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixText: '%',
        isDense: true,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (text) {
        final parsed = double.tryParse(text);
        if (parsed != null && parsed >= 0 && parsed <= 100) {
          onChanged(parsed);
        }
      },
    );
  }
  
  double _getTotalRate() {
    switch (_selectedTaxType) {
      case TaxType.cgstSgst:
        return _cgstRate + _sgstRate;
      case TaxType.igst:
        return _igstRate;
      case TaxType.none:
        return 0;
    }
  }
}

enum TaxType { cgstSgst, igst, none }