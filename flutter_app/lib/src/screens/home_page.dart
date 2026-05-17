import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/app_theme.dart';
import '../core/models.dart';
import '../core/seed_data.dart';
import '../widgets/shared.dart';
import '../services/backend_api_service.dart';
import '../services/ai_service.dart';
import '../widgets/ai_analysis_card.dart';
import '../services/ai_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.plan,
    required this.goal,
    required this.totalPoints,
    required this.resilienceScore,
    required this.smartDecisionScore,
    required this.currentStreak,
    required this.recentPoints,
    required this.transactions,
    required this.breed,
    required this.accessory,
    required this.effect,
    required this.showAlert,
    this.latestNudge,
    required this.onSaveAlert,
    required this.onOpenAlternatives,
    required this.onDismissAlert,
    required this.onNavigate,
    required this.userName,
    required this.balance,
    required this.savingsPocket,
    required this.aiInsights,
    required this.lastNudgeText,
    required this.lastRiskLevel,
    required this.userId,
    required this.onAiNudge,
  });

  final BudgetPlan plan;
  final double goal;
  final int totalPoints;
  final int resilienceScore;
  final int smartDecisionScore;
  final int currentStreak;
  final List<PointsEvent> recentPoints;
  final List<TransactionRecord> transactions;
  final String breed;
  final String accessory;
  final String effect;
  final bool showAlert;
  final AiNudge? latestNudge;
  final VoidCallback onSaveAlert;
  final VoidCallback onOpenAlternatives;
  final VoidCallback onDismissAlert;
  final ValueChanged<int> onNavigate;
  final String userName;
  final double balance;
  final double savingsPocket;
  final List<String> aiInsights;
  final String lastNudgeText;
  final String lastRiskLevel;
  final String userId;
  final void Function(AiNudge nudge, double? newBalance) onAiNudge;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? aiResult;
  int? demoResilienceScore;
  int? demoSmartDecisionScore;
  double? _simulatedBalance;
  final List<TransactionRecord> _simulatedTransactions = <TransactionRecord>[];

  Future<void> _openPaymentSimulation() async {
    final request = await showModalBottomSheet<_PaymentSimulationRequest>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaymentSimulationSheet(
        userId: widget.userId.isNotEmpty ? widget.userId : 'demo_user_001',
        dailyBudget: widget.plan.dailyLimit > 0 ? widget.plan.dailyLimit : 30,
        currentDailySpending: _estimateCurrentDailySpending(),
        savingsGoal: widget.goal > 0 ? widget.goal : 500,
      ),
    );

    if (!mounted || request == null) return;

    await Future<void>.delayed(const Duration(milliseconds: 90));
    if (!mounted) return;

    final result = await showGeneralDialog<_PaymentSimulationResolution>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'ThinkTwice Alert',
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) =>
          _ThinkTwiceSimulationAlertDialog(
        request: request,
        breed: widget.breed,
        accessory: widget.accessory,
        effect: widget.effect,
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final scale = Tween<double>(begin: 0.92, end: 1).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        );
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(fade);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: ScaleTransition(scale: scale, child: child),
          ),
        );
      },
    );

    if (!mounted || result == null) return;

    setState(() {
      aiResult = result.aiResult;
      AiState.latestAiResult = result.aiResult;
      final scoreAnalysis =
          result.aiResult['scoreAnalysis'] as Map<String, dynamic>?;
      demoResilienceScore =
          (scoreAnalysis?['resilienceScore'] as num?)?.toInt() ??
              demoResilienceScore;
      demoSmartDecisionScore =
          (scoreAnalysis?['smartDecisionScore'] as num?)?.toInt() ??
              demoSmartDecisionScore;
      if (result.newBalance != null) {
        _simulatedBalance = result.newBalance;
      }
      if (result.completedTransaction != null) {
        _simulatedTransactions.removeWhere(
          (item) => item.id == result.completedTransaction!.id,
        );
        _simulatedTransactions.insert(0, result.completedTransaction!);
      }
    });

    if (result.radarContext != null) {
      AiState.latestSimulationContext = result.radarContext;
      widget.onNavigate(1);
      return;
    }

    if (result.savedInstead) {
      widget.onSaveAlert();
    } else {
      showContainedSnackBar(
        context,
        message: result.bannerBody,
        accentColor: result.bannerTone == 'warning'
            ? context.colors.warning
            : context.colors.primary,
        icon: result.bannerTone == 'warning'
            ? Icons.warning_amber_rounded
            : Icons.info_rounded,
      );
    }
  }

  double _estimateCurrentDailySpending() {
    final recentSpend = widget.transactions
        .where((tx) => tx.amount < 0)
        .take(3)
        .fold<double>(0, (sum, tx) => sum + tx.amount.abs());
    if (recentSpend <= 0) return 18;
    return (recentSpend / 3).clamp(12, 80).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final goal = widget.goal;
    final totalPoints = widget.totalPoints;
    final resilienceScore = demoResilienceScore ?? widget.resilienceScore;
    final smartDecisionScore =
        demoSmartDecisionScore ?? widget.smartDecisionScore;
    final currentStreak = widget.currentStreak;
    final recentPoints = widget.recentPoints;
    final transactionIds =
        _simulatedTransactions.map((item) => item.id).toSet();
    final transactions = [
      ..._simulatedTransactions,
      ...widget.transactions.where((item) => !transactionIds.contains(item.id)),
    ];
    final breed = widget.breed;
    final accessory = widget.accessory;
    final effect = widget.effect;
    final showAlert = widget.showAlert;
    final onSaveAlert = widget.onSaveAlert;
    final onOpenAlternatives = widget.onOpenAlternatives;
    final onDismissAlert = widget.onDismissAlert;
    final onNavigate = widget.onNavigate;
    final userName = widget.userName;
    final balance = _simulatedBalance ?? widget.balance;
    final savingsPocket = widget.savingsPocket;
    final aiInsights = widget.aiInsights;
    final lastNudgeText = widget.lastNudgeText;
    final lastRiskLevel = widget.lastRiskLevel;
    final overspendingRisk = plan.allocations
            .firstWhere((item) => item.name == 'Food & drinks')
            .percent >=
        0.34;
    final challengeCompleted = currentStreak >= 3;
    final leveledUp = resilienceScore >= 70;
    final savingsWin = plan.savingsRate >= 0.25;
    final emotion = leveledUp
        ? AvatarMood.excited
        : (overspendingRisk && !showAlert)
            ? AvatarMood.sad
            : (savingsWin || challengeCompleted)
                ? AvatarMood.happy
                : AvatarMood.neutral;
    final level = 1 + (totalPoints ~/ 300);
    final pointsIntoLevel = totalPoints % 300;
    final nextLevelPoints = 300;
    final levelProgress = (pointsIntoLevel / nextLevelPoints).clamp(0.0, 1.0);
    final streakLabel = '$currentStreak day${currentStreak == 1 ? '' : 's'}';
    final insights = aiInsights.isNotEmpty
        ? aiInsights
            .take(3)
            .map((text) => (
                  Icons.psychology_alt_rounded,
                  lastRiskLevel == 'high'
                      ? 'warning'
                      : lastRiskLevel == 'medium'
                          ? 'primary'
                          : 'success',
                  text.length > 60 ? '${text.substring(0, 60)}...' : text,
                  text,
                ))
            .toList()
        : [
            (
              Icons.restaurant_rounded,
              'warning',
              'Food spending is 35% above average today',
              'AI flagged late food purchases as your main overspending risk right now.',
            ),
            (
              Icons.savings_outlined,
              'success',
              'You avoided RM47 overspending this week',
              'Your recent nudges and safer swaps kept this week under your flexible budget.',
            ),
            (
              Icons.wallet_outlined,
              'primary',
              'You can still save RM20 today',
              'Staying under your safe daily limit keeps your weekly goal within reach.',
            ),
          ];
    final categories = plan.allocations
        .where((item) => item.name != 'Savings')
        .take(4)
        .toList();
    final trend = [30, 45, 28, 60, 35, 52, 41];
    final goalProgress = (plan.savingsAmount * 0.6 / goal).clamp(0.0, 1.0);
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good evening,',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: context.colors.mutedForeground)),
                      const SizedBox(height: 2),
                      Text(userName,
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5)),
                    ],
                  ),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: _openPaymentSimulation,
                    icon: const Icon(Icons.payments_rounded, size: 18),
                    label: const Text('Simulate Payment'),
                    style: FilledButton.styleFrom(
                      foregroundColor: context.colors.primary,
                      backgroundColor: context.colors.primary.withOpacity(0.12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.96, end: 1.02),
                    duration: const Duration(milliseconds: 1800),
                    builder: (context, value, child) =>
                        Transform.scale(scale: value, child: child),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: context.colors.softMintGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: context.colors.softShadow,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(
                        'assets/images/thinktwice-logo.png',
                        width: 44,
                        height: 44,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              StaggeredReveal(
                index: 0,
                child: GradientCard(
                  padding: const EdgeInsets.all(20),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -32,
                        top: -32,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  blurRadius: 30,
                                  spreadRadius: 18)
                            ],
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.account_balance_wallet_outlined,
                                  size: 15,
                                  color: Colors.white.withOpacity(0.96)),
                              const SizedBox(width: 6),
                              Text(
                                'Current balance',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withOpacity(0.96)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          AnimatedNumberText(
                            value: balance,
                            prefix: 'RM ',
                            decimals: 2,
                            style: TextStyle(
                              fontSize: 39,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1.2,
                              shadows: [
                                Shadow(
                                    color: Color(0x3A173A31),
                                    blurRadius: 14,
                                    offset: Offset(0, 4)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Savings goal',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withOpacity(0.9)),
                              ),
                              Text(
                                'RM ${formatRm(plan.savingsAmount * 0.6)} / RM ${formatRm(goal)}',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white.withOpacity(0.96)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          AnimatedFillBar(
                            value: goalProgress,
                            minHeight: 10,
                            backgroundColor: Colors.white24,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.14)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome_rounded,
                                    color: Colors.white.withOpacity(0.98),
                                    size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'Your savings pocket is glowing',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white.withOpacity(0.98)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _heroMiniCard(
                                  icon: Icons.wallet_rounded,
                                  label: 'Money Habit Score',
                                  value: '$resilienceScore',
                                  glowColor: const Color(0xFF92F0D5),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _heroMiniCard(
                                  icon: Icons.local_fire_department_rounded,
                                  label: 'Smart Spending Streak',
                                  value: streakLabel,
                                  glowColor: const Color(0xFFFFD58B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _heroMiniCard(
                                  icon: Icons.psychology_alt_rounded,
                                  label: 'Smart Spending',
                                  value: '$smartDecisionScore',
                                  glowColor: const Color(0xFFC7F7E9),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _heroMiniCard(
                                  icon: Icons.savings_rounded,
                                  label: 'Savings Goal',
                                  value: '${formatRm(goalProgress * 100)}%',
                                  glowColor: const Color(0xFFFFE8AF),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              StaggeredReveal(
                index: 1,
                child: WhiteCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(pocketBuddyName(),
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color:
                                            context.colors.accentForeground)),
                                const SizedBox(height: 4),
                                Text(
                                    '${pocketBuddyName()} is keeping a gentle eye on your spending vibe.',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.3)),
                                const SizedBox(height: 6),
                                Text(
                                  moodLabel(emotion),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: context.colors.mutedForeground),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFFFF7D8),
                                  const Color(0xFFF7DA8C),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      context.colors.accent.withOpacity(0.28),
                                  blurRadius: 14,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Text(
                              'Level $level',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: context.colors.accentForeground),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFFFFCF6),
                              context.colors.guardianGradient.colors.last
                                  .withOpacity(0.96),
                              const Color(0xFFD9F4EA),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: context.colors.primary.withOpacity(0.12)),
                          boxShadow: [
                            BoxShadow(
                              color: context.colors.primary.withOpacity(0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            avatarPreview(
                              context,
                              breed: breed,
                              accessory: accessory,
                              effect: leveledUp ? 'sparkle_aura' : effect,
                              mood: emotion,
                              size: 120,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF2D5C53).withOpacity(0.92),
                                      const Color(0xFF3D766C).withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1C3F38)
                                          .withOpacity(0.16),
                                      blurRadius: 18,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.14),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.12)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.auto_awesome_rounded,
                                              size: 14,
                                              color: const Color(0xFFFFE7A3)),
                                          const SizedBox(width: 6),
                                          Text(
                                            leveledUp
                                                ? 'Epic mood sparkle'
                                                : 'Chill check-in mode',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      leveledUp
                                          ? '${pocketBuddyName()} is glowing because your money habits just leveled up.'
                                          : overspendingRisk
                                              ? '${pocketBuddyName()} is giving you a soft heads-up before the streak slips.'
                                              : '${pocketBuddyName()} is calm, alert, and ready to hype your next good call.',
                                      style: TextStyle(
                                          fontSize: 12,
                                          height: 1.5,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              Colors.white.withOpacity(0.96)),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _guardianChip(
                                            context,
                                            Icons.favorite_rounded,
                                            savingsWin
                                                ? 'Feeling good'
                                                : 'Keeping watch'),
                                        _guardianChip(
                                            context,
                                            Icons.inventory_2_rounded,
                                            '${nextLevelPoints - pointsIntoLevel} pts to next look'),
                                        _guardianChip(
                                            context,
                                            Icons.local_fire_department_rounded,
                                            streakLabel),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: progressStat(
                                context, 'Reward points', '$totalPoints pts'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: progressStat(context, 'Next unlock',
                                '${nextLevelPoints - pointsIntoLevel} pts left'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Text('Level progress',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700)),
                          const Spacer(),
                          Text(
                            '${formatRm(levelProgress * 100)}%',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: context.colors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      AnimatedFillBar(
                        value: levelProgress,
                        minHeight: 10,
                        color: context.colors.primary,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: context.colors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Icon(
                                leveledUp
                                    ? Icons.celebration_rounded
                                    : Icons.bolt_rounded,
                                size: 16,
                                color: context.colors.success),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                leveledUp
                                    ? 'Your cat is proud. You just hit a stronger resilience tier.'
                                    : 'A couple more smart saves and you will unlock your next collectible.',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: context.colors.foreground),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text('Recent points earned',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      ...recentPoints.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color:
                                      context.colors.primary.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Icon(item.icon,
                                    size: 18, color: context.colors.primary),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(item.label,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                              ),
                              Text(
                                '+${item.points}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: context.colors.success),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (aiResult != null) ...[
                const SizedBox(height: 12),
                AiAnalysisCard(aiResult: aiResult!),
              ],
              const SizedBox(height: 16),
              StaggeredReveal(
                index: 3,
                child: Row(
                  children: [
                    Expanded(
                        child: QuickActionCard(
                            icon: Icons.savings_outlined,
                            label: 'Save Now',
                            color: context.colors.primary,
                            onTap: onSaveAlert)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: QuickActionCard(
                            icon: Icons.map_rounded,
                            label: 'Radar',
                            color: context.colors.accent,
                            onTap: () => onNavigate(1))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: QuickActionCard(
                            icon: Icons.emoji_events_rounded,
                            label: 'Challenges',
                            color: context.colors.warning,
                            onTap: () => onNavigate(2))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              sectionHeader(context, 'Money check-ins',
                  action: 'See all', onTap: () => onNavigate(3)),
              const SizedBox(height: 8),
              ...insights.asMap().entries.map((entry) => StaggeredReveal(
                    index: 3 + entry.key,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InsightCard(
                        icon: entry.value.$1,
                        tone: entry.value.$2,
                        title: entry.value.$3,
                        body: entry.value.$4,
                      ),
                    ),
                  )),
              const SizedBox(height: 12),
              StaggeredReveal(
                index: 6,
                child: WhiteCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Progress after action',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                              child: progressStat(
                                  context, 'Saved this week', 'RM 37')),
                          const SizedBox(width: 8),
                          Expanded(
                              child: progressStat(
                                  context, 'Radar savings', 'RM 22')),
                          const SizedBox(width: 8),
                          Expanded(
                              child:
                                  progressStat(context, 'Score gain', '+12')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: context.colors.warmGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.celebration_rounded,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Every good save nudges your future self forward.',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              StaggeredReveal(
                index: 7,
                child: WhiteCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('This week',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.colors.success.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.trending_up_rounded,
                                    size: 12, color: context.colors.success),
                                const SizedBox(width: 4),
                                Text('-12%',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: context.colors.success)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 96,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(trend.length, (index) {
                            final value = trend[index];
                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: value.toDouble(),
                                      decoration: BoxDecoration(
                                        color: index == 5
                                            ? null
                                            : context.colors.muted,
                                        gradient: index == 5
                                            ? context.colors.primaryGradient
                                            : null,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(6)),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      [
                                        'M',
                                        'T',
                                        'W',
                                        'T',
                                        'F',
                                        'S',
                                        'S'
                                      ][index],
                                      style: TextStyle(
                                          fontSize: 9,
                                          color:
                                              context.colors.mutedForeground),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...categories.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(item.name,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500)),
                                  const Spacer(),
                                  Text(
                                    '${formatRm(item.percent * 100)}% | RM ${formatRm(item.amount)}',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: context.colors.mutedForeground),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: item.percent,
                                  minHeight: 6,
                                  backgroundColor: context.colors.muted,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(item.color),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              StaggeredReveal(
                index: 8,
                child: WhiteCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      sectionHeader(context, 'Squad leaderboard',
                          action: 'View',
                          onTap: () => onNavigate(2),
                          compact: true),
                      const SizedBox(height: 8),
                      ...[
                        (
                          1,
                          'Mira',
                          1240,
                          false,
                          'british_shorthair',
                          'glasses',
                          'glow_outline'
                        ),
                        (
                          2,
                          'You',
                          totalPoints + smartDecisionScore,
                          true,
                          breed,
                          accessory,
                          effect
                        ),
                        (
                          3,
                          'Hafiz',
                          980,
                          false,
                          'orange_tabby',
                          'headphones',
                          'sparkle_aura'
                        ),
                      ].map((item) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: item.$4
                                ? context.colors.primary.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                    color: context.colors.muted,
                                    shape: BoxShape.circle),
                                alignment: Alignment.center,
                                child: Text('${item.$1}',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700)),
                              ),
                              const SizedBox(width: 12),
                              avatarPreview(context,
                                  breed: item.$5,
                                  accessory: item.$6,
                                  effect: item.$7,
                                  mood: item.$4
                                      ? AvatarMood.proud
                                      : AvatarMood.happy,
                                  size: 44,
                                  showBackground: false),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Text(item.$2,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600))),
                              Text('${item.$3} pts',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: context.colors.primary)),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showAlert)
          Positioned.fill(
            child: AIInterventionModal(
              nudge: widget.latestNudge,
              onSaveNow: onSaveAlert,
              onFindAlternative: onOpenAlternatives,
              onIgnore: onDismissAlert,
            ),
          ),
      ],
    );
  }

  Widget _heroMiniCard(
      {required IconData icon,
      required String label,
      required String value,
      required Color glowColor}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.24),
            Colors.white.withOpacity(0.1),
            glowColor.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.16),
            blurRadius: 16,
            spreadRadius: -8,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: Colors.white.withOpacity(0.96)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.92)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.95, end: 1),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) => Transform.scale(
                scale: scale, alignment: Alignment.centerLeft, child: child),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _guardianChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.96),
            const Color(0xFFF4FFF9).withOpacity(0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.colors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.colors.foreground),
          ),
        ],
      ),
    );
  }
}

