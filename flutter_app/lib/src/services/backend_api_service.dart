import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../core/models.dart';

const String _backendUrl = 'https://us-central1-thinktwice-kamihack.cloudfunctions.net/api';

class UserProfile {
  final String userId;
  final String displayName;
  final double dailyBudget;
  final double savingsGoal;
  final int resilienceScore;
  final double savingsPocket;
  final double currentBalance;
  final int streak;
  final int smartDecisionScore;

  final String breed;
  final String expression;
  final String accessory;
  final String effect;

  const UserProfile({
    required this.userId,
    this.displayName = '',
    required this.dailyBudget,
    required this.savingsGoal,
    required this.resilienceScore,
    required this.savingsPocket,
    required this.currentBalance,
    required this.streak,
    required this.smartDecisionScore,
    this.breed = 'siamese',
    this.expression = 'proud',
    this.accessory = 'none',
    this.effect = 'none',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      dailyBudget: (json['dailyBudget'] as num?)?.toDouble() ?? 50,
      savingsGoal: (json['savingsGoal'] as num?)?.toDouble() ?? 500,
      resilienceScore: (json['resilienceScore'] as num?)?.toInt() ?? 50,
      savingsPocket: (json['savingsPocket'] as num?)?.toDouble() ?? 0,
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      smartDecisionScore: (json['smartDecisionScore'] as num?)?.toInt() ?? 50,
      breed: json['breed'] as String? ?? 'siamese',
      expression: json['expression'] as String? ?? 'proud',
      accessory: json['accessory'] as String? ?? 'none',
      effect: json['effect'] as String? ?? 'none',
    );
  }
}

class AiNudge {
  final String riskLevel;
  final String? nudgeText;
  final String? suggestedAction;
  final double saveAmount;
  final bool triggerSmartRadar;
  final String? radarCategory;
  final String? radarMessage;
  final List<String> aiExplanation;
  final String severityLevel;
  final int resilienceImpact;

  const AiNudge({
    required this.riskLevel,
    this.nudgeText,
    this.suggestedAction,
    required this.saveAmount,
    required this.triggerSmartRadar,
    this.radarCategory,
    this.radarMessage,
    required this.aiExplanation,
    required this.severityLevel,
    required this.resilienceImpact,
  });

  factory AiNudge.fromJson(Map<String, dynamic> json) {
    return AiNudge(
      riskLevel: json['riskLevel'] as String? ?? 'low',
      nudgeText: json['nudgeText'] as String?,
      suggestedAction: json['suggestedAction'] as String?,
      saveAmount: (json['saveAmount'] as num?)?.toDouble() ?? 0,
      triggerSmartRadar: json['triggerSmartRadar'] as bool? ?? false,
      radarCategory: json['radarCategory'] as String?,
      radarMessage: json['radarMessage'] as String?,
      aiExplanation: List<String>.from(json['aiExplanation'] as List? ?? []),
      severityLevel: json['severityLevel'] as String? ?? 'low',
      resilienceImpact: (json['resilienceImpact'] as num?)?.toInt() ?? 0,
    );
  }
}

class UserNotFoundException implements Exception {
  final String message;
  UserNotFoundException(this.message);
  @override
  String toString() => 'UserNotFoundException: $message';
}

class BackendApiService {
  static final _client = http.Client();

