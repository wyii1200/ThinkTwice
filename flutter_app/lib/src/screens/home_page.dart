import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/models.dart';
import '../core/seed_data.dart';
import '../widgets/shared.dart';
import '../services/backend_api_service.dart';
import '../services/ai_service.dart';
import '../widgets/ai_analysis_card.dart';

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
  bool isLoadingAi = false;
  int? demoResilienceScore;
  int? demoSmartDecisionScore;

  Future<void> simulateAiTransaction() async {
    setState(() {
      isLoadingAi = true;
    });

    try {
      final result = await AiService.analyzeRisk();

      setState(() {
        aiResult = result;
        demoResilienceScore = result['scoreAnalysis']['resilienceScore'];
        demoSmartDecisionScore = result['scoreAnalysis']['smartDecisionScore'];
        isLoadingAi = false;
      });

      final smartRadar =
          result['integrationPayload']['smartRadar']['triggerSmartRadar'];
      final radarCategory =
          result['integrationPayload']['smartRadar']['radarCategory'];

      if (smartRadar == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 6),
            content: Text(
              'Smart Radar triggered for $radarCategory savings. Opening shortly...',
            ),
          ),
        );

        Future.delayed(const Duration(seconds: 8), () {
          if (mounted) {
            widget.onNavigate(1);
          }
        });
      }
    } catch (e) {
      setState(() {
        isLoadingAi = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI error: $e')),
      );
    }
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
    final transactions = widget.transactions;
    final breed = widget.breed;
    final accessory = widget.accessory;
    final effect = widget.effect;
    final showAlert = widget.showAlert;
    final onSaveAlert = widget.onSaveAlert;
    final onOpenAlternatives = widget.onOpenAlternatives;
    final onDismissAlert = widget.onDismissAlert;
    final onNavigate = widget.onNavigate;
    final userName = widget.userName;
    final balance = widget.balance;
    final savingsPocket = widget.savingsPocket;
    final aiInsights = widget.aiInsights;
    final lastNudgeText = widget.lastNudgeText;
    final lastRiskLevel = widget.lastRiskLevel;
    final userId = widget.userId;
    final onAiNudge = widget.onAiNudge;
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
                  IconButton(
                    onPressed: () async {
                      final result = await BackendApiService.postTransaction(
                        userId: userId,
                        amount: 45,
                        category: 'food',
                        merchant: 'McDonald KLCC',
                        description: 'Late night supper',
                      );
                      onAiNudge(result.nudge, result.newBalance);
                    },
                    icon: Icon(Icons.refresh_rounded,
                        color: context.colors.mutedForeground),
                    tooltip: 'Simulate transaction',
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
                                  label: 'Resilience',
                                  value: '$resilienceScore',
                                  glowColor: const Color(0xFF92F0D5),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _heroMiniCard(
                                  icon: Icons.local_fire_department_rounded,
                                  label: 'Current streak',
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
                                  label: 'Smart score',
                                  value: '$smartDecisionScore',
                                  glowColor: const Color(0xFFC7F7E9),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _heroMiniCard(
                                  icon: Icons.savings_rounded,
                                  label: 'Savings goal',
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
                                Text('Cat Companion',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color:
                                            context.colors.accentForeground)),
                                const SizedBox(height: 4),
                                const Text(
                                    'Your collectible cat is watching your spending vibe.',
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
                                                : 'Gentle idle loop',
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
                                          ? 'It is glowing because your saving habits just leveled up.'
                                          : overspendingRisk
                                              ? 'Its face is warning you softly before the streak breaks.'
                                              : 'It is calm, alert, and ready to celebrate your next good call.',
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
                                                ? 'Comforted'
                                                : 'Observing'),
                                        _guardianChip(
                                            context,
                                            Icons.inventory_2_rounded,
                                            '${nextLevelPoints - pointsIntoLevel} pts to next unlock'),
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
                                context, 'Total points', '$totalPoints pts'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: progressStat(context, 'Next level',
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
              StaggeredReveal(
                index: 2,
                child: WhiteCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Live AI Demo',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Simulate a late-night food transaction and let ThinkTwice analyse the risk.',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.mutedForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoadingAi ? null : simulateAiTransaction,
                          icon: Icon(
                            isLoadingAi
                                ? Icons.hourglass_top_rounded
                                : Icons.auto_awesome_rounded,
                          ),
                          label: Text(
                            isLoadingAi
                                ? 'AI analysing...'
                                : 'Simulate RM80 Food Spending',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
              sectionHeader(context, 'AI Insights',
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
                        (2, 'You', totalPoints, true, breed, accessory, effect),
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
