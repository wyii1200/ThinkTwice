import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../core/app_theme.dart';
import '../core/models.dart';
import '../services/radar_api_service.dart';
import '../widgets/shared.dart';
import '../services/ai_service.dart';
import '../services/ai_state.dart';

String _fmt(double amount) => amount.toStringAsFixed(2);



class RadarPage extends StatefulWidget {
  const RadarPage({
    super.key,
    required this.deals,
    required this.userLocation,
    required this.onLocationChanged,
    required this.onPostDeal,
    required this.onUpvoteDeal,
    required this.onVerifyDeal,
  });

  final List<CommunityDeal> deals;
  final LatLng userLocation;
  final ValueChanged<LatLng> onLocationChanged;
  final ValueChanged<CommunityDeal> onPostDeal;
  final ValueChanged<String> onUpvoteDeal;
  final ValueChanged<String> onVerifyDeal;

  @override
  State<RadarPage> createState() => _RadarPageState();
}

class _RadarPageState extends State<RadarPage> {
  GoogleMapController? _mapController;
  CommunityDeal? _selectedDeal;
  bool _loadingLocation = false;

  // API state
  List<ApiDeal> _apiDeals = [];
  MonthlySummary? _monthlySummary;
  bool _loadingDeals = true;
  String? _dealsError;
  String? _activeCategory = 'food';
  final Map<String, String> _dealImageUrls = {};
  // FIX 2 & 3: Route state — only generated when user requests it
  RouteResult? _routeResult;
  bool _loadingRoute = false;
  String? _routeError;
  final List<String> _groceryItems = [];
  String? _aiRouteVerdict;
  List<_RoutePlanStop> _plannedRouteStops = [];
  String? _routeDecisionNote;
  

  // FIX 1: Change this to your laptop WiFi IP when testing on physical device
  // Run `ipconfig` in PowerShell → IPv4 Address under WiFi adapter
  // e.g. 'http://192.168.1.105:4000'
  // Emulator: 'http://10.0.2.2:4000'  |  Web/desktop: 'http://localhost:4000'
  // Deployed: 'https://thinktwice-zu5d.onrender.com'

  static String get _userId =>
    FirebaseAuth.instance.currentUser?.uid ?? 'test_user_001';

  @override
  void initState() {
    super.initState();
    final simulationContext = AiState.latestSimulationContext;
    final simulatedCategory = simulationContext?['category']?.toString();
    if (simulatedCategory != null && simulatedCategory.isNotEmpty) {
      _activeCategory = simulatedCategory;
    }
    _detectLocation();
    _loadDeals();
    _loadMonthlySummary();
  }

