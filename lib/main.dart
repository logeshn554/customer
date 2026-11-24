import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import 'src/router/app_router.dart';
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

class AllGoCustomerApp extends StatelessWidget {
  const AllGoCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AllGo Customer',
      debugShowCheckedModeBanner: false,
      theme: AllGoTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}

