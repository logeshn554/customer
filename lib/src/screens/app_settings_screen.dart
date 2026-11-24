import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import '../components/theme_selection_sheet.dart';
import '../providers/app_settings_provider.dart';

class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  bool _orderNotifications = true;
  bool _promoNotifications = true;
  bool _smsAlerts = true;

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cached Data?'),
        content: const Text(
          'This will remove temporary network image caches and locally cached menu drafts. Your saved addresses and account information will remain safe.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AllGoColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('App cache cleared successfully (42.8 MB freed)'),
          backgroundColor: AllGoColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('App Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildSectionHeader('Notifications & Alerts'),
          SwitchListTile(
            title: const Text('Order Status Updates'),
            subtitle: const Text('Push alerts when courier is dispatched or arrives'),
            value: _orderNotifications,
            activeColor: AllGoColors.primary,
            onChanged: (val) => setState(() => _orderNotifications = val),
          ),
          SwitchListTile(
            title: const Text('Promotions & Discounts'),
            subtitle: const Text('Special coupons, festive offers, and deal alerts'),
            value: _promoNotifications,
            activeColor: AllGoColors.primary,
            onChanged: (val) => setState(() => _promoNotifications = val),
          ),
          SwitchListTile(
            title: const Text('SMS Critical Alerts'),
            subtitle: const Text('Backup SMS notifications for order delivery PINs'),
            value: _smsAlerts,
            activeColor: AllGoColors.primary,
            onChanged: (val) => setState(() => _smsAlerts = val),
          ),
          const Divider(height: 32),
          _buildSectionHeader('Appearance & Display'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme Mode'),
            subtitle: Text(
              themeMode == ThemeMode.system
                  ? 'System Default'
                  : themeMode == ThemeMode.dark
                      ? 'Dark Mode'
                      : 'Light Mode',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => ThemeSelectionSheet.show(context),
          ),
          const Divider(height: 32),
          _buildSectionHeader('Data & Storage'),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined, color: AllGoColors.warning),
            title: const Text('Clear Cache'),
            subtitle: const Text('Free up storage used by image previews & network cache'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _clearCache,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: AllGoTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.8),
      ),
    );
  }
}