enum _SimulationStage { entry, preview, analysing, intervention }

class _PaymentSimulationRequest {
  const _PaymentSimulationRequest({
    required this.userId,
    required this.amount,
    required this.categoryLabel,
    required this.normalizedCategory,
    required this.merchant,
    required this.description,
    required this.location,
    required this.dailyBudget,
    required this.currentDailySpending,
    required this.savingsGoal,
    required this.transactionPayload,
    required this.aiPayload,
  });

  final String userId;
  final double amount;
  final String categoryLabel;
  final String normalizedCategory;
  final String merchant;
  final String description;
  final String location;
  final double dailyBudget;
  final double currentDailySpending;
  final double savingsGoal;
  final Map<String, dynamic> transactionPayload;
  final Map<String, dynamic> aiPayload;
}

class _PaymentSimulationResolution {
  const _PaymentSimulationResolution({
    required this.aiResult,
    required this.bannerTitle,
    required this.bannerBody,
    required this.bannerTone,
    this.completedTransaction,
    this.newBalance,
    this.radarContext,
    this.savedInstead = false,
  });

  final Map<String, dynamic> aiResult;
  final String bannerTitle;
  final String bannerBody;
  final String bannerTone;
  final TransactionRecord? completedTransaction;
  final double? newBalance;
  final Map<String, dynamic>? radarContext;
  final bool savedInstead;
}

