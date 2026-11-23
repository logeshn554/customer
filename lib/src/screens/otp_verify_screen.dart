import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';
import 'customer_home_shell.dart';

class OtpVerifyScreen extends ConsumerStatefulWidget {
  final String phone;

  const OtpVerifyScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  int _secondsRemaining = 60;
  Timer? _countdownTimer;
  String _enteredCode = '';

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _secondsRemaining = 60;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleVerify(String code) async {
    _enteredCode = code;
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final String currentPlatform = kIsWeb
        ? 'WEB'
        : (Platform.isIOS ? 'IOS' : 'ANDROID');
    final success = await authNotifier.verifyOtp(code, platform: currentPlatform);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CustomerHomeShell()),
        (route) => false,
      );
    } else {
      final error = ref.read(authNotifierProvider).errorMessage ?? 'Verification failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AllGoColors.error,
        ),
      );
    }
  }

  Future<void> _handleResend() async {
    if (_secondsRemaining > 0) return;

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final success = await authNotifier.requestOtp(widget.phone);

    if (!mounted) return;

    if (success) {
      _startCountdown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New verification code sent'),
          backgroundColor: AllGoColors.success,
        ),
      );
    } else {
      final error = ref.read(authNotifierProvider).errorMessage ?? 'Failed to resend';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AllGoColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AllGoColors.surface,
      appBar: const AllGoAppBar(title: 'Verify Phone'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text('Enter 6-digit code', style: AllGoTypography.heading2),
              const SizedBox(height: 8),
              Text(
                'We sent an SMS code to ${widget.phone}.',
                style: AllGoTypography.subtitle,
              ),
              const SizedBox(height: 36),
              AllGoOtpInput(
                length: 6,
                onCompleted: (code) => _handleVerify(code),
                onChanged: (code) => _enteredCode = code,
              ),
              const SizedBox(height: 24),
              Center(
                child: _secondsRemaining > 0
                    ? Text(
                        'Resend code in $_secondsRemaining seconds',
                        style: AllGoTypography.bodyMedium.copyWith(color: AllGoColors.textTertiary),
                      )
                    : TextButton(
                        onPressed: _handleResend,
                        child: Text(
                          'Resend Code',
                          style: AllGoTypography.button.copyWith(color: AllGoColors.primary),
                        ),
                      ),
              ),
              const Spacer(),
              AllGoButton(
                label: 'Verify & Continue',
                isLoading: authState.isLoading,
                onPressed: _enteredCode.length == 6
                    ? () => _handleVerify(_enteredCode)
                    : null,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

