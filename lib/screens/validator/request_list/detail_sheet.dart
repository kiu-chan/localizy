import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:localizy/api/validator_api.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/screens/validator/map/assignment_map_page.dart';

class DetailSheet extends StatefulWidget {
  final ValidationAssignment assignment;

  const DetailSheet({super.key, required this.assignment});

  @override
  State<DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<DetailSheet> {
  late ValidationAssignment _a;
  bool _actionLoading = false;

  @override
  void initState() {
    super.initState();
    _a = widget.assignment;
  }

  (Color, IconData) get _statusStyle => switch (_a.status) {
        'Assigned' => (Colors.orange, Icons.assignment_ind),
        'Scheduled' => (Colors.blue, Icons.event_available),
        'Verified' => (Colors.green, Icons.verified),
        'Rejected' => (Colors.red, Icons.cancel),
        _ => (Colors.grey, Icons.event),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (Color sc, IconData si) = _statusStyle;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scroll) => SingleChildScrollView(
        controller: scroll,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_a.requestId,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(_a.requestType,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                _badge(_a.status, sc, si),
              ],
            ),
            const SizedBox(height: 20),

            // General Info
            _section(l10n.validatorGeneralInfo),
            _row(Icons.low_priority, l10n.validatorPriority, _a.priority),
            _row(Icons.calendar_today, l10n.validatorSubmitted,
                _a.submittedDate != null ? _fmt(_a.submittedDate!) : '-'),
            _row(Icons.assignment_ind, l10n.validatorAssignedDate,
                _a.assignedDate != null ? _fmt(_a.assignedDate!) : '-'),
            if (_a.notes != null && _a.notes!.isNotEmpty)
              _row(Icons.notes, l10n.validatorNotes, _a.notes!),

            // Address
            if (_a.address != null) ...[
              const SizedBox(height: 16),
              _section(l10n.address),
              _row(Icons.qr_code, l10n.validatorCode, _a.address!.code),
              _row(Icons.location_city, l10n.validatorCityCode, _a.address!.cityCode),
              if (_a.address!.lat != null && _a.address!.lng != null) ...[
                _row(Icons.my_location, l10n.coordinates,
                    '${_a.address!.lat!.toStringAsFixed(6)}, ${_a.address!.lng!.toStringAsFixed(6)}'),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openMap,
                    icon: const Icon(Icons.map, size: 18),
                    label: Text(l10n.validatorViewOnMap),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green.shade700,
                      side: BorderSide(color: Colors.green.shade700),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ],

            // Requester
            if (_a.submittedBy != null) ...[
              const SizedBox(height: 16),
              _section(l10n.validatorRequester),
              _row(Icons.person, l10n.validatorNameLabel, _a.submittedBy!.name),
              if (_a.submittedBy!.email != null &&
                  _a.submittedBy!.email!.isNotEmpty)
                _row(Icons.email, l10n.email, _a.submittedBy!.email!),
            ],

            // Verification Data + attachments
            if (_a.verificationData != null) ...[
              const SizedBox(height: 16),
              _section(l10n.validatorVerificationData),
              _check(l10n.validatorPhotosProvided, _a.verificationData!.photosProvided),
              _check(l10n.validatorDocumentsProvided, _a.verificationData!.documentsProvided),
              _check(l10n.validatorLocationVerified, _a.verificationData!.locationVerified),
              _row(Icons.attach_file, l10n.validatorAttachments,
                  l10n.validatorFileCount(_a.attachmentsCount)),
              if (_a.verificationData!.idDocumentUrl != null ||
                  _a.verificationData!.addressProofUrl != null) ...[
                const SizedBox(height: 10),
                _buildAttachmentThumbnails(_a.verificationData!, l10n),
              ],
            ],

            // Assigned Validator
            if (_a.assignedValidator != null) ...[
              const SizedBox(height: 16),
              _section(l10n.validatorAssignedValidatorLabel),
              _row(Icons.badge, l10n.validatorNameLabel, _a.assignedValidator!.name),
            ],

            // Processing Info
            if (_a.processedBy != null ||
                _a.processingNotes != null ||
                _a.rejectionReason != null) ...[
              const SizedBox(height: 16),
              _section(l10n.validatorProcessingInfo),
              if (_a.processedBy != null)
                _row(Icons.manage_accounts, l10n.validatorProcessedBy,
                    _a.processedBy!.name),
              if (_a.processedDate != null)
                _row(Icons.check_circle_outline, l10n.validatorProcessedDate,
                    _fmt(_a.processedDate!)),
              if (_a.processingNotes != null && _a.processingNotes!.isNotEmpty)
                _row(Icons.comment, l10n.validatorProcessingNotes, _a.processingNotes!),
              if (_a.rejectionReason != null && _a.rejectionReason!.isNotEmpty)
                _row(Icons.cancel_outlined, l10n.validatorRejectionReason,
                    _a.rejectionReason!,
                    valueColor: Colors.red.shade700),
            ],

            const SizedBox(height: 24),

            // Action buttons
            if (_actionLoading)
              const Center(child: CircularProgressIndicator())
            else if (_a.isAssigned)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showConfirmAppointmentDialog,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(l10n.confirmAppointment),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              )
            else if (_a.isScheduled)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showVerifyDialog,
                      icon: const Icon(Icons.verified_outlined),
                      label: Text(l10n.validatorVerify),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showRejectDialog,
                      icon: const Icon(Icons.cancel_outlined),
                      label: Text(l10n.validatorReject),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                    side: BorderSide(color: Colors.green.shade700),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(l10n.close),
                ),
              ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Navigation ──────────────────────────────────────────────────────────────
  void _openMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssignmentMapPage(assignment: _a),
      ),
    );
  }

  void _openPhotoViewer(String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(title,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                placeholder: (ctx, url2) =>
                    const CircularProgressIndicator(color: Colors.white),
                errorWidget: (ctx, url2, err) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.broken_image,
                        color: Colors.white54, size: 64),
                    const SizedBox(height: 12),
                    Text(AppLocalizations.of(ctx)!.validatorCannotLoadImage,
                        style: TextStyle(color: Colors.grey.shade400)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Actions ─────────────────────────────────────────────────────────────────
  void _showConfirmAppointmentDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.event_available,
                    size: 32, color: Colors.green.shade700),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.confirmAppointment,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.validatorConfirmAppointmentDesc,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_a.address != null)
                      _dialogInfoRow(Icons.location_on,
                          _a.address!.code),
                    if (_a.assignedDate != null)
                      _dialogInfoRow(Icons.calendar_today,
                          _fmt(_a.assignedDate!)),
                    _dialogInfoRow(Icons.low_priority, _a.priority),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _doConfirmAppointment();
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: Text(l10n.confirm),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogInfoRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );

  Future<void> _doConfirmAppointment() async {
    setState(() => _actionLoading = true);
    try {
      await ValidatorApi.confirmAppointment(_a.id);
      setState(() => _actionLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.validatorAppointmentConfirmed),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _actionLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showVerifyDialog() {
    final l10n = AppLocalizations.of(context)!;
    final notesCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.verified_outlined,
                    size: 32, color: Colors.green.shade700),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.validatorVerifyAddress,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.validatorVerifyAddressDesc,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.validatorNotes,
                  hintText: l10n.validatorNotesHint,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green.shade700, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _doVerify(notesCtrl.text.trim());
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: Text(l10n.confirm),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRejectDialog() {
    final l10n = AppLocalizations.of(context)!;
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cancel_outlined,
                    size: 32, color: Colors.red.shade400),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.validatorRejectAddress,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.validatorRejectAddressDesc,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.validatorReasonLabel,
                  hintText: l10n.validatorReasonHint,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red.shade400, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final reason = reasonCtrl.text.trim();
                        if (reason.isEmpty) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text(l10n.validatorReasonRequired)),
                          );
                          return;
                        }
                        Navigator.pop(ctx);
                        _doReject(reason);
                      },
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: Text(l10n.validatorReject),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _doVerify(String notes) async {
    setState(() => _actionLoading = true);
    try {
      await ValidatorApi.verifyValidation(_a.id, notes);
      setState(() => _actionLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.validatorAddressVerified),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _actionLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _doReject(String reason) async {
    setState(() => _actionLoading = true);
    try {
      await ValidatorApi.rejectValidation(_a.id, reason);
      setState(() => _actionLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.validatorAddressRejected),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _actionLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ── UI helpers ───────────────────────────────────────────────────────────────
  Widget _buildAttachmentThumbnails(ValidationVerificationData data, AppLocalizations l10n) {
    final items = <(String, String)>[];
    if (data.idDocumentUrl != null) {
      items.add((l10n.identityDocument, data.idDocumentUrl!));
    }
    if (data.addressProofUrl != null) {
      items.add((l10n.addressProofDoc, data.addressProofUrl!));
    }

    return Row(
      children: items
          .map((item) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: item == items.last ? 0 : 8),
                  child: GestureDetector(
                    onTap: () => _openPhotoViewer(item.$2, item.$1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: item.$2,
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (ctx, url) => Container(
                              height: 100,
                              color: Colors.grey.shade200,
                              child: const Center(
                                  child: CircularProgressIndicator()),
                            ),
                            errorWidget: (ctx, url, err) => Container(
                              height: 100,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image,
                                  color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(item.$1,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.green.shade700,
            letterSpacing: 0.5,
          ),
        ),
      );

  Widget _row(IconData icon, String label, String value,
          {Color? valueColor}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade500),
            const SizedBox(width: 10),
            SizedBox(
              width: 110,
              child: Text(label,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ),
            Expanded(
              child: Text(value,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: valueColor)),
            ),
          ],
        ),
      );

  Widget _check(String label, bool value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_circle : Icons.cancel,
              size: 18,
              color: value ? Colors.green : Colors.red.shade300,
            ),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          ],
        ),
      );

  Widget _badge(String status, Color color, IconData icon) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(status,
                style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );

  String _fmt(DateTime dt) {
    final l = dt.toLocal();
    return '${l.day.toString().padLeft(2, '0')}/${l.month.toString().padLeft(2, '0')}/${l.year}'
        '  ${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }
}
