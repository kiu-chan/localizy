import 'package:flutter/material.dart';
import 'package:localizy/core/theme/app_colors.dart';
import 'package:localizy/features/verification/presentation/widgets/verification_ui.dart';
import 'package:localizy/l10n/app_localizations.dart';

class AppointmentPage extends StatefulWidget {
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final Function(Map<String, dynamic>) onNext;
  final VoidCallback onPrevious;

  const AppointmentPage({
    super.key,
    this.initialDate,
    this.initialTime,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedTimeSlot;

  final List<Map<String, dynamic>> _timeSlots = [
    {'time': '08:00 - 10:00', 'available': true},
    {'time': '10:00 - 12:00', 'available': true},
    {'time': '13:00 - 15:00', 'available': false},
    {'time': '15:00 - 17:00', 'available': true},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedTime = widget.initialTime;
  }

  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now.add(const Duration(days: 1));
    final DateTime lastDate = now.add(const Duration(days: 30));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectTimeSlot(String timeSlot) {
    setState(() {
      _selectedTimeSlot = timeSlot;
      try {
        // Parse "08:00 - 10:00" -> "08:00"
        final startTime = timeSlot.split(' - ')[0].trim();
        // Split "08:00" by ":"
        final parts = startTime.split(':');
        if (parts.length == 2) {
          _selectedTime = TimeOfDay(
            hour: int.parse(parts[0].trim()),
            minute: int.parse(parts[1].trim()),
          );
        }
      } catch (e) {
        _selectedTime = const TimeOfDay(hour: 8, minute: 0);
      }
    });
  }

  void _confirmAppointment() {
    if (_selectedDate != null && _selectedTime != null) {
      widget.onNext({
        'date': _selectedDate,
        'time': _selectedTime,
        'timeSlot': _selectedTimeSlot,
      });
    }
  }

  String _formatDate(DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;

    if (locale == 'vi') {
      final weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
      return '${weekdays[date.weekday % 7]}, ${date.day}/${date.month}/${date.year}';
    } else if (locale == 'fr') {
      final weekdays = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
      return '${weekdays[date.weekday % 7]}, ${date.day}/${date.month}/${date.year}';
    } else {
      // English
      final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      return '${weekdays[date.weekday % 7]}, ${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VerificationInfoBanner(text: localizations.appointmentIntro),
                const SizedBox(height: 24),
                VerificationSectionTitle(localizations.selectDate),
                const SizedBox(height: 12),
                _buildDatePicker(localizations),
                if (_selectedDate != null) ...[
                  const SizedBox(height: 24),
                  VerificationSectionTitle(localizations.selectTimeSlot),
                  const SizedBox(height: 12),
                  _buildTimeSlots(),
                ],
                if (_selectedDate != null && _selectedTimeSlot != null) ...[
                  const SizedBox(height: 20),
                  _buildSummaryCard(localizations),
                ],
                const SizedBox(height: 24),
                VerificationNotesCard(
                  title: localizations.importantNotes,
                  notes: [
                    localizations.noteStaffWillArrive,
                    localizations.notePleaseBePresent,
                    localizations.notePrepareOriginalDocs,
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
              label: localizations.confirmAppointment,
              icon: Icons.arrow_forward,
              onPressed: _selectedDate != null && _selectedTimeSlot != null
                  ? _confirmAppointment
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(AppLocalizations localizations) {
    final hasDate = _selectedDate != null;

    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: verificationCardDecoration(
          borderColor: hasDate ? AppColors.primary : null,
        ).copyWith(
          color: hasDate ? AppColors.primarySurface : AppColors.surface,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calendar_today,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasDate
                        ? _formatDate(_selectedDate!)
                        : localizations.selectDate,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: hasDate ? AppColors.ink : AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasDate
                        ? localizations.tapToChange
                        : localizations.selectDateSuitable,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.disabled),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _timeSlots.map((slot) {
            return SizedBox(
              width: cardWidth,
              child: _buildTimeSlotCard(
                time: slot['time'] as String,
                isAvailable: slot['available'] as bool,
                isSelected: _selectedTimeSlot == slot['time'],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTimeSlotCard({
    required String time,
    required bool isAvailable,
    required bool isSelected,
  }) {
    final localizations = AppLocalizations.of(context)!;

    final Color background = !isAvailable
        ? AppColors.fill
        : isSelected
            ? AppColors.primary
            : AppColors.surface;
    final Color foreground = !isAvailable
        ? AppColors.disabled
        : isSelected
            ? AppColors.surface
            : AppColors.ink;

    return InkWell(
      onTap: isAvailable ? () => _selectTimeSlot(time) : null,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected && isAvailable
                ? AppColors.primary
                : AppColors.border,
          ),
          boxShadow: isAvailable ? AppShadows.cardList : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAvailable ? Icons.access_time : Icons.event_busy,
              size: 20,
              color: !isAvailable
                  ? AppColors.disabled
                  : isSelected
                      ? AppColors.surface
                      : AppColors.primary,
            ),
            const SizedBox(height: 6),
            Text(
              time,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: foreground,
              ),
            ),
            if (!isAvailable) ...[
              const SizedBox(height: 2),
              Text(
                localizations.fullyBooked,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.disabled,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: verificationCardDecoration(
        borderColor: AppColors.primary.withValues(alpha: 0.4),
      ).copyWith(color: AppColors.primarySurface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                localizations.yourAppointment,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.border),
          _buildSummaryRow(
            Icons.calendar_today,
            localizations.date,
            _formatDate(_selectedDate!),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            Icons.access_time,
            localizations.timeSlot,
            _selectedTimeSlot!,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
