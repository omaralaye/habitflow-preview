import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/subscription_plan.dart';
import '../data/models/user_subscription.dart';

class SubscriptionService {
  static SupabaseClient get _client => Supabase.instance.client;

  static const int freeMaxHabits = 5;
  UserSubscription? _cachedSubscription;
  StreamSubscription? _realtimeSub;

  UserSubscription? get cachedSubscription => _cachedSubscription;

  Future<UserSubscription> getSubscription() async {
    if (_cachedSubscription != null) return _cachedSubscription!;
    try {
      final data = await _client
          .from('user_subscriptions')
          .select('*, subscription_plans(*)')
          .single();

      final sub = UserSubscription.fromJson(data as Map<String, dynamic>);
      _cachedSubscription = sub;
      return sub;
    } catch (_) {
      _cachedSubscription = UserSubscription(
        id: '',
        userId: '',
        planId: 'free',
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return _cachedSubscription!;
    }
  }

  Future<SubscriptionPlan> getPlan(String planId) async {
    try {
      final data = await _client
          .from('subscription_plans')
          .select()
          .eq('id', planId)
          .single();

      return SubscriptionPlan(
        id: data['id'] as String,
        name: data['name'] as String,
        description: data['description'] as String?,
        maxHabits: data['max_habits'] as int?,
        priceMonthlyCents: data['price_monthly_cents'] as int?,
        priceYearlyCents: data['price_yearly_cents'] as int?,
        stripePriceIdMonthly: data['stripe_price_id_monthly'] as String?,
        stripePriceIdYearly: data['stripe_price_id_yearly'] as String?,
      );
    } catch (_) {
      return const SubscriptionPlan(id: 'free', name: 'Free', maxHabits: 5);
    }
  }

  Future<List<SubscriptionPlan>> getAllPlans() async {
    try {
      final data = await _client
          .from('subscription_plans')
          .select()
          .order('id') as List;

      return data.map((json) {
        final d = json as Map<String, dynamic>;
        return SubscriptionPlan(
          id: d['id'] as String,
          name: d['name'] as String,
          description: d['description'] as String?,
          maxHabits: d['max_habits'] as int?,
          priceMonthlyCents: d['price_monthly_cents'] as int?,
          priceYearlyCents: d['price_yearly_cents'] as int?,
          stripePriceIdMonthly: d['stripe_price_id_monthly'] as String?,
          stripePriceIdYearly: d['stripe_price_id_yearly'] as String?,
        );
      }).toList();
    } catch (_) {
      return [
        const SubscriptionPlan(id: 'free', name: 'Free', maxHabits: 5),
        const SubscriptionPlan(
          id: 'premium',
          name: 'Premium',
          priceMonthlyCents: 999,
          priceYearlyCents: 7999,
        ),
      ];
    }
  }

  Future<String> createCheckoutSession(String priceId) async {
    final response = await _client.functions.invoke(
      'stripe-create-checkout',
      body: {'price_id': priceId},
    );

    final data = response.data as Map<String, dynamic>;
    if (data['url'] == null) throw Exception('No checkout URL returned');
    return data['url'] as String;
  }

  Future<String> createPortalSession() async {
    final response = await _client.functions.invoke(
      'stripe-portal',
      body: {},
    );

    final data = response.data as Map<String, dynamic>;
    if (data['url'] == null) throw Exception('No portal URL returned');
    return data['url'] as String;
  }

  Future<bool> canAddHabit({int currentCount = 0}) async {
    try {
      final sub = await getSubscription();
      if (sub.isPremium) return true;

      final plan = await getPlan(sub.planId);
      final maxHabits = plan.maxHabits ?? freeMaxHabits;

      return currentCount < maxHabits;
    } catch (_) {
      return true;
    }
  }

  Stream<UserSubscription> subscribeToChanges() {
    _realtimeSub?.cancel();
    final controller = StreamController<UserSubscription>();
    const channelName = 'realtime:user_subscriptions';

    _client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          table: 'user_subscriptions',
          schema: 'public',
          callback: (payload) async {
            final sub = await getSubscription();
            controller.add(sub);
          },
        )
        .subscribe();

    return controller.stream;
  }

  void dispose() {
    _realtimeSub?.cancel();
  }
}
