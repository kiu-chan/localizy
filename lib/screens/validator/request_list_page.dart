import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:localizy/api/validator_api.dart';
import 'package:localizy/l10n/app_localizations.dart';
import 'package:localizy/screens/validator/map/assignment_map_page.dart';

class RequestListPage extends StatefulWidget {
  const RequestListPage({super.key});

  @override
  State<RequestListPage> createState() => _RequestListPageState();
}

class _RequestListPageState extends State<RequestListPage> {
  String _selectedFilter = 'All';
  List<ValidationAssignment> _assignments = [];
  bool _isLoading = true;
  String? _error;

  static const _filters = ['All', 'Assigned', 'Scheduled', 'Verified', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ValidatorApi.getMyAssignments();
      setState(() {
        _assignments = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ValidationAssignment> get _filtered {
    if (_selectedFilter == 'All') return _assignments;
    return _assignments.where((a) => a.status == _selectedFilter).toList();
  }

  String _filterLabel(String filter, AppLocalizations l10n) => switch (filter) {
        'All' => l10n.validatorFilterAll,
        'Assigned' => l10n.validatorStatusAssigned,
        'Scheduled' => l10n.validatorScheduledStat,
        'Verified' => l10n.validatorVerifiedStat,
        'Rejected' => l10n.validatorRejectedStat,
        _ => filter,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          l10n.validatorRequestList,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAssignments,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 56,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: _filters
                  .map((f) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterChip(f, _filterLabel(f, l10n)),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildError(l10n)
                    : _filtered.isEmpty
                        ? _buildEmpty(l10n)
                        : RefreshIndicator(
                            onRefresh: _loadAssignments,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) => _buildCard(_filtered[i], l10n),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = value),
      backgroundColor: Colors.grey.shade200,
      selectedColor: Colors.green.shade100,
      labelStyle: TextStyle(
        color: isSelected ? Colors.green.shade700 : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: Colors.green.shade700,
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(l10n.validatorFailedToLoadAssignments,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _loadAssignments,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(l10n.validatorNoAssignmentsFound,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildCard(ValidationAssignment a, AppLocalizations l10n) {
    final (Color sc, IconData si) = _statusStyle(a.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showDetail(a, l10n),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        a.requestType,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(a.requestId,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  a.address?.code ?? l10n.validatorNoAddress,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(a.address?.cityCode ?? '-',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600)),
                    const SizedBox(width: 16),
                    Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      a.assignedDate != null
                          ? _formatDate(a.assignedDate!)
                          : '-',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      _statusBadge(a.status, sc, si),
                      const SizedBox(width: 8),
                      _priorityBadge(a.priority),
                    ]),
                    Icon(Icons.arrow_forward_ios,
                        size: 14, color: Colors.grey.shade400),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDetail(ValidationAssignment a, AppLocalizations l10n) async {
    final shouldReload = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DetailSheet(assignment: a),
    );
    if (shouldReload == true && mounted) {
      _loadAssignments();
    }
  }

  // ── helpers ────────────────────────────────────────────────────────────
  (Color, IconData) _statusStyle(String s) => switch (s) {
        'Assigned' => (Colors.orange, Icons.assignment_ind),
        'Scheduled' => (Colors.blue, Icons.event_available),
        'Verified' => (Colors.green, Icons.verified),
        'Rejected' => (Colors.red, Icons.cancel),
        _ => (Colors.grey, Icons.event),
      };

  Widget _statusBadge(String status, Color color, IconData icon) =>
      Container(
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

  Widget _priorityBadge(String priority) {
    final color = switch (priority) {
      'High' => Colors.red,
      'Medium' => Colors.orange,
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(priority,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  String _formatDate(DateTime dt) {
    final l = dt.toLocal();
    return '${l.day.toString().padLeft(2, '0')}/${l.month.toString().padLeft(2, '0')}/${l.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail bottom-sheet
// ─────────────────────────────────────────────────────────────────────────────
class _DetailSheet extends StatefulWidget {
  final ValidationAssignment assignment;

  const _DetailSheet({required this.assignment});

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> {
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
                    onPressed: () => _openMap(),
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
                  onPressed: _doConfirmAppointment,
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

  // ── Navigation ─────────────────────────────────────────────────────────────
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
      builder: (ctx) => AlertDialog(
        title: Text(l10n.validatorVerifyAddress),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.validatorVerifyAddressDesc,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.validatorNotes,
                hintText: l10n.validatorNotesHint,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel)),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _doVerify(notesCtrl.text.trim());
            },
            icon: const Icon(Icons.check),
            label: Text(l10n.confirm),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog() {
    final l10n = AppLocalizations.of(context)!;
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.validatorRejectAddress),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.validatorRejectAddressDesc,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.validatorReasonLabel,
                hintText: l10n.validatorReasonHint,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel)),
          ElevatedButton.icon(
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
            icon: const Icon(Icons.cancel_outlined),
            label: Text(l10n.validatorReject),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
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

  // ── UI helpers ──────────────────────────────────────────────────────────────
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
                  padding:
                      EdgeInsets.only(right: item == items.last ? 0 : 8),
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
                  style:
                      TextStyle(fontSize: 13, color: Colors.grey.shade600)),
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
                style:
                    TextStyle(fontSize: 13, color: Colors.grey.shade700)),
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