  @override
  void didUpdateWidget(covariant RadarPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedDeal != null) {
      final updated = _apiDeals.where((d) => d.dealId == _selectedDeal!.id);
      if (updated.isNotEmpty) {
        _selectedDeal = _apiDealToCommunityDeal(updated.first);
      }
    }
  }

  // ── Data loading ───────────────────────────────────────────────────────────

  Future<void> _loadDeals({String? category}) async {
    setState(() {
      _loadingDeals = true;
      _dealsError = null;
      _routeResult = null;
      _plannedRouteStops = [];
      _routeDecisionNote = null;
      if (category != null) _activeCategory = category;
    });

    try {
      final deals = await RadarApiService.getDeals(
        lat: widget.userLocation.latitude,
        lng: widget.userLocation.longitude,
        category: _activeCategory,
        radiusMeters: 5000,
      );
      if (!mounted) return;
      setState(() {
        _apiDeals = deals;

//for image caching in map markers — avoids re-downloading when deal list refreshes
        for (final d in deals) {
          if (d.imageUrl != null && d.imageUrl!.isNotEmpty) {
            _dealImageUrls[d.dealId] = d.imageUrl!;
          }
        }

        _loadingDeals = false;
        if (_selectedDeal == null && deals.isNotEmpty) {
          _selectedDeal = _apiDealToCommunityDeal(deals.first);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _dealsError = e.toString();
        _loadingDeals = false;
        _apiDeals = widget.deals.map(_communityDealToApiDeal).toList();
      });
    }
  }

  Future<void> _loadMonthlySummary() async {
    try {
      final summary = await RadarApiService.getMonthlySummary(userId: _userId);
      if (!mounted) return;
      setState(() => _monthlySummary = summary);
    } catch (_) {}
  }

  // ── Location ───────────────────────────────────────────────────────────────

  Future<void> _detectLocation() async {
    setState(() => _loadingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();
      final current = LatLng(position.latitude, position.longitude);
      if (!mounted) return;

      widget.onLocationChanged(current);
      _mapController?.animateCamera(CameraUpdate.newLatLng(current));
      await _loadDeals();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  // ── FIX 2 & 3: Route generation — user-triggered with grocery input ────────

  Future<void> _openGroceryInputSheet() async {
    final items = await showContainedBottomSheet<List<String>>(
      context,
      barrierLabel: 'Grocery Input',
      builder: (ctx) => _GroceryInputSheet(
        storeName: _selectedDeal?.storeName ?? 'nearby grocery stores',
        initialItems: _groceryItems,
      ),
    );

    if (items == null || items.isEmpty || !mounted) return;

    setState(() {
      _groceryItems
        ..clear()
        ..addAll(items);
      _loadingRoute = true;
      _routeError = null;
      _plannedRouteStops = [];
      _routeDecisionNote = null;
    });

    try {
      final routePlan = await _buildSmartRoutePlan(items);
      if (routePlan.stops.isEmpty) {
        throw Exception('No suitable store found for this grocery list.');
      }

      // Only send lat/lng — never address strings (causes Directions API NOT_FOUND)
      final stops = routePlan.stops.map((stop) => stop.toApiStop()).toList();

      final result = await RadarApiService.optimizeRoute(
        userId: _userId,
        originLat: widget.userLocation.latitude,
        originLng: widget.userLocation.longitude,
        groceryList: items,
        stops: stops,
      );

      if (!mounted) return;
      setState(() {
        _routeResult = result;
        _plannedRouteStops = _mergeRouteOrder(routePlan.stops, result);
        _routeDecisionNote = routePlan.decisionNote;
        if (_plannedRouteStops.first.deal != null) {
          _selectedDeal = _apiDealToCommunityDeal(_plannedRouteStops.first.deal!);
        }
        _loadingRoute = false;
        _aiRouteVerdict = null; // Clear previous verdict
      });

      // Trigger AI analysis asynchronously
      AiService.analyzeRouteWorth(result).then((verdict) {
        if (mounted) setState(() => _aiRouteVerdict = verdict);
      });

      _animateMapToRoute();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _routeError = e.toString();
        _loadingRoute = false;
        _plannedRouteStops = [];
        _routeDecisionNote = null;
      });
    }
  }

  Future<_RoutePlan> _buildSmartRoutePlan(List<String> items) async {
    final communityDeals = await _loadRouteCandidateDeals();
    final unmatchedItems = items.toSet();
    final chosenDeals = <ApiDeal, List<String>>{};

    for (final item in items) {
      final rankedDeals = communityDeals
          .where((deal) => _dealMatchesItem(deal, item))
          .map((deal) => _ScoredDeal(
                deal: deal,
                netValue: _estimatedDealNetValue(deal),
              ))
          .where((candidate) => candidate.netValue > 0.25)
          .toList()
        ..sort((a, b) {
          final scoreCompare = b.netValue.compareTo(a.netValue);
          if (scoreCompare != 0) return scoreCompare;
          final trustCompare = b.deal.trustScore.compareTo(a.deal.trustScore);
          if (trustCompare != 0) return trustCompare;
          return b.deal.upvotes.compareTo(a.deal.upvotes);
        });

      if (rankedDeals.isEmpty) continue;
      final bestDeal = rankedDeals.first.deal;
      chosenDeals.putIfAbsent(bestDeal, () => []).add(item);
      unmatchedItems.remove(item);
    }

    final stops = <_RoutePlanStop>[
      for (final entry in chosenDeals.entries)
        _RoutePlanStop.communityDeal(entry.key, entry.value),
    ];

    if (unmatchedItems.isNotEmpty || stops.isEmpty) {
      final fallbackItems = stops.isEmpty ? items : unmatchedItems.toList();
      stops.add(await _recommendedFallbackStop(fallbackItems));
    }

    stops.sort((a, b) {
      if (a.isCommunityDeal != b.isCommunityDeal) {
        return a.isCommunityDeal ? -1 : 1;
      }
      return a.distanceFrom(widget.userLocation)
          .compareTo(b.distanceFrom(widget.userLocation));
    });

    final coveredCount = items.length - unmatchedItems.length;
    final decisionNote = coveredCount > 0
        ? 'AI picked $coveredCount community deal item${coveredCount == 1 ? '' : 's'} first, then filled the gaps with a recommended grocery store.'
        : 'No community deal was a better match for this list, so AI recommended a nearby grocery store.';

    return _RoutePlan(stops: stops, decisionNote: decisionNote);
  }

  Future<List<ApiDeal>> _loadRouteCandidateDeals() async {
    final knownDeals = <String, ApiDeal>{
      for (final deal in _apiDeals) deal.dealId: deal,
      for (final deal in widget.deals.map(_communityDealToApiDeal))
        deal.dealId: deal,
    };

    try {
      final groceryDeals = await RadarApiService.getDeals(
        lat: widget.userLocation.latitude,
        lng: widget.userLocation.longitude,
        category: 'grocery',
        radiusMeters: 5000,
      );
      for (final deal in groceryDeals) {
        knownDeals[deal.dealId] = deal;
      }
    } catch (_) {}

    return knownDeals.values
        .where((deal) => !deal.hidden)
        .where((deal) =>
            deal.category == 'grocery' || deal.category == _activeCategory)
        .toList();
  }

  bool _dealMatchesItem(ApiDeal deal, String item) {
    final itemText = _normaliseRouteText(item);
    if (itemText.isEmpty) return false;
    final dealText = _normaliseRouteText(
      '${deal.title} ${deal.description ?? ''} ${deal.category}',
    );
    if (dealText.isEmpty) return false;
    return dealText.contains(itemText) || itemText.contains(dealText);
  }

  double _estimatedDealNetValue(ApiDeal deal) {
    final saving = math.max(0, deal.originalPrice - deal.price);
    final travelCost = _distanceKm(
          widget.userLocation.latitude,
          widget.userLocation.longitude,
          deal.lat,
          deal.lng,
        ) *
        0.15;
    return saving - travelCost;
  }

  Future<_RoutePlanStop> _recommendedFallbackStop(List<String> items) async {
    try {
      final nearby = await RadarApiService.getNearby(
        lat: widget.userLocation.latitude,
        lng: widget.userLocation.longitude,
        category: 'grocery',
        radiusMeters: 3000,
      );
      final places = nearby.nearbyPlaces.toList()
        ..sort((a, b) => _distanceKm(
              widget.userLocation.latitude,
              widget.userLocation.longitude,
              a.lat,
              a.lng,
            ).compareTo(_distanceKm(
              widget.userLocation.latitude,
              widget.userLocation.longitude,
              b.lat,
              b.lng,
            )));
      if (places.isNotEmpty) {
        return _RoutePlanStop.nearbyPlace(places.first, items);
      }
    } catch (_) {}

    return _RoutePlanStop.generated(
      storeName: 'Nearby Grocery',
      lat: widget.userLocation.latitude + 0.005,
      lng: widget.userLocation.longitude + 0.005,
      items: items,
    );
  }

  List<_RoutePlanStop> _mergeRouteOrder(
    List<_RoutePlanStop> plannedStops,
    RouteResult result,
  ) {
    if (result.orderedStops.isEmpty) return plannedStops;

    final remaining = plannedStops.toList();
    final ordered = <_RoutePlanStop>[];
    for (final routeStop in result.orderedStops) {
      final index = remaining.indexWhere(
        (stop) => stop.storeName == routeStop.storeName,
      );
      if (index == -1) continue;
      ordered.add(remaining.removeAt(index).copyWith(items: routeStop.items));
    }
    return [...ordered, ...remaining];
  }

  String _normaliseRouteText(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  double _distanceKm(double lat1, double lng1, double lat2, double lng2) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLng = _degToRad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _degToRad(double degrees) => degrees * math.pi / 180;

  void _animateMapToRoute() {
    final routeStops = _plannedRouteStops;
    if (routeStops.isEmpty && _selectedDeal == null) return;

    final allLats = <double>[
      widget.userLocation.latitude,
      if (routeStops.isNotEmpty)
        ...routeStops.map((stop) => stop.lat)
      else
        _selectedDeal!.latitude,
    ];
    final allLngs = <double>[
      widget.userLocation.longitude,
      if (routeStops.isNotEmpty)
        ...routeStops.map((stop) => stop.lng)
      else
        _selectedDeal!.longitude,
    ];

    final bounds = LatLngBounds(
      southwest: LatLng(
        allLats.reduce((a, b) => a < b ? a : b) - 0.005,
        allLngs.reduce((a, b) => a < b ? a : b) - 0.005,
      ),
      northeast: LatLng(
        allLats.reduce((a, b) => a > b ? a : b) + 0.005,
        allLngs.reduce((a, b) => a > b ? a : b) + 0.005,
      ),
    );

    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }

  // ── Voting ─────────────────────────────────────────────────────────────────

  Future<void> _handleUpvote(String dealId) async {
    try {
      final result =
          await RadarApiService.upvoteDeal(dealId: dealId, userId: _userId);
      widget.onUpvoteDeal(dealId);
      await _loadDeals(); // sync Firestore → UI
      if (!mounted) return;
      final switched = result['switched'] == true;
      showContainedSnackBar(
        context,
        message: switched
            ? 'Switched to upvote. Trust score updated.'
            : 'Upvoted! Trust score updated.',
        accentColor: context.colors.success,
      );
    } on AlreadyVotedException {
      if (!mounted) return;
      showContainedSnackBar(
        context,
        message: 'You already upvoted this deal.',
        accentColor: context.colors.warning,
        icon: Icons.info_rounded,
      );
    } catch (e) {
      if (!mounted) return;
      showContainedSnackBar(
        context,
        message: 'Could not upvote: $e',
        accentColor: context.colors.destructive,
        icon: Icons.error_outline_rounded,
      );
    }
  }

  Future<void> _handleVerify(String dealId) async {
    await _handleUpvote(dealId);
    widget.onVerifyDeal(dealId);
  }

  Future<void> _handleDownvote(String dealId) async {
    try {
      final result =
          await RadarApiService.downvoteDeal(dealId: dealId, userId: _userId);
      await _loadDeals(); // sync Firestore data back to UI
      if (!mounted) return;
      final switched = result['switched'] == true;
      showContainedSnackBar(
        context,
        message: switched
            ? 'Switched to downvote. Trust score updated.'
            : 'Downvoted. Trust score reduced.',
        accentColor: context.colors.warning,
        icon: Icons.info_rounded,
      );
    } on AlreadyVotedException catch (e) {
      if (!mounted) return;
      // "Already downvoted" or "own deal" — show clean message
      final msg = e.message.contains('own deal')
          ? 'You cannot downvote your own deal.'
          : 'You already downvoted this deal.';
      showContainedSnackBar(
        context,
        message: msg,
        accentColor: context.colors.warning,
        icon: Icons.info_rounded,
      );
    } catch (e) {
      if (!mounted) return;
      showContainedSnackBar(
        context,
        message: 'Could not downvote: $e',
        accentColor: context.colors.destructive,
        icon: Icons.error_outline_rounded,
      );
    }
  }

  // ── Post deal ──────────────────────────────────────────────────────────────

  Future<void> _openPostDealSheet() async {
    final result = await showContainedBottomSheet<_PostDealResult>(
      context,
      barrierLabel: 'Post Community Deal',
      builder: (context) => PostDealSheet(userLocation: widget.userLocation),
    );

    if (!mounted || result == null) return;

    try {
      final apiDeal = await RadarApiService.postDeal(
        title: result.title,
        storeName: result.storeName,
        category: result.category,
        price: result.price,
        originalPrice: result.originalPrice ,
        lat: result.lat,
        lng: result.lng,
        address: result.address,
        userId: _userId,
        imageBytes: result.imageBytes,
        description: result.description,
      );

      final communityDeal = _apiDealToCommunityDeal(apiDeal);
      widget.onPostDeal(communityDeal);

      setState(() {
        _apiDeals = [apiDeal, ..._apiDeals];
        // Cache image URL for the new deal
        if (apiDeal.imageUrl != null && apiDeal.imageUrl!.isNotEmpty) {
          _dealImageUrls[apiDeal.dealId] = apiDeal.imageUrl!;
        }
        _selectedDeal = communityDeal;
      });

      _mapController?.animateCamera(
          CameraUpdate.newLatLng(LatLng(apiDeal.lat, apiDeal.lng)));

      if (!mounted) return;
      showContainedSnackBar(
        context,
        message: 'Deal posted! You earned points for helping others save.',
        accentColor: context.colors.success,
      );
    } catch (e) {
      if (!mounted) return;
      showContainedSnackBar(
        context,
        message: 'Failed to post deal: $e',
        accentColor: context.colors.destructive,
        icon: Icons.error_outline_rounded,
      );
    }
  }
// 1. The Claim Logic
  Future<void> _claimDeal(CommunityDeal deal) async {
    try {
      await RadarApiService.useDeal(
        userId: _userId,
        dealId: deal.id,
        amountSaved: deal.originalPrice - deal.dealPrice,
        category: deal.category,
        dealTitle: deal.title,// <--- Add this property to your Api Service
      );
            await _loadMonthlySummary();

      if (!mounted) return;
      showContainedSnackBar(
        context,
        message:
            'Awesome! Added RM ${(deal.originalPrice - deal.dealPrice).toStringAsFixed(2)} to your savings.',
        accentColor: context.colors.success,
        icon: Icons.celebration_rounded,
      );
    } catch (e) {
      if (!mounted) return;
      showContainedSnackBar(
        context,
        message: 'Failed to claim deal: $e',
        accentColor: context.colors.destructive,
        icon: Icons.error_outline_rounded,
      );
    }
  }

  // 2. The Bottom Sheet UI
  void _showDealDetailsSheet(CommunityDeal deal) {
    final isOwner = deal.submittedBy == _userId;

    showContainedBottomSheet(
      context,
      barrierLabel: 'Deal Details',
      barrierColor: const Color(0x7A17332D),
      builder: (ctx) {
        final colors = ctx.colors;
        final safeBottom = MediaQuery.of(ctx).padding.bottom;
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.86,
          ),
          child: Material(
            color: colors.card,
            elevation: 24,
            shadowColor: Colors.black.withOpacity(0.18),
            borderRadius: BorderRadius.circular(28),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: colors.mutedForeground.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deal.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${deal.storeName} • ${deal.category}',
                          style: TextStyle(
                            color: colors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 184,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: colors.muted,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _buildDealImage(deal),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.background,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colors.primary.withOpacity(0.10),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                deal.description.isNotEmpty
                                    ? deal.description
                                    : 'No description provided.',
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.45,
                                  color: colors.foreground.withOpacity(0.82),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.background,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colors.success.withOpacity(0.14),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. The Prices Row
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Deal Price',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colors.mutedForeground,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'RM ${deal.dealPrice.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: colors.success,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Usually',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colors.mutedForeground,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'RM ${deal.originalPrice.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            decoration: TextDecoration.lineThrough,
                                            color: colors.mutedForeground,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              // 2. A subtle divider
                              const SizedBox(height: 16),
                              Divider(color: colors.primary.withOpacity(0.08), height: 1),
                              const SizedBox(height: 12),

                              // 3. The Location Block
                              const Text(
                                'Location',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.location_on_rounded, size: 18, color: colors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      deal.address.isNotEmpty ? deal.address : 'Near ${deal.storeName}',
                                      style: TextStyle(
                                        fontSize: 14, 
                                        color: colors.foreground.withOpacity(0.82), 
                                        height: 1.4
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    16 + safeBottom.clamp(0.0, 16.0),
                  ),
                  decoration: BoxDecoration(
                    color: colors.card,
                    border: Border(
                      top: BorderSide(color: colors.primary.withOpacity(0.10)),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _claimDeal(deal);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          icon: const Icon(Icons.receipt_long_rounded),
                          label: const Text(
                            'Claim Deal & Record Savings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      if (isOwner) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  final titleCtrl = TextEditingController(
                                    text: deal.title,
                                  );
                                  final priceCtrl = TextEditingController(
                                    text: deal.dealPrice.toString(),
                                  );
                                  final descCtrl = TextEditingController(
                                    text: deal.description,
                                  );
                                  final origPriceCtrl = TextEditingController(
                                    text: deal.originalPrice.toString(),
                                  );

                                  await showContainedDialog(
                                    context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Edit Deal'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: titleCtrl,
                                            decoration: const InputDecoration(
                                              labelText: 'Title',
                                            ),
                                          ),
                                          TextField(
                                            controller: priceCtrl,
                                            decoration: const InputDecoration(
                                              labelText: 'Price (RM)',
                                            ),
                                          ),
                                          TextField(
                                            controller: origPriceCtrl,
                                            decoration: const InputDecoration(
                                              labelText: 'Original Price (RM)',
                                            ),
                                            keyboardType: TextInputType.number,
                                          ),
                                          TextField(
                                            controller: descCtrl,
                                            decoration: const InputDecoration(
                                              labelText: 'Description',
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        FilledButton(
                                          onPressed: () async {
                                            await RadarApiService.editDeal(
                                              dealId: deal.id,
                                              userId: _userId,
                                              title: titleCtrl.text,
                                              price: double.tryParse(
                                                    priceCtrl.text,
                                                  ) ??
                                                  deal.dealPrice,
                                              description: descCtrl.text,
                                              originalPrice: double.tryParse(
                                                    origPriceCtrl.text,
                                                  ) ??
                                                  deal.originalPrice,
                                            );
                                            Navigator.pop(context);
                                            _loadDeals();
                                            showContainedSnackBar(
                                              context,
                                              message: 'Deal updated!',
                                              accentColor:
                                                  context.colors.success,
                                            );
                                          },
                                          child: const Text('Save'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colors.primary,
                                  side: BorderSide(
                                    color: colors.primary.withOpacity(0.24),
                                  ),
                                ),
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Edit'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  try {
                                    await RadarApiService.deleteDeal(
                                      dealId: deal.id,
                                      userId: _userId,
                                    );
                                    Navigator.pop(ctx);
                                    _loadDeals();
                                    showContainedSnackBar(
                                      context,
                                      message: 'Deal deleted',
                                      accentColor: context.colors.success,
                                    );
                                  } catch (e) {
                                    showContainedSnackBar(
                                      context,
                                      message: 'Delete failed: $e',
                                      accentColor:
                                          context.colors.destructive,
                                      icon: Icons.error_outline_rounded,
                                    );
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colors.destructive,
                                  side: BorderSide(
                                    color:
                                        colors.destructive.withOpacity(0.24),
                                  ),
                                ),
                                icon: const Icon(Icons.delete, size: 18),
                                label: const Text('Delete'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  // ── Use route ──────────────────────────────────────────────────────────────

  Future<void> _openNavigation(CommunityDeal deal) async {
    try {
      final routeUsesSelectedDeal = _routeResult == null ||
          _plannedRouteStops.any((stop) => stop.deal?.dealId == deal.id);
      if (routeUsesSelectedDeal) {
        await RadarApiService.useDeal(
          userId: _userId,
          dealId: deal.id,
          amountSaved: deal.estimatedSavings,
          category: deal.category,
          dealTitle: deal.title, // <--- Add this property to your Api Service
        );
      }
      if (_routeResult != null) {
        await RadarApiService.acceptRoute(
          userId: _userId,
          routeId: _routeResult!.routeId,
          actualSavingsRM: _routeResult!.savings.netSavingRM,
        );
      }
      await _loadMonthlySummary();
    } catch (_) {}

    final routeStops = _plannedRouteStops;
    final destination = routeStops.isNotEmpty
        ? LatLng(routeStops.last.lat, routeStops.last.lng)
        : LatLng(deal.latitude, deal.longitude);
    final waypoints = routeStops.length > 1
        ? routeStops
            .take(routeStops.length - 1)
            .map((stop) => '${stop.lat},${stop.lng}')
            .join('|')
        : null;

    final uri = Uri.https(
      'www.google.com',
      '/maps/dir/',
      {
        'api': '1',
        'destination': '${destination.latitude},${destination.longitude}',
        if (waypoints != null) 'waypoints': waypoints,
        'travelmode': 'driving',
      },
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (!mounted) return;
    showContainedSnackBar(
      context,
      message: 'Could not open Google Maps.',
      accentColor: context.colors.warning,
      icon: Icons.info_rounded,
    );
  }

// ── UI components ───────────────────────────────────────────────────────────
  Widget _buildDealImage(CommunityDeal deal) {
    if (deal.imageBytes != null) {
      return Image.memory(deal.imageBytes!, fit: BoxFit.cover);
    }

    final url = deal.imageUrl ?? _dealImageUrls[deal.id];
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        // 👇 Removed the useless CORS header from here
        loadingBuilder: (ctx, child, progress) => progress == null
            ? child
            : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorBuilder: (ctx, error, stack) {
          debugPrint('Image load failed: $error');
          return Icon(Icons.storefront_rounded,
              size: 28, color: Theme.of(ctx).colorScheme.secondary);
        },
      );
    }

    return Icon(Icons.storefront_rounded,
        size: 28, color: Theme.of(context).colorScheme.secondary);
  }
  // ── Helpers ────────────────────────────────────────────────────────────────

  double _distanceTo(double lat, double lng) =>
      Geolocator.distanceBetween(widget.userLocation.latitude,
          widget.userLocation.longitude, lat, lng) /
      1000;

  CommunityDeal _apiDealToCommunityDeal(ApiDeal d) {
    final distKm = _distanceTo(d.lat, d.lng);
    return CommunityDeal(
      id: d.dealId,
      title: d.title,
      storeName: d.storeName,
      category: d.category,
      description: (d.description != null && d.description!.isNotEmpty) 
          ? d.description! 
          : '${d.category} deal at ${d.storeName}',
      expiryDate: d.expiresAt != null
          ? DateTime.tryParse(d.expiresAt!) ??
              DateTime.now().add(const Duration(days: 7))
          : DateTime.now().add(const Duration(days: 7)),
      latitude: d.lat,
      longitude: d.lng,
      originalPrice: d.originalPrice,
      dealPrice: d.price,
      discountLabel: 'Save RM ${_fmt(d.price * 0.2)}',
      upvotes: d.upvotes,
      verifications: d.trustScore,
      distanceKm: distKm,
      submittedBy: d.submittedBy,
      imageUrl: d.imageUrl,
      address: d.address,
    );
  }

  ApiDeal _communityDealToApiDeal(CommunityDeal d) => ApiDeal(
        dealId: d.id,
        title: d.title,
        storeName: d.storeName,
        category: d.category,
        price: d.dealPrice,
        originalPrice: d.originalPrice,
        lat: d.latitude,
        lng: d.longitude,
        address: '',
        submittedBy: 'seed',
        trustScore: d.verifications,
        upvotes: d.upvotes,
        downvotes: 0,
        verified: d.verifications >= 70,
        hidden: false,
        createdAt: DateTime.now().toIso8601String(),
      );

  List<_RoutePlanStop> get _routeDisplayStops {
    if (_plannedRouteStops.isNotEmpty) return _plannedRouteStops;
    if (_selectedDeal == null || _groceryItems.isEmpty) return const [];
    return [
      _RoutePlanStop.communityDeal(
        _communityDealToApiDeal(_selectedDeal!),
        _groceryItems,
      ),
    ];
  }

  // FIX 4: Markers with labeled route stops
  Set<Marker> _markers() {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('user'),
        position: widget.userLocation,
        infoWindow: const InfoWindow(title: 'You are here'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    };

    // Community deal markers
    // Community deal markers
    for (final deal in _apiDeals) {
      markers.add(Marker(
        markerId: MarkerId(deal.dealId),
        position: LatLng(deal.lat, deal.lng),
        infoWindow: InfoWindow(
          title: deal.title,
          snippet: '${deal.storeName} • RM ${_fmt(deal.price)}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          deal.verified
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueOrange,
        ),
        onTap: () {
          final communityDeal = _apiDealToCommunityDeal(deal);
          setState(() => _selectedDeal = communityDeal);
          
          // 👈 ADD THIS LINE TO MAP MARKERS TOO!
          _showDealDetailsSheet(communityDeal); 
        },
      ));
    }

    // Route stop markers — only shown when route is generated
    if (_routeResult != null && _plannedRouteStops.isNotEmpty) {
      for (var i = 0; i < _plannedRouteStops.length; i++) {
        final stop = _plannedRouteStops[i];
        final label = String.fromCharCode(65 + i);
        markers.add(Marker(
          markerId: MarkerId('stop_$label'),
          position: LatLng(stop.lat, stop.lng),
          infoWindow: InfoWindow(
            title: 'Stop $label — ${stop.storeName}',
            snippet: stop.items.take(3).join(', '),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            stop.isCommunityDeal
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueViolet,
          ),
        ));
      }
    }

    return markers;
  }

  Set<Polyline> _polylines() {
    if (_routeResult != null && _plannedRouteStops.isNotEmpty) {
      return {
        Polyline(
          polylineId: const PolylineId('route-full'),
          width: 5,
          color: const Color(0xFF41B89B),
          points: [
            widget.userLocation,
            ..._plannedRouteStops.map((stop) => LatLng(stop.lat, stop.lng)),
          ],
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      };
    }

    if (_selectedDeal != null) {
      return {
        Polyline(
          polylineId: const PolylineId('selected-route'),
          width: 4,
          color: const Color(0xFF41B89B),
          points: [
            widget.userLocation,
            LatLng(_selectedDeal!.latitude, _selectedDeal!.longitude),
          ],
        ),
      };
    }

    return {};
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sortedDeals = _apiDeals.map(_apiDealToCommunityDeal).toList()
      ..sort((a, b) => (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999));

    final selected =
        _selectedDeal ?? (sortedDeals.isNotEmpty ? sortedDeals.first : null);

    final totalSaved = _monthlySummary?.totalSavedRM ??
        _apiDeals.fold<double>(0, (s, d) => s + d.price * 0.2);

    final aiResult = AiState.latestAiResult;
    final simulationContext = AiState.latestSimulationContext;

    final aiTriggeredRadar =
        aiResult != null && AiService.shouldTriggerSmartRadar(aiResult);

    final radarCategory = aiResult != null
        ? AiService.extractRadarCategory(aiResult)
        : _activeCategory ?? 'food';

    final aiCoaching = aiResult != null
        ? AiService.extractCoachingMessage(aiResult)
        : 'Run Live AI Analysis to get personalised Smart Radar guidance.';

    final aiPrediction = aiResult != null
        ? AiService.extractPrediction(aiResult)
        : 'ThinkTwice will recommend nearby savings opportunities when risk is detected.';

    final simulationMerchant =
        simulationContext?['merchant']?.toString().trim() ?? '';
    final simulationLocation =
        simulationContext?['location']?.toString().trim() ?? '';
    final simulationCategory =
        simulationContext?['category']?.toString().trim() ?? radarCategory;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Radar',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Deals, routes, and community savings near you',
              style: TextStyle(
                  fontSize: 14, color: context.colors.mutedForeground)),

          const SizedBox(height: 20),
          WhiteCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.psychology_alt_rounded,
                      color: context.colors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'AI Smart Radar Trigger',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  aiTriggeredRadar
                      ? 'AI triggered Radar for ${radarCategory.toUpperCase()} savings.'
                      : 'Smart Radar is ready for AI-triggered savings.',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  aiPrediction,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: context.colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    aiCoaching,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          if (simulationContext != null) ...[
            WhiteCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.colors.accent.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.radar_rounded,
                      color: context.colors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Triggered by ThinkTwice AI',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Looking for cheaper ${simulationCategory.toUpperCase()} options'
                          '${simulationMerchant.isNotEmpty ? ' near $simulationMerchant' : ''}'
                          '${simulationLocation.isNotEmpty ? ' around $simulationLocation' : ''}.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: context.colors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Savings card — tap to see breakdown ───────────────────────────
          GestureDetector(
            onTap: () => _showSavingsRecords(context),
            child: GradientCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text('You saved this month',
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded,
                        color: Colors.white70, size: 16),
                  ]),
                  const SizedBox(height: 4),
                  Text('RM ${_fmt(totalSaved)}',
                      style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(
                    _loadingLocation
                        ? 'Detecting your location...'
                        : _monthlySummary != null
                            ? '${_monthlySummary!.recordCount} savings recorded · tap to view'
                            : 'Tap to view savings records',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Category chips ────────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['food', 'grocery', 'transport'].map((cat) {
                final isActive = _activeCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat[0].toUpperCase() + cat.substring(1)),
                    selected: isActive,
                    onSelected: (_) => _loadDeals(category: cat),
                    selectedColor: context.colors.primary.withOpacity(0.15),
                    checkmarkColor: context.colors.primary,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // ── Nearby deals preview ──────────────────────────────────────────
          WhiteCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('Nearby deals',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  if (_loadingDeals)
                    const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  if (_dealsError != null && !_loadingDeals)
                    Icon(Icons.wifi_off_rounded,
                        size: 16, color: Colors.orange.shade700),
                ]),
                const SizedBox(height: 10),
                if (_dealsError != null && _apiDeals.isEmpty)
                  Text('Showing offline data',
                      style: TextStyle(
                          fontSize: 11, color: context.colors.mutedForeground))
                else
                  ...sortedDeals.take(2).map((deal) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: context.colors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Icon(Icons.local_offer_rounded,
                                color: context.colors.primary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(deal.title,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700)),
                                  Text(
                                    '${deal.storeName} • ${deal.distanceKm?.toStringAsFixed(2) ?? '--'} km away',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: context.colors.mutedForeground),
                                  ),
                                ]),
                          ),
                          // FIX 5: Original vs deal price
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'RM ${_fmt(deal.originalPrice)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'RM ${_fmt(deal.dealPrice)}',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: context.colors.success),
                              ),
                            ],
                          ),
                        ]),
                      )),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── FIX 4: Map with labeled route markers + legend overlay ────────
          Container(
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: GoogleMap(
                    initialCameraPosition:
                        CameraPosition(target: widget.userLocation, zoom: 14.2),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    markers: _markers(),
                    polylines: _polylines(),
                    onMapCreated: (c) => _mapController = c,
                    onTap: (_) => setState(() => _selectedDeal = null),
                  ),
                ),
                // Legend — only visible when route is active
                if (_routeResult != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.93),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _legendRow(Colors.blue, '📍 You'),
                          for (var i = 0; i < _plannedRouteStops.length; i++) ...[
                            const SizedBox(height: 4),
                            _legendRow(
                              _plannedRouteStops[i].isCommunityDeal
                                  ? const Color(0xFF41B89B)
                                  : Colors.purple,
                              '${String.fromCharCode(65 + i)} — ${_plannedRouteStops[i].storeName}',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Selected deal card ────────────────────────────────────────────
          if (selected != null) ...[
            WhiteCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: context.colors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.route_rounded,
                          color: context.colors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(selected.title,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700)),
                            Text(selected.storeName,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: context.colors.mutedForeground)),
                          ]),
                    ),
                    if (_apiDeals
                        .any((d) => d.dealId == selected.id && d.verified))
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: context.colors.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.verified_rounded,
                              size: 12, color: context.colors.success),
                          const SizedBox(width: 4),
                          Text('Verified',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: context.colors.success,
                                  fontWeight: FontWeight.w600)),
                        ]),
                      ),
                  ]),

                  const SizedBox(height: 14),

                  // Distance + FIX 5: price comparison stat
                  Row(children: [
                    Expanded(
                        child: progressStat(context, 'Distance',
                            '${selected.distanceKm?.toStringAsFixed(2) ?? '--'} km')),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: context.colors.success.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Price',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: context.colors.mutedForeground)),
                            const SizedBox(height: 2),
                            Row(children: [
                              Text(
                                'RM ${_fmt(selected.originalPrice)}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'RM ${_fmt(selected.dealPrice)}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: context.colors.success),
                              ),
                            ]),
                            Text(
                              'You save RM ${_fmt(selected.originalPrice - selected.dealPrice)}',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: context.colors.success,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 14),

                  // FIX 3: Generate route button — only before route exists
                  if (_routeResult == null && !_loadingRoute)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _openGroceryInputSheet,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(color: context.colors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: Icon(Icons.add_shopping_cart_rounded,
                            color: context.colors.primary),
                        label: Text(
                          'Add grocery list & generate route',
                          style: TextStyle(color: context.colors.primary),
                        ),
                      ),
                    ),

                  if (_loadingRoute)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)),
                            SizedBox(width: 10),
                            Text('Optimising your route...'),
                          ],
                        ),
                      ),
                    ),

                  if (_routeError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('Route error: $_routeError',
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12)),
                    ),

                  // Route ready banner
                  if (_routeResult != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(children: [
                        Icon(Icons.check_circle_rounded,
                            size: 16, color: context.colors.success),
                        const SizedBox(width: 6),
                        Text('Route ready',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: context.colors.success)),
                        const Spacer(),
                        Text(
                          'Net save RM ${_fmt(_routeResult!.savings.netSavingRM)}',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: context.colors.success),
                        ),
                      ]),
                    ),
                    if (_routeDecisionNote != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _routeDecisionNote!,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.35,
                          color: context.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ],

                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _openNavigation(selected),
                      style: FilledButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Use This Route'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Route stops + savings breakdown (only after route generated) ─
            if (_routeResult != null) ...[
              WhiteCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Text('Optimised route',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      Text(
                        '${_routeResult!.totalDistanceKm} km • ${_routeResult!.totalDurationMinutes} min',
                        style: TextStyle(
                            fontSize: 11,
                            color: context.colors.mutedForeground),
                      ),
                    ]),
                    const SizedBox(height: 12),

                    for (var i = 0; i < _routeDisplayStops.length; i++) ...[
                      _routeStop(
                        context,
                        label: String.fromCharCode(65 + i),
                        color: _routeDisplayStops[i].isCommunityDeal
                            ? const Color(0xFF41B89B)
                            : Colors.purple,
                        store: _routeDisplayStops[i].storeName,
                        items: _routeDisplayStops[i].items,
                        source: _routeDisplayStops[i].source,
                      ),
                      if (i < _routeDisplayStops.length - 1) _routeConnector(),
                    ],

                    const SizedBox(height: 14),

                    // FIX 5: Savings breakdown with gross/travel/net