class _PaymentSimulationSheet extends StatefulWidget {
  const _PaymentSimulationSheet({
    required this.userId,
    required this.dailyBudget,
    required this.currentDailySpending,
    required this.savingsGoal,
  });

  final String userId;
  final double dailyBudget;
  final double currentDailySpending;
  final double savingsGoal;

  @override
  State<_PaymentSimulationSheet> createState() =>
      _PaymentSimulationSheetState();
}

class _PaymentSimulationSheetState extends State<_PaymentSimulationSheet> {
  static const LatLng _demoCoordinates = LatLng(3.1390, 101.6869);

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  _SimulationStage _stage = _SimulationStage.entry;
  String? _selectedCategory;

  final List<_SimulationTemplate> _quickTemplates = const [
    _SimulationTemplate(
      label: 'Late-night bubble tea',
      amount: '19.90',
      category: 'Food',
      merchant: 'Tealive Bukit Bintang',
      description: 'Late night craving for bubble tea after class',
      location: 'Bukit Bintang',
    ),
    _SimulationTemplate(
      label: 'Shopping impulse',
      amount: '36.00',
      category: 'Shopping',
      merchant: 'MINISO',
      description: 'Impulse treat after spotting a cute desk item',
      location: 'Mid Valley',
    ),
    _SimulationTemplate(
      label: 'Transport overspend',
      amount: '28.50',
      category: 'Transport',
      merchant: 'Grab',
      description: 'Peak hour ride instead of train',
      location: 'KL Sentral',
    ),
    _SimulationTemplate(
      label: 'Food budget risk',
      amount: '24.00',
      category: 'Food',
      merchant: 'McDonald KLCC',
      description: 'Treat meal while already close to food budget',
      location: 'KLCC',
    ),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _previewPayment() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _stage = _SimulationStage.preview);
  }

  void _confirmPayment() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || _selectedCategory == null) return;

    final now = DateTime.now().toIso8601String();
    final normalizedCategory = _normalizeCategory(_selectedCategory!);
    final hasLocation = _locationController.text.trim().isNotEmpty;
    final coordinates = hasLocation ? _demoCoordinates : null;

    final transactionPayload = <String, dynamic>{
      'userId': widget.userId,
      'amount': amount,
      'category': normalizedCategory,
      'merchant': _merchantController.text.trim(),
      'description': _descriptionController.text.trim(),
      'userAction': 'confirm_payment',
      'lat': coordinates?.latitude,
      'lng': coordinates?.longitude,
    };

    final aiPayload = <String, dynamic>{
      'user_id': widget.userId,
      'daily_budget': widget.dailyBudget > 0 ? widget.dailyBudget : 30,
      'current_daily_spending':
          widget.currentDailySpending > 0 ? widget.currentDailySpending : 18,
      'savings_goal': widget.savingsGoal > 0 ? widget.savingsGoal : 500,
      'transactions': [
        {
          'transaction_id':
              'txn_${DateTime.now().microsecondsSinceEpoch.toString()}',
          'amount': amount,
          'category': normalizedCategory,
          'time': now,
          'location': _locationController.text.trim(),
          'merchant': _merchantController.text.trim(),
          'status': 'before_confirmation',
        }
      ],
      'user_action': {
        'actionType': 'confirm_payment',
        'timestamp': now,
        'interactionSource': 'simulation',
      },
    };

    Navigator.of(context).pop(
      _PaymentSimulationRequest(
        userId: widget.userId,
        amount: amount,
        categoryLabel: _selectedCategory!,
        normalizedCategory: normalizedCategory,
        merchant: _merchantController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        dailyBudget: widget.dailyBudget > 0 ? widget.dailyBudget : 30,
        currentDailySpending:
            widget.currentDailySpending > 0 ? widget.currentDailySpending : 18,
        savingsGoal: widget.savingsGoal > 0 ? widget.savingsGoal : 500,
        transactionPayload: transactionPayload,
        aiPayload: aiPayload,
      ),
    );
  }

  String _normalizeCategory(String category) {
    return category.toLowerCase().replaceAll('&', 'and').replaceAll(' ', '_');
  }

  void _applyTemplate(_SimulationTemplate template) {
    setState(() {
      _amountController.text = template.amount;
      _selectedCategory = template.category;
      _merchantController.text = template.merchant;
      _descriptionController.text = template.description;
      _locationController.text = template.location;
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final amount = double.tryParse(_amountController.text.trim());
    final merchantText = _merchantController.text.trim();
    final payeeLabel = merchantText.isNotEmpty
        ? merchantText
        : (_selectedCategory ?? 'merchant');

    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            media.width < 560 ? 12 : 20,
            12,
            media.width < 560 ? 12 : 20,
            16,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 640,
              maxHeight: media.height * 0.88,
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 26,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 5,
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: context.colors.muted,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      media.width < 560 ? 16 : 20,
                      14,
                      media.width < 560 ? 8 : 12,
                      0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Simulate Payment',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'A clean payment flow before ThinkTwice jumps in.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.colors.mutedForeground,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      media.width < 560 ? 16 : 20,
                      14,
                      media.width < 560 ? 16 : 20,
                      12,
                    ),
                    child: _StepStrip(stage: _stage),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        media.width < 560 ? 16 : 20,
                        4,
                        media.width < 560 ? 16 : 20,
                        media.width < 560 ? 20 : 28,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _quickTemplates
                                  .map(
                                    (template) => ActionChip(
                                      avatar: const Icon(
                                        Icons.flash_on_rounded,
                                        size: 16,
                                      ),
                                      label: Text(template.label),
                                      onPressed: () => _applyTemplate(template),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                            if (_stage == _SimulationStage.entry) ...[
                        _fieldLabel('Amount (RM)'),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _inputDecoration('Enter payment amount'),
                          validator: (value) {
                            final parsed =
                                double.tryParse((value ?? '').trim());
                            if (parsed == null || parsed <= 0) {
                              return 'Amount is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _fieldLabel('Category'),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: _inputDecoration('Choose a category'),
                          items: const [
                            DropdownMenuItem(
                                value: 'Food', child: Text('Food')),
                            DropdownMenuItem(
                              value: 'Transport',
                              child: Text('Transport'),
                            ),
                            DropdownMenuItem(
                              value: 'Shopping',
                              child: Text('Shopping'),
                            ),
                            DropdownMenuItem(
                              value: 'Entertainment',
                              child: Text('Entertainment'),
                            ),
                            DropdownMenuItem(
                                value: 'Bills', child: Text('Bills')),
                            DropdownMenuItem(
                              value: 'Education',
                              child: Text('Education'),
                            ),
                            DropdownMenuItem(
                                value: 'Other', child: Text('Other')),
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedCategory = value),
                          validator: (value) =>
                              value == null ? 'Category is required' : null,
                        ),
                        const SizedBox(height: 12),
                        _fieldLabel('Merchant'),
                        TextFormField(
                          controller: _merchantController,
                          decoration:
                              _inputDecoration('Optional merchant name'),
                        ),
                        const SizedBox(height: 12),
                        _fieldLabel('Description'),
                        TextFormField(
                          controller: _descriptionController,
                          decoration:
                              _inputDecoration('Optional spending context'),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        _fieldLabel('Location / area'),
                        TextFormField(
                          controller: _locationController,
                          decoration: _inputDecoration('Optional area or mall'),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _previewPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text('Preview Payment'),
                          ),
                        ),
                            ],
                            if (_stage == _SimulationStage.preview) ...[
                        _PreviewCard(
                          amountLabel: amount != null
                              ? 'RM ${amount.toStringAsFixed(2)}'
                              : 'RM 0.00',
                          payeeLabel: payeeLabel,
                          category: _selectedCategory ?? 'Other',
                          description: _descriptionController.text.trim(),
                          location: _locationController.text.trim(),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _confirmPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text('Confirm Payment'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () =>
                                setState(() => _stage = _SimulationStage.entry),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE5EBE7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE5EBE7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: context.colors.primary, width: 1.5),
      ),
    );
  }
}

class _StepStrip extends StatelessWidget {
  const _StepStrip({required this.stage});

  final _SimulationStage stage;

  @override
  Widget build(BuildContext context) {
    final activeIndex = switch (stage) {
      _SimulationStage.entry => 0,
      _SimulationStage.preview => 1,
      _SimulationStage.analysing => 2,
      _SimulationStage.intervention => 2,
    };

    const labels = [
      'Enter payment',
      'Preview payment',
      'AI intervention',
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(labels.length, (index) {
        final isCompleted = index < activeIndex;
        final isCurrent = index == activeIndex;
        final isActive = index <= activeIndex;

        return Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: isActive ? context.colors.primaryGradient : null,
                        color: isActive ? null : const Color(0xFFF1EBDD),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCurrent
                              ? context.colors.primary.withOpacity(0.16)
                              : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: context.colors.primary.withOpacity(0.18),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: isCompleted
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: isActive
                                    ? Colors.white
                                    : context.colors.mutedForeground,
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      labels[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.3,
                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w700,
                        color: isActive
                            ? context.colors.foreground
                            : context.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              if (index < labels.length - 1)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        gradient: index < activeIndex
                            ? context.colors.primaryGradient
                            : null,
                        color: index < activeIndex
                            ? null
                            : const Color(0xFFEDE6D8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.amountLabel,
    required this.payeeLabel,
    required this.category,
    required this.description,
    required this.location,
  });

  final String amountLabel;
  final String payeeLabel;
  final String category;
  final String description;
  final String location;

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: context.colors.softMintGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'GXBank-style confirmation',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'You are about to pay $amountLabel to $payeeLabel.',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            'Category: $category',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: context.colors.mutedForeground,
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: context.colors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (location.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.place_rounded,
                    size: 14, color: context.colors.primary),
                const SizedBox(width: 6),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ThinkTwiceSimulationAlertDialog extends StatefulWidget {
  const _ThinkTwiceSimulationAlertDialog({
    required this.request,
    required this.breed,
    required this.accessory,
    required this.effect,
  });

  final _PaymentSimulationRequest request;
  final String breed;
  final String accessory;
  final String effect;

  @override
  State<_ThinkTwiceSimulationAlertDialog> createState() =>
      _ThinkTwiceSimulationAlertDialogState();
}

class _ThinkTwiceSimulationAlertDialogState
    extends State<_ThinkTwiceSimulationAlertDialog> {
  Map<String, dynamic>? _analysisResult;
  bool _loading = true;
  bool _submitting = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    try {
      final result =
          await AiService.analyzeRiskWithPayload(widget.request.aiPayload);
      if (!mounted) return;
      setState(() {
        _analysisResult = result;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _analysisResult = _buildSimulationFallbackAiResult(widget.request);
        _loading = false;
        _statusMessage = 'Using local fallback scoring for the demo.';
      });
    }
  }

  Future<void> _resolveContinue() async {
    if (_analysisResult == null || _submitting) return;
    setState(() => _submitting = true);

    double? newBalance;
    try {
      final result = await BackendApiService.postTransaction(
        userId: widget.request.userId,
        amount: widget.request.amount,
        category: widget.request.normalizedCategory,
        merchant: widget.request.merchant.isEmpty
            ? widget.request.categoryLabel
            : widget.request.merchant,
        description: widget.request.description.isEmpty
            ? null
            : widget.request.description,
      );
      newBalance = result.newBalance;
    } catch (_) {
      newBalance = null;
    }

    if (!mounted) return;
    Navigator.of(context).pop(
      _PaymentSimulationResolution(
        aiResult: _analysisResult!,
        bannerTitle: 'Payment completed.',
        bannerBody:
            'Payment completed, but ThinkTwice logged this as a risky decision.',
        bannerTone: 'warning',
        newBalance: newBalance,
        completedTransaction: TransactionRecord(
          id: 'sim_${DateTime.now().microsecondsSinceEpoch}',
          merchant: widget.request.merchant.isEmpty
              ? widget.request.categoryLabel
              : widget.request.merchant,
          amount: -widget.request.amount.abs(),
          icon: _iconForCategory(widget.request.normalizedCategory),
          timestampLabel: 'Just now',
          category: widget.request.categoryLabel,
        ),
      ),
    );
  }

  void _resolveSave() {
    if (_analysisResult == null || _submitting) return;
    Navigator.of(context).pop(
      _PaymentSimulationResolution(
        aiResult: _analysisResult!,
        bannerTitle: 'Nice choice - RM8 moved to your savings goal.',
        bannerBody: '+RM8 saved. +5 resilience score. Streak maintained.',
        bannerTone: 'success',
        savedInstead: true,
      ),
    );
  }

  void _resolveRadar() {
    if (_analysisResult == null || _submitting) return;
    Navigator.of(context).pop(
      _PaymentSimulationResolution(
        aiResult: _analysisResult!,
        bannerTitle: 'Smart Radar opened from ThinkTwice AI.',
        bannerBody:
            'Nearby alternatives are ready so the judge can compare cheaper options before paying.',
        bannerTone: 'primary',
        radarContext: {
          'amount': widget.request.amount,
          'category': widget.request.normalizedCategory,
          'merchant': widget.request.merchant,
          'description': widget.request.description,
          'location': widget.request.location,
          'lat': widget.request.transactionPayload['lat'],
          'lng': widget.request.transactionPayload['lng'],
          'source': 'payment_simulation',
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final compact = media.width < 560;
    final maxDialogHeight = media.height * 0.85;
    final visibility =
        _analysisResult?['aiVisibility'] as Map<String, dynamic>?;
    final reasons = (visibility?['bulletReasons'] as List<dynamic>? ??
            _analysisResult?['riskAnalysis']?['reasons'] as List<dynamic>? ??
            const <dynamic>[])
        .map((item) => item.toString())
        .toList();
    final riskLevel =
        _analysisResult?['riskAnalysis']?['riskLevel']?.toString() ?? 'low';
    final avatarMood = switch (riskLevel) {
      'high' => AvatarMood.sad,
      'medium' => AvatarMood.neutral,
      _ => AvatarMood.happy,
    };
    final demoDecision =
        _analysisResult?['demoDecision'] as Map<String, dynamic>?;

    final title = friendlyRiskTitle(riskLevel);

    final prediction = demoDecision?['futureImpact']?.toString() ??
        visibility?['predictionText']?.toString() ??
        friendlyRiskSummary(riskLevel);

    final recommendedAction = demoDecision?['recommendedAction']?.toString() ??
        'Save RM8 or find a cheaper nearby option.';

    final riskLabel = friendlyRiskBadge(riskLevel);

    final confidence = demoDecision?['confidence']?.toString() ??
        visibility?['confidenceText']?.toString() ??
        '${_analysisResult?['interventionConfidence'] ?? 0}%';

    final estimatedSavings =
        demoDecision?['estimatedSavings']?.toString() ?? 'RM8';

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 12 : 20,
              12,
              compact ? 12 : 20,
              compact ? 12 : 16,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 640,
                maxHeight: maxDialogHeight,
              ),
              child: Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.22),
                      blurRadius: 30,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _loading
                      ? Padding(
                          key: const ValueKey('loading'),
                          padding: EdgeInsets.all(compact ? 18 : 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              WalletGuardianPreview(
                                breed: widget.breed,
                                accessory: widget.accessory,
                                effect: widget.effect,
                                mood: AvatarMood.sad,
                                size: compact ? 84 : 96,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Checking this purchase for you...',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Looking for budget pressure, impulse spending, and smarter nearby options.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.45,
                                  color: context.colors.mutedForeground,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 18),
                              CircularProgressIndicator(
                                color: context.colors.primary,
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          key: const ValueKey('alert'),
                          padding: EdgeInsets.all(compact ? 16 : 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: WalletGuardianPreview(
                                  breed: widget.breed,
                                  accessory: widget.accessory,
                                  effect: widget.effect,
                                  mood: avatarMood,
                                  size: compact ? 84 : 96,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        context.colors.primary.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'ThinkTwice Support',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.6,
                                      color: context.colors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  height: 1.08,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                prediction,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  height: 1.4,
                                  color: context.colors.foreground,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _AlertMetricTile(
                                      label: 'Budget Impact',
                                      value: riskLabel,
                                      tone: riskLevel,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _AlertMetricTile(
                                      label: 'Confidence',
                                      value:
                                          confidence.toString().contains('%')
                                              ? confidence.toString()
                                              : '$confidence%',
                                      tone: riskLevel,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: context.colors.primaryGradient,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: context.colors.primary
                                          .withOpacity(0.22),
                                      blurRadius: 18,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Recommended Action',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      recommendedAction,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (reasons.isNotEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: context.colors.background,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .dividerColor
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Why this caught our attention',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...reasons.take(3).map(
                                            (reason) => Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 8,
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.circle,
                                                    size: 8,
                                                    color:
                                                        context.colors.primary,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      reason,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        height: 1.4,
                                                        color: context.colors
                                                            .mutedForeground,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                    ],
                                  ),
                                ),
                              if (_statusMessage != null) ...[
                                const SizedBox(height: 10),
                                Text(
                                  _statusMessage!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: context.colors.mutedForeground,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      _submitting ? null : _resolveContinue,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context.colors.foreground,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: const Text('Continue Anyway'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      _submitting ? null : _resolveSave,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context.colors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child:
                                      Text('Save $estimatedSavings Instead'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed:
                                      _submitting ? null : _resolveRadar,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: const Text('Find Cheaper Nearby'),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: Text(
                                  'Small savings today can become healthier habits tomorrow.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: context.colors.mutedForeground,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AlertMetricTile extends StatelessWidget {
  const _AlertMetricTile({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final String tone;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      'high' => context.colors.warning,
      'medium' => context.colors.accent,
      _ => context.colors.primary,
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

Map<String, dynamic> _buildSimulationFallbackAiResult(
  _PaymentSimulationRequest request,
) {
  final transaction = (request.aiPayload['transactions'] as List<dynamic>).first
      as Map<String, dynamic>;
  final amount = (transaction['amount'] as num).toDouble();
  final category = transaction['category'].toString();
  final description = request.description.toLowerCase();
  final currentDaily = request.currentDailySpending;
  final dailyBudget = request.dailyBudget;

  double riskScore = 18;
  final reasons = <String>[];

  if (amount > 15) {
    riskScore += 18;
    reasons.add('Amount is above the usual low-risk micro-spend range.');
  }

  if (const {'food', 'shopping', 'entertainment'}.contains(category)) {
    riskScore += 16;
    reasons.add(
      '${request.categoryLabel} often drives impulse spending for this demo profile.',
    );
  }

  if (RegExp(r'impulse|craving|treat|bubble tea|late night')
      .hasMatch(description)) {
    riskScore += 18;
    reasons.add('Description suggests an impulse or late-night purchase.');
  }

  if (currentDaily + amount > dailyBudget) {
    riskScore += 32;
    reasons.add(
      'This payment would push today\'s spending above the safe daily budget.',
    );
  }

  final riskLevel = riskScore >= 65
      ? 'high'
      : riskScore >= 38
          ? 'medium'
          : 'low';
  final confidence = riskLevel == 'high'
      ? 86
      : riskLevel == 'medium'
          ? 78
          : 68;
  final prediction = currentDaily + amount > dailyBudget
      ? 'Your spending is slightly higher than usual.'
      : riskLevel == 'high'
          ? 'Possible impulse spending detected.'
          : 'This purchase looks manageable.';
  final recommendedAction = riskLevel == 'low'
      ? 'Continue with awareness'
      : category == 'transport'
          ? 'Find cheaper nearby'
          : 'Save RM8 Instead';
  final shouldTriggerRadar = riskLevel != 'low' &&
      const {'food', 'shopping', 'transport'}.contains(category);

  return {
    'userId': request.userId,
    'fallbackUsed': true,
    'riskAnalysis': {
      'riskLevel': riskLevel,
      'riskScore': riskScore.round(),
      'reasons': reasons,
    },
    'scoreAnalysis': {
      'resilienceScore': riskLevel == 'high'
          ? 44
          : riskLevel == 'medium'
              ? 57
              : 71,
      'smartDecisionScore': riskLevel == 'high'
          ? 41
          : riskLevel == 'medium'
              ? 55
              : 68,
    },
    'spendingVelocityAnalysis': {
      'overspendingPrediction': {'prediction': prediction},
    },
    'intervention': {
      'finalAction': recommendedAction.toLowerCase().replaceAll(' ', '_'),
      'recommendedButtonText': recommendedAction,
    },
    'integrationPayload': {
      'smartRadar': {
        'triggerSmartRadar': shouldTriggerRadar,
        'radarCategory': category,
        'radarMessage':
            'ThinkTwice spotted cheaper ${category.toLowerCase()} alternatives nearby.',
      },
    },
    'interventionConfidence': confidence,
    'behaviourSeverityScore': riskScore.round(),
    'aiVisibility': {
      'riskLabel': friendlyRiskTitle(riskLevel),
      'summary': riskLevel == 'high'
          ? 'Possible impulse spending detected.'
          : riskLevel == 'medium'
              ? 'Your spending is slightly higher than usual.'
              : 'This purchase looks manageable.',
      'bulletReasons': reasons,
      'predictionText': prediction,
      'recommendedActionText': recommendedAction,
      'confidenceText': '$confidence%',
      'severityScoreText': '${riskScore.round()}/100',
    },
    'transactionPayload': request.transactionPayload,
  };
}

class _SimulationTemplate {
  const _SimulationTemplate({
    required this.label,
    required this.amount,
    required this.category,
    required this.merchant,
    required this.description,
    required this.location,
  });

  final String label;
  final String amount;
  final String category;
  final String merchant;
  final String description;
  final String location;
}

IconData _iconForCategory(String category) {
  switch (category) {
    case 'food':
      return Icons.restaurant_rounded;
    case 'transport':
      return Icons.directions_car_rounded;
    case 'shopping':
      return Icons.shopping_bag_rounded;
    case 'entertainment':
      return Icons.movie_rounded;
    case 'bills':
      return Icons.receipt_long_rounded;
    case 'education':
      return Icons.school_rounded;
    default:
      return Icons.payments_rounded;
  }
}
