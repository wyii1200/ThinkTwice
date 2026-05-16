import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Import your radar service to access RouteResult for the analyzeRouteWorth method
import '../services/radar_api_service.dart'; 

class AiService {
  static String get baseUrl {
    // Force the app to use your live AI orchestrator so it works anywhere
    return 'https://thinktwice-guq9.onrender.com';
    
    // TIP: If you need to test locally again, uncomment this block:
    /*
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
    */
  }


  /// Analyzes a generated route and returns a 1-sentence verdict
  static Future<String> analyzeRouteWorth(RouteResult route) async {
    try {
      final url = Uri.parse('$baseUrl/analyze-route');
      
      final payload = {
        'distanceKm': route.totalDistanceKm,
        'travelCostRM': route.savings.travelCostRM,
        'grossSavingRM': route.savings.grossSavingRM,
        'netSavingRM': route.savings.netSavingRM,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10)); 

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['verdict'] ?? 'AI recommends this route!'; 
      }
      return 'Smart Route ready. Net savings: RM ${route.savings.netSavingRM.toStringAsFixed(2)}';
    } catch (e) {
      debugPrint('AI Route Analysis Error: $e');
      return 'Smart Route ready. Net savings: RM ${route.savings.netSavingRM.toStringAsFixed(2)}';
    }
  }


  static Future<Map<String, dynamic>> analyzeRisk() async {
    return analyzeRiskWithPayload(highRiskDemoPayload());
  }

  static Future<Map<String, dynamic>> analyzeRiskWithPayload(
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl/analyze-risk');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      throw Exception(
        'AI request failed with status ${response.statusCode}: ${response.body}',
      );
    } catch (e) {
      throw Exception(
        'Unable to connect to AI service at $baseUrl. Error: $e',
      );
    }
  }
  
  // ─── Demo Payloads ──────────────────────────────────────────────────────

  static Map<String, dynamic> highRiskDemoPayload() {
    return {
      "user_id": "user_high_001",
      "daily_budget": 50,
      "current_daily_spending": 80,
      "savings_goal": 500,
      "transactions": [
        {
          "transaction_id": "txn_high_001",
          "amount": 12,
          "category": "food",
          "time": "10:45 PM",
          "location": "Mid Valley"
        },
        {
          "transaction_id": "txn_high_002",
          "amount": 18,
          "category": "food",
          "time": "8:30 PM",
          "location": "Cafe"
        },
        {
          "transaction_id": "txn_high_003",
          "amount": 20,
          "category": "food",
          "time": "7:15 PM",
          "location": "Restaurant"
        },
        {
          "transaction_id": "txn_high_004",
          "amount": 10,
          "category": "transport",
          "time": "3:00 PM",
          "location": "LRT"
        },
        {
          "transaction_id": "txn_high_005",
          "amount": 20,
          "category": "shopping",
          "time": "10:30 PM",
          "location": "Mall"
        }
      ],
      "user_action": {
        "actionType": "opened_smart_radar",
        "timestamp": DateTime.now().toIso8601String(),
        "interactionSource": "demo_button"
      }
    };
  }

  // ─── Data Extraction Helpers ────────────────────────────────────────────

  static List<String> extractInsightTexts(Map<String, dynamic> aiResult) {
    final explanation = aiResult['aiExplanation'];
    if (explanation is List) {
      return explanation.map((item) => item.toString()).toList();
    }
    return [];
  }

  static String extractRiskLevel(Map<String, dynamic> aiResult) {
    return aiResult['riskAnalysis']?['riskLevel']?.toString() ?? 'low';
  }

  static String extractPrediction(Map<String, dynamic> aiResult) {
    return aiResult['spendingVelocityAnalysis']?['overspendingPrediction']
                ?['prediction']
            ?.toString() ??
        'AI is monitoring your spending behaviour.';
  }

  static String extractDashboardInsight(Map<String, dynamic> aiResult) {
    return aiResult['intervention']?['dashboardInsight']?.toString() ??
        aiResult['llmCoaching']?['dashboardInsight']?.toString() ??
        'ThinkTwice is analysing your financial habits.';
  }

  static String extractCoachingMessage(Map<String, dynamic> aiResult) {
    return aiResult['intervention']?['llmEnhancedNudge']?.toString() ??
        aiResult['llmCoaching']?['coachingMessage']?.toString() ??
        aiResult['intervention']?['nudge']?.toString() ??
        'Keep tracking your spending habits.';
  }

  static int extractResilienceScore(Map<String, dynamic> aiResult) {
    return aiResult['scoreAnalysis']?['resilienceScore'] ?? 50;
  }

  static int extractSmartDecisionScore(Map<String, dynamic> aiResult) {
    return aiResult['scoreAnalysis']?['smartDecisionScore'] ?? 50;
  }

  static bool shouldTriggerSmartRadar(Map<String, dynamic> aiResult) {
    return aiResult['integrationPayload']?['smartRadar']
            ?['triggerSmartRadar'] ==
        true;
  }

  static String extractRadarCategory(Map<String, dynamic> aiResult) {
    return aiResult['integrationPayload']?['smartRadar']?['radarCategory']
            ?.toString() ??
        '';
  }
}