// FIX 5: Savings breakdown with gross/travel/net
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: context.colors.warning.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Savings breakdown',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          _savingsRow('Gross savings',
                              _routeResult!.savings.grossSavingRM,
                              isPositive: true),
                          _savingsRow('Est. travel cost',
                              _routeResult!.savings.travelCostRM,
                              isPositive: false),
                          const Divider(height: 16),
                          _savingsRow(
                              'Net savings', _routeResult!.savings.netSavingRM,
                              isPositive: true, isBold: true),
                          if (!_routeResult!.savings.worthIt)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '⚠️ Travel cost exceeds savings — consider ordering online.',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange.shade700),
                              ),
                            ),
                            
                          // 👈 3. ADD THIS AI VERDICT UI HERE
                          if (_aiRouteVerdict != null) ...[
                            const Divider(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.auto_awesome, size: 16, color: Colors.purple),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _aiRouteVerdict!,
                                    style: const TextStyle(
                                      fontSize: 12, 
                                      fontStyle: FontStyle.italic, 
                                      color: Colors.purple,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          // END OF AI VERDICT UI
                          
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () => setState(() {
                        _routeResult = null;
                        _groceryItems.clear();
                        _plannedRouteStops = [];
                        _routeDecisionNote = null;
                      }),
                      icon: const Icon(Icons.refresh_rounded, size: 14),
                      label: const Text('Change grocery list',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],

          // ── Community deals ───────────────────────────────────────────────
          Row(children: [
            const Text('Community deals',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const Spacer(),
            FilledButton(
              onPressed: _openPostDealSheet,
              style: FilledButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 14),
                  SizedBox(width: 4),
                  Text('Post Deal',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ]),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'You saved RM ${_fmt(totalSaved)} using Radar this month.',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.colors.primary),
            ),
          ),

          const SizedBox(height: 10),

          if (_loadingDeals && _apiDeals.isEmpty)
            const Center(
                child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ))
            else
            ...sortedDeals.map((deal) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  // 1. THIS GESTURE DETECTOR BRINGS THE CLICK BACK!
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedDeal = deal);
                      _mapController?.animateCamera(
                          CameraUpdate.newLatLng(LatLng(deal.latitude, deal.longitude)));
                      _showDealDetailsSheet(deal); // Opens the description sheet!
                    },
                    child: WhiteCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left: The Deal Image
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: context.colors.warning.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: _buildDealImage(deal),
                            ),
                            const SizedBox(width: 12),
                            
                            // Middle: Title, Store, Distance
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(deal.title,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 2),
                                  Text('${deal.storeName} • ${deal.category}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: context.colors.mutedForeground)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${deal.distanceKm?.toStringAsFixed(2) ?? '--'} km away\nexpires ${deal.expiryDate.day}/${deal.expiryDate.month}',
                                    style: TextStyle(
                                        fontSize: 11,
                                        height: 1.3,
                                        color: context.colors.mutedForeground),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Right: Original Price, Deal Price, and Save Badge
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'RM ${_fmt(deal.originalPrice)}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'RM ${_fmt(deal.dealPrice)}',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: context.colors.success),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: context.colors.success.withOpacity(0.14),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Save RM ${_fmt(deal.estimatedSavings)}',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: context.colors.success),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _handleUpvote(deal.id),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              foregroundColor: const Color(0xFF41B89B),
                            ),
                            icon: const Icon(Icons.thumb_up_alt_outlined,
                                size: 16),
                            label: Text('${deal.upvotes}'),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _handleDownvote(deal.id),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              foregroundColor: Colors.red.shade400,
                              side: BorderSide(color: Colors.red.shade200),
                            ),
                            icon: const Icon(Icons.thumb_down_alt_outlined,
                                size: 16),
                            label: Text(
                                '${_apiDeals.firstWhere((d) => d.dealId == deal.id, orElse: () => _communityDealToApiDeal(deal)).downvotes}'),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: () => _handleVerify(deal.id),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.verified_rounded, size: 16),
                            label: Text('${deal.verifications}'),
                          ),
                        ),
                      ]),
                    ]),
                  ),
                )),
        )],
      ),
    );
  }

  // ── Savings records modal ─────────────────────────────────────────────────

  void _showSavingsRecords(BuildContext context) {
    final summary = _monthlySummary;

    showContainedBottomSheet(
      context,
      barrierLabel: 'Savings Records',
      builder: (ctx) => SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.86,
          ),
          child: Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                24 + MediaQuery.of(ctx).padding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3ECE6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Savings this month',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary != null
                        ? '${summary.month} · ${summary.recordCount} records'
                        : 'Loading...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(ctx).hintColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF41B89B), Color(0xFF2E9B82)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total saved',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'RM ${_fmt(summary?.totalSavedRM ?? 0)}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (summary != null && summary.records.isNotEmpty) ...[
                    const Text(
                      'Recent History',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    ...summary.records.map((record) {
                      final isDeal = record['type'] == 'deal_used';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF41B89B).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              isDeal
                                  ? Icons.local_offer_rounded
                                  : Icons.route_rounded,
                              color: const Color(0xFF41B89B),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              record['dealTitle'] ??
                                  (isDeal ? 'Community Deal' : 'Smart Route'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '+ RM ${_fmt((record['amountSaved'] as num).toDouble())}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF41B89B),
                            ),
                          ),
                        ]),
                      );
                    }),
                  ] else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          summary == null
                              ? 'Loading records...'
                              : 'No savings recorded yet. Start using deals and routes!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).hintColor,
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

  // ── Sub-widgets ────────────────────────────────────────────────────────────

  Widget _legendRow(Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _routeStop(
    BuildContext context, {
    required String label,
    required Color color,
    required String store,
    required List<String> items,
    String? source,
  }) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
      ),
      const SizedBox(width: 12),
      Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Text(store, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  if (source != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(source, style: const TextStyle(fontSize: 8, color: Colors.blue)),
                    )
                  ]
                ],
              ),
          if (items.isNotEmpty)
            Text(items.join(', '),
                style: TextStyle(
                    fontSize: 11, color: context.colors.mutedForeground)),
        ]),
      ),
    ]);
  }

  Widget _routeConnector() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 4, bottom: 4),
      child:
          Container(width: 2, height: 20, color: Colors.grey.withOpacity(0.3)),
    );
  }

  Widget _savingsRow(String label, double amount,
      {required bool isPositive, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.normal)),
        const Spacer(),
        Text(
          '${isPositive ? '+' : '-'} RM ${_fmt(amount.abs())}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            color: isPositive ? const Color(0xFF41B89B) : Colors.red.shade400,
          ),
        ),
      ]),
    );
  }
}

