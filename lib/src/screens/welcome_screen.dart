import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import 'phone_login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllGoColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AllGoColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: AllGoColors.textInverse,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Everything you need,\ndelivered or on the move.',
                textAlign: TextAlign.center,
                style: AllGoTypography.heading1.copyWith(height: 1.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Food, Groceries, Courier, Rides and Professional Drivers in one super app.',
                textAlign: TextAlign.center,
                style: AllGoTypography.subtitle,
              ),
              const Spacer(),
              AllGoButton(
                label: 'Get Started with Phone Number',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'By continuing, you agree to our Terms of Service & Privacy Policy.',
                textAlign: TextAlign.center,
                style: AllGoTypography.caption,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

