import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

//testing with local server
const String _baseUrl = 'http://localhost:4000';

//const String _baseUrl = 'https://thinktwice-zu5d.onrender.com';
// ─── Response models ──────────────────────────────────────────────────────────

  //final String submittedBy;

class ApiDeal {
  final String dealId;
  final String title;
  final String storeName;
  final String category;
  final double price;
  final double originalPrice;
  final double lat;
  final double lng;
  final String address;
  final String? imageUrl;
  final String submittedBy;
  final int trustScore;
  final int upvotes;
  final int downvotes;
  final bool verified;
  final bool hidden;
  final String createdAt;
  final String? expiresAt;
  final String? description;
  


  const ApiDeal({
    required this.dealId,
    required this.title,
    required this.storeName,
    required this.category,
    required this.price,
    required this.originalPrice,
    required this.lat,
    required this.lng,
    required this.address,
    this.imageUrl,
    required this.submittedBy,
    required this.trustScore,
    required this.upvotes,
    required this.downvotes,
    required this.verified,
    required this.hidden,
    required this.createdAt,
    this.expiresAt,
    this.description,
  });

  factory ApiDeal.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>?;
    return ApiDeal(
      dealId: json['dealId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      storeName: json['storeName'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? ((json['price'] as num?)?.toDouble() ?? 0) * 1.2,
      lat: (loc?['_latitude'] as num?)?.toDouble() ?? 0,
      lng: (loc?['_longitude'] as num?)?.toDouble() ?? 0,
      address: json['address'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      submittedBy: json['submittedBy'] as String? ?? '',
      trustScore: (json['trustScore'] as num?)?.toInt() ?? 50,
      upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
      downvotes: (json['downvotes'] as num?)?.toInt() ?? 0,
      verified: json['verified'] as bool? ?? false,
      hidden: json['hidden'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
      expiresAt: json['expiresAt'] as String?,
      description: json['description'] as String?,
    );
  }
}

class NearbyResult {
  final List<ApiDeal> communityDeals;
  final List<NearbyPlace> nearbyPlaces;

  const NearbyResult({required this.communityDeals, required this.nearbyPlaces});
}

class NearbyPlace {
  final String placeId;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final double? rating;
  final bool? isOpen;

  const NearbyPlace({
    required this.placeId,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.rating,
    this.isOpen,
  });

  factory NearbyPlace.fromJson(Map<String, dynamic> json) => NearbyPlace(
        placeId: json['placeId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        address: json['address'] as String? ?? '',
        lat: (json['lat'] as num?)?.toDouble() ?? 0,
        lng: (json['lng'] as num?)?.toDouble() ?? 0,
        rating: (json['rating'] as num?)?.toDouble(),
        isOpen: json['isOpen'] as bool?,
      );
}

class RouteResult {
  final String routeId;
  final List<RouteStop> orderedStops;
  final double totalDistanceKm;
  final int totalDurationMinutes;
  final SavingsBreakdown savings;
  final String? polyline;

  const RouteResult({
    required this.routeId,
    required this.orderedStops,
    required this.totalDistanceKm,
    required this.totalDurationMinutes,
    required this.savings,
    this.polyline,
  });

  factory RouteResult.fromJson(Map<String, dynamic> json) => RouteResult(
        routeId: json['routeId'] as String? ?? '',
        orderedStops: (json['orderedStops'] as List<dynamic>? ?? [])
            .map((s) => RouteStop.fromJson(s as Map<String, dynamic>))
            .toList(),
        totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble() ?? 0,
        totalDurationMinutes: (json['totalDurationMinutes'] as num?)?.toInt() ?? 0,
        savings: SavingsBreakdown.fromJson(
            json['savings'] as Map<String, dynamic>? ?? {}),
        polyline: json['polyline'] as String?,
      );
}

class RouteStop {
  final String storeName;
  final String address;
  final List<String> items;
  final String? source; 

  const RouteStop(
      {required this.storeName, required this.address, required this.items , this.source});

  factory RouteStop.fromJson(Map<String, dynamic> json) => RouteStop(
        storeName: json['storeName'] as String? ?? '',
        address: json['address'] as String? ?? '',
        items: List<String>.from(json['items'] as List<dynamic>? ?? []),
        source: json['source'] as String?,
      );
}

class SavingsBreakdown {
  final double grossSavingRM;
  final double travelCostRM;
  final double netSavingRM;
  final bool worthIt;

  const SavingsBreakdown({
    required this.grossSavingRM,
    required this.travelCostRM,
    required this.netSavingRM,
    required this.worthIt,
  });

  factory SavingsBreakdown.fromJson(Map<String, dynamic> json) =>
      SavingsBreakdown(
        grossSavingRM: (json['grossSavingRM'] as num?)?.toDouble() ?? 0,
        travelCostRM: (json['travelCostRM'] as num?)?.toDouble() ?? 0,
        netSavingRM: (json['netSavingRM'] as num?)?.toDouble() ?? 0,
        worthIt: json['worthIt'] as bool? ?? false,
      );
}

class MonthlySummary {
  final String month;
  final double totalSavedRM;
  final Map<String, double> byType;
  final int recordCount;
  final List<dynamic> records;

  const MonthlySummary({
    required this.month,
    required this.totalSavedRM,
    required this.byType,
    required this.recordCount,
    required this.records,
  });

    factory MonthlySummary.fromJson(Map<String, dynamic> json) {
    final rawByType = json['byType'] as Map<String, dynamic>? ?? {};
    return MonthlySummary(
      month: json['month'] as String? ?? '',
      totalSavedRM: (json['totalSavedRM'] as num?)?.toDouble() ?? 0,
      byType: rawByType.map((k, v) => MapEntry(k, (v as num).toDouble())),
      recordCount: (json['recordCount'] as num?)?.toInt() ?? 0,
      records: json['records'] as List<dynamic>? ?? [], // 👈 3. ADD THIS
    );
  }
}

// ─── API Service ──────────────────────────────────────────────────────────────

class RadarApiService {
  static final _client = http.Client();

  // GET /deals — list all visible deals, optionally filtered by location
  static Future<List<ApiDeal>> getDeals({
    double? lat,
    double? lng,
    String? category,
    double radiusMeters = 3000,
    bool verifiedOnly = false,
  }) async {
    final params = <String, String>{
      if (lat != null) 'lat': lat.toString(),
      if (lng != null) 'lng': lng.toString(),
      if (category != null) 'category': category,
      'radius': radiusMeters.toInt().toString(),
      if (verifiedOnly) 'verified': 'true',
    };

    final uri = Uri.parse('$_baseUrl/deals').replace(queryParameters: params);
    final res = await _client.get(uri).timeout(const Duration(seconds: 10));
    final body = jsonDecode(res.body) as Map<String, dynamic>;

    if (body['success'] != true) {
      throw Exception(body['error'] ?? 'Failed to fetch deals');
    }

    final list = body['deals'] as List<dynamic>? ?? [];
    return list.map((d) => ApiDeal.fromJson(d as Map<String, dynamic>)).toList();
  }

  // Add to radar_api_service.dart
  static Future<void> deleteDeal({required String dealId, required String userId}) async {
    final uri = Uri.parse('$_baseUrl/deals/$dealId');
    final res = await _client.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    if (res.statusCode != 200) throw Exception('Failed to delete deal');
  }

    static Future<void> editDeal({
    required String dealId,
    required String userId,
    required String title,
    required double price,
    required String description,
    required double originalPrice,
  }) async {
    final uri = Uri.parse('$_baseUrl/deals/$dealId');
    final res = await _client.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'title': title,
        'price': price,
        if (description != null && description.isNotEmpty) 'description': description,
        'originalPrice': originalPrice,
      }),
    );
    if (res.statusCode != 200) throw Exception('Failed to edit deal');
  }

