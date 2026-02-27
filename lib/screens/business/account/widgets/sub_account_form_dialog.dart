import 'package:flutter/material.dart';
import 'package:localizy/api/sub_account_api.dart';
import 'package:localizy/l10n/app_localizations.dart';

/// Hiển thị bottom sheet tạo tài khoản con mới.
/// Trả về [SubAccount] vừa tạo, hoặc `null` nếu huỷ / lỗi.
Future<SubAccount?> showCreateSubAccountDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SubAccountFormSheet(
      title: l10n.addNewSubAccount,
      confirmLabel: l10n.create,
      confirmIcon: Icons.person_add_outlined,
      formKey: formKey,
      nameCtrl: nameCtrl,
      emailCtrl: emailCtrl,
      passwordCtrl: passwordCtrl,
      phoneCtrl: phoneCtrl,
    ),
  );
  if (confirmed != true || !context.mounted) return null;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final account = await SubAccountApi.createSubAccount(
      email: emailCtrl.text.trim(),
      fullName: nameCtrl.text.trim(),
      password: passwordCtrl.text,
      phone: phoneCtrl.text.trim(),
    );
    if (context.mounted) Navigator.pop(context);
    return account;
  } catch (e) {
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorCreatingSubAccount(e)),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return null;
  }
}

/// Hiển thị bottom sheet chỉnh sửa tài khoản con.
/// Trả về [SubAccount] đã cập nhật, hoặc `null` nếu huỷ / lỗi.
Future<SubAccount?> showEditSubAccountDialog(
  BuildContext context,
  SubAccount account,
) async {
  final l10n = AppLocalizations.of(context)!;
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController(text: account.fullName);
  final emailCtrl = TextEditingController(text: account.email);
  final phoneCtrl = TextEditingController(text: account.phone);

  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SubAccountFormSheet(
      title: l10n.editSubAccount,
      confirmLabel: l10n.save,
      confirmIcon: Icons.check_outlined,
      formKey: formKey,
      nameCtrl: nameCtrl,
      emailCtrl: emailCtrl,
      phoneCtrl: phoneCtrl,
      // passwordCtrl null → chế độ edit (ẩn field mật khẩu)
    ),
  );
  if (confirmed != true || !context.mounted) return null;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final updated = await SubAccountApi.updateSubAccount(
      id: account.id,
      name: nameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
    );
    if (context.mounted) Navigator.pop(context);
    return updated;
  } catch (e) {
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorUpdatingSubAccount(e)),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return null;
  }
}

// ─── Bottom sheet widget ─────────────────────────────────────────────────────

class _SubAccountFormSheet extends StatefulWidget {
  final String title;
  final String confirmLabel;
  final IconData confirmIcon;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController? passwordCtrl;
  final TextEditingController phoneCtrl;

  const _SubAccountFormSheet({
    required this.title,
    required this.confirmLabel,
    required this.confirmIcon,
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    this.passwordCtrl,
    required this.phoneCtrl,
  });

  @override
  State<_SubAccountFormSheet> createState() => _SubAccountFormSheetState();
}

class _SubAccountFormSheetState extends State<_SubAccountFormSheet> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // Padding bottom theo keyboard — tránh tràn
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottom + safeBottom + 16),
      child: SingleChildScrollView(
        // physics cần để scroll khi keyboard che nội dung
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Drag handle ──────────────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Title ────────────────────────────────────────────────────
            Text(
              widget.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              widget.passwordCtrl != null
                  ? l10n.addNewSubAccount
                  : l10n.editSubAccount,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),

            // ── Form ─────────────────────────────────────────────────────
            Form(
              key: widget.formKey,
              child: Column(
                children: [
                  _FormField(
                    controller: widget.nameCtrl,
                    label: l10n.fullName,
                    hint: 'Nguyễn Văn A',
                    icon: Icons.person_outline,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.pleaseEnterFullName
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _FormField(
                    controller: widget.emailCtrl,
                    label: l10n.email,
                    hint: 'email@company.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return l10n.pleaseEnterEmail;
                      }
                      if (!v.contains('@')) return l10n.invalidEmail;
                      return null;
                    },
                  ),
                  if (widget.passwordCtrl != null) ...[
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: widget.passwordCtrl,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Colors.blue.shade600, width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red.shade400),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.red.shade400, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 16),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return l10n.pleaseEnterPassword;
                        }
                        if (v.length < 6) return l10n.passwordMinLength;
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 14),
                  _FormField(
                    controller: widget.phoneCtrl,
                    label: l10n.phoneOptional,
                    hint: '0901 234 567',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Actions ──────────────────────────────────────────────────
            Row(
              children: [
                // Cancel
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                // Confirm
                Expanded(
                  flex: 3,
                  child: FilledButton.icon(
                    onPressed: () {
                      if (widget.formKey.currentState!.validate()) {
                        Navigator.pop(context, true);
                      }
                    },
                    icon: Icon(widget.confirmIcon, size: 18),
                    label: Text(widget.confirmLabel),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable form field ─────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      ),
    );
  }
}
