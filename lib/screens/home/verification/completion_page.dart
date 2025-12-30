import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localizy/l10n/app_localizations.dart';

class CompletionPage extends StatelessWidget {
  final File? idDocument;
  final File? addressProof;
  final Map<String, double>? location;
  final String? paymentMethod;
  final DateTime? appointmentDate;
  final TimeOfDay? appointmentTime;
  final String?  timeSlot;
  final VoidCallback onComplete;
  final VoidCallback onPrevious;

  const CompletionPage({
    super.key,
    this.idDocument,
    this.addressProof,
    this.location,
    this.paymentMethod,
    this.appointmentDate,
    this.appointmentTime,
    this.timeSlot,
    required this.onComplete,
    required this.onPrevious,
  });

  String _generateAddressCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'ADDR-${timestamp.toString().substring(5)}';
  }

  String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    
    if (locale == 'vi') {
      final weekdays = ['Chủ nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
      return '${weekdays[date.weekday % 7]}, ${date.day}/${date.month}/${date. year}';
    } else if (locale == 'fr') {
      final weekdays = ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
      return '${weekdays[date.weekday % 7]}, ${date.day}/${date.month}/${date.year}';
    } else {
      // English
      final weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      return '${weekdays[date.weekday % 7]}, ${date.day}/${date.month}/${date.year}';
    }
  }

  String _getPaymentMethodName(BuildContext context, String method) {
    final localizations = AppLocalizations.of(context)!;
    
    switch (method) {
      case 'momo':
        return localizations. paymentMomo;
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

  void _copyAddressCode(BuildContext context, String code) {
    final localizations = AppLocalizations.of(context)!;
    
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(localizations. addressCodeCopied),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final addressCode = _generateAddressCode();
    
    return SingleChildScrollView(
      padding:  const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 24),
          
          // Success animation/icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.shade50,
            ),
            child:  Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green. shade700,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            localizations.requestSubmitted,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            localizations.thankYouForCompleting,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Address code
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green. shade400, Colors.green.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.qr_code,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  localizations.yourAddressCode,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    addressCode,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton. icon(
                  onPressed:  () => _copyAddressCode(context, addressCode),
                  icon: const Icon(Icons.copy, size: 18),
                  label: Text(localizations.copyCode),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors. white),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height:  24),
          
          // Summary card
          Card(
            elevation:  2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child:  Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.requestSummary,
                    style:  const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    context,
                    Icons.credit_card,
                    localizations.identityDocument,
                    localizations.uploaded,
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    context,
                    Icons.receipt_long,
                    localizations.addressProofDoc,
                    localizations. uploaded,
                  ),
                  const SizedBox(height:  12),
                  _buildSummaryRow(
                    context,
                    Icons.location_on,
                    localizations.location,
                    location != null
                        ? '${location!['lat']! . toStringAsFixed(4)}, ${location!['lng']!.toStringAsFixed(4)}'
                        : localizations.confirmed,
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    context,
                    Icons.payment,
                    localizations.payment,
                    paymentMethod != null
                        ? _getPaymentMethodName(context, paymentMethod!)
                        : localizations.completed,
                  ),
                  if (appointmentDate != null) ...[
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      context,
                      Icons.calendar_today,
                      localizations.appointmentDate,
                      _formatDate(context, appointmentDate!),
                    ),
                  ],
                  if (timeSlot != null) ...[
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      context,
                      Icons. access_time,
                      localizations.timeSlot,
                      timeSlot!,
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // What's next section
          Card(
            elevation: 2,
            color: Colors.blue.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue. shade700),
                      const SizedBox(width: 8),
                      Text(
                        localizations.nextSteps,
                        style: const TextStyle(
                          fontSize:  16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height:  12),
                  _buildStepItem('1', localizations.step1ReceiveEmail),
                  _buildStepItem('2', localizations.step2StaffContact),
                  _buildStepItem('3', localizations.step3VerifyAddress),
                  _buildStepItem('4', localizations.step4ReceiveResult),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Important notes
          Card(
            elevation: 2,
            color:  Colors.amber.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child:  Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        localizations.importantNotesTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:  FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildNoteItem(localizations. noteSaveAddressCode),
                  _buildNoteItem(localizations.notePrepareOriginalDocs),
                  _buildNoteItem(localizations.noteBePresentOnTime),
                  _buildNoteItem(localizations.noteContactHotline),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copyAddressCode(context, addressCode),
                  icon: const Icon(Icons.share),
                  label: Text(localizations.share),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.green.shade700),
                    foregroundColor: Colors.green. shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width:  12),
              Expanded(
                flex: 2,
                child:  ElevatedButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.home),
                  label: Text(localizations.backToHome),
                  style:  ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green.shade700),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style:  const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:  Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize:  13)),
          ),
        ],
      ),
    );
  }
}