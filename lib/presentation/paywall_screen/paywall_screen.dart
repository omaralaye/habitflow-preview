import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_settings.dart';
import '../../data/models/subscription_plan.dart';
import '../../services/subscription_service.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isYearly = false;
  bool _isLoading = true;
  bool _isProcessing = false;
  List<SubscriptionPlan> _plans = [];
  SubscriptionPlan? _freePlan;
  SubscriptionPlan? _premiumPlan;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      final plans = await _subscriptionService.getAllPlans();
      if (mounted) {
        setState(() {
          _plans = plans;
          _freePlan = plans.firstWhere(
            (p) => p.isFree,
            orElse: () => const SubscriptionPlan(id: 'free', name: 'Free', maxHabits: 5),
          );
          _premiumPlan = plans.firstWhere(
            (p) => !p.isFree,
            orElse: () => const SubscriptionPlan(id: 'premium', name: 'Premium'),
          );
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSubscribe() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final priceId = _isYearly
          ? _premiumPlan?.stripePriceIdYearly
          : _premiumPlan?.stripePriceIdMonthly;

      if (priceId == null || priceId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment not configured yet. Please try again later.')),
          );
        }
        return;
      }

      final url = await _subscriptionService.createCheckoutSession(priceId);
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start checkout: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Upgrade to Premium',
                    style: GoogleFonts.dmSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock unlimited habits and more',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildPlanComparison(theme),
                  const SizedBox(height: 24),
                  _buildToggle(theme),
                  if (_premiumPlan != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _isYearly
                          ? 'Save ~33% with yearly billing'
                          : 'Billed monthly, cancel anytime',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  _buildSubscribeButton(theme),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Continue with Free plan',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildPlanComparison(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          _buildPlanRow(
            theme: theme,
            icon: Icons.check_circle_rounded,
            feature: 'Basic habit tracking',
            free: true,
            premium: true,
          ),
          _buildDivider(theme),
          _buildPlanRow(
            theme: theme,
            icon: Icons.straighten_rounded,
            feature: 'Max habits',
            free: true,
            freeLabel: '${_freePlan?.maxHabits ?? 5} habits',
            premium: true,
            premiumLabel: 'Unlimited',
          ),
          _buildDivider(theme),
          _buildPlanRow(
            theme: theme,
            icon: Icons.auto_graph_rounded,
            feature: 'Streak tracking',
            free: true,
            premium: true,
          ),
          _buildDivider(theme),
          _buildPlanRow(
            theme: theme,
            icon: Icons.bar_chart_rounded,
            feature: 'Progress charts',
            free: true,
            premium: true,
          ),
          _buildDivider(theme),
          _buildPlanRow(
            theme: theme,
            icon: Icons.emoji_events_rounded,
            feature: 'Challenges',
            free: true,
            premium: true,
          ),
          _buildDivider(theme),
          _buildPlanRow(
            theme: theme,
            icon: Icons.cloud_rounded,
            feature: 'Cloud sync',
            free: false,
            premium: true,
          ),
          _buildDivider(theme),
          _buildPlanRow(
            theme: theme,
            icon: Icons.palette_rounded,
            feature: 'Custom themes',
            free: false,
            premium: true,
          ),
          _buildDivider(theme),
          _buildPlanRow(
            theme: theme,
            icon: Icons.diamond_rounded,
            feature: 'Premium badge',
            free: false,
            premium: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanRow({
    required ThemeData theme,
    required IconData icon,
    required String feature,
    required bool free,
    bool? premium,
    String? freeLabel,
    String? premiumLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              feature,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              freeLabel ?? (free ? '✓' : '—'),
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: free
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              premiumLabel ?? ((premium ?? false) ? '✓' : '—'),
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: (premium ?? false)
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: theme.colorScheme.outline.withValues(alpha: 0.1),
    );
  }

  Widget _buildToggle(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isYearly = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isYearly ? theme.colorScheme.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !_isYearly
                      ? [BoxShadow(color: theme.colorScheme.shadow.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 1))]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      'Monthly',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: !_isYearly
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (_premiumPlan?.monthlyPrice != null)
                      Text(
                        '\$${_premiumPlan!.monthlyPrice!.toStringAsFixed(0)}/mo',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: !_isYearly
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isYearly = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isYearly ? theme.colorScheme.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _isYearly
                      ? [BoxShadow(color: theme.colorScheme.shadow.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 1))]
                      : null,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Yearly',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _isYearly
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Save',
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_premiumPlan?.yearlyPrice != null)
                      Text(
                        '\$${_premiumPlan!.yearlyPrice!.toStringAsFixed(0)}/yr',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: _isYearly
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _handleSubscribe,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Subscribe — \$${_isYearly
                    ? (_premiumPlan?.yearlyPrice ?? 0).toStringAsFixed(2)
                    : (_premiumPlan?.monthlyPrice ?? 0).toStringAsFixed(2)}',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
