import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/localization/app_localizations.dart';
import 'src/providers/app_settings_provider.dart';
import 'src/router/app_router.dart';
import 'src/theme/app_theme_customer.dart';
import 'src/widgets/global_error_boundary.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GlobalErrorWidget.initialize();
  runApp(
    const ProviderScope(
      child: AllGoCustomerApp(),
    ),
  );
}

class AllGoCustomerApp extends ConsumerWidget {
  const AllGoCustomerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'AllGo Customer',
      debugShowCheckedModeBanner: false,
      theme: AllGoCustomerTheme.lightTheme,
      darkTheme: AllGoCustomerTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
      builder: (context, child) {
        return MediaQuery.withClampedTextScaling(
          minScaleFactor: 0.8,
          maxScaleFactor: 1.5,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