class _RoutePlan {
  const _RoutePlan({required this.stops, required this.decisionNote});

  final List<_RoutePlanStop> stops;
  final String decisionNote;
}

class _ScoredDeal {
  const _ScoredDeal({required this.deal, required this.netValue});

  final ApiDeal deal;
  final double netValue;
}

class _RoutePlanStop {
  const _RoutePlanStop({
    required this.storeName,
    required this.lat,
    required this.lng,
    required this.items,
    required this.source,
    this.address = '',
    this.deal,
  });

  factory _RoutePlanStop.communityDeal(ApiDeal deal, List<String> items) =>
      _RoutePlanStop(
        storeName: deal.storeName,
        lat: deal.lat,
        lng: deal.lng,
        address: deal.address,
        items: items,
        source: 'ThinkTwice Community',
        deal: deal,
      );

  factory _RoutePlanStop.nearbyPlace(NearbyPlace place, List<String> items) =>
      _RoutePlanStop(
        storeName: place.name,
        lat: place.lat,
        lng: place.lng,
        address: place.address,
        items: items,
        source: 'AI recommended store',
      );

  factory _RoutePlanStop.generated({
    required String storeName,
    required double lat,
    required double lng,
    required List<String> items,
  }) =>
      _RoutePlanStop(
        storeName: storeName,
        lat: lat,
        lng: lng,
        items: items,
        source: 'AI recommended store',
      );

