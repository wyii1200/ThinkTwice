import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../widgets/app_shell.dart';

class RadarScreen extends ConsumerWidget {
  const RadarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deals = ref.watch(mockRepositoryProvider).loadDeals();
    final markers = deals
        .map(
          (deal) => Marker(
            markerId: MarkerId(deal.label),
            position: LatLng(deal.latitude, deal.longitude),
            infoWindow: InfoWindow(
              title: deal.label,
              snippet: 'Save RM${deal.savings.toStringAsFixed(0)}',
            ),
          ),
        )
        .toSet();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart Radar',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Best deals within 2km · Petaling Jaya',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'POTENTIAL SAVE',
                    style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: AppColors.muted),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'RM 14',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.emerald),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: SizedBox(
              height: 290,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(3.1097, 101.6118),
                      zoom: 14.5,
                    ),
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                    markers: markers,
                  ),
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 18,
                    child: GlassCard(
                      strong: true,
                      radius: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.ai),
                              SizedBox(width: 6),
                              Text(
                                'AI ROUTE · Cheapest combo',
                                style: TextStyle(fontSize: 11, color: AppColors.ai, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Jaya Grocer → Tesco → Mydin',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Rice · Eggs & Milk · Veggies',
                            style: TextStyle(fontSize: 11, color: AppColors.muted),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ESTIMATED SAVINGS',
                                      style: TextStyle(fontSize: 10, color: AppColors.muted),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'RM 14.20',
                                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.emerald),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          GradientButton(
            label: 'Start route',
            gradient: AppColors.emeraldGradient,
            onTap: () {},
          ),
          const SizedBox(height: 18),
          const AppSectionTitle(
            'Community deals',
            trailing: Text(
              'Verified by 124 students',
              style: TextStyle(fontSize: 10, color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 10),
          for (final deal in deals) ...[
            GlassCard(
              radius: 22,
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppColors.emeraldGradient),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.place_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              deal.label,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            if (deal.tag != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.risk.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  deal.tag!,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: AppColors.risk,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          deal.description,
                          style: const TextStyle(fontSize: 11, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: AppColors.gold),
                      const SizedBox(height: 2),
                      Text(
                        deal.rating.toString(),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
