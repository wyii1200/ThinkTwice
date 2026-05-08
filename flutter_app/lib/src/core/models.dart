import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class BudgetAllocation {
  const BudgetAllocation({
    required this.name,
    required this.percent,
    required this.amount,
    required this.color,
  });

  final String name;
  final double percent;
  final double amount;
  final Color color;
}

class BudgetPlan {
  const BudgetPlan({
    required this.dailyLimit,
    required this.savingsAmount,
    required this.savingsRate,
    required this.flexibleSpend,
    required this.adaptabilityScore,
    required this.allocations,
    required this.recommendations,
  });

  final double dailyLimit;
  final double savingsAmount;
  final double savingsRate;
  final double flexibleSpend;
  final int adaptabilityScore;
  final List<BudgetAllocation> allocations;
  final List<String> recommendations;
}

class CommunityDeal {
  const CommunityDeal({
    required this.id,
    required this.title,
    required this.storeName,
    required this.category,
    required this.description,
    required this.expiryDate,
    required this.latitude,
    required this.longitude,
    required this.originalPrice,
    required this.dealPrice,
    required this.discountLabel,
    required this.upvotes,
    required this.verifications,
    this.imageBytes,
    this.distanceKm,
    this.postedByUser = false,
  });

  final String id;
  final String title;
  final String storeName;
  final String category;
  final String description;
  final DateTime expiryDate;
  final double latitude;
  final double longitude;
  final double originalPrice;
  final double dealPrice;
  final String discountLabel;
  final int upvotes;
  final int verifications;
  final Uint8List? imageBytes;
  final double? distanceKm;
  final bool postedByUser;

  double get estimatedSavings => math.max(0, originalPrice - dealPrice);

  CommunityDeal copyWith({
    String? id,
    String? title,
    String? storeName,
    String? category,
    String? description,
    DateTime? expiryDate,
    double? latitude,
    double? longitude,
    double? originalPrice,
    double? dealPrice,
    String? discountLabel,
    int? upvotes,
    int? verifications,
    Uint8List? imageBytes,
    double? distanceKm,
    bool? postedByUser,
  }) {
    return CommunityDeal(
      id: id ?? this.id,
      title: title ?? this.title,
      storeName: storeName ?? this.storeName,
      category: category ?? this.category,
      description: description ?? this.description,
      expiryDate: expiryDate ?? this.expiryDate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      originalPrice: originalPrice ?? this.originalPrice,
      dealPrice: dealPrice ?? this.dealPrice,
      discountLabel: discountLabel ?? this.discountLabel,
      upvotes: upvotes ?? this.upvotes,
      verifications: verifications ?? this.verifications,
      imageBytes: imageBytes ?? this.imageBytes,
      distanceKm: distanceKm ?? this.distanceKm,
      postedByUser: postedByUser ?? this.postedByUser,
    );
  }
}

class PointsEvent {
  const PointsEvent({
    required this.label,
    required this.points,
    required this.icon,
  });

  final String label;
  final int points;
  final IconData icon;
}

class QuestProgress {
  const QuestProgress({
    required this.id,
    required this.title,
    required this.progress,
    required this.progressLabel,
    required this.rewardLabel,
    required this.rewardPoints,
    required this.isCompleted,
    this.isClaimed = false,
  });

  final String id;
  final String title;
  final double progress;
  final String progressLabel;
  final String rewardLabel;
  final int rewardPoints;
  final bool isCompleted;
  final bool isClaimed;

  QuestProgress copyWith({
    String? id,
    String? title,
    double? progress,
    String? progressLabel,
    String? rewardLabel,
    int? rewardPoints,
    bool? isCompleted,
    bool? isClaimed,
  }) {
    return QuestProgress(
      id: id ?? this.id,
      title: title ?? this.title,
      progress: progress ?? this.progress,
      progressLabel: progressLabel ?? this.progressLabel,
      rewardLabel: rewardLabel ?? this.rewardLabel,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}

class RewardShopItem {
  const RewardShopItem({
    required this.id,
    required this.name,
    required this.price,
    required this.icon,
    required this.category,
    this.value,
    this.owned = false,
  });

  final String id;
  final String name;
  final int price;
  final IconData icon;
  final String category;
  final String? value;
  final bool owned;

  RewardShopItem copyWith({
    String? id,
    String? name,
    int? price,
    IconData? icon,
    String? category,
    String? value,
    bool? owned,
  }) {
    return RewardShopItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      value: value ?? this.value,
      owned: owned ?? this.owned,
    );
  }
}

class AvatarCustomizationResult {
  const AvatarCustomizationResult({
    required this.accessory,
    required this.outfit,
    required this.cosmetic,
    required this.purchasedItemIds,
  });

  final String accessory;
  final String outfit;
  final String cosmetic;
  final Set<String> purchasedItemIds;
}






