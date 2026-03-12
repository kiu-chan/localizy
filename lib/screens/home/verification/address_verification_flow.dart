import 'dart:io';

import 'package:flutter/material.dart';
import 'package:localizy/api/verification_api.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/screens/home/verification/appointment_page.dart';
import 'package:localizy/screens/home/verification/completion_page.dart';
import 'package:localizy/screens/home/verification/document_upload_page.dart';
import 'package:localizy/screens/home/verification/map_confirmation_page.dart';
import 'package:localizy/screens/home/verification/payment_page.dart';

class AddressVerificationFlow extends StatefulWidget {
  const AddressVerificationFlow({super.key});

  @override
  State<AddressVerificationFlow> createState() =>
      _AddressVerificationFlowState();
}

class _AddressVerificationFlowState extends State<AddressVerificationFlow> {
  int _currentStep = 0;

  // Data from steps
  File? _idDocument;
  File? _addressProof;
  String _idType = 'cmnd';
  String? _selectedCityId;
  String? _selectedCityName;
  String? _fullAddress;
  Map<String, double>? _location;
  String? _locationName;
  String? _paymentMethod;
  DateTime? _appointmentDate;
  TimeOfDay? _appointmentTime;
  String? _timeSlot;

  static const int _totalSteps = 5;

  List<String> _getStepTitles(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
      loc.uploadDocuments,
      loc.confirmLocation,
      loc.payment,
      loc.selectAppointment,
      loc.complete,
    ];
  }

  void _nextStep(dynamic data) {
    setState(() {
      switch (_currentStep) {
        case 0:
          // Document upload
          if (data is Map) {
            _idDocument = data['idDocument'];
            _addressProof = data['addressProof'];
            _idType = data['idType'];
          }
          break;
        case 1:
          // Map + city + full address
          if (data is Map) {
            _location = {
              'lat': data['lat'] as double,
              'lng': data['lng'] as double,
            };
            _locationName = data['locationName'] as String?;
            _selectedCityId = data['cityId'] as String?;
            _selectedCityName = data['cityName'] as String?;
            _fullAddress = data['fullAddress'] as String?;
          }
          break;
        case 2:
          // Payment
          _paymentMethod = data as String?;
          break;
        case 3:
          // Appointment
          if (data is Map) {
            _appointmentDate = data['date'];
            _appointmentTime = data['time'];
            _timeSlot = data['timeSlot'];
          }
          break;
      }

      if (_currentStep < _totalSteps - 1) {
        _currentStep++;
      } else {
        _completeVerification();
      }
    });
  }

  void _previousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }

  Future<void> _completeVerification() async {
    if (!mounted) return;

    final localizations = AppLocalizations.of(context)!;

    if (_location == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.pleaseSelectLocation)),
        );
      }
      setState(() {
        _currentStep = 1;
      });
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      final resp = await VerificationApi.createVerificationRequest(
        addressId: null,
        requestType: 'NewAddress',
        priority: 'Medium',
        idType: _idType.toUpperCase(),
        photosProvided: _idDocument != null,
        documentsProvided: _addressProof != null,
        attachmentsCount:
            (_idDocument != null ? 1 : 0) + (_addressProof != null ? 1 : 0),
        latitude: _location!['lat']!,
        longitude: _location!['lng']!,
        locationName: _locationName,
        fullAddress: _fullAddress,
        cityId: _selectedCityId,
        paymentMethod: _paymentMethod ?? 'momo',
        paymentAmount: 100000,
        appointmentDate: _appointmentDate,
        appointmentTimeSlot: _timeSlot,
        idDocument: _idDocument,
        addressProof: _addressProof,
      );

      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.requestSubmitted)),
        );
      }

      if (mounted) Navigator.of(context).pop(resp);
    } catch (e) {
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop && _currentStep > 0) {
          _previousStep();
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
              if (_currentStep > 0) {
                _previousStep();
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Column(
          children: [
            _buildProgressStepper(),
            Expanded(child: _buildStepContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStepper() {
    final localizations = AppLocalizations.of(context)!;
    final stepTitles = _getStepTitles(context);

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
              _currentStep + 1,
              _totalSteps,
              stepTitles[_currentStep],
            ),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            localizations.percentComplete(
              (((_currentStep + 1) / _totalSteps) * 100).toInt(),
            ),
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDot(int index) {
    final isCompleted = index < _currentStep;
    final isCurrent = index == _currentStep;

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
      color: index < _currentStep
          ? const Color(0xFF4285F4)
          : Colors.grey.shade300,
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return DocumentUploadPage(
          initialIdDocument: _idDocument,
          initialAddressProof: _addressProof,
          initialIdType: _idType,
          onDocumentsUploaded: (idDoc, addressDoc, idType) {
            _nextStep({
              'idDocument': idDoc,
              'addressProof': addressDoc,
              'idType': idType,
            });
          },
        );
      case 1:
        return MapConfirmationPage(
          initialLocation: _location,
          initialLocationName: _locationName,
          initialCityId: _selectedCityId,
          initialCityName: _selectedCityName,
          initialFullAddress: _fullAddress,
          onNext: _nextStep,
          onPrevious: _previousStep,
        );
      case 2:
        return PaymentPage(
          initialPaymentMethod: _paymentMethod,
          onNext: _nextStep,
          onPrevious: _previousStep,
        );
      case 3:
        return AppointmentPage(
          initialDate: _appointmentDate,
          initialTime: _appointmentTime,
          onNext: _nextStep,
          onPrevious: _previousStep,
        );
      case 4:
        return CompletionPage(
          idDocument: _idDocument,
          addressProof: _addressProof,
          location: _location,
          locationName: _locationName,
          cityName: _selectedCityName,
          fullAddress: _fullAddress,
          paymentMethod: _paymentMethod,
          appointmentDate: _appointmentDate,
          appointmentTime: _appointmentTime,
          timeSlot: _timeSlot,
          onComplete: _completeVerification,
          onPrevious: _previousStep,
        );
      default:
        return const SizedBox();
    }
  }
}
