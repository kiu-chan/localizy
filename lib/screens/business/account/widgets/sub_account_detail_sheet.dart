import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localizy/api/sub_account_api.dart';
import 'package:localizy/l10n/app_localizations.dart';

/// Hiển thị bottom sheet chi tiết tài khoản con.
/// Trả về `true` nếu người dùng nhấn Edit.
Future<bool> showSubAccountDetailSheet(
  BuildContext context,
  SubAccount account,
) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SubAccountDetailSheet(account: account),
  );
  return result == true;
}

class _SubAccountDetailSheet extends StatelessWidget {
  final SubAccount account;

  const _SubAccountDetailSheet({required this.account});

  Color get _avatarColor {
    const palette = [
      Color(0xFF4C84F5),
      Color(0xFF9C6BDE),
      Color(0xFF22BFC7),
      Color(0xFFF57C49),
      Color(0xFFE84393),
      Color(0xFF3DAA70),
    ];
    if (account.fullName.isEmpty) return palette[0];
    return palette[account.fullName.codeUnitAt(0) % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _avatarColor;
    final initial = account.fullName.isNotEmpty
        ? account.fullName.substring(0, 1).toUpperCase()
        : '?';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ─────────────────────────────────────────────────
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),

          // ── Avatar + name/email ──────────────────────────────────────────
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            account.fullName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            account.email,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),

          // ── Info card ────────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                if (account.phone.isNotEmpty)
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: l10n.phoneOptional,
                    value: account.phone,
                  ),
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: l10n.createdDate,
                  value: _formatDate(account.createdAt),
                ),
                _InfoRow(
                  icon: Icons.badge_outlined,
                  label: l10n.accountId,
                  value: account.id.length > 16
                      ? '${account.id.substring(0, 16)}…'
                      : account.id,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: account.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.idCopied),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Edit button ──────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.edit),
              style: FilledButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '-';
    try {
      return raw.contains('T') ? raw.split('T').first : raw;
    } catch (_) {
      return raw;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Icon(icon, size: 18, color: Colors.grey.shade500),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: Text(
                    label,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade500),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.end,
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.copy_outlined,
                      size: 14, color: Colors.grey.shade400),
                ],
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(height: 1, indent: 46, color: Colors.grey.shade100),
      ],
    );
  }
}
