import 'package:flutter/material.dart';
import 'customer_home_screen.dart';

export 'customer_home_screen.dart';

/// Customer Home Shell screen facade.
/// Supported core super-app service verticals:
/// - Food Delivery: Restaurant meals and delicacies
/// - Quick Grocery: 15-minute essentials and daily needs
/// - City Parcel: Intracavity point-to-point courier delivery
/// - Mobility Rides: Bike Taxi, Auto Rickshaw, and Cab
/// - Hire Driver: On-demand professional chauffeur service
class CustomerHomeShell extends StatelessWidget {
  const CustomerHomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomerHomePage();
  }
}
