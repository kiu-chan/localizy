import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceiptRow {
  const ReceiptRow(this.label, this.value, {this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;
}

/// Khung biên lai dùng chung để render ra ảnh chia sẻ
/// (giao dịch, vé đậu xe, xác minh địa chỉ).
class ReceiptWidget extends StatelessWidget {
  const ReceiptWidget({
    super.key,
    required this.headerColor,
    required this.typeIcon,
    required this.subtitle,
    this.amountText,
    required this.statusLabel,
    required this.statusIcon,
    this.badgeText,
    required this.rows,
    this.footerText = 'Official Receipt · Citea',
  });

  final Color headerColor;
  final IconData typeIcon;
  final String subtitle;

  /// null → không hiển thị số tiền (ví dụ xác minh miễn phí).
  final String? amountText;
  final String statusLabel;
  final IconData statusIcon;

  /// Biển số xe hiển thị nổi bật (vé đậu xe).
  final String? badgeText;
  final List<ReceiptRow> rows;
  final String footerText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      color: const Color(0xFFEEF0F3),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildDashedSeparator(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Column(
                  children: [for (final row in rows) _buildDetailRow(row)],
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            headerColor,
            Color.lerp(headerColor, Colors.black, 0.22)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on,
                  color: Colors.white.withValues(alpha: 0.7), size: 14),
              const SizedBox(width: 5),
              Text(
                'C I T I Z E N',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25), width: 1.5),
            ),
            child: Icon(typeIcon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
          ),
          if (amountText != null) ...[
            const SizedBox(height: 6),
            Text(
              amountText!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: Colors.white, size: 13),
                const SizedBox(width: 5),
                Text(
                  statusLabel,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (badgeText != null && badgeText!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badgeText!,
                style: TextStyle(
                  color: headerColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDashedSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: List.generate(
          32,
          (i) => Expanded(
            child: Container(
              height: 1.5,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              color: i.isEven ? Colors.grey.shade200 : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(ReceiptRow row) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              row.label,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              row.value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: row.valueColor ?? const Color(0xFF111111),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_outlined, size: 12, color: headerColor),
              const SizedBox(width: 5),
              Text(
                footerText,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
            style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
