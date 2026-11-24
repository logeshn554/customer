import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import '../common/friendly_error.dart';

/// Reusable user-friendly error display with a clear Retry button.
class ErrorRetryView extends StatelessWidget {
  final FriendlyError error;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorRetryView({
    super.key,
    required this.error,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  factory ErrorRetryView.fromException({
    Key? key,
    required Object exception,
    VoidCallback? onRetry,
    IconData? icon,
  }) {
    return ErrorRetryView(
      key: key,
      error: FriendlyError.from(exception),
      onRetry: onRetry,
      icon: icon ?? Icons.error_outline_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AllGoColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AllGoColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              error.title,
              textAlign: TextAlign.center,
              style: AllGoTypography.heading3.copyWith(
                fontWeight: FontWeight.w700,
                color: AllGoColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: AllGoTypography.bodyMedium.copyWith(
                color: AllGoColors.textSecondary,
                height: 1.4,
              ),
            ),
            if (error.isRetryable && onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AllGoColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
