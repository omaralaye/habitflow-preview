class SubscriptionPlan {
  final String id;
  final String name;
  final String? description;
  final int? maxHabits;
  final int? priceMonthlyCents;
  final int? priceYearlyCents;
  final String? stripePriceIdMonthly;
  final String? stripePriceIdYearly;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    this.description,
    this.maxHabits,
    this.priceMonthlyCents,
    this.priceYearlyCents,
    this.stripePriceIdMonthly,
    this.stripePriceIdYearly,
  });

  bool get isFree => id == 'free';

  double? get monthlyPrice => priceMonthlyCents != null ? priceMonthlyCents! / 100 : null;
  double? get yearlyPrice => priceYearlyCents != null ? priceYearlyCents! / 100 : null;
}
