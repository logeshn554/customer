import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import '../localization/app_localizations.dart';
import '../providers/app_settings_provider.dart';

class ThemeSelectionSheet extends ConsumerWidget {
  const ThemeSelectionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const ThemeSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeModeProvider);
    final l10n = AppLocalizations.of(context);

    final title = l10n?.themeTitle ?? 'App Theme';
    final systemTitle = l10n?.themeSystem ?? 'System Default';
    final lightTitle = l10n?.themeLight ?? 'Light Mode';
    final darkTitle = l10n?.themeDark ?? 'Dark Mode';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AllGoColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: AllGoTypography.heading3),
            const SizedBox(height: 16),
            _buildThemeOption(
              context: context,
              ref: ref,
              mode: ThemeMode.system,
              title: systemTitle,
              subtitle: 'Follow device system preference',
              isSelected: currentMode == ThemeMode.system,
              icon: Icons.brightness_auto,
            ),
            _buildThemeOption(
              context: context,
              ref: ref,
              mode: ThemeMode.light,
              title: lightTitle,
              subtitle: 'Classic bright theme',
              isSelected: currentMode == ThemeMode.light,
              icon: Icons.light_mode_outlined,
            ),
            _buildThemeOption(
              context: context,
              ref: ref,
              mode: ThemeMode.dark,
              title: darkTitle,
              subtitle: 'Easy on the eyes in low light',
              isSelected: currentMode == ThemeMode.dark,
              icon: Icons.dark_mode_outlined,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required WidgetRef ref,
    required ThemeMode mode,
    required String title,
    required String subtitle,
    required bool isSelected,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AllGoColors.primaryLight.withValues(alpha: 0.15) : AllGoColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AllGoColors.primary : AllGoColors.divider,
          width: isSelected ? 1.5 : 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: isSelected ? AllGoColors.primary : AllGoColors.textSecondary),
          title: Text(title, style: AllGoTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, style: AllGoTypography.caption),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: AllGoColors.primary)
              : const Icon(Icons.radio_button_unchecked, color: AllGoColors.textTertiary),
          onTap: () {
            ref.read(themeModeProvider.notifier).setThemeMode(mode);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
