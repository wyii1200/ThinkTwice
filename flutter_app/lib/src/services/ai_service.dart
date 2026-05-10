import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiService {
  static String get baseUrl {
    // Flutter Web
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    // Android Emulator
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }

    // Windows / macOS / iOS Simulator
    return 'http://127.0.0.1:8000';
  }

  static Future<Map<String, dynamic>> analyzeRisk() async {
    final url = Uri.parse('$baseUrl/analyze-risk');

    final body = {
      "user_id": "user_high_001",
      "daily_budget": 50,
      "current_daily_spending": 80,
      "savings_goal": 300,
      "transactions": [
        {
          "amount": 20,
          "category": "food",
          "time": "23:10",
          "location": "Mid Valley"
        },
        {
          "amount": 15,
          "category": "food",
          "time": "22:45",
          "location": "Mid Valley"
        },
        {
          "amount": 15,
          "category": "food",
          "time": "21:50",
          "location": "Mid Valley"
        },
        {
          "amount": 10,
          "category": "transport",
          "time": "20:30",
          "location": "KL"
        },
        {
          "amount": 20,
          "category": "shopping",
          "time": "19:00",
          "location": "KL"
        }
      ],
      "user_action": {
        "actionType": "opened_smart_radar",
        "timestamp": DateTime.now().toIso8601String(),
        "interactionSource": "demo_button"
      }
    };

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
}
