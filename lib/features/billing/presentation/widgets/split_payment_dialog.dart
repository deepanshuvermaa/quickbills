import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplitPaymentDialog extends StatefulWidget {
  final double totalAmount;
  final Function(List<PaymentSplit>) onConfirm;
  
  const SplitPaymentDialog({
    super.key,
    required this.totalAmount,
    required this.onConfirm,
  });

  @override
  State<SplitPaymentDialog> createState() => _SplitPaymentDialogState();
}

class PaymentSplit {
  final String method;
  final double amount;
  final String? reference;

  PaymentSplit({
    required this.method,
    required this.amount,
    this.reference,
  });
}

class _SplitPaymentDialogState extends State<SplitPaymentDialog> {
  final List<_PaymentEntry> _payments = [];
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    // Add first payment entry
    _payments.add(_PaymentEntry(
      method: 'Cash',
      controller: TextEditingController(),
      referenceController: TextEditingController(),
    ));
  }
  
  @override
  void dispose() {
    for (var payment in _payments) {
      payment.controller.dispose();
      payment.referenceController.dispose();
    }
    super.dispose();
  }
  
  double get _totalEntered {
    double total = 0;
    for (var payment in _payments) {
      total += double.tryParse(payment.controller.text) ?? 0;
    }
    return total;
  }
  
  double get _remaining => widget.totalAmount - _totalEntered;
  
  void _addPayment() {
    setState(() {
      _payments.add(_PaymentEntry(
        method: 'Cash',
        controller: TextEditingController(),
        referenceController: TextEditingController(),
      ));
    });
  }
  
  void _removePayment(int index) {
    setState(() {
      _payments[index].controller.dispose();
      _payments[index].referenceController.dispose();
      _payments.removeAt(index);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Split Payment'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Amount summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount:'),
                        Text(
                          '₹${widget.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Remaining:'),
                        Text(
                          '₹${_remaining.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _remaining == 0 ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Payment entries
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _payments.length,
                  itemBuilder: (context, index) {
                    return _buildPaymentEntry(index);
                  },
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Add payment button
              TextButton.icon(
                onPressed: _payments.length < 4 ? _addPayment : null,
                icon: const Icon(Icons.add),
                label: const Text('Add Payment Method'),
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
          onPressed: _remaining == 0 && _totalEntered > 0
              ? () {
                  if (_formKey.currentState!.validate()) {
                    final splits = _payments
                        .where((p) => (double.tryParse(p.controller.text) ?? 0) > 0)
                        .map((p) => PaymentSplit(
                              method: p.method,
                              amount: double.parse(p.controller.text),
                              reference: p.referenceController.text.isEmpty
                                  ? null
                                  : p.referenceController.text,
                            ))
                        .toList();
                    widget.onConfirm(splits);
                    Navigator.pop(context);
                  }
                }
              : null,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
  
  Widget _buildPaymentEntry(int index) {
    final payment = _payments[index];
    final showReference = payment.method != 'Cash';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: payment.method,
                    decoration: const InputDecoration(
                      labelText: 'Method',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    items: ['Cash', 'UPI', 'Card', 'Bank Transfer']
                        .map((method) => DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        payment.method = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: payment.controller,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '₹',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Invalid';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                if (_payments.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removePayment(index),
                  ),
              ],
            ),
            if (showReference) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: payment.referenceController,
                decoration: InputDecoration(
                  labelText: payment.method == 'UPI'
                      ? 'Transaction ID'
                      : payment.method == 'Card'
                          ? 'Last 4 digits'
                          : 'Reference Number',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaymentEntry {
  String method;
  final TextEditingController controller;
  final TextEditingController referenceController;
  
  _PaymentEntry({
    required this.method,
    required this.controller,
    required this.referenceController,
  });
}