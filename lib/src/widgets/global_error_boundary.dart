import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

/// Global error boundary and Flutter error widget override.
/// Replaces red screen of death with a clean AllGo error recovery screen.
class GlobalErrorWidget {
  static void initialize() {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        color: AllGoColors.surface,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.report_problem_rounded,
                  color: AllGoColors.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: AllGoTypography.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'An unexpected view rendering error occurred.',
                  textAlign: TextAlign.center,
                  style: AllGoTypography.bodyMedium.copyWith(
                    color: AllGoColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    };
  }
}