  static Future<void> setupUser({
    required String userId,
    required double dailyBudget,
    required double savingsGoal,
    required String displayName,
    String? fcmToken,
    String? breed,
    String? expression,
    String? accessory,
    String? effect,
    required Map<String, double> categoryPercents,
    required List<int> yesAnswers,
    required int adaptabilityScore,
    required double savingsRate,
    required double flexibleSpend,
  }) async {
    final uri = Uri.parse('$_backendUrl/users/setup');
    final res = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': userId,
            'dailyBudget': dailyBudget,
            'savingsGoal': savingsGoal,
            'displayName': displayName,
            if (fcmToken != null) 'fcmToken': fcmToken,
            if (breed != null) 'breed': breed,
            if (expression != null) 'expression': expression,
            if (accessory != null) 'accessory': accessory,
            if (effect != null) 'effect': effect,
            'categoryPercents': categoryPercents,
            'yesAnswers': yesAnswers,
            'adaptabilityScore': adaptabilityScore,
            'savingsRate': savingsRate,
            'flexibleSpend': flexibleSpend,
          }),
        )
        .timeout(const Duration(seconds: 10));

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['error'] ?? 'User setup failed');
    }
  }

  static Future<void> updateUserProfile(
      String userId, Map<String, dynamic> updates) async {
    final uri = Uri.parse('$_backendUrl/users/$userId');
    final res = await _client
        .patch(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(updates),
        )
        .timeout(const Duration(seconds: 10));

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['error'] ?? 'Failed to update profile');
    }
  }

  static Future<void> updateFcmToken({
    required String userId,
    required String fcmToken,
  }) async {
    final uri = Uri.parse('$_backendUrl/users/$userId/fcm-token');
    await _client
        .put(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'fcmToken': fcmToken}),
        )
        .timeout(const Duration(seconds: 10));
  }

  static Future<UserProfile> getUserProfile(String userId) async {
    final uri = Uri.parse('$_backendUrl/users/$userId');
    final res = await _client.get(uri).timeout(const Duration(seconds: 10));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 404 || body['error'] == 'User not found') {
      throw UserNotFoundException(body['error'] ?? 'User not found');
    }
    if (body['success'] != true) {
      throw Exception(body['error'] ?? 'Failed to fetch profile');
    }
    return UserProfile.fromJson(body['profile'] as Map<String, dynamic>);
  }

  static Future<
          ({AiNudge nudge, double? newBalance, Map<String, dynamic> aiResult})>
      postTransaction({
    required String userId,
    required double amount,
    required String category,
    required String merchant,
    String? description,
  }) async {
    final uri = Uri.parse('$_backendUrl/webhook/transaction');
    final res = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': userId,
            'amount': amount,
            'category': category,
            'merchant': merchant,
            if (description != null) 'description': description,
          }),
        )
        .timeout(const Duration(seconds: 15));

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['error'] ?? 'Transaction failed');
    }
    final aiResult = body['aiResult'] as Map<String, dynamic>;

    final fullAiResult = aiResult['fullAiResult'] is Map<String, dynamic>
        ? aiResult['fullAiResult'] as Map<String, dynamic>
        : aiResult;

    return (
      nudge: AiNudge.fromJson(aiResult),
      newBalance: (body['newBalance'] as num?)?.toDouble(),
      aiResult: fullAiResult,
    );
  }

  static Future<double> confirmTransaction({
    required String userId,
    required double amount,
    required String category,
    required String merchant,
    String? description,
  }) async {
    final uri = Uri.parse('$_backendUrl/webhook/transaction/confirm');
    final res = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': userId,
            'amount': amount,
            'category': category,
            'merchant': merchant,
            if (description != null) 'description': description,
          }),
        )
        .timeout(const Duration(seconds: 15));

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['error'] ?? 'Confirm transaction failed');
    }
    
    return (body['newBalance'] as num).toDouble();
  }

  static Future<List<Map<String, dynamic>>> getTransactions(
    String userId, {
    int limit = 20,
  }) async {
    final uri = Uri.parse('$_backendUrl/transactions/$userId?limit=$limit');
    final res = await _client.get(uri).timeout(const Duration(seconds: 10));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['error'] ?? 'Failed to fetch transactions');
    }
    return List<Map<String, dynamic>>.from(body['transactions'] as List? ?? []);
  }

  static Future<List<Map<String, dynamic>>> getNudgeHistory(
      String userId) async {
    final uri = Uri.parse('$_backendUrl/nudge/history/$userId');
    final res = await _client.get(uri).timeout(const Duration(seconds: 10));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) return [];
    return List<Map<String, dynamic>>.from(body['nudges'] as List? ?? []);
  }

  static Future<Map<String, dynamic>> approveAutoSave({
    required String userId,
    required double amount,
    String? nudgeId,
  }) async {
    final uri = Uri.parse('$_backendUrl/autosave/approve');
    final res = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': userId,
            'amount': amount,
            if (nudgeId != null) 'nudgeId': nudgeId,
          }),
        )
        .timeout(const Duration(seconds: 10));

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['error'] ?? 'Auto save failed');
    }
    return body;
  }

  static Future<void> rejectAutoSave({
    required String userId,
    String? nudgeId,
  }) async {
    final uri = Uri.parse('$_backendUrl/autosave/reject');
    await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': userId,
            if (nudgeId != null) 'nudgeId': nudgeId,
          }),
        )
        .timeout(const Duration(seconds: 10));
  }

  static Future<void> sendNudgeResponse({
    required String userId,
    required String nudgeId,
    required String action,
  }) async {
    final uri = Uri.parse('$_backendUrl/nudge/response');
    await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': userId,
            'nudgeId': nudgeId,
            'action': action,
          }),
        )
        .timeout(const Duration(seconds: 10));
  }

  static Future<GamificationData> getGamificationData(String userId) async {
    final uri = Uri.parse('$_backendUrl/gamification/$userId');
    final res = await _client.get(uri).timeout(const Duration(seconds: 10));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['error'] ?? 'Failed to fetch gamification data');
    }
    return GamificationData.fromJson(body['gamification'] as Map<String, dynamic>);
  }

  static Future<void> claimQuest(String userId, String questId) async {
    final uri = Uri.parse('$_backendUrl/gamification/claim-quest');
    final res = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': userId,
            'questId': questId,
          }),
        )
        .timeout(const Duration(seconds: 10));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['error'] ?? 'Failed to claim quest');
    }
  }

  static Future<void> awardPoints(String userId, int points, String reason) async {
    final uri = Uri.parse('$_backendUrl/gamification/award-points');
    final res = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': userId,
            'points': points,
            'reason': reason,
          }),
        )
        .timeout(const Duration(seconds: 10));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['error'] ?? 'Failed to award points');
    }
  }
}