  final String storeName;
  final double lat;
  final double lng;
  final String address;
  final List<String> items;
  final String source;
  final ApiDeal? deal;

  bool get isCommunityDeal => deal != null;

  Map<String, dynamic> toApiStop() => {
        'storeName': storeName,
        'lat': lat,
        'lng': lng,
        'address': address,
        'items': items,
        'source': source,
        if (deal != null) ...{
          'dealId': deal!.dealId,
          'dealTitle': deal!.title,
          'dealPrice': deal!.price,
          'originalPrice': deal!.originalPrice,
          'trustScore': deal!.trustScore,
        },
      };

  _RoutePlanStop copyWith({List<String>? items}) => _RoutePlanStop(
        storeName: storeName,
        lat: lat,
        lng: lng,
        address: address,
        items: items ?? this.items,
        source: source,
        deal: deal,
      );

  double distanceFrom(LatLng origin) {
    const earthRadiusKm = 6371.0;
    final dLat = (lat - origin.latitude) * math.pi / 180;
    final dLng = (lng - origin.longitude) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(origin.latitude * math.pi / 180) *
            math.cos(lat * math.pi / 180) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earthRadiusKm * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }
}

// ─── Grocery Input Sheet ──────────────────────────────────────────────────────

class _GroceryInputSheet extends StatefulWidget {
  const _GroceryInputSheet(
      {required this.storeName, required this.initialItems});

