import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Maps raw exceptions and errors into user-friendly messages and actionable hints.
/// Prevents raw technical exceptions, database strings, or stack traces from appearing to users.
class FriendlyError {
  final String title;
  final String message;
  final bool isRetryable;
  final String? technicalDetails;

  const FriendlyError({
    required this.title,
    required this.message,
    this.isRetryable = true,
    this.technicalDetails,
  });

  /// Factory mapper to turn any thrown exception/object into a user-friendly error.
  factory FriendlyError.from(Object error, [StackTrace? stackTrace]) {
    // Log in debug mode for developer visibility
    if (kDebugMode) {
      debugPrint('[AllGo Error]: $error');
      if (stackTrace != null) {
        debugPrint('[AllGo StackTrace]: $stackTrace');
      }
    }

    final errorStr = error.toString().toLowerCase();

    if (error is SocketException ||
        errorStr.contains('socketexception') ||
        errorStr.contains('failed host lookup') ||
        errorStr.contains('connection refused') ||
        errorStr.contains('network is unreachable')) {
      return const FriendlyError(
        title: 'No Internet Connection',
        message: 'Please check your Wi-Fi or mobile data connection and try again.',
        isRetryable: true,
      );
    }

    if (error is TimeoutException ||
        errorStr.contains('timeout') ||
        errorStr.contains('timed out')) {
      return const FriendlyError(
        title: 'Connection Timed Out',
        message: 'The server took too long to respond. Please check your connection and retry.',
        isRetryable: true,
      );
    }

    if (errorStr.contains('unauthorized') ||
        errorStr.contains('401') ||
        errorStr.contains('jwt') ||
        errorStr.contains('session expired')) {
      return const FriendlyError(
        title: 'Session Expired',
        message: 'Your login session has expired. Please log in again to continue.',
        isRetryable: false,
      );
    }

    if (errorStr.contains('forbidden') || errorStr.contains('403')) {
      return const FriendlyError(
        title: 'Access Restricted',
        message: 'You do not have permission to perform this action.',
        isRetryable: false,
      );
    }

    if (errorStr.contains('not found') || errorStr.contains('404')) {
      return const FriendlyError(
        title: 'Item Not Available',
        message: 'The requested item or outlet could not be found.',
        isRetryable: false,
      );
    }

    if (errorStr.contains('insufficient') && errorStr.contains('balance')) {
      return const FriendlyError(
        title: 'Insufficient Balance',
        message: 'Your wallet does not have enough balance for this transaction.',
        isRetryable: false,
      );
    }

    if (errorStr.contains('location') &&
        (errorStr.contains('denied') || errorStr.contains('permission'))) {
      return const FriendlyError(
        title: 'Location Permission Needed',
        message: 'Please allow location access to discover nearby outlets and track deliveries.',
        isRetryable: true,
      );
    }

    return FriendlyError(
      title: 'Something went wrong',
      message: 'We encountered an unexpected issue. Please try again in a few moments.',
      isRetryable: true,
      technicalDetails: kDebugMode ? error.toString() : null,
    );
  }
}
