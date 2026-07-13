import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localizy/core/theme/app_colors.dart';
import 'package:localizy/l10n/app_localizations.dart';

import '../providers/verification_flow_provider.dart';
import 'appointment_page.dart';
import 'completion_page.dart';
import 'document_upload_page.dart';
import 'map_confirmation_page.dart';
import 'payment_page.dart';

/// Wizard xác minh địa chỉ 5 bước. Toàn bộ dữ liệu các bước nằm trong
/// [verificationFlowProvider]; trang này chỉ render bước hiện tại.
class AddressVerificationFlow extends ConsumerWidget {
  const AddressVerificationFlow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final flow = ref.watch(verificationFlowProvider);
    final notifier = ref.read(verificationFlowProvider.notifier);

    return PopScope(
      canPop: flow.currentStep == 0,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop && flow.currentStep > 0) {
          notifier.previousStep();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.addressVerification),
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (flow.currentStep > 0) {
                notifier.previousStep();
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Column(
          children: [
            _ProgressStepper(currentStep: flow.currentStep),
            Expanded(child: _buildStepContent(context, ref, flow)),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(
      BuildContext context, WidgetRef ref, VerificationFlowState flow) {
    final notifier = ref.read(verificationFlowProvider.notifier);

    switch (flow.currentStep) {
      case 0:
        return DocumentUploadPage(
          initialIdDocument: flow.idDocument,
          initialAddressProof: flow.addressProof,
          initialIdType: flow.idType,
          onDocumentsUploaded: (idDoc, addressDoc, idType) {
            notifier.setDocuments(
              idDocument: idDoc,
              addressProof: addressDoc,
              idType: idType,
            );
          },
        );
      case 1:
        return MapConfirmationPage(
          initialLocation: flow.locationMap,
          initialLocationName: flow.locationName,
          initialCityId: flow.cityId,
          initialCityName: flow.cityName,
          initialFullAddress: flow.fullAddress,
          onNext: (data) {
            notifier.setLocation(
              latitude: data['lat'] as double,
              longitude: data['lng'] as double,
              locationName: data['locationName'] as String?,
              cityId: data['cityId'] as String?,
              cityName: data['cityName'] as String?,
              fullAddress: data['fullAddress'] as String?,
            );
          },
          onPrevious: notifier.previousStep,
        );
      case 2:
        return PaymentPage(
          initialPaymentMethod: flow.paymentMethod,
          onNext: notifier.setPaymentMethod,
          onPrevious: notifier.previousStep,
        );
      case 3:
        return AppointmentPage(
          initialDate: flow.appointmentDate,
          initialTime: flow.appointmentTime,
          onNext: (data) {
            notifier.setAppointment(
              date: data['date'],
              time: data['time'],
              timeSlot: data['timeSlot'],
            );
          },
          onPrevious: notifier.previousStep,
        );
      case 4:
        return CompletionPage(
          idDocument: flow.idDocument,
          addressProof: flow.addressProof,
          location: flow.locationMap,
          locationName: flow.locationName,
          cityName: flow.cityName,
          fullAddress: flow.fullAddress,
          paymentMethod: flow.paymentMethod,
          appointmentDate: flow.appointmentDate,
          appointmentTime: flow.appointmentTime,
          timeSlot: flow.timeSlot,
          onComplete: () => _completeVerification(context, ref),
          onPrevious: notifier.previousStep,
        );
      default:
        return const SizedBox();
    }
  }

  Future<void> _completeVerification(BuildContext context, WidgetRef ref) async {
    final localizations = AppLocalizations.of(context)!;
    final notifier = ref.read(verificationFlowProvider.notifier);

    if (!ref.read(verificationFlowProvider).hasLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.pleaseSelectLocation)),
      );
      notifier.goToLocationStep();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final resp = await notifier.submit();

      if (!context.mounted) return;
      Navigator.of(context).pop(); // close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.requestSubmitted)),
      );
      Navigator.of(context).pop(resp);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}

class _ProgressStepper extends StatelessWidget {
  const _ProgressStepper({required this.currentStep});

  final int currentStep;

  static const int _totalSteps = VerificationFlowState.totalSteps;

  List<String> _stepTitles(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
      loc.uploadDocuments,
      loc.confirmLocation,
      loc.payment,
      loc.selectAppointment,
      loc.complete,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final stepTitles = _stepTitles(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalSteps * 2 - 1, (index) {
              if (index.isOdd) {
                return Expanded(child: _buildStepLine(index ~/ 2));
              }
              return _buildStepDot(index ~/ 2);
            }),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  localizations.stepProgress(
                    currentStep + 1,
                    stepTitles[currentStep],
                    _totalSteps,
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                localizations.percentComplete(
                  (((currentStep + 1) / _totalSteps) * 100).toInt(),
                ),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepDot(int index) {
    final isCompleted = index < currentStep;
    final isCurrent = index == currentStep;
    final isDone = isCompleted || isCurrent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone ? AppColors.primary : AppColors.surface,
        border: Border.all(
          color: isDone ? AppColors.primary : AppColors.border,
          width: 1.5,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: AppColors.surface, size: 16)
            : Text(
                '${index + 1}',
                style: TextStyle(
                  color: isCurrent ? AppColors.surface : AppColors.disabled,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
      ),
    );
  }

  Widget _buildStepLine(int index) {
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: index < currentStep ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
