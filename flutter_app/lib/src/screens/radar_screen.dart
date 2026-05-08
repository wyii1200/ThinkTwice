import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';


import '../core/app_theme.dart';
import '../core/models.dart';
import '../services/radar_api_service.dart';
import '../widgets/shared.dart';

// ─── Radar Page ───────────────────────────────────────────────────────────────
// Replaces seed_data deals with live data from the Smart Radar backend.
// All callbacks (onPostDeal, onUpvoteDeal, onVerifyDeal) are preserved so
// Person 3's main app shell doesn't need to change its wiring at all.

// Local helper — mirrors formatRm from shared.dart
String _fmt(double amount) => amount.toStringAsFixed(2);

class RadarPage extends StatefulWidget {
  const RadarPage({
    super.key,
    required this.deals,               // kept for compatibility — used as fallback
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

  // ── API state ──────────────────────────────────────────────────────────────
  List<ApiDeal> _apiDeals = [];
  MonthlySummary? _monthlySummary;
  bool _loadingDeals = true;
  String? _dealsError;
  String? _activeCategory = 'food';

  // Hardcoded userId — replace with real auth uid once Person 1 sets up auth
  static const String _userId = 'test_user_001';

  @override
  void initState() {
    super.initState();
    _detectLocation();
    _loadDeals();
    _loadMonthlySummary();
  }

  @override
  void didUpdateWidget(covariant RadarPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync selected deal if parent updates the list
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
        // Fall back to seed data so screen isn't empty
        _apiDeals = widget.deals.map(_communityDealToApiDeal).toList();
      });
    }
  }

  Future<void> _loadMonthlySummary() async {
    try {
      final summary =
          await RadarApiService.getMonthlySummary(userId: _userId);
      if (!mounted) return;
      setState(() => _monthlySummary = summary);
    } catch (_) {
      // Non-fatal — summary card will show fallback value
    }
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

      // Reload deals centred on real location
      await _loadDeals();
    } catch (_) {
      // Keep default center
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  // ── Voting ─────────────────────────────────────────────────────────────────

  Future<void> _handleUpvote(String dealId) async {
    try {
      await RadarApiService.upvoteDeal(dealId: dealId, userId: _userId);
      widget.onUpvoteDeal(dealId);
      await _loadDeals(); // refresh list so trust score updates
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upvoted! Trust score updated.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF41B89B),
        ),
      );
    } on AlreadyVotedException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _handleVerify(String dealId) async {
    // "Verify" in UI maps to downvote in trust system for flagging bad deals,
    // OR you can re-map this to a separate verify endpoint later.
    // For now, treat it as a community validation upvote.
    await _handleUpvote(dealId);
    widget.onVerifyDeal(dealId);
  }

  // ── Deal submission ────────────────────────────────────────────────────────

  Future<void> _openPostDealSheet() async {
    final result = await showModalBottomSheet<_PostDealResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PostDealSheet(userLocation: widget.userLocation),
    );

    if (!mounted || result == null) return;

    try {
      final apiDeal = await RadarApiService.postDeal(
        title: result.title,
        storeName: result.storeName,
        category: result.category,
        price: result.price,
        lat: result.lat,
        lng: result.lng,
        address: result.address,
        userId: _userId,
        imageBytes: result.imageBytes,
      );

      // Convert to CommunityDeal for the parent callback
      final communityDeal = _apiDealToCommunityDeal(apiDeal);
      widget.onPostDeal(communityDeal);

      setState(() {
        _apiDeals = [apiDeal, ..._apiDeals];
        _selectedDeal = communityDeal;
      });

      _mapController?.animateCamera(
          CameraUpdate.newLatLng(LatLng(apiDeal.lat, apiDeal.lng)));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deal posted! You earned points for helping others save.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF41B89B),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post deal: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ── Use a deal route ───────────────────────────────────────────────────────

  Future<void> _openNavigation(CommunityDeal deal) async {
    // Record the savings proof in the backend
    try {
      await RadarApiService.useDeal(
        userId: _userId,
        dealId: deal.id,
        amountSaved: deal.estimatedSavings,
        category: deal.category,
      );
      await _loadMonthlySummary(); // update savings card
    } catch (_) {
      // Non-fatal — still open navigation
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${deal.latitude},${deal.longitude}'
      '&travelmode=driving',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open Google Maps on this device.')),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  double _distanceTo(double lat, double lng) {
    return Geolocator.distanceBetween(
          widget.userLocation.latitude,
          widget.userLocation.longitude,
          lat,
          lng,
        ) /
        1000;
  }

  CommunityDeal _apiDealToCommunityDeal(ApiDeal d) {
    final distKm = _distanceTo(d.lat, d.lng);
    return CommunityDeal(
      id: d.dealId,
      title: d.title,
      storeName: d.storeName,
      category: d.category,
      description: '${d.category} deal at ${d.storeName}',
      expiryDate: d.expiresAt != null
          ? DateTime.tryParse(d.expiresAt!) ?? DateTime.now().add(const Duration(days: 7))
          : DateTime.now().add(const Duration(days: 7)),
      latitude: d.lat,
      longitude: d.lng,
      originalPrice: d.price * 1.2,   // estimate original as 20% above deal price
      dealPrice: d.price,
      discountLabel: 'Save RM ${_fmt(d.price * 0.2)}',
      upvotes: d.upvotes,
      verifications: d.trustScore,
      distanceKm: distKm,
    );
  }

  // Fallback: convert CommunityDeal (from seed) → ApiDeal shape for offline mode
  ApiDeal _communityDealToApiDeal(CommunityDeal d) => ApiDeal(
        dealId: d.id,
        title: d.title,
        storeName: d.storeName,
        category: d.category,
        price: d.dealPrice,
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

  Set<Marker> _markers(BuildContext context) {
    return {
      Marker(
        markerId: const MarkerId('user'),
        position: widget.userLocation,
        infoWindow: const InfoWindow(title: 'You are here'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      ..._apiDeals.map((deal) {
        return Marker(
          markerId: MarkerId(deal.dealId),
          position: LatLng(deal.lat, deal.lng),
          infoWindow: InfoWindow(
            title: deal.title,
            snippet: '${deal.storeName} • RM ${_fmt(deal.price)}',
          ),
          onTap: () => setState(
              () => _selectedDeal = _apiDealToCommunityDeal(deal)),
        );
      }),
    };
  }

  Set<Polyline> _polylines() {
    if (_selectedDeal == null) return {};
    return {
      Polyline(
        polylineId: const PolylineId('selected-route'),
        width: 5,
        color: const Color(0xFF41B89B),
        points: [
          widget.userLocation,
          LatLng(_selectedDeal!.latitude, _selectedDeal!.longitude),
        ],
      ),
    };
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sortedDeals = _apiDeals
        .map(_apiDealToCommunityDeal)
        .toList()
      ..sort((a, b) =>
          (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999));

    final selected = _selectedDeal ??
        (sortedDeals.isNotEmpty ? sortedDeals.first : null);

    // Savings shown: prefer live summary, fall back to sum of deal prices
    final totalSaved = _monthlySummary?.totalSavedRM ??
        _apiDeals.fold<double>(0, (s, d) => s + d.price * 0.2);

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
                  fontSize: 14,
                  color: context.colors.mutedForeground)),

          const SizedBox(height: 20),

          // ── Savings summary card ──────────────────────────────────────────
          GradientCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('You saved this month',
                    style: TextStyle(fontSize: 12, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  'RM ${_fmt(totalSaved)}',
                  style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  _loadingLocation
                      ? 'Detecting your location...'
                      : _monthlySummary != null
                          ? '${_monthlySummary!.recordCount} savings recorded this month'
                          : 'Live nearby deals and estimated savings',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Category filter chips ─────────────────────────────────────────
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
                    selectedColor:
                        context.colors.primary.withOpacity(0.15),
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
                Row(
                  children: [
                    const Text('Nearby deals',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    if (_loadingDeals)
                      const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    if (_dealsError != null && !_loadingDeals)
                      Icon(Icons.wifi_off_rounded,
                          size: 16, color: Colors.orange.shade700),
                  ],
                ),
                const SizedBox(height: 10),
                if (_dealsError != null && _apiDeals.isEmpty)
                  Text('Showing offline data • ${_dealsError!}',
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
                                    '${deal.storeName} • '
                                    '${deal.distanceKm?.toStringAsFixed(2) ?? '--'} km away',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: context.colors.mutedForeground),
                                  ),
                                ]),
                          ),
                          Text(
                            'RM ${_fmt(deal.dealPrice)}',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: context.colors.success),
                          ),
                        ]),
                      )),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Map ───────────────────────────────────────────────────────────
          Container(
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: widget.userLocation, zoom: 14.2),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: _markers(context),
                polylines: _polylines(),
                onMapCreated: (c) => _mapController = c,
                onTap: (_) => setState(() => _selectedDeal = null),
              ),
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
                    // Verified badge
                    if (_apiDeals
                        .any((d) => d.dealId == selected.id && d.verified))
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: context.colors.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                  Row(children: [
                    Expanded(
                        child: progressStat(context, 'Distance',
                            '${selected.distanceKm?.toStringAsFixed(2) ?? '--'} km')),
                    const SizedBox(width: 10),
                    Expanded(
                        child: progressStat(context, 'Estimated savings',
                            'RM ${_fmt(selected.estimatedSavings)}')),
                  ]),
                  const SizedBox(height: 12),
                  Text(selected.description,
                      style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: context.colors.mutedForeground)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(children: [
                      Text('Deal route ready',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: context.colors.success)),
                      const Spacer(),
                      Text(
                          'Save ${selected.discountLabel.replaceFirst('Save ', '')}',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: context.colors.success)),
                    ]),
                  ),
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

            // ── Cheapest route stops card ─────────────────────────────────
            WhiteCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cheapest route',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  _routeStop(context, 'Store A', selected.storeName,
                      selected.title),
                  const SizedBox(height: 8),
                  _routeStop(context, 'Store B', 'Fresh Mart',
                      'Eggs and pantry top-up'),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.warning.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Estimated savings: RM ${_fmt(selected.estimatedSavings + 6)}',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.colors.accentForeground),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Community deals list ──────────────────────────────────────────
          Row(children: [
            const Text('Community deals',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
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
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ]),

          const SizedBox(height: 10),

          // Savings banner
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

          // Deal cards
          if (_loadingDeals && _apiDeals.isEmpty)
            const Center(
                child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ))
          else
            ...sortedDeals.map((deal) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: WhiteCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: context.colors.warning.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: deal.imageBytes != null
                                  ? Image.memory(deal.imageBytes!,
                                      fit: BoxFit.cover)
                                  : Icon(Icons.storefront_rounded,
                                      size: 24,
                                      color: context.colors.accentForeground),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(deal.title,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 2),
                                    Text(
                                        '${deal.storeName} • ${deal.category}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                context.colors.mutedForeground)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${deal.distanceKm?.toStringAsFixed(2) ?? '--'} km away'
                                      ' • expires ${deal.expiryDate.day}/${deal.expiryDate.month}',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color:
                                              context.colors.mutedForeground),
                                    ),
                                  ]),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() => _selectedDeal = deal);
                                _mapController?.animateCamera(
                                    CameraUpdate.newLatLng(
                                        LatLng(deal.latitude, deal.longitude)));
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: context.colors.success.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Save RM ${_fmt(deal.estimatedSavings)}',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: context.colors.success),
                                ),
                              ),
                            ),
                          ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _handleUpvote(deal.id),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.thumb_up_alt_outlined,
                                size: 16),
                            label: Text('Upvote ${deal.upvotes}'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: () => _handleVerify(deal.id),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            icon:
                                const Icon(Icons.verified_rounded, size: 16),
                            label: Text('Verify ${deal.verifications}'),
                          ),
                        ),
                      ]),
                    ]),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _routeStop(
      BuildContext context, String label, String store, String item) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: context.colors.muted,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(label.split(' ').last,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(store,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          Text(item,
              style: TextStyle(
                  fontSize: 11, color: context.colors.mutedForeground)),
        ]),
      ),
    ]);
  }
}

