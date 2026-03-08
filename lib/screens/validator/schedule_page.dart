import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:localizy/api/validator_api.dart';
import 'package:localizy/screens/validator/map/assignment_map_page.dart';
import 'package:table_calendar/table_calendar.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<ValidationAssignment> _assignments = [];
  bool _isLoading = true;
  String? _error;

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
      final assignments = await ValidatorApi.getMyAssignments();
      setState(() {
        _assignments = assignments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ValidationAssignment> _getAssignmentsForDay(DateTime day) {
    return _assignments.where((a) {
      final d = a.calendarDate;
      if (d == null) return false;
      return d.year == day.year && d.month == day.month && d.day == day.day;
    }).toList();
  }

  Future<void> _confirmAppointment(ValidationAssignment assignment) async {
    try {
      final updated = await ValidatorApi.confirmAppointment(assignment.id);
      setState(() {
        final idx = _assignments.indexWhere((a) => a.id == updated.id);
        if (idx != -1) _assignments[idx] = updated;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment confirmed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Schedule',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onFormatChanged: (format) {
                          setState(() => _calendarFormat = format);
                        },
                        eventLoader: _getAssignmentsForDay,
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.green.shade300,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.green.shade700,
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: BoxDecoration(
                            color: Colors.green.shade700,
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: false,
                          titleTextStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          leftChevronIcon: Icon(
                            Icons.chevron_left,
                            color: Colors.green.shade700,
                          ),
                          rightChevronIcon: Icon(
                            Icons.chevron_right,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _selectedDay != null
                          ? _buildAssignmentsList()
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 64, color: Colors.grey.shade300),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Select a day to view schedule',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text('Failed to load assignments',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _loadAssignments,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentsList() {
    final assignments = _getAssignmentsForDay(_selectedDay!);

    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No assignments for this day',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      itemBuilder: (context, index) => _buildAssignmentCard(assignments[index]),
    );
  }

  Widget _buildAssignmentCard(ValidationAssignment a) {
    final (Color statusColor, IconData statusIcon) = _statusStyle(a.status);

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
          onTap: () => _showAssignmentDetail(a),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 70,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _statusBadge(a.status, statusColor, statusIcon),
                          const SizedBox(width: 8),
                          _priorityBadge(a.priority),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        a.requestId,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        a.requestType,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600),
                      ),
                      if (a.address != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.place, size: 13, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${a.address!.code} · ${a.address!.cityCode}',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey.shade500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAssignmentDetail(ValidationAssignment a) {
    final (Color statusColor, IconData statusIcon) = _statusStyle(a.status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    child: Text(
                      a.requestId,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _statusBadge(a.status, statusColor, statusIcon),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                a.requestType,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),

              // Thông tin chính
              _sectionTitle('General Info'),
              _detailRow(Icons.low_priority, 'Priority', a.priority),
              _detailRow(Icons.calendar_today, 'Submitted',
                  a.submittedDate != null ? _formatDateTime(a.submittedDate!) : '-'),
              _detailRow(Icons.assignment_ind, 'Assigned Date',
                  a.assignedDate != null ? _formatDateTime(a.assignedDate!) : '-'),
              if (a.notes != null && a.notes!.isNotEmpty)
                _detailRow(Icons.notes, 'Notes', a.notes!),

              // Địa chỉ
              if (a.address != null) ...[
                const SizedBox(height: 16),
                _sectionTitle('Address'),
                _detailRow(Icons.qr_code, 'Code', a.address!.code),
                _detailRow(Icons.location_city, 'City Code', a.address!.cityCode),
                if (a.address!.lat != null && a.address!.lng != null) ...[
                  _detailRow(Icons.my_location, 'Coordinates',
                      '${a.address!.lat!.toStringAsFixed(6)}, ${a.address!.lng!.toStringAsFixed(6)}'),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openMap(a),
                      icon: const Icon(Icons.map, size: 18),
                      label: const Text('View on Map'),
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

              // Người yêu cầu
              if (a.submittedBy != null) ...[
                const SizedBox(height: 16),
                _sectionTitle('Requester'),
                _detailRow(Icons.person, 'Name', a.submittedBy!.name),
                if (a.submittedBy!.email != null && a.submittedBy!.email!.isNotEmpty)
                  _detailRow(Icons.email, 'Email', a.submittedBy!.email!),
              ],

              // Tài liệu xác minh
              if (a.verificationData != null) ...[
                const SizedBox(height: 16),
                _sectionTitle('Verification Data'),
                _checkRow('Photos Provided', a.verificationData!.photosProvided),
                _checkRow('Documents Provided', a.verificationData!.documentsProvided),
                _checkRow('Location Verified', a.verificationData!.locationVerified),
                _detailRow(Icons.attach_file, 'Attachments', '${a.attachmentsCount} file(s)'),
                if (a.verificationData!.idDocumentUrl != null ||
                    a.verificationData!.addressProofUrl != null) ...[
                  const SizedBox(height: 10),
                  _buildAttachmentThumbnails(a.verificationData!),
                ],
              ],

              // Validator được giao
              if (a.assignedValidator != null) ...[
                const SizedBox(height: 16),
                _sectionTitle('Assigned Validator'),
                _detailRow(Icons.badge, 'Name', a.assignedValidator!.name),
              ],

              // Xử lý
              if (a.processedBy != null || a.processingNotes != null || a.rejectionReason != null) ...[
                const SizedBox(height: 16),
                _sectionTitle('Processing Info'),
                if (a.processedBy != null)
                  _detailRow(Icons.manage_accounts, 'Processed By', a.processedBy!.name),
                if (a.processedDate != null)
                  _detailRow(Icons.check_circle_outline, 'Processed Date',
                      _formatDateTime(a.processedDate!)),
                if (a.processingNotes != null && a.processingNotes!.isNotEmpty)
                  _detailRow(Icons.comment, 'Processing Notes', a.processingNotes!),
                if (a.rejectionReason != null && a.rejectionReason!.isNotEmpty)
                  _detailRow(Icons.cancel_outlined, 'Rejection Reason',
                      a.rejectionReason!, valueColor: Colors.red.shade700),
              ],

              const SizedBox(height: 24),

              // Action button
              if (a.isAssigned)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmAppointment(a),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Confirm Appointment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
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
                    child: const Text('Close'),
                  ),
                ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _openMap(ValidationAssignment a) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssignmentMapPage(assignment: a),
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
                    const Icon(Icons.broken_image, color: Colors.white54, size: 64),
                    const SizedBox(height: 12),
                    Text('Cannot load image',
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

  Widget _buildAttachmentThumbnails(ValidationVerificationData data) {
    final items = <(String label, String url)>[];
    if (data.idDocumentUrl != null) {
      items.add(('ID Document', data.idDocumentUrl!));
    }
    if (data.addressProofUrl != null) {
      items.add(('Address Proof', data.addressProofUrl!));
    }

    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: item == items.last ? 0 : 8),
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
                          placeholder: (ctx, url2) => Container(
                            height: 100,
                            color: Colors.grey.shade200,
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                          errorWidget: (ctx, url2, err) => Container(
                            height: 100,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$1,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
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
  }

  Widget _detailRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: value ? Colors.green : Colors.red.shade300,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status, Color color, IconData icon) {
    return Container(
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
          Text(
            status,
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

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
      child: Text(
        priority,
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  (Color, IconData) _statusStyle(String status) {
    return switch (status) {
      'Assigned' => (Colors.orange, Icons.assignment_ind),
      'Scheduled' => (Colors.blue, Icons.event_available),
      'Verified' => (Colors.green, Icons.verified),
      'Rejected' => (Colors.red, Icons.cancel),
      _ => (Colors.grey, Icons.event),
    };
  }

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}'
        '  ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
