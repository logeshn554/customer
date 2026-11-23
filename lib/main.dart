import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import 'src/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
    return MaterialApp(
      title: 'AllGo Customer',
      debugShowCheckedModeBanner: false,
      theme: AllGoTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

