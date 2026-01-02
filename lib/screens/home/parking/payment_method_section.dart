import 'package:flutter/material.dart';
import 'package:localizy/l10n/app_localizations.dart';

class PaymentMethodSection extends StatelessWidget {
  final String?  selectedPaymentMethod;
  final Function(String) onSelectPaymentMethod;

  const PaymentMethodSection({
    Key? key,
    required this.selectedPaymentMethod,
    required this.onSelectPaymentMethod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.payment, size: 24, color: Colors. green.shade700),
            const SizedBox(width: 8),
            const Text(
              'Payment Method',
              style:  TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors. black.withOpacity(0.05),
                blurRadius:  10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildPaymentMethodCard(
                context: context,
                method: 'momo',
                icon: Icons.account_balance_wallet,
                title: l10n.paymentMomo,
                description: l10n.paymentMomoDescription,
                color: Colors.pink,
              ),
              const SizedBox(height: 12),
              _buildPaymentMethodCard(
                context: context,
                method: 'zalopay',
                icon: Icons.payment,
                title: l10n.paymentZaloPay,
                description: l10n.paymentZaloPayDescription,
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildPaymentMethodCard(
                context: context,
                method: 'bank',
                icon: Icons.account_balance,
                title: l10n.paymentBankTransfer,
                description:  l10n.paymentBankTransferDescription,
                color:  Colors.teal,
              ),
              const SizedBox(height: 12),
              _buildPaymentMethodCard(
                context: context,
                method: 'card',
                icon: Icons.credit_card,
                title: l10n.paymentCard,
                description: l10n.paymentCardDescription,
                color:  Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard({
    required BuildContext context,
    required String method,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final isSelected = selectedPaymentMethod == method;
    
    return InkWell(
      onTap: () => onSelectPaymentMethod(method),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color. withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding:  const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color. withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight. bold,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? color : Colors. transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors. white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}