  final String storeName;
  final List<String> initialItems;

  @override
  State<_GroceryInputSheet> createState() => _GroceryInputSheetState();
}

class _GroceryInputSheetState extends State<_GroceryInputSheet> {
  final _controller = TextEditingController();
  late List<String> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.initialItems);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addItem() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _items.add(text);
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3ECE6),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'What do you need to buy?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "We'll find the cheapest route across nearby stores.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: ['Rice', 'Eggs', 'Bread', 'Milk', 'Vegetables']
                              .map((item) => ActionChip(
                                    label: Text(
                                      item,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    onPressed: () => setState(
                                      () => _items.add(item.toLowerCase()),
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText: 'Add item (e.g. cooking oil)',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE3ECE6),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE3ECE6),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                              ),
                              onSubmitted: (_) => _addItem(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: _addItem,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF41B89B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              minimumSize: const Size(48, 48),
                            ),
                            child: const Icon(Icons.add_rounded),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        if (_items.isNotEmpty) ...[
                          const Text(
                            'Your list:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: _items
                                .map((item) => Chip(
                                      label: Text(
                                        item,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      deleteIcon: const Icon(
                                        Icons.close,
                                        size: 14,
                                      ),
                                      onDeleted: () =>
                                          setState(() => _items.remove(item)),
                                    ))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + safeBottom),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).dividerColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                  child: FilledButton(
                    onPressed:
                        _items.isEmpty ? null : () => Navigator.of(context).pop(_items),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF41B89B),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _items.isEmpty
                          ? 'Add at least one item'
                          : 'Generate cheapest route (${_items.length} items)',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Post Deal Sheet ──────────────────────────────────────────────────────────

class _PostDealResult {
  final String title;
  final String storeName;
  final String category;
  final double price;
  final double originalPrice;
  final double lat;
  final double lng;
  final String address;
  final Uint8List? imageBytes;
  final String description;

  const _PostDealResult({
    required this.title,
    required this.storeName,
    required this.category,
    required this.price,
    required this.originalPrice,
    required this.lat,
    required this.lng,
    required this.address,
    required this.description,
    this.imageBytes,
  });
}

class PostDealSheet extends StatefulWidget {
  const PostDealSheet({super.key, required this.userLocation});

  final LatLng userLocation;

  @override
  State<PostDealSheet> createState() => _PostDealSheetState();
}

class _PostDealSheetState extends State<PostDealSheet> {
  final _titleController = TextEditingController();
  final _storeController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController(text: 'Current location');
  final _descriptionController = TextEditingController();
  final _originalPriceController = TextEditingController();
  String _selectedCategory = 'food';
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));
  Uint8List? _imageBytes;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _storeController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() => _imageBytes = bytes);
  }

  void _submit() {
    final price = double.tryParse(_priceController.text) ?? 0;
    final originalPrice = double.tryParse(_originalPriceController.text) ?? price * 1.2;

    if (_titleController.text.trim().isEmpty ||
        _storeController.text.trim().isEmpty ||
        price <= 0) {
      showContainedSnackBar(
        context,
        message: 'Please fill in title, store name, and price.',
        accentColor: context.colors.warning,
        icon: Icons.info_rounded,
      );
      return;
    }
    setState(() => _submitting = true);
    Navigator.of(context).pop(_PostDealResult(
      title: _titleController.text.trim(),
      storeName: _storeController.text.trim(),
      category: _selectedCategory,
      price: price,
      originalPrice: originalPrice,
      lat: widget.userLocation.latitude + 0.0025,
      lng: widget.userLocation.longitude + 0.0025,
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? 'Near current location'
          : _addressController.text.trim(),
      imageBytes: _imageBytes,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.90,
          ),
          child: Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                    children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                      color: const Color(0xFFE3ECE6),
                      borderRadius: BorderRadius.circular(999)),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Post Community Deal',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Help others save nearby and earn points for the community.',
                  style: TextStyle(
                      fontSize: 12, color: Theme.of(context).hintColor)),
              const SizedBox(height: 16),
              _field(controller: _titleController, label: 'Deal title'),
              const SizedBox(height: 10),
              _field(controller: _storeController, label: 'Store name'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE3ECE6))),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE3ECE6))),
                ),
                items: const [
                  DropdownMenuItem(value: 'food', child: Text('Food & drinks')),
                  DropdownMenuItem(value: 'grocery', child: Text('Grocery')),
                  DropdownMenuItem(
                      value: 'transport', child: Text('Transport')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategory = v);
                },
              ),
              const SizedBox(height: 10),
              _field(controller: _originalPriceController, label: 'Original price (RM)', keyboardType: TextInputType.number),
const SizedBox(height: 10),
              _field(
                  controller: _priceController,
                  label: 'Deal price (RM)',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              _field(controller: _addressController, label: 'Address'),
              const SizedBox(height: 10),
              _field(
                  controller: _descriptionController,
                  label: 'Description (optional)',
                  maxLines: 3),
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 60)),
                    initialDate: _expiryDate,
                  );
                  if (picked != null) setState(() => _expiryDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE3ECE6)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.event_rounded, size: 18),
                    const SizedBox(width: 10),
                    Text(
                        'Expires: ${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}'),
                  ]),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _pickImage,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.image_outlined),
                label: Text(
                    _imageBytes == null ? 'Upload image' : 'Image selected ✓'),
              ),
              if (_imageBytes != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(_imageBytes!,
                      height: 140, fit: BoxFit.cover),
                ),
              ],
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + safeBottom),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).dividerColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF41B89B),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Submit deal'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE3ECE6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE3ECE6)),
        ),
      ),
    );
  }
}
