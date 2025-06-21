// lib/Constants/SubscriptionPlans.dart
class SubscriptionPlan {
  final String name;
  final int durationMonths;
  final double price;

  SubscriptionPlan({required this.name, required this.durationMonths, required this.price});
}

final List<SubscriptionPlan> subscriptionPlans = [
  SubscriptionPlan(name: '1 Month Plan', durationMonths: 1, price: 100.0),
  SubscriptionPlan(name: '3 Months Plan', durationMonths: 3, price: 250.0),
  SubscriptionPlan(name: '6 Months Plan', durationMonths: 6, price: 500.0),
  SubscriptionPlan(name: '12 Months Plan', durationMonths: 12, price: 900.0),
];

final SubscriptionPlan freeTrialPlan = SubscriptionPlan(name: 'Free Trial', durationMonths: 1, price: 0.0);