class LeaderboardItem {
  final int rank;
  final String userId;
  final String displayName;
  final int totalPoints;
  final int smartSpendingStreak;
  final String avatarId;
  final bool isCurrentUser;
  final String breed;
  final String accessory;
  final String effect;

  const LeaderboardItem({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.totalPoints,
    required this.smartSpendingStreak,
    required this.avatarId,
    required this.isCurrentUser,
    required this.breed,
    required this.accessory,
    required this.effect,
  });

  factory LeaderboardItem.fromJson(Map<String, dynamic> json) {
    return LeaderboardItem(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      userId: json['userId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'Player',
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
      smartSpendingStreak: (json['smartSpendingStreak'] as num?)?.toInt() ?? 0,
      avatarId: json['avatarId'] as String? ?? 'default',
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
      breed: json['breed'] as String? ?? 'siamese',
      accessory: json['accessory'] as String? ?? 'none',
      effect: json['effect'] as String? ?? 'none',
    );
  }
}

class GamificationData {
  final int totalPoints;
  final int level;
  final String levelLabel;
  final double levelProgress;
  final int pointsToNextLevel;
  final List<LeaderboardItem> leaderboard;
  final List<QuestProgress> quests;
  final List<String> unlockedAvatars;
  final List<PointsEvent> recentPointsEvents;

  const GamificationData({
    required this.totalPoints,
    required this.level,
    required this.levelLabel,
    required this.levelProgress,
    required this.pointsToNextLevel,
    required this.leaderboard,
    required this.quests,
    required this.unlockedAvatars,
    required this.recentPointsEvents,
  });

  factory GamificationData.fromJson(Map<String, dynamic> json) {
    final questsList = (json['quests'] as List? ?? [])
        .map((q) {
          final id = q['id'] as String? ?? '';
          final title = q['title'] as String? ?? '';
          final progress = (q['progress'] as num?)?.toDouble() ?? 0.0;
          final progressLabel = q['progressLabel'] as String? ?? '';
          final rewardLabel = q['rewardLabel'] as String? ?? '';
          final rewardPoints = (q['rewardPoints'] as num?)?.toInt() ?? 0;
          final isCompleted = q['isCompleted'] as bool? ?? false;
          final isClaimed = q['isClaimed'] as bool? ?? false;
          return QuestProgress(
            id: id,
            title: title,
            progress: progress,
            progressLabel: progressLabel,
            rewardLabel: rewardLabel,
            rewardPoints: rewardPoints,
            isCompleted: isCompleted,
            isClaimed: isClaimed,
          );
        })
        .toList();

    final leaderboardList = (json['leaderboard'] as List? ?? [])
        .map((l) => LeaderboardItem.fromJson(l as Map<String, dynamic>))
        .toList();

    final recentEventsList = (json['recentPointsEvents'] as List? ?? [])
        .map((e) {
          final iconStr = e['icon'] as String?;
          IconData iconData = Icons.star_rounded;
          if (iconStr == 'savings_outlined') iconData = Icons.savings_outlined;
          if (iconStr == 'emoji_events_rounded') iconData = Icons.emoji_events_rounded;
          if (iconStr == 'auto_awesome_rounded') iconData = Icons.auto_awesome_rounded;
          if (iconStr == 'map_rounded') iconData = Icons.map_rounded;
          if (iconStr == 'thumb_up_rounded') iconData = Icons.thumb_up_rounded;
          
          return PointsEvent(
            label: e['label'] as String? ?? 'Earned points',
            points: (e['points'] as num?)?.toInt() ?? 0,
            icon: iconData,
          );
        })
        .toList();

    return GamificationData(
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      levelLabel: json['levelLabel'] as String? ?? 'Beginner',
      levelProgress: (json['levelProgress'] as num?)?.toDouble() ?? 0.0,
      pointsToNextLevel: (json['pointsToNextLevel'] as num?)?.toInt() ?? 200,
      leaderboard: leaderboardList,
      quests: questsList,
      unlockedAvatars: List<String>.from(json['unlockedAvatars'] as List? ?? ['default']),
      recentPointsEvents: recentEventsList,
    );
  }
}
