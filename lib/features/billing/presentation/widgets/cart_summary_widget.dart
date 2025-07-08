import 'package:flutter/material.dart';

import '../widgets/tax_settings_dialog.dart';

class CartSummaryWidget extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double total;
  final double? discount;
  final TaxType? taxType;
  final double? cgst;
  final double? sgst;
  final double? igst;
  final VoidCallback? onTaxSettingsTap;
  
  const CartSummaryWidget({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.total,
    this.discount,
    this.taxType,
    this.cgst,
    this.sgst,
    this.igst,
    this.onTaxSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow('Subtotal', subtotal),
            if (discount != null && discount! > 0) ...[
              const SizedBox(height: 8),
              _buildSummaryRow('Discount', -discount!, color: Colors.green),
            ],
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onTaxSettingsTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (taxType == TaxType.cgstSgst && cgst != null && sgst != null)
                        Text('Tax (CGST ${cgst!.toStringAsFixed(1)}% + SGST ${sgst!.toStringAsFixed(1)}%)')
                      else if (taxType == TaxType.igst && igst != null)
                        Text('Tax (IGST ${igst!.toStringAsFixed(1)}%)')
                      else
                        const Text('Tax'),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.settings,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                  Text('₹${tax.toStringAsFixed(2)}'),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(),
            ),
            _buildSummaryRow(
              'Total',
              total,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }
}