import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum DiscountType { percentage, fixed }
enum DiscountLevel { item, bill }

class DiscountDialog extends StatefulWidget {
  final double currentAmount;
  final Function(DiscountType type, double value, DiscountLevel level) onApplyDiscount;
  final double? existingDiscountValue;
  final DiscountType? existingDiscountType;
  
  const DiscountDialog({
    super.key,
    required this.currentAmount,
    required this.onApplyDiscount,
    this.existingDiscountValue,
    this.existingDiscountType,
  });

  @override
  State<DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<DiscountDialog> {
  late DiscountType _discountType;
  late DiscountLevel _discountLevel;
  final _discountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    _discountType = widget.existingDiscountType ?? DiscountType.percentage;
    _discountLevel = DiscountLevel.bill;
    if (widget.existingDiscountValue != null) {
      _discountController.text = widget.existingDiscountValue!.toStringAsFixed(2);
    }
  }
  
  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }
  
  double _calculateDiscountAmount() {
    final value = double.tryParse(_discountController.text) ?? 0;
    if (_discountType == DiscountType.percentage) {
      return widget.currentAmount * (value / 100);
    }
    return value;
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Apply Discount'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Discount Level Selection
            const Text('Apply discount to:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<DiscountLevel>(
                segments: const [
                  ButtonSegment(
                    value: DiscountLevel.bill,
                    label: Text('Entire Bill'),
                    icon: Icon(Icons.receipt_long),
                  ),
                  ButtonSegment(
                    value: DiscountLevel.item,
                    label: Text('Selected Item'),
                    icon: Icon(Icons.inventory_2),
                  ),
                ],
                selected: {_discountLevel},
                onSelectionChanged: (Set<DiscountLevel> selection) {
                  setState(() {
                    _discountLevel = selection.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // Discount Type Selection
            const Text('Discount type:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<DiscountType>(
                segments: const [
                  ButtonSegment(
                    value: DiscountType.percentage,
                    label: Text('Percentage'),
                    icon: Icon(Icons.percent),
                  ),
                  ButtonSegment(
                    value: DiscountType.fixed,
                    label: Text('Fixed Amount'),
                    icon: Icon(Icons.currency_rupee),
                  ),
                ],
                selected: {_discountType},
                onSelectionChanged: (Set<DiscountType> selection) {
                  setState(() {
                    _discountType = selection.first;
                    _discountController.clear();
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // Discount Value Input
            TextFormField(
              controller: _discountController,
              decoration: InputDecoration(
                labelText: _discountType == DiscountType.percentage
                    ? 'Discount Percentage'
                    : 'Discount Amount',
                suffixText: _discountType == DiscountType.percentage ? '%' : '₹',
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                if (_discountType == DiscountType.percentage)
                  _PercentageInputFormatter(),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a discount value';
                }
                final discountValue = double.tryParse(value);
                if (discountValue == null || discountValue <= 0) {
                  return 'Please enter a valid discount';
                }
                if (_discountType == DiscountType.percentage && discountValue > 100) {
                  return 'Percentage cannot exceed 100%';
                }
                if (_discountType == DiscountType.fixed && discountValue > widget.currentAmount) {
                  return 'Discount cannot exceed bill amount';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            
            // Preview
            if (_discountController.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Original Amount: ₹${widget.currentAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Discount: ₹${_calculateDiscountAmount().toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, color: Colors.green),
                    ),
                    const Divider(),
                    Text(
                      'Final Amount: ₹${(widget.currentAmount - _calculateDiscountAmount()).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final value = double.parse(_discountController.text);
              widget.onApplyDiscount(_discountType, value, _discountLevel);
              Navigator.pop(context);
            }
          },
          child: const Text('Apply Discount'),
        ),
      ],
    );
  }
}

class _PercentageInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final value = double.tryParse(newValue.text);
    if (value != null && value > 100) {
      return oldValue;
    }
    return newValue;
  }
}