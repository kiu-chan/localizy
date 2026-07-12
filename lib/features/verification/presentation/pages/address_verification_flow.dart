import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalSteps, (index) {
              return Row(
                children: [
                  _buildStepDot(index),
                  if (index < _totalSteps - 1) _buildStepLine(index),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            localizations.stepProgress(
              currentStep + 1,
              _totalSteps,
              stepTitles[currentStep],
            ),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            localizations.percentComplete(
              (((currentStep + 1) / _totalSteps) * 100).toInt(),
            ),
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDot(int index) {
    final isCompleted = index < currentStep;
    final isCurrent = index == currentStep;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted || isCurrent
            ? const Color(0xFF4285F4)
            : Colors.grey.shade300,
        border: Border.all(
          color: isCurrent ? const Color(0xFF1565C0) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : Text(
                '${index + 1}',
                style: TextStyle(
                  color: isCurrent ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  Widget _buildStepLine(int index) {
    return Container(
      width: 40,
      height: 2,
      color:
          index < currentStep ? const Color(0xFF4285F4) : Colors.grey.shade300,
    );
  }
}
