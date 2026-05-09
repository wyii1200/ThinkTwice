import 'dart:convert';
import 'package:http/http.dart' as http;

const String _backendUrl = 'http://localhost:3000';

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
  }) async {
    final uri = Uri.parse('$_backendUrl/users/setup');
    final res = await _client.post(
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
      }),
    ).timeout(const Duration(seconds: 10));

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['error'] ?? 'User setup failed');
    }
  }

  static Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    final uri = Uri.parse('$_backendUrl/users/$userId');
    final res = await _client.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updates),
    ).timeout(const Duration(seconds: 10));

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
    await _client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'fcmToken': fcmToken}),
    ).timeout(const Duration(seconds: 10));
  }

  static Future<UserProfile> getUserProfile(String userId) async {
    final uri = Uri.parse('$_backendUrl/users/$userId');
    final res = await _client.get(uri).timeout(const Duration(seconds: 10));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['error'] ?? 'Failed to fetch profile');
    }
    return UserProfile.fromJson(body['profile'] as Map<String, dynamic>);
  }

  static Future<({AiNudge nudge, double? newBalance})> postTransaction({
    required String userId,
    required double amount,
    required String category,
    required String merchant,
    String? description,
  }) async {
    final uri = Uri.parse('$_backendUrl/webhook/transaction');
    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'amount': amount,
        'category': category,
        'merchant': merchant,
        if (description != null) 'description': description,
      }),
    ).timeout(const Duration(seconds: 15));

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['error'] ?? 'Transaction failed');
    }
    return (
      nudge: AiNudge.fromJson(body['aiResult'] as Map<String, dynamic>),
      newBalance: (body['newBalance'] as num?)?.toDouble(),
    );
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

  static Future<List<Map<String, dynamic>>> getNudgeHistory(String userId) async {
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
    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'amount': amount,
        if (nudgeId != null) 'nudgeId': nudgeId,
      }),
    ).timeout(const Duration(seconds: 10));

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
    await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        if (nudgeId != null) 'nudgeId': nudgeId,
      }),
    ).timeout(const Duration(seconds: 10));
  }

  static Future<void> sendNudgeResponse({
    required String userId,
    required String nudgeId,
    required String action,
  }) async {
    final uri = Uri.parse('$_backendUrl/nudge/response');
    await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'nudgeId': nudgeId,
        'action': action,
      }),
    ).timeout(const Duration(seconds: 10));
  }
}