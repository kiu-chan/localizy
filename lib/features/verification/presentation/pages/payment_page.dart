import 'package:flutter/material.dart';
import 'package:localizy/core/config/currency_config.dart';
import 'package:localizy/core/theme/app_colors.dart';
import 'package:localizy/features/verification/presentation/widgets/verification_ui.dart';
import 'package:localizy/l10n/app_localizations.dart';

class PaymentPage extends StatefulWidget {
  final String? initialPaymentMethod;
  final Function(String) onNext;
  final VoidCallback onPrevious;

  const PaymentPage({
    super.key,
    this.initialPaymentMethod,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? _selectedPaymentMethod;
  final double _basicFee = 3.00;
  final double _travelFee = 1.00;
  double get _verificationFee => _basicFee + _travelFee;

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = widget.initialPaymentMethod;
  }

  void _selectPaymentMethod(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
  }

  void _processPayment() {
    final localizations = AppLocalizations.of(context)!;

    if (_selectedPaymentMethod != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(localizations.processing),
            ],
          ),
          content: Text(localizations.pleaseWaitAMoment),
        ),
      );

      // Simulate payment processing
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          widget.onNext(_selectedPaymentMethod!);
        }
      });
    }
  }

  String _formatCurrency(double amount) => CurrencyConfig.format(amount);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VerificationInfoBanner(text: localizations.paymentIntro),
                const SizedBox(height: 20),
                _buildFeeSummary(localizations),
                const SizedBox(height: 24),
                VerificationSectionTitle(localizations.selectPaymentMethod),
                const SizedBox(height: 12),
                _buildPaymentMethodCard(
                  method: 'momo',
                  icon: Icons.account_balance_wallet,
                  title: localizations.paymentMomo,
                  description: localizations.paymentMomoDescription,
                ),
                const SizedBox(height: 10),
                _buildPaymentMethodCard(
                  method: 'zalopay',
                  icon: Icons.payment,
                  title: localizations.paymentZaloPay,
                  description: localizations.paymentZaloPayDescription,
                ),
                const SizedBox(height: 10),
                _buildPaymentMethodCard(
                  method: 'bank',
                  icon: Icons.account_balance,
                  title: localizations.paymentBankTransfer,
                  description: localizations.paymentBankTransferDescription,
                ),
                const SizedBox(height: 10),
                _buildPaymentMethodCard(
                  method: 'card',
                  icon: Icons.credit_card,
                  title: localizations.paymentCard,
                  description: localizations.paymentCardDescription,
                ),
                const SizedBox(height: 24),
                _buildFeeBreakdown(localizations),
                const SizedBox(height: 24),
                VerificationNotesCard(
                  title: localizations.importantNotes,
                  notes: [
                    localizations.noteFeeNonRefundable,
                    localizations.noteReceiveInvoice,
                    localizations.noteVerificationStartsAfterPayment,
                  ],
                ),
              ],
            ),
          ),
        ),
        _buildBottomBar(localizations),
      ],
    );
  }

  Widget _buildFeeSummary(AppLocalizations localizations) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            localizations.totalPayment,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.surface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatCurrency(_verificationFee),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.surface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            localizations.addressVerificationFee,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.surface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required String method,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedPaymentMethod == method;

    return InkWell(
      onTap: () => _selectPaymentMethod(method),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: verificationCardDecoration(
          borderColor: isSelected ? AppColors.primary : null,
        ).copyWith(
          color: isSelected ? AppColors.primarySurface : AppColors.surface,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check,
                      size: 14, color: AppColors.surface)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeBreakdown(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: verificationCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.feeDetails,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
          const Divider(height: 24, color: AppColors.border),
          _buildFeeRow(
            localizations.basicVerificationFee,
            _formatCurrency(_basicFee),
          ),
          const SizedBox(height: 8),
          _buildFeeRow(
            localizations.travelFee,
            _formatCurrency(_travelFee),
          ),
          const Divider(height: 24, color: AppColors.border),
          _buildFeeRow(
            localizations.total,
            _formatCurrency(_verificationFee),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13.5,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.ink : AppColors.muted,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13.5,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? AppColors.primary : AppColors.ink,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(AppLocalizations localizations) {
    final hasMethod = _selectedPaymentMethod != null;

    return VerificationBottomBar(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: VerificationPrimaryButton(
              label: hasMethod
                  ? '${localizations.payButton} ${_formatCurrency(_verificationFee)}'
                  : localizations.selectPaymentMethod,
              leadingIcon: Icons.lock,
              onPressed: hasMethod ? _processPayment : null,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 14, color: AppColors.muted),
              const SizedBox(width: 6),
              Text(
                localizations.securedBySSL,
                style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