  // POST /deals — submit a community deal
  static Future<ApiDeal> postDeal({
    required String title,
    required String storeName,
    required String category,
    required double price,
    required double lat,
    required double lng,
    required String address,
    required String userId,
    required double originalPrice,
    Uint8List? imageBytes,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'storeName': storeName,
      'category': category,
      'price': price,
      'originalPrice': originalPrice,
      'lat': lat,
      'lng': lng,
      'address': address,
      'submittedBy': userId,
      if (imageBytes != null) 'imageBase64': base64Encode(imageBytes),
    };

    final uri = Uri.parse('$_baseUrl/deals');
    final res = await _client
        .post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));

    final resBody = jsonDecode(res.body) as Map<String, dynamic>;
    if (resBody['success'] != true) {
      throw Exception(resBody['error'] ?? 'Failed to post deal');
    }

    return ApiDeal.fromJson(resBody['deal'] as Map<String, dynamic>);
  }

  // POST /deals/:id/upvote
  static Future<Map<String, dynamic>> upvoteDeal({
    required String dealId,
    required String userId,
  }) async {
    final uri = Uri.parse('$_baseUrl/deals/$dealId/upvote');
    final res = await _client
        .post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'userId': userId}))
        .timeout(const Duration(seconds: 10));

    final body = jsonDecode(res.body) as Map<String, dynamic>;

    // 409 = already voted — not a crash, just inform the UI
    if (res.statusCode == 409) {
      throw AlreadyVotedException(body['error'] as String? ?? 'Already voted');
    }
    if (body['success'] != true) {
      throw Exception(body['error'] ?? 'Upvote failed');
    }

    return body;
  }

  // POST /deals/:id/downvote
  static Future<Map<String, dynamic>> downvoteDeal({
    required String dealId,
    required String userId,
  }) async {
    final uri = Uri.parse('$_baseUrl/deals/$dealId/downvote');
    final res = await _client
        .post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'userId': userId}))
        .timeout(const Duration(seconds: 10));

    final body = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode == 409) {
      final error = body['error'] as String? ?? '';
      // "Already downvoted" = true duplicate → block
      // "Cannot downvote your own deal" → block
      // Anything else at 409 = was previously upvoted → already switched by backend, treat as success
      if (error.contains('Already downvoted') || error.contains('Cannot downvote')) {
        throw AlreadyVotedException(error);
      }
      // Should not happen with updated backend, but handle gracefully
      throw AlreadyVotedException(error);
    }
    if (body['success'] != true) {
      throw Exception(body['error'] ?? 'Downvote failed');
    }

    return body;
  }

  // POST /deals/use — record that user claimed a deal
  static Future<String> useDeal({
    required String userId,
    required String dealId,
    required double amountSaved,
    required String category,
    required String dealTitle,
  }) async {
    final uri = Uri.parse('$_baseUrl/deals/use');
    final res = await _client
        .post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': userId,
              'dealId': dealId,
              'amountSaved': amountSaved,
              'category': category,
              'dealTitle': dealTitle,
            }))
        .timeout(const Duration(seconds: 10));

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['error'] ?? 'Failed to record deal usage');
    }

    return body['proofId'] as String;
  }

  // GET /radar/nearby — nearby Google Places + community deals
  static Future<NearbyResult> getNearby({
    required double lat,
    required double lng,
    String category = 'food',
    double radiusMeters = 2000,
  }) async {
    final uri = Uri.parse('$_baseUrl/radar/nearby').replace(
      queryParameters: {
        'lat': lat.toString(),
        'lng': lng.toString(),
        'category': category,
        'radius': radiusMeters.toInt().toString(),
      },
    );

    final res = await _client.get(uri).timeout(const Duration(seconds: 10));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['error'] ?? 'Failed to fetch nearby');
    }

    final places = (body['nearbyPlaces'] as List<dynamic>? ?? [])
        .map((p) => NearbyPlace.fromJson(p as Map<String, dynamic>))
        .toList();

    final deals = (body['communityDeals'] as List<dynamic>? ?? [])
        .map((d) => ApiDeal.fromJson(d as Map<String, dynamic>))
        .toList();

    return NearbyResult(communityDeals: deals, nearbyPlaces: places);
  }

  // POST /radar/route-optimize
  static Future<RouteResult> optimizeRoute({
    required String userId,
    required double originLat,
    required double originLng,
    required List<String> groceryList,
    required List<Map<String, dynamic>> stops,
  }) async {
    final uri = Uri.parse('$_baseUrl/radar/route-optimize');
    final res = await _client
        .post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': userId,
              'originLat': originLat,
              'originLng': originLng,
              'groceryList': groceryList,
              'stops': stops,
            }))
        .timeout(const Duration(seconds: 15));

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(body['error'] ?? 'Route optimization failed');
    }

    return RouteResult.fromJson(body);
  }

  // POST /radar/route-accepted — user followed the route
  static Future<void> acceptRoute({
    required String userId,
    required String routeId,
    double? actualSavingsRM,
  }) async {
    final uri = Uri.parse('$_baseUrl/radar/route-accepted');
    await _client
        .post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': userId,
              'routeId': routeId,
              if (actualSavingsRM != null) 'actualSavingsRM': actualSavingsRM,
            }))
        .timeout(const Duration(seconds: 10));
  }

  // GET /radar/savings-summary
  static Future<MonthlySummary> getMonthlySummary({
    required String userId,
    String? month,
  }) async {
    final params = <String, String>{
      'userId': userId,
      if (month != null) 'month': month,
    };

    final uri = Uri.parse('$_baseUrl/radar/savings-summary')
        .replace(queryParameters: params);
    final res = await _client.get(uri).timeout(const Duration(seconds: 10));
    final body = jsonDecode(res.body) as Map<String, dynamic>;

    if (body['success'] != true) {
      throw Exception(body['error'] ?? 'Failed to fetch summary');
    }

    return MonthlySummary.fromJson(body);
  }
}

// Custom exception for duplicate votes — UI can catch this specifically
class AlreadyVotedException implements Exception {
  final String message;
  const AlreadyVotedException(this.message);

  @override
  String toString() => message;
}