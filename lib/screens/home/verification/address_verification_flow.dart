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
  State<AddressVerificationFlow> createState() => _AddressVerificationFlowState();
}

class _AddressVerificationFlowState extends State<AddressVerificationFlow> {
  int _currentStep = 0;
  
  // Data from steps
  File? _idDocument;
  File? _addressProof;
  String _idType = 'cmnd';
  Map<String, double>? _location;
  String?  _paymentMethod;
  DateTime? _appointmentDate;
  TimeOfDay? _appointmentTime;
  String? _timeSlot;

  List<String> _getStepTitles(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return [
      localizations.uploadDocuments,
      localizations.confirmLocation,
      localizations.payment,
      localizations.selectAppointment,
      localizations.complete,
    ];
  }

  void _nextStep(dynamic data) {
    setState(() {
      // Save data from current step
      switch (_currentStep) {
        case 0:
          // Document upload data
          if (data is Map) {
            _idDocument = data['idDocument'];
            _addressProof = data['addressProof'];
            _idType = data['idType'];
          }
          break;
        case 1:
          // Map location data
          _location = data as Map<String, double>?;
          break;
        case 2:
          // Payment data
          _paymentMethod = data as String?;
          break;
        case 3:
          // Appointment data
          if (data is Map) {
            _appointmentDate = data['date'];
            _appointmentTime = data['time'];
            _timeSlot = data['timeSlot'];
          }
          break;
      }
      
      if (_currentStep < 4) {
        _currentStep++;
      } else {
        // Finish the flow
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

    // Basic validation before sending
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

    // Show a loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      final attachments = <File>[];
      if (_idDocument != null) attachments.add(_idDocument!);
      if (_addressProof != null) attachments.add(_addressProof!);

      final photosProvided = _idDocument != null;
      final documentsProvided = _addressProof != null;
      final attachmentsCount = attachments.length;

      // Use VerificationService to create the request
      final resp = await VerificationApi.createVerificationRequest(
        addressId: '', // If you have an addressId, set it here
        requestType: 'NewAddress',
        priority: 'Medium',
        idType: _idType.toUpperCase(),
        notes: '',
        photosProvided: photosProvided,
        documentsProvided: documentsProvided,
        attachmentsCount: attachmentsCount,
        latitude: _location!['lat']!,
        longitude: _location!['lng']!,
        paymentMethod: _paymentMethod ?? 'momo',
        paymentAmount: 100000, // amount used in app (adjust as needed)
        appointmentDate: _appointmentDate,
        appointmentTimeSlot: _timeSlot,
        attachments: attachments,
      );

      // Close loading
      if (mounted) Navigator.of(context).pop();

      // Show success and return to previous screen (or home)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.requestSubmitted)),
        );
      }

      // Optionally pass result back or simply pop
      if (mounted) Navigator.of(context).pop(resp);
    } catch (e) {
      // Close loading
      if (mounted) Navigator.of(context).pop();

      final msg = e.toString();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
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
      child:  Scaffold(
        appBar: AppBar(
          title: Text(localizations.addressVerification),
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon:  const Icon(Icons.arrow_back),
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
          children:  [
            // Progress Stepper
            _buildProgressStepper(),
            
            // Current Step Content
            Expanded(
              child: _buildStepContent(),
            ),
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
          // Step indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Row(
                children: [
                  _buildStepDot(index),
                  if (index < 4) _buildStepLine(index),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),
          // Step title
          Text(
            localizations.stepProgress(_currentStep + 1, 5, stepTitles[_currentStep]),
            style:  const TextStyle(
              fontSize:  16,
              fontWeight:  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // Progress percentage
          Text(
            localizations.percentComplete((((_currentStep + 1) / 5) * 100).toInt()),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
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
        color: isCompleted
            ? Colors.green.shade700
            : isCurrent
                ? Colors.green.shade700
                : Colors.grey.shade300,
        border: Border.all(
          color: isCurrent ?  Colors.green.shade900 :  Colors.transparent,
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
    final isCompleted = index < _currentStep;
    
    return Container(
      width:  40,
      height: 2,
      color: isCompleted ? Colors.green.shade700 : Colors.grey.shade300,
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
              'addressProof':  addressDoc,
              'idType': idType,
            });
          },
        );
      case 1:
        return MapConfirmationPage(
          initialLocation: _location,
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
          initialTime:  _appointmentTime,
          onNext: _nextStep,
          onPrevious: _previousStep,
        );
      case 4:
        return CompletionPage(
          idDocument: _idDocument,
          addressProof: _addressProof,
          location: _location,
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