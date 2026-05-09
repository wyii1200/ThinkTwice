import 'dart:convert';
import 'package:http/http.dart' as http;

const String _backendUrl = 'http://localhost:3000';

class UserProfile {
  final String userId;
  final double dailyBudget;
  final double savingsGoal;
  final int resilienceScore;
  final double savingsPocket;
  final int streak;
  final int smartDecisionScore;
  final int totalPoints;
  final String displayName;

  const UserProfile({
    required this.userId,
    required this.dailyBudget,
    required this.savingsGoal,
    required this.resilienceScore,
    required this.savingsPocket,
    required this.streak,
    required this.smartDecisionScore,
    required this.totalPoints,
    required this.displayName,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId:             json['userId']             as String? ?? '',
      dailyBudget:        (json['dailyBudget']        as num?)?.toDouble() ?? 50,
      savingsGoal:        (json['savingsGoal']        as num?)?.toDouble() ?? 500,
      resilienceScore:    (json['resilienceScore']    as num?)?.toInt()    ?? 50,
      savingsPocket:      (json['savingsPocket']      as num?)?.toDouble() ?? 0,
      streak:             (json['streak']             as num?)?.toInt()    ?? 0,
      smartDecisionScore: (json['smartDecisionScore'] as num?)?.toInt()    ?? 0,
      totalPoints:        (json['totalPoints']        as num?)?.toInt()    ?? 0,
      displayName:        json['displayName']         as String? ?? 'Friend',
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
  });

  factory AiNudge.fromJson(Map<String, dynamic> json) {
    return AiNudge(
      riskLevel:        json['riskLevel']        as String? ?? 'low',
      nudgeText:        json['nudgeText']        as String?,
      suggestedAction:  json['suggestedAction']  as String?,
      saveAmount:       (json['saveAmount']      as num?)?.toDouble() ?? 0,
      triggerSmartRadar: json['triggerSmartRadar'] as bool? ?? false,
      radarCategory:    json['radarCategory']    as String?,
      radarMessage:     json['radarMessage']     as String?,
      aiExplanation:    List<String>.from(json['aiExplanation'] as List? ?? []),
      severityLevel:    json['severityLevel']    as String? ?? 'low',
    );
  }
}

class BackendApiService {
  static final _client = http.Client();

  static Future<void> setupUser({
    required String userId,
    double dailyBudget = 50,
    double savingsGoal = 500,
    String? fcmToken,
  }) async {
    final uri = Uri.parse('$_backendUrl/users/setup');
    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId':      userId,
        'dailyBudget': dailyBudget,
        'savingsGoal': savingsGoal,
        if (fcmToken != null) 'fcmToken': fcmToken,
      }),
    ).timeout(const Duration(seconds: 10));

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) throw Exception(body['error'] ?? 'User setup failed');
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
    if (body['success'] != true) throw Exception(body['error'] ?? 'Failed to fetch profile');

    return UserProfile.fromJson(body['profile'] as Map<String, dynamic>);
  }

  static Future<Map<String, dynamic>> getDashboard(String userId) async {
    final uri = Uri.parse('$_backendUrl/dashboard/$userId');
    final res = await _client.get(uri).timeout(const Duration(seconds: 10));

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) throw Exception(body['error'] ?? 'Failed to fetch dashboard');

    return body['dashboard'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getGamification(String userId) async {
    final uri = Uri.parse('$_backendUrl/gamification/$userId');
    final res = await _client.get(uri).timeout(const Duration(seconds: 10));

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) throw Exception(body['error'] ?? 'Failed to fetch gamification');

    return body['gamification'] as Map<String, dynamic>;
  }

  static Future<AiNudge> postTransaction({
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
        'userId':   userId,
        'amount':   amount,
        'category': category,
        'merchant': merchant,
        if (description != null) 'description': description,
      }),
    ).timeout(const Duration(seconds: 15));

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) throw Exception(body['error'] ?? 'Transaction failed');

    return AiNudge.fromJson(body['aiResult'] as Map<String, dynamic>);
  }

  static Future<List<Map<String, dynamic>>> getTransactions(
    String userId, {
    int limit = 20,
  }) async {
    final uri = Uri.parse('$_backendUrl/transactions/$userId?limit=$limit');
    final res = await _client.get(uri).timeout(const Duration(seconds: 10));

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) throw Exception(body['error'] ?? 'Failed to fetch transactions');

    return List<Map<String, dynamic>>.from(body['transactions'] as List? ?? []);
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
    if (body['success'] != true) throw Exception(body['error'] ?? 'Auto save failed');

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
        'userId':  userId,
        'nudgeId': nudgeId,
        'action':  action,
      }),
    ).timeout(const Duration(seconds: 10));
  }

  static Future<int> claimQuest({
    required String userId,
    required String questId,
  }) async {
    final uri = Uri.parse('$_backendUrl/gamification/claim-quest');
    final res = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'questId': questId}),
    ).timeout(const Duration(seconds: 10));

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) throw Exception(body['error'] ?? 'Failed to claim quest');

    return (body['pointsAwarded'] as num?)?.toInt() ?? 0;
  }
}