// ─── Post Deal Sheet ──────────────────────────────────────────────────────────
// Internal result type — carries form data back to RadarPage for API call
class _PostDealResult {
  final String title;
  final String storeName;
  final String category;
  final double price;
  final double lat;
  final double lng;
  final String address;
  final Uint8List? imageBytes;

  const _PostDealResult({
    required this.title,
    required this.storeName,
    required this.category,
    required this.price,
    required this.lat,
    required this.lng,
    required this.address,
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
  final _categoryController = TextEditingController(text: 'food');
  final _priceController = TextEditingController();
  final _addressController = TextEditingController(text: 'Current location');
  final _descriptionController = TextEditingController();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));
  Uint8List? _imageBytes;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _storeController.dispose();
    _categoryController.dispose();
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

    if (_titleController.text.trim().isEmpty ||
        _storeController.text.trim().isEmpty ||
        price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please fill in title, store name, and price.')),
      );
      return;
    }

    setState(() => _submitting = true);

    Navigator.of(context).pop(_PostDealResult(
      title: _titleController.text.trim(),
      storeName: _storeController.text.trim(),
      category: _categoryController.text.trim().toLowerCase(),
      price: price,
      lat: widget.userLocation.latitude + 0.0025,
      lng: widget.userLocation.longitude + 0.0025,
      address: _addressController.text.trim().isEmpty
          ? 'Near current location'
          : _addressController.text.trim(),
      imageBytes: _imageBytes,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.65,
      maxChildSize: 0.96,
      builder: (context, controller) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: controller,
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
              const Text('Post Community Deal',
                  style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                  'Help others save nearby and earn points for the community.',
                  style: TextStyle(
                      fontSize: 12, color: Theme.of(context).hintColor)),
              const SizedBox(height: 16),
              _field(controller: _titleController, label: 'Deal title'),
              const SizedBox(height: 10),
              _field(controller: _storeController, label: 'Store name'),
              const SizedBox(height: 10),
              // Category dropdown
              DropdownButtonFormField<String>(
                value: _categoryController.text,
                decoration: InputDecoration(
                  labelText: 'Category',
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
                items: const [
                  DropdownMenuItem(value: 'food', child: Text('Food & drinks')),
                  DropdownMenuItem(
                      value: 'grocery', child: Text('Grocery')),
                  DropdownMenuItem(
                      value: 'transport', child: Text('Transport')),
                ],
                onChanged: (v) {
                  if (v != null) _categoryController.text = v;
                },
              ),
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
              // Expiry date picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate:
                        DateTime.now().add(const Duration(days: 60)),
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
                label: Text(_imageBytes == null
                    ? 'Upload image'
                    : 'Image selected ✓'),
              ),
              if (_imageBytes != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(_imageBytes!,
                      height: 140, fit: BoxFit.cover),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF41B89B),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Submit deal'),
              ),
            ],
          ),
        );
      },
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