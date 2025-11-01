// lib/Constants/SubscriptionPlans.dart
class SubscriptionPlan {
  final String name;
  final int durationMonths;
  final double price;

  SubscriptionPlan({required this.name, required this.durationMonths, required this.price});
}

final List<SubscriptionPlan> subscriptionPlans = [
  SubscriptionPlan(name: '1 Month', durationMonths: 1, price: 3.0),
  SubscriptionPlan(name: '3 Months', durationMonths: 3, price: 200.0),
  SubscriptionPlan(name: '6 Months', durationMonths: 6, price: 400.0),
  SubscriptionPlan(name: '12 Months', durationMonths: 12, price: 700.0),
];

final SubscriptionPlan freeTrialPlan = SubscriptionPlan(name: 'Free Trial', durationMonths: 1, price: 0.0);
final SubscriptionPlan transportPlan = SubscriptionPlan(name: '1 Month', durationMonths: 1, price: 3.0);
final SubscriptionPlan productPlan = SubscriptionPlan(name: 'Unlimited Period', durationMonths: 1, price: 3.0);

