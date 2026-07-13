import 'dart:io';
import 'package:flutter/material.dart';
import 'package:localizy/core/theme/app_colors.dart';
import 'package:localizy/features/verification/presentation/widgets/verification_ui.dart';
import 'package:localizy/l10n/app_localizations.dart';

class CompletionPage extends StatelessWidget {
  final File? idDocument;
  final File? addressProof;
  final String? cityName;
  final String? fullAddress;
  final Map<String, double>? location;
  final String? locationName;
  final String? paymentMethod;
  final DateTime? appointmentDate;
  final TimeOfDay? appointmentTime;
  final String? timeSlot;
  final VoidCallback onComplete;
  final VoidCallback onPrevious;

  const CompletionPage({
    super.key,
    this.idDocument,
    this.addressProof,
    this.cityName,
    this.fullAddress,
    this.location,
    this.locationName,
    this.paymentMethod,
    this.appointmentDate,
    this.appointmentTime,
    this.timeSlot,
    required this.onComplete,
    required this.onPrevious,
  });

  String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;

    if (locale == 'vi') {
      final weekdays = [
        'Chủ nhật',
        'Thứ 2',
        'Thứ 3',
        'Thứ 4',
        'Thứ 5',
        'Thứ 6',
        'Thứ 7'
      ];
      return '${weekdays[date.weekday % 7]}, ${date.day}/${date.month}/${date.year}';
    } else if (locale == 'fr') {
      final weekdays = [
        'Dimanche',
        'Lundi',
        'Mardi',
        'Mercredi',
        'Jeudi',
        'Vendredi',
        'Samedi'
      ];
      return '${weekdays[date.weekday % 7]}, ${date.day}/${date.month}/${date.year}';
    } else {
      // English
      final weekdays = [
        'Sunday',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday'
      ];
      return '${weekdays[date.weekday % 7]}, ${date.day}/${date.month}/${date.year}';
    }
  }

  String _getPaymentMethodName(BuildContext context, String method) {
    final localizations = AppLocalizations.of(context)!;

    switch (method) {
      case 'momo':
        return localizations.paymentMomo;
      case 'zalopay':
        return localizations.paymentZaloPay;
      case 'bank':
        return localizations.paymentBankTransfer;
      case 'card':
        return localizations.paymentCard;
      default:
        return localizations.paymentUnknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              children: [
                _buildSuccessHeader(context, localizations),
                const SizedBox(height: 24),
                _buildSummaryCard(context, localizations),
                const SizedBox(height: 16),
                _buildNextStepsCard(localizations),
                const SizedBox(height: 16),
                VerificationNotesCard(
                  title: localizations.importantNotesTitle,
                  notes: [
                    localizations.noteSaveAddressCode,
                    localizations.notePrepareOriginalDocs,
                    localizations.noteBePresentOnTime,
                    localizations.noteContactHotline,
                  ],
                ),
              ],
            ),
          ),
        ),
        VerificationBottomBar(
          child: SizedBox(
            width: double.infinity,
            child: VerificationPrimaryButton(
              label: localizations.submitVerificationRequest,
              leadingIcon: Icons.send,
              onPressed: onComplete,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessHeader(
      BuildContext context, AppLocalizations localizations) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success.withValues(alpha: 0.1),
          ),
          child: const Icon(
            Icons.check_circle,
            size: 64,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          localizations.requestSubmitted,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          localizations.thankYouForCompleting,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13.5,
            height: 1.4,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: verificationCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.requestSummary,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
          const Divider(height: 20, color: AppColors.border),
          _buildSummaryRow(
            Icons.credit_card,
            localizations.identityDocument,
            localizations.uploaded,
          ),
          _buildSummaryRow(
            Icons.receipt_long,
            localizations.addressProofDoc,
            localizations.uploaded,
          ),
          if (cityName != null && cityName!.isNotEmpty)
            _buildSummaryRow(
              Icons.location_city,
              localizations.cityNameSummary,
              cityName!,
            ),
          if (fullAddress != null && fullAddress!.isNotEmpty)
            _buildSummaryRow(
              Icons.home_outlined,
              localizations.fullAddressSummary,
              fullAddress!,
            ),
          _buildSummaryRow(
            Icons.location_on,
            localizations.location,
            location != null
                ? '${location!['lat']!.toStringAsFixed(4)}, ${location!['lng']!.toStringAsFixed(4)}'
                : localizations.confirmed,
          ),
          if (locationName != null && locationName!.isNotEmpty)
            _buildSummaryRow(
              Icons.label_outline,
              localizations.mapLocationNameLabel,
              locationName!,
            ),
          _buildSummaryRow(
            Icons.payment,
            localizations.payment,
            paymentMethod != null
                ? _getPaymentMethodName(context, paymentMethod!)
                : localizations.completed,
          ),
          if (appointmentDate != null)
            _buildSummaryRow(
              Icons.calendar_today,
              localizations.appointmentDate,
              _formatDate(context, appointmentDate!),
            ),
          if (timeSlot != null)
            _buildSummaryRow(
              Icons.access_time,
              localizations.timeSlot,
              timeSlot!,
              isLast: true,
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepsCard(AppLocalizations localizations) {
    final steps = [
      localizations.step1ReceiveEmail,
      localizations.step2StaffContact,
      localizations.step3VerifyAddress,
      localizations.step4ReceiveResult,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                localizations.nextSteps,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < steps.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == steps.length - 1 ? 0 : 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: AppColors.surface,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        steps[i],
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.35,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
