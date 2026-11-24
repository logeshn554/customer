import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import 'welcome_screen.dart';
import '../common/friendly_error.dart';

class PrivacySecurityScreen extends ConsumerStatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  ConsumerState<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends ConsumerState<PrivacySecurityScreen> {
  final _biometricAuth = BiometricAuthService();
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = false;
  bool _personalizationEnabled = true;
  List<Map<String, dynamic>> _deviceSessions = [];

  @override
  void initState() {
    super.initState();
    _loadSecurityPreferences();
  }

  Future<void> _loadSecurityPreferences() async {
    final bio = await _biometricAuth.isBiometricEnabled();
    if (mounted) setState(() => _biometricEnabled = bio);
    try {
      final sessions = await ref.read(apiClientProvider).listDeviceSessions();
      if (mounted) setState(() => _deviceSessions = sessions);
    } catch (e, st) {
      FriendlyError.from(e, st);
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('This action is irreversible. All wallet credits, saved addresses, and active orders will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AllGoColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm Deletion'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authNotifierProvider.notifier).deleteAccount();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const WelcomeScreen()), (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllGoColors.background,
      appBar: const AllGoAppBar(title: 'Privacy & Security'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            _buildSectionHeader('Security Settings'),
            _buildSwitchTile('Biometric Login', 'Unlock app with Fingerprint or Face ID', Icons.fingerprint, _biometricEnabled, (v) async {
              setState(() => _biometricEnabled = v);
              await _biometricAuth.setBiometricEnabled(v);
            }),
            _buildSwitchTile('Two-Factor Authentication (2FA)', 'Require SMS OTP on new device sign-ins', Icons.security, _twoFactorEnabled, (v) => setState(() => _twoFactorEnabled = v)),
            const SizedBox(height: 20),

            _buildSectionHeader('Active Device Sessions'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AllGoColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AllGoColors.divider, width: 0.8)),
              child: Column(
                children: [
                  _buildSessionItem(device: 'This Mobile Device', location: 'Active Now', isCurrent: true),
                  if (_deviceSessions.isNotEmpty) ...[
                    ..._deviceSessions.map((s) => Column(
                      children: [
                        const Divider(height: 24),
                        _buildSessionItem(
                          device: '${s['platform'] ?? 'Device'}: ${s['device_id'] ?? 'Mobile'}',
                          location: 'Last active: ${s['last_active_at'] ?? 'Recently'}',
                          isCurrent: false,
                          onRevoke: () async {
                            if (s['device_id'] != null) {
                              await ref.read(apiClientProvider).revokeDeviceSession(s['device_id'].toString());
                              _loadSecurityPreferences();
                            }
                          },
                        ),
                      ],
                    )),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader('Privacy Preferences'),
            _buildSwitchTile('Personalized Offers', 'Allow suggestions based on previous orders', Icons.cookie_outlined, _personalizationEnabled, (v) => setState(() => _personalizationEnabled = v)),
            const SizedBox(height: 28),

            _buildSectionHeader('Legal & Compliance (DPDP Act 2023)'),
            _buildActionTile(
              'Privacy Policy',
              'View AllGo Data Protection and Privacy Policy',
              Icons.policy_outlined,
              () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LegalPolicyViewerScreen(
                    title: 'Privacy Policy',
                    markdownContent: '# AllGo Privacy Policy\n\nUnder the Digital Personal Data Protection Act (DPDP) 2023, your personal data and location data are collected solely for delivery and ride fulfillment. You have the right to request access, correction, or deletion of your data at any time.',
                  ),
                ),
              ),
            ),
            _buildActionTile(
              'Terms & Conditions',
              'View Master Service Terms & Conditions',
              Icons.description_outlined,
              () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LegalPolicyViewerScreen(
                    title: 'Terms & Conditions',
                    markdownContent: '# AllGo Master Terms & Conditions\n\nAll bookings, shopping orders, rides, and driver hires are governed by the AllGo service terms. Orders are fulfilled directly by verified merchant outlets and certified delivery partners.',
                  ),
                ),
              ),
            ),
            _buildActionTile(
              'Permissions & Consent Rationale',
              'Review why AllGo accesses device permissions',
              Icons.security_update_good_outlined,
              () => PermissionRationaleDialog.show(
                context,
                title: 'Device Permissions',
                rationale: 'AllGo uses Location, Notification, and Camera permissions to ensure delivery routing, order status alerts, and QR code handovers.',
                icon: Icons.security_outlined,
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader('Danger Zone'),
            Container(
              decoration: BoxDecoration(color: AllGoColors.error.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: AllGoColors.error.withValues(alpha: 0.3))),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: const Icon(Icons.delete_forever, color: AllGoColors.error, size: 26),
                  title: Text('Delete Account', style: AllGoTypography.bodyLarge.copyWith(color: AllGoColors.error, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Permanently remove all personal data and order history', style: TextStyle(fontSize: 12, color: AllGoColors.error)),
                  onTap: _handleDeleteAccount,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title.toUpperCase(), style: AllGoTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.8)),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: AllGoColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AllGoColors.divider, width: 0.8)),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: AllGoColors.textPrimary, size: 24),
          title: Text(title, style: AllGoTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, style: AllGoTypography.caption),
          trailing: const Icon(Icons.chevron_right, size: 20, color: AllGoColors.textTertiary),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: AllGoColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AllGoColors.divider, width: 0.8)),
      child: Material(
        color: Colors.transparent,
        child: SwitchListTile(
          secondary: Icon(icon, color: AllGoColors.textPrimary, size: 24),
          title: Text(title, style: AllGoTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, style: AllGoTypography.caption),
          activeColor: AllGoColors.primary,
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSessionItem({required String device, required String location, required bool isCurrent, VoidCallback? onRevoke}) {
    return Row(
      children: [
        Icon(isCurrent ? Icons.phone_android : Icons.laptop, color: isCurrent ? AllGoColors.primary : AllGoColors.textSecondary),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(device, style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  if (isCurrent) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AllGoColors.success.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                      child: const Text('Active', style: TextStyle(color: AllGoColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(location, style: AllGoTypography.caption),
            ],
          ),
        ),
        if (!isCurrent && onRevoke != null)
          TextButton(
            onPressed: onRevoke,
            child: const Text('Revoke', style: TextStyle(color: AllGoColors.error, fontSize: 12)),
          ),
      ],
    );
  }
}
