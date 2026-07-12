import 'dart:io';

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/verification_repository.dart';

/// Toàn bộ dữ liệu wizard xác minh địa chỉ (5 bước).
class VerificationFlowState {
  const VerificationFlowState({
    this.currentStep = 0,
    this.idDocument,
    this.addressProof,
    this.idType = 'cmnd',
    this.latitude,
    this.longitude,
    this.locationName,
    this.cityId,
    this.cityName,
    this.fullAddress,
    this.paymentMethod,
    this.appointmentDate,
    this.appointmentTime,
    this.timeSlot,
  });

  static const int totalSteps = 5;

  final int currentStep;

  // Bước 1 — giấy tờ
  final File? idDocument;
  final File? addressProof;
  final String idType;

  // Bước 2 — vị trí
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final String? cityId;
  final String? cityName;
  final String? fullAddress;

  // Bước 3 — thanh toán
  final String? paymentMethod;

  // Bước 4 — lịch hẹn
  final DateTime? appointmentDate;
  final TimeOfDay? appointmentTime;
  final String? timeSlot;

  bool get hasLocation => latitude != null && longitude != null;

  /// Vị trí dạng map cho các trang bước cũ (giữ nguyên API constructor).
  Map<String, double>? get locationMap =>
      hasLocation ? {'lat': latitude!, 'lng': longitude!} : null;

  VerificationFlowState copyWith({
    int? currentStep,
    File? idDocument,
    File? addressProof,
    String? idType,
    double? latitude,
    double? longitude,
    String? locationName,
    String? cityId,
    String? cityName,
    String? fullAddress,
    String? paymentMethod,
    DateTime? appointmentDate,
    TimeOfDay? appointmentTime,
    String? timeSlot,
  }) {
    return VerificationFlowState(
      currentStep: currentStep ?? this.currentStep,
      idDocument: idDocument ?? this.idDocument,
      addressProof: addressProof ?? this.addressProof,
      idType: idType ?? this.idType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      fullAddress: fullAddress ?? this.fullAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      timeSlot: timeSlot ?? this.timeSlot,
    );
  }
}

/// autoDispose: đóng wizard là state reset, mở lại bắt đầu từ đầu.
final verificationFlowProvider = NotifierProvider.autoDispose<
    VerificationFlowNotifier, VerificationFlowState>(
  VerificationFlowNotifier.new,
);

class VerificationFlowNotifier extends Notifier<VerificationFlowState> {
  @override
  VerificationFlowState build() => const VerificationFlowState();

  void setDocuments({File? idDocument, File? addressProof, required String idType}) {
    state = state.copyWith(
      idDocument: idDocument,
      addressProof: addressProof,
      idType: idType,
    );
    _advance();
  }

  void setLocation({
    required double latitude,
    required double longitude,
    String? locationName,
    String? cityId,
    String? cityName,
    String? fullAddress,
  }) {
    state = state.copyWith(
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      cityId: cityId,
      cityName: cityName,
      fullAddress: fullAddress,
    );
    _advance();
  }

  void setPaymentMethod(String? method) {
    state = state.copyWith(paymentMethod: method);
    _advance();
  }

  void setAppointment({DateTime? date, TimeOfDay? time, String? timeSlot}) {
    state = state.copyWith(
      appointmentDate: date,
      appointmentTime: time,
      timeSlot: timeSlot,
    );
    _advance();
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  /// Quay lại bước chọn vị trí (khi submit thiếu vị trí).
  void goToLocationStep() {
    state = state.copyWith(currentStep: 1);
  }

  void _advance() {
    if (state.currentStep < VerificationFlowState.totalSteps - 1) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  /// Gửi yêu cầu xác minh với dữ liệu đã thu thập.
  Future<Map<String, dynamic>> submit() {
    final s = state;
    return ref.read(verificationRepositoryProvider).createVerificationRequest(
          idType: s.idType.toUpperCase(),
          photosProvided: s.idDocument != null,
          documentsProvided: s.addressProof != null,
          attachmentsCount:
              (s.idDocument != null ? 1 : 0) + (s.addressProof != null ? 1 : 0),
          latitude: s.latitude!,
          longitude: s.longitude!,
          locationName: s.locationName,
          fullAddress: s.fullAddress,
          cityId: s.cityId,
          paymentMethod: s.paymentMethod ?? 'momo',
          paymentAmount: 100000,
          appointmentDate: s.appointmentDate,
          appointmentTimeSlot: s.timeSlot,
          idDocument: s.idDocument,
          addressProof: s.addressProof,
        );
  }
}
