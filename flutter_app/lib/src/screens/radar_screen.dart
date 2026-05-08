import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../core/app_theme.dart';
import '../core/models.dart';
import '../core/seed_data.dart';
import '../widgets/shared.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedDeal = widget.deals.isNotEmpty ? _withDistance(widget.deals.first) : null;
    _detectLocation();
  }

  @override
  void didUpdateWidget(covariant RadarPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedDeal != null) {
      final updated = widget.deals.where((deal) => deal.id == _selectedDeal!.id);
      if (updated.isNotEmpty) {
        _selectedDeal = _withDistance(updated.first);
      }
    } else if (widget.deals.isNotEmpty) {
      _selectedDeal = _withDistance(widget.deals.first);
    }
  }

  Future<void> _detectLocation() async {
    setState(() => _loadingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      final current = LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      widget.onLocationChanged(current);
      _mapController?.animateCamera(CameraUpdate.newLatLng(current));
      setState(() {
        if (_selectedDeal != null) {
          _selectedDeal = _withDistance(_selectedDeal!);
        }
      });
    } catch (_) {
      // Keep the default center when location is unavailable.
    } finally {
      if (mounted) {
        setState(() => _loadingLocation = false);
      }
    }
  }

  CommunityDeal _withDistance(CommunityDeal deal) {
    final meters = Geolocator.distanceBetween(
      widget.userLocation.latitude,
      widget.userLocation.longitude,
      deal.latitude,
      deal.longitude,
    );
    return deal.copyWith(distanceKm: meters / 1000);
  }

  Set<Marker> _markers(BuildContext context) {
    return {
      Marker(
        markerId: const MarkerId('user'),
        position: widget.userLocation,
        infoWindow: const InfoWindow(title: 'You are here'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      ...widget.deals.map((deal) {
        final enhanced = _withDistance(deal);
        return Marker(
          markerId: MarkerId(deal.id),
          position: LatLng(deal.latitude, deal.longitude),
          infoWindow: InfoWindow(
            title: deal.title,
            snippet: '${deal.storeName} • Save RM ${formatRm(deal.estimatedSavings)}',
          ),
          onTap: () {
            setState(() => _selectedDeal = enhanced);
          },
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

  Future<void> _openPostDealSheet() async {
    final newDeal = await showModalBottomSheet<CommunityDeal>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PostDealSheet(userLocation: widget.userLocation),
    );

    if (!mounted || newDeal == null) return;
    widget.onPostDeal(newDeal);
    setState(() => _selectedDeal = _withDistance(newDeal));
    _mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(newDeal.latitude, newDeal.longitude)));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Deal posted! You earned points for helping others save.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF41B89B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedDeals = widget.deals.map(_withDistance).toList()
      ..sort((a, b) => (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999));
    final selected = _selectedDeal != null ? _withDistance(_selectedDeal!) : (sortedDeals.isNotEmpty ? sortedDeals.first : null);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Smart Radar', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Deals, routes, and community savings near you', style: TextStyle(fontSize: 14, color: context.colors.mutedForeground)),
          const SizedBox(height: 20),
          GradientCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('You saved this month', style: TextStyle(fontSize: 12, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  'RM ${formatRm(widget.deals.fold<double>(0, (sum, deal) => sum + deal.estimatedSavings))}',
                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  _loadingLocation ? 'Detecting your location...' : 'Live nearby deals and estimated savings',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: widget.userLocation, zoom: 14.2),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: _markers(context),
                polylines: _polylines(),
                onMapCreated: (controller) => _mapController = controller,
                onTap: (_) => setState(() => _selectedDeal = null),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (selected != null)
            WhiteCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: context.colors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.route_rounded, color: context.colors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(selected.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                            Text(selected.storeName, style: TextStyle(fontSize: 12, color: context.colors.mutedForeground)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: progressStat(context, 'Distance', '${selected.distanceKm?.toStringAsFixed(2) ?? '--'} km')),
                      const SizedBox(width: 10),
                      Expanded(child: progressStat(context, 'Estimated savings', 'RM ${formatRm(selected.estimatedSavings)}')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(selected.description, style: TextStyle(fontSize: 12, height: 1.4, color: context.colors.mutedForeground)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text('Deal route ready', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.success)),
                        const Spacer(),
                        Text('Save ${selected.discountLabel.replaceFirst('Save ', '')}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.colors.success)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Community deals', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const Spacer(),
              FilledButton(
                onPressed: _openPostDealSheet,
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 14),
                    SizedBox(width: 4),
                    Text('Post Community Deal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...sortedDeals.map((deal) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: WhiteCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
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
                              ? Image.memory(deal.imageBytes!, fit: BoxFit.cover)
                              : Icon(Icons.storefront_rounded, size: 24, color: context.colors.accentForeground),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(deal.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text('${deal.storeName} • ${deal.category}', style: TextStyle(fontSize: 12, color: context.colors.mutedForeground)),
                              const SizedBox(height: 4),
                              Text(
                                '${deal.distanceKm?.toStringAsFixed(2) ?? '--'} km away • expires ${deal.expiryDate.day}/${deal.expiryDate.month}',
                                style: TextStyle(fontSize: 11, color: context.colors.mutedForeground),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() => _selectedDeal = deal);
                            _mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(deal.latitude, deal.longitude)));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.colors.success.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Save RM ${formatRm(deal.estimatedSavings)}',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: context.colors.success),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => widget.onUpvoteDeal(deal.id),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.thumb_up_alt_outlined, size: 16),
                            label: Text('Upvote ${deal.upvotes}'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: () => widget.onVerifyDeal(deal.id),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.verified_rounded, size: 16),
                            label: Text('Verify ${deal.verifications}'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

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
  final _categoryController = TextEditingController(text: 'Food & drinks');
  final _originalPriceController = TextEditingController();
  final _dealPriceController = TextEditingController();
  final _locationController = TextEditingController(text: 'Use current location');
  final _descriptionController = TextEditingController();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 2));
  Uint8List? _imageBytes;

  @override
  void dispose() {
    _titleController.dispose();
    _storeController.dispose();
    _categoryController.dispose();
    _originalPriceController.dispose();
    _dealPriceController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() => _imageBytes = bytes);
  }

  void _submit() {
    final originalPrice = double.tryParse(_originalPriceController.text) ?? 0;
    final dealPrice = double.tryParse(_dealPriceController.text) ?? 0;
    if (_titleController.text.trim().isEmpty ||
        _storeController.text.trim().isEmpty ||
        _categoryController.text.trim().isEmpty ||
        originalPrice <= 0 ||
        dealPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the deal form before posting.')),
      );
      return;
    }

    final newDeal = CommunityDeal(
      id: 'deal-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      storeName: _storeController.text.trim(),
      category: _categoryController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? 'Community-submitted savings deal.' : _descriptionController.text.trim(),
      expiryDate: _expiryDate,
      latitude: widget.userLocation.latitude + 0.0025,
      longitude: widget.userLocation.longitude + 0.0025,
      originalPrice: originalPrice,
      dealPrice: dealPrice,
      discountLabel: 'Save RM ${formatRm(originalPrice - dealPrice)}',
      upvotes: 1,
      verifications: 0,
      imageBytes: _imageBytes,
      postedByUser: true,
    );

    Navigator.of(context).pop(newDeal);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: DraggableScrollableSheet(
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
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Post Community Deal', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Help others save nearby and earn points for the community.', style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                const SizedBox(height: 16),
                _dealField(controller: _titleController, label: 'Deal title'),
                const SizedBox(height: 10),
                _dealField(controller: _storeController, label: 'Store name'),
                const SizedBox(height: 10),
                _dealField(controller: _categoryController, label: 'Category'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _dealField(controller: _originalPriceController, label: 'Original price')),
                    const SizedBox(width: 10),
                    Expanded(child: _dealField(controller: _dealPriceController, label: 'Price / discount')),
                  ],
                ),
                const SizedBox(height: 10),
                _dealField(controller: _locationController, label: 'Location'),
                const SizedBox(height: 10),
                _dealField(controller: _descriptionController, label: 'Description', maxLines: 3),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                      initialDate: _expiryDate,
                    );
                    if (picked != null) {
                      setState(() => _expiryDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE3ECE6)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_rounded, size: 18),
                        const SizedBox(width: 10),
                        Expanded(child: Text('Expiry date: ${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.image_outlined),
                  label: Text(_imageBytes == null ? 'Upload image' : 'Image selected'),
                ),
                if (_imageBytes != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(_imageBytes!, height: 140, fit: BoxFit.cover),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF41B89B),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Submit deal'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _dealField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
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




