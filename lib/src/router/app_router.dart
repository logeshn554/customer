import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/phone_login_screen.dart';
import '../screens/otp_verify_screen.dart';
import '../screens/customer_home_shell.dart';
import '../screens/outlet_catalog_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/order_detail_screen.dart';
import '../screens/delivery_tracking_screen.dart';
import '../screens/ride_booking_screen.dart';
import '../screens/parcel_send_screen.dart';
import '../screens/hire_driver_screen.dart';
import '../screens/account_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/saved_addresses_screen.dart';
import '../screens/wallet_screen.dart';
import '../screens/payments_and_refunds_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/privacy_security_screen.dart';
import '../screens/support_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Named route path definitions
class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String outlet = '/outlet/:outletId';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderDetail = '/order/:orderId';
  static const String deliveryTracking = '/track/:jobId';
  static const String rideBooking = '/ride';
  static const String parcelSend = '/parcel';
  static const String hireDriver = '/hire-driver';
  static const String account = '/account';
  static const String editProfile = '/account/profile';
  static const String savedAddresses = '/account/addresses';
  static const String wallet = '/wallet';
  static const String paymentsRefunds = '/payments';
  static const String notifications = '/notifications';
  static const String privacySecurity = '/privacy';
  static const String support = '/support';
}

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.welcome,
      name: 'welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const PhoneLoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.otp,
      name: 'otp',
      builder: (context, state) {
        final phone = (state.extra as String?) ?? state.uri.queryParameters['phone'] ?? '';
        return OtpVerifyScreen(phone: phone);
      },
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const CustomerHomeShell(),
    ),
    GoRoute(
      path: AppRoutes.outlet,
      name: 'outlet',
      builder: (context, state) {
        final outletId = state.pathParameters['outletId'] ?? '';
        final outletName = state.uri.queryParameters['name'] ?? 'Store';
        final categoryName = state.uri.queryParameters['category'];
        return OutletCatalogScreen(
          outletId: outletId,
          outletName: outletName,
          categoryName: categoryName,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.cart,
      name: 'cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: AppRoutes.checkout,
      name: 'checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: AppRoutes.orderDetail,
      name: 'orderDetail',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId'] ?? '';
        return OrderDetailScreen(subOrderId: orderId);
      },
    ),
    GoRoute(
      path: AppRoutes.deliveryTracking,
      name: 'deliveryTracking',
      builder: (context, state) {
        final jobId = state.pathParameters['jobId'] ?? '';
        return DeliveryTrackingScreen(jobId: jobId);
      },
    ),
    GoRoute(
      path: AppRoutes.rideBooking,
      name: 'rideBooking',
      builder: (context, state) {
        final activeRideId = state.uri.queryParameters['id'];
        return RideBookingScreen(activeRideId: activeRideId);
      },
    ),
    GoRoute(
      path: AppRoutes.parcelSend,
      name: 'parcelSend',
      builder: (context, state) {
        final activeParcelId = state.uri.queryParameters['id'];
        return ParcelSendScreen(activeParcelId: activeParcelId);
      },
    ),
    GoRoute(
      path: AppRoutes.hireDriver,
      name: 'hireDriver',
      builder: (context, state) {
        final activeBookingId = state.uri.queryParameters['id'];
        return HireDriverScreen(activeBookingId: activeBookingId);
      },
    ),
    GoRoute(
      path: AppRoutes.account,
      name: 'account',
      builder: (context, state) => const AccountScreen(),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      name: 'editProfile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.savedAddresses,
      name: 'savedAddresses',
      builder: (context, state) => const SavedAddressesScreen(),
    ),
    GoRoute(
      path: AppRoutes.wallet,
      name: 'wallet',
      builder: (context, state) => const WalletScreen(),
    ),
    GoRoute(
      path: AppRoutes.paymentsRefunds,
      name: 'paymentsRefunds',
      builder: (context, state) => const PaymentsAndRefundsScreen(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      name: 'notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.privacySecurity,
      name: 'privacySecurity',
      builder: (context, state) => const PrivacySecurityScreen(),
    ),
    GoRoute(
      path: AppRoutes.support,
      name: 'support',
      builder: (context, state) => const CustomerSupportScreen(),
    ),
  ],
);
