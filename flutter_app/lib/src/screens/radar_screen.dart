import 'dart:typed_data';
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
    if (_selectedDeal == null) return;

    final items = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _GroceryInputSheet(
        storeName: _selectedDeal!.storeName,
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
    });

    try {
      // Only send lat/lng — never address strings (causes Directions API NOT_FOUND)
      final stops = [
        {
          'storeName': _selectedDeal!.storeName,
          'lat': _selectedDeal!.latitude,
          'lng': _selectedDeal!.longitude,
          'items': items.take((items.length / 2).ceil()).toList(),
        },
        {
          'storeName': 'Fresh Mart',
          'lat': widget.userLocation.latitude + 0.008,
          'lng': widget.userLocation.longitude + 0.005,
          'items': items.skip((items.length / 2).ceil()).toList(),
        },
      ];

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
      });
    }
  }

  void _animateMapToRoute() {
    if (_selectedDeal == null) return;

    final stopBLat = widget.userLocation.latitude + 0.008;
    final stopBLng = widget.userLocation.longitude + 0.005;

    final allLats = [
      widget.userLocation.latitude,
      _selectedDeal!.latitude,
      stopBLat,
    ];
    final allLngs = [
      widget.userLocation.longitude,
      _selectedDeal!.longitude,
      stopBLng,
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(switched
            ? 'Switched to upvote — trust score updated.'
            : 'Upvoted! Trust score updated.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF41B89B),
      ));
    } on AlreadyVotedException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You already upvoted this deal.'),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not upvote: $e'),
        behavior: SnackBarBehavior.floating,
      ));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(switched
            ? 'Switched to downvote — trust score updated.'
            : 'Downvoted — trust score reduced.'),
        behavior: SnackBarBehavior.floating,
      ));
    } on AlreadyVotedException catch (e) {
      if (!mounted) return;
      // "Already downvoted" or "own deal" — show clean message
      final msg = e.message.contains('own deal')
          ? 'You cannot downvote your own deal.'
          : 'You already downvoted this deal.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not downvote: $e'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  // ── Post deal ──────────────────────────────────────────────────────────────

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
        originalPrice: result.originalPrice ,
        lat: result.lat,
        lng: result.lng,
        address: result.address,
        userId: _userId,
        imageBytes: result.imageBytes,
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text('Deal posted! You earned points for helping others save.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF41B89B),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to post deal: $e'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ));
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.celebration, color: Colors.white),
              const SizedBox(width: 12),
              Text('Awesome! Added RM ${(deal.originalPrice - deal.dealPrice).toStringAsFixed(2)} to your savings.'),
            ],
          ),
          backgroundColor: const Color(0xFF41B89B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to claim deal: $e')),
      );
    }
  }

  // 2. The Bottom Sheet UI
  void _showDealDetailsSheet(CommunityDeal deal) {
    final isOwner = deal.submittedBy == _userId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(deal.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('${deal.storeName} • ${deal.category}', style: TextStyle(color: context.colors.mutedForeground)),
            
            const SizedBox(height: 16),
            Container(
              height: 180, width: double.infinity,
              decoration: BoxDecoration(color: context.colors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              clipBehavior: Clip.antiAlias,
              child: _buildDealImage(deal),
            ),
            
            const SizedBox(height: 16),
            // THE DESCRIPTION YOU WANTED
            const Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(deal.description.isNotEmpty ? deal.description : 'No description provided.', 
                 style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4)),
            
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Deal Price', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('RM ${deal.dealPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 24, color: context.colors.success, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Usually', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('RM ${deal.originalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, decoration: TextDecoration.lineThrough, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // THE CLAIM BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _claimDeal(deal);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.success,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Claim Deal & Record Savings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            // EDIT/DELETE IF IT'S THEIR OWN DEAL
            if (isOwner) ...[
              const Divider(height: 32),
              Row(
                children: [
                // Inside _showDealDetailsSheet under the "Edit" button:
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(ctx); // Close details sheet
                        
                        // Simple edit dialog
                        final titleCtrl = TextEditingController(text: deal.title);
                        final priceCtrl = TextEditingController(text: deal.dealPrice.toString());
                        final descCtrl = TextEditingController(text: deal.description);
                        final origPriceCtrl = TextEditingController(text: deal.originalPrice.toString());

                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Edit Deal'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                                TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Price (RM)')),
                                TextField(controller: origPriceCtrl, decoration: const InputDecoration(labelText: 'Original Price (RM)'), keyboardType: TextInputType.number),
                                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
                              ],
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                              FilledButton(
                                onPressed: () async {
                                  await RadarApiService.editDeal(
                                    dealId: deal.id,
                                    userId: _userId,
                                    title: titleCtrl.text,
                                    price: double.tryParse(priceCtrl.text) ?? deal.dealPrice,
                                    description: descCtrl.text,
                                    originalPrice: double.tryParse(origPriceCtrl.text) ?? deal.originalPrice,
                                  );
                                  Navigator.pop(context);
                                  _loadDeals(); // Refresh the screen!
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deal updated!')));
                                },
                                child: const Text('Save'),
                              )
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          await RadarApiService.deleteDeal(dealId: deal.id, userId: _userId);
                          Navigator.pop(ctx);
                          _loadDeals(); // Refresh list
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deal deleted')));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.shade200),
                      ),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Delete'),
                    ),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }


  // ── Use route ──────────────────────────────────────────────────────────────

  Future<void> _openNavigation(CommunityDeal deal) async {
    try {
      await RadarApiService.useDeal(
        userId: _userId,
        dealId: deal.id,
        amountSaved: deal.estimatedSavings,
        category: deal.category,
        dealTitle: deal.title, // <--- Add this property to your Api Service
      );
      if (_routeResult != null) {
        await RadarApiService.acceptRoute(
          userId: _userId,
          routeId: _routeResult!.routeId,
          actualSavingsRM: _routeResult!.savings.netSavingRM,
        );
      }
      await _loadMonthlySummary();
    } catch (_) {}

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
      const SnackBar(content: Text('Could not open Google Maps.')),
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
      description: d.description ?? '${d.category} deal at ${d.storeName}',

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
    if (_routeResult != null && _selectedDeal != null) {
      // Stop A — selected deal
      markers.add(Marker(
        markerId: const MarkerId('stop_A'),
        position: LatLng(_selectedDeal!.latitude, _selectedDeal!.longitude),
        infoWindow: InfoWindow(
          title: 'Stop A — ${_selectedDeal!.storeName}',
          snippet: _groceryItems.take(3).join(', '),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
      // Stop B — nearby store
      markers.add(Marker(
        markerId: const MarkerId('stop_B'),
        position: LatLng(
          widget.userLocation.latitude + 0.008,
          widget.userLocation.longitude + 0.005,
        ),
        infoWindow: InfoWindow(
          title: 'Stop B — Fresh Mart',
          snippet: _groceryItems
              .skip((_groceryItems.length / 2).ceil())
              .take(3)
              .join(', '),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ));
    }

    return markers;
  }

  Set<Polyline> _polylines() {
    if (_routeResult != null && _selectedDeal != null) {
      return {
        Polyline(
          polylineId: const PolylineId('route-full'),
          width: 5,
          color: const Color(0xFF41B89B),
          points: [
            widget.userLocation,
            LatLng(_selectedDeal!.latitude, _selectedDeal!.longitude),
            LatLng(
              widget.userLocation.latitude + 0.008,
              widget.userLocation.longitude + 0.005,
            ),
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
                          const SizedBox(height: 4),
                          _legendRow(const Color(0xFF41B89B),
                              'A — ${selected?.storeName ?? ''}'),
                          const SizedBox(height: 4),
                          _legendRow(Colors.purple, 'B — Fresh Mart'),
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

                   _routeStop(context,
                        label: 'A',
                        color: const Color(0xFF41B89B),
                        store: _routeResult!.orderedStops.isNotEmpty
                            ? _routeResult!.orderedStops[0].storeName
                            : selected.storeName,
                        items: _routeResult!.orderedStops.isNotEmpty
                            ? _routeResult!.orderedStops[0].items
                            : _groceryItems.take((_groceryItems.length / 2).ceil()).toList(),
                        source: _routeResult!.orderedStops.isNotEmpty ? 'ThinkTwice Community' : null),
                    _routeConnector(),
                    _routeStop(context,
                        label: 'B',
                        color: Colors.purple,
                        store: 'Fresh Mart',
                        items: _groceryItems
                            .skip((_groceryItems.length / 2).ceil())
                            .toList()),

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



    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                    borderRadius: BorderRadius.circular(999)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Savings this month',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              summary != null
                  ? '${summary.month} · ${summary.recordCount} records'
                  : 'Loading...',
              style: TextStyle(fontSize: 12, color: Theme.of(ctx).hintColor),
            ),
            const SizedBox(height: 20),

            // Total
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
                  const Text('Total saved',
                      style: TextStyle(fontSize: 12, color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(
                    'RM ${_fmt(summary?.totalSavedRM ?? 0)}',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Breakdown / Recent History
            if (summary != null && summary.records.isNotEmpty) ...[
              const Text('Recent History', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              ...summary.records.map((record) {
                // Change icon based on whether it was a deal or a route
                final isDeal = record['type'] == 'deal_used';
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF41B89B).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        isDeal ? Icons.local_offer_rounded : Icons.route_rounded, 
                        color: const Color(0xFF41B89B), 
                        size: 18
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        record['dealTitle'] ?? (isDeal ? 'Community Deal' : 'Smart Route'), 
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)
                      ),
                    ),
                    Text(
                      '+ RM ${_fmt((record['amountSaved'] as num).toDouble())}', 
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF41B89B))
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
                    style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor),
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
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
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                  borderRadius: BorderRadius.circular(999)),
            ),
          ),
          const SizedBox(height: 14),
          const Text('What do you need to buy?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text("We'll find the cheapest route across nearby stores.",
              style:
                  TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
          const SizedBox(height: 16),

          // Quick-add chips
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: ['Rice', 'Eggs', 'Bread', 'Milk', 'Vegetables']
                .map((item) => ActionChip(
                      label: Text(item, style: const TextStyle(fontSize: 12)),
                      onPressed: () =>
                          setState(() => _items.add(item.toLowerCase())),
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
                    borderSide: const BorderSide(color: Color(0xFFE3ECE6)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE3ECE6)),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    borderRadius: BorderRadius.circular(14)),
                minimumSize: const Size(48, 48),
              ),
              child: const Icon(Icons.add_rounded),
            ),
          ]),

          const SizedBox(height: 12),

          if (_items.isNotEmpty) ...[
            const Text('Your list:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _items
                  .map((item) => Chip(
                        label: Text(item, style: const TextStyle(fontSize: 12)),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => setState(() => _items.remove(item)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _items.isEmpty
                  ? null
                  : () => Navigator.of(context).pop(_items),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF41B89B),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
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

  const _PostDealResult({
    required this.title,
    required this.storeName,
    required this.category,
    required this.price,
    required this.originalPrice,
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill in title, store name, and price.')));
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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