import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('ta')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AllGo Super App'**
  String get appTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get tabExplore;

  /// No description provided for @tabOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get tabOrders;

  /// No description provided for @tabAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get tabAccount;

  /// No description provided for @serviceFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get serviceFood;

  /// No description provided for @serviceGrocery.
  ///
  /// In en, this message translates to:
  /// **'Grocery'**
  String get serviceGrocery;

  /// No description provided for @serviceParcel.
  ///
  /// In en, this message translates to:
  /// **'Parcel'**
  String get serviceParcel;

  /// No description provided for @serviceRides.
  ///
  /// In en, this message translates to:
  /// **'Rides'**
  String get serviceRides;

  /// No description provided for @serviceDriver.
  ///
  /// In en, this message translates to:
  /// **'Hire Driver'**
  String get serviceDriver;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In with Phone'**
  String get loginTitle;

  /// No description provided for @phoneLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your 10-digit mobile number to get started'**
  String get phoneLoginSubtitle;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Phone Number'**
  String get enterPhoneNumber;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get phoneNumberHint;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get sendOtp;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit mobile number'**
  String get invalidPhone;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit verification code sent to your phone'**
  String get otpSubtitle;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @resendTimer.
  ///
  /// In en, this message translates to:
  /// **'Resend code in'**
  String get resendTimer;

  /// No description provided for @verifyAndProceed.
  ///
  /// In en, this message translates to:
  /// **'Verify & Proceed'**
  String get verifyAndProceed;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 6-digit code'**
  String get invalidOtp;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to AllGo'**
  String get welcomeTitle;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Your city\'s super app for food, groceries, rides & parcels'**
  String get welcomeTagline;

  /// No description provided for @exploreAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Explore as Guest'**
  String get exploreAsGuest;

  /// No description provided for @acceptTerms.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms of Service & Privacy Policy'**
  String get acceptTerms;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search for food, groceries, dishes or stores...'**
  String get searchPlaceholder;

  /// No description provided for @deliveringTo.
  ///
  /// In en, this message translates to:
  /// **'Delivering to'**
  String get deliveringTo;

  /// No description provided for @changeLocation.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeLocation;

  /// No description provided for @offersAndDeals.
  ///
  /// In en, this message translates to:
  /// **'Offers & Deals'**
  String get offersAndDeals;

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended for You'**
  String get recommendedForYou;

  /// No description provided for @popularNearYou.
  ///
  /// In en, this message translates to:
  /// **'Popular Near You'**
  String get popularNearYou;

  /// No description provided for @reorderTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Again'**
  String get reorderTitle;

  /// No description provided for @favoriteStores.
  ///
  /// In en, this message translates to:
  /// **'Favorite Stores'**
  String get favoriteStores;

  /// No description provided for @recentStores.
  ///
  /// In en, this message translates to:
  /// **'Recent Stores'**
  String get recentStores;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @vegOnly.
  ///
  /// In en, this message translates to:
  /// **'Veg Only'**
  String get vegOnly;

  /// No description provided for @nonVeg.
  ///
  /// In en, this message translates to:
  /// **'Non-Veg'**
  String get nonVeg;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @deliveryTime.
  ///
  /// In en, this message translates to:
  /// **'mins'**
  String get deliveryTime;

  /// No description provided for @freeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Free Delivery'**
  String get freeDelivery;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'Open Now'**
  String get openNow;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @searchInStore.
  ///
  /// In en, this message translates to:
  /// **'Search in store...'**
  String get searchInStore;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @customizable.
  ///
  /// In en, this message translates to:
  /// **'Customizable'**
  String get customizable;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addItem;

  /// No description provided for @removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeItem;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View Cart'**
  String get viewCart;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get itemsCount;

  /// No description provided for @myCart.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get myCart;

  /// No description provided for @emptyCartTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get emptyCartTitle;

  /// No description provided for @emptyCartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add delicious food or daily essentials to get started'**
  String get emptyCartSubtitle;

  /// No description provided for @browseStores.
  ///
  /// In en, this message translates to:
  /// **'Browse Stores'**
  String get browseStores;

  /// No description provided for @billDetails.
  ///
  /// In en, this message translates to:
  /// **'Bill Details'**
  String get billDetails;

  /// No description provided for @itemTotal.
  ///
  /// In en, this message translates to:
  /// **'Item Total'**
  String get itemTotal;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get deliveryFee;

  /// No description provided for @platformFee.
  ///
  /// In en, this message translates to:
  /// **'Platform Fee'**
  String get platformFee;

  /// No description provided for @gstAndTaxes.
  ///
  /// In en, this message translates to:
  /// **'GST & Restaurant Taxes'**
  String get gstAndTaxes;

  /// No description provided for @toPay.
  ///
  /// In en, this message translates to:
  /// **'To Pay'**
  String get toPay;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// No description provided for @selectAddress.
  ///
  /// In en, this message translates to:
  /// **'Select Address'**
  String get selectAddress;

  /// No description provided for @addNewAddress.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get addNewAddress;

  /// No description provided for @deliveryInstructions.
  ///
  /// In en, this message translates to:
  /// **'Delivery Instructions'**
  String get deliveryInstructions;

  /// No description provided for @leaveAtDoor.
  ///
  /// In en, this message translates to:
  /// **'Leave at door'**
  String get leaveAtDoor;

  /// No description provided for @doNotRingBell.
  ///
  /// In en, this message translates to:
  /// **'Don\'t ring bell'**
  String get doNotRingBell;

  /// No description provided for @cookingNotes.
  ///
  /// In en, this message translates to:
  /// **'Cooking / packaging notes'**
  String get cookingNotes;

  /// No description provided for @deliveryTip.
  ///
  /// In en, this message translates to:
  /// **'Delivery Partner Tip'**
  String get deliveryTip;

  /// No description provided for @addTip.
  ///
  /// In en, this message translates to:
  /// **'Add tip'**
  String get addTip;

  /// No description provided for @couponCode.
  ///
  /// In en, this message translates to:
  /// **'Apply Coupon'**
  String get couponCode;

  /// No description provided for @couponApplied.
  ///
  /// In en, this message translates to:
  /// **'Coupon Applied'**
  String get couponApplied;

  /// No description provided for @availableOffers.
  ///
  /// In en, this message translates to:
  /// **'Available Offers'**
  String get availableOffers;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;

  /// No description provided for @cashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery (COD)'**
  String get cashOnDelivery;

  /// No description provided for @upi.
  ///
  /// In en, this message translates to:
  /// **'UPI Payment'**
  String get upi;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'AllGo Wallet'**
  String get wallet;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Credit / Debit Card'**
  String get card;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @discardCheckoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard Checkout?'**
  String get discardCheckoutTitle;

  /// No description provided for @discardCheckoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to go back? Items in your cart are preserved.'**
  String get discardCheckoutMessage;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @orderSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Placed Successfully!'**
  String get orderSuccessTitle;

  /// No description provided for @orderSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your order is confirmed and being prepared.'**
  String get orderSuccessSubtitle;

  /// No description provided for @orderFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get orderFailedTitle;

  /// No description provided for @orderPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Pending'**
  String get orderPendingTitle;

  /// No description provided for @viewOrderDetails.
  ///
  /// In en, this message translates to:
  /// **'View Order Details'**
  String get viewOrderDetails;

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track Order'**
  String get trackOrder;

  /// No description provided for @activeOrders.
  ///
  /// In en, this message translates to:
  /// **'Active Orders'**
  String get activeOrders;

  /// No description provided for @pastOrders.
  ///
  /// In en, this message translates to:
  /// **'Past Orders'**
  String get pastOrders;

  /// No description provided for @orderStatusPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed'**
  String get orderStatusPlaced;

  /// No description provided for @orderStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get orderStatusConfirmed;

  /// No description provided for @orderStatusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get orderStatusPreparing;

  /// No description provided for @orderStatusOutForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for Delivery'**
  String get orderStatusOutForDelivery;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// No description provided for @rateAndReview.
  ///
  /// In en, this message translates to:
  /// **'Rate & Review'**
  String get rateAndReview;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @courierDetails.
  ///
  /// In en, this message translates to:
  /// **'Courier Partner'**
  String get courierDetails;

  /// No description provided for @callDriver.
  ///
  /// In en, this message translates to:
  /// **'Call Driver'**
  String get callDriver;

  /// No description provided for @callStore.
  ///
  /// In en, this message translates to:
  /// **'Call Store'**
  String get callStore;

  /// No description provided for @chatWithDriver.
  ///
  /// In en, this message translates to:
  /// **'Chat with Driver'**
  String get chatWithDriver;

  /// No description provided for @shareTracking.
  ///
  /// In en, this message translates to:
  /// **'Share Live Tracking'**
  String get shareTracking;

  /// No description provided for @etaTitle.
  ///
  /// In en, this message translates to:
  /// **'Estimated Delivery'**
  String get etaTitle;

  /// No description provided for @sendParcel.
  ///
  /// In en, this message translates to:
  /// **'Send a Parcel'**
  String get sendParcel;

  /// No description provided for @pickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Pickup Location'**
  String get pickupLocation;

  /// No description provided for @dropoffLocation.
  ///
  /// In en, this message translates to:
  /// **'Drop-off Location'**
  String get dropoffLocation;

  /// No description provided for @packageWeight.
  ///
  /// In en, this message translates to:
  /// **'Package Weight (kg)'**
  String get packageWeight;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// No description provided for @twoWheeler.
  ///
  /// In en, this message translates to:
  /// **'2 Wheeler'**
  String get twoWheeler;

  /// No description provided for @threeWheeler.
  ///
  /// In en, this message translates to:
  /// **'3 Wheeler'**
  String get threeWheeler;

  /// No description provided for @tataAce.
  ///
  /// In en, this message translates to:
  /// **'Tata Ace'**
  String get tataAce;

  /// No description provided for @pickupTruck.
  ///
  /// In en, this message translates to:
  /// **'Pickup Truck'**
  String get pickupTruck;

  /// No description provided for @fragileHandling.
  ///
  /// In en, this message translates to:
  /// **'Fragile / Handle with care'**
  String get fragileHandling;

  /// No description provided for @parcelSummary.
  ///
  /// In en, this message translates to:
  /// **'Parcel Details'**
  String get parcelSummary;

  /// No description provided for @fareEstimate.
  ///
  /// In en, this message translates to:
  /// **'Estimated Fare'**
  String get fareEstimate;

  /// No description provided for @bookParcel.
  ///
  /// In en, this message translates to:
  /// **'Book Parcel Delivery'**
  String get bookParcel;

  /// No description provided for @bookRide.
  ///
  /// In en, this message translates to:
  /// **'Book a Ride'**
  String get bookRide;

  /// No description provided for @pickupPoint.
  ///
  /// In en, this message translates to:
  /// **'Pickup Point'**
  String get pickupPoint;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @vehicleEconomy.
  ///
  /// In en, this message translates to:
  /// **'Economy'**
  String get vehicleEconomy;

  /// No description provided for @vehicleComfort.
  ///
  /// In en, this message translates to:
  /// **'Comfort'**
  String get vehicleComfort;

  /// No description provided for @vehicleAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get vehicleAuto;

  /// No description provided for @vehicleBike.
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get vehicleBike;

  /// No description provided for @fare.
  ///
  /// In en, this message translates to:
  /// **'Fare'**
  String get fare;

  /// No description provided for @bookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// No description provided for @hireDriver.
  ///
  /// In en, this message translates to:
  /// **'Hire a Driver'**
  String get hireDriver;

  /// No description provided for @hourlyDriver.
  ///
  /// In en, this message translates to:
  /// **'Hourly Driver Service'**
  String get hourlyDriver;

  /// No description provided for @driverExperience.
  ///
  /// In en, this message translates to:
  /// **'Verified professional drivers'**
  String get driverExperience;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myAccount;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @biometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get biometricLogin;

  /// No description provided for @twoFactorAuth.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication (2FA)'**
  String get twoFactorAuth;

  /// No description provided for @activeSessions.
  ///
  /// In en, this message translates to:
  /// **'Active Device Sessions'**
  String get activeSessions;

  /// No description provided for @thisDevice.
  ///
  /// In en, this message translates to:
  /// **'This Mobile Device'**
  String get thisDevice;

  /// No description provided for @revokeSession.
  ///
  /// In en, this message translates to:
  /// **'Revoke Session'**
  String get revokeSession;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action is permanent and cannot be undone.'**
  String get deleteAccountConfirm;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center & FAQs'**
  String get helpCenter;

  /// No description provided for @faqs.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqs;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About AllGo'**
  String get aboutApp;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get themeTitle;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeSystem;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get offlineTitle;

  /// No description provided for @offlineMessage.
  ///
  /// In en, this message translates to:
  /// **'You are currently offline. Please check your connection.'**
  String get offlineMessage;

  /// No description provided for @exitAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit AllGo?'**
  String get exitAppTitle;

  /// No description provided for @exitAppMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to exit the application?'**
  String get exitAppMessage;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @deliverTogether.
  ///
  /// In en, this message translates to:
  /// **'Deliver Together'**
  String get deliverTogether;

  /// No description provided for @fastestDelivery.
  ///
  /// In en, this message translates to:
  /// **'Fastest Delivery'**
  String get fastestDelivery;

  /// No description provided for @deliveriesOnly.
  ///
  /// In en, this message translates to:
  /// **'Deliveries Only'**
  String get deliveriesOnly;

  /// No description provided for @ridesOnly.
  ///
  /// In en, this message translates to:
  /// **'Rides Only'**
  String get ridesOnly;

  /// No description provided for @allJobs.
  ///
  /// In en, this message translates to:
  /// **'All Jobs (Max Earnings)'**
  String get allJobs;

  /// No description provided for @locationPermissionRationale.
  ///
  /// In en, this message translates to:
  /// **'AllGo requires your location to deliver orders and offer rides accurately.'**
  String get locationPermissionRationale;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
