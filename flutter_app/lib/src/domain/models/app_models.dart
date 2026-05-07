import 'package:flutter/material.dart';

enum CatBreed {
  orangeTabby,
  britishShorthair,
  siamese,
  persian,
  calico,
  tuxedo,
  ragdoll,
}

enum CatHat { none, cap, crown }

class UserProfileModel {
  const UserProfileModel({
    required this.name,
    required this.school,
    required this.level,
    required this.rank,
    required this.resilience,
    required this.streak,
    required this.badges,
    required this.income,
    required this.habit,
    required this.goals,
    required this.concerns,
    required this.dailyBudget,
    required this.autoSaveRate,
    required this.spendingAlerts,
    required this.catName,
    required this.catBreed,
    required this.catHat,
    required this.catGlasses,
  });

  final String name;
  final String school;
  final int level;
  final String rank;
  final int resilience;
  final int streak;
  final int badges;
  final String income;
  final String habit;
  final List<String> goals;
  final List<String> concerns;
  final double dailyBudget;
  final double autoSaveRate;
  final bool spendingAlerts;
  final String catName;
  final CatBreed catBreed;
  final CatHat catHat;
  final bool catGlasses;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name'] as String,
      school: json['school'] as String,
      level: json['level'] as int,
      rank: json['rank'] as String,
      resilience: json['resilience'] as int,
      streak: json['streak'] as int,
      badges: json['badges'] as int,
      income: json['income'] as String,
      habit: json['habit'] as String,
      goals: List<String>.from(json['goals'] as List<dynamic>),
      concerns: List<String>.from(json['concerns'] as List<dynamic>),
      dailyBudget: (json['dailyBudget'] as num).toDouble(),
      autoSaveRate: (json['autoSaveRate'] as num).toDouble(),
      spendingAlerts: json['spendingAlerts'] as bool,
      catName: json['catName'] as String,
      catBreed: CatBreed.values.byName(json['catBreed'] as String),
      catHat: CatHat.values.byName(json['catHat'] as String),
      catGlasses: json['catGlasses'] as bool,
    );
  }

  UserProfileModel copyWith({
    String? income,
    String? habit,
    List<String>? goals,
    List<String>? concerns,
    double? dailyBudget,
    double? autoSaveRate,
    bool? spendingAlerts,
    String? catName,
    CatBreed? catBreed,
    CatHat? catHat,
    bool? catGlasses,
  }) {
    return UserProfileModel(
      name: name,
      school: school,
      level: level,
      rank: rank,
      resilience: resilience,
      streak: streak,
      badges: badges,
      income: income ?? this.income,
      habit: habit ?? this.habit,
      goals: goals ?? this.goals,
      concerns: concerns ?? this.concerns,
      dailyBudget: dailyBudget ?? this.dailyBudget,
      autoSaveRate: autoSaveRate ?? this.autoSaveRate,
      spendingAlerts: spendingAlerts ?? this.spendingAlerts,
      catName: catName ?? this.catName,
      catBreed: catBreed ?? this.catBreed,
      catHat: catHat ?? this.catHat,
      catGlasses: catGlasses ?? this.catGlasses,
    );
  }
}

class AppTransaction {
  const AppTransaction({
    required this.icon,
    required this.name,
    required this.category,
    required this.time,
    required this.amount,
    this.isRisk = false,
  });

  final IconData icon;
  final String name;
  final String category;
  final String time;
  final double amount;
  final bool isRisk;
}

class InsightCardModel {
  const InsightCardModel({
    required this.title,
    required this.subtitle,
    required this.gradient,
  });

  final String title;
  final String subtitle;
  final List<Color> gradient;
}

class RadarDeal {
  const RadarDeal({
    required this.label,
    required this.savings,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.rating,
    this.tag,
  });

  final String label;
  final double savings;
  final double latitude;
  final double longitude;
  final String description;
  final double rating;
  final String? tag;
}

class QuestModel {
  const QuestModel({
    required this.title,
    required this.reward,
    required this.progress,
    required this.subtitle,
    this.claimable = false,
  });

  final String title;
  final String reward;
  final double progress;
  final String subtitle;
  final bool claimable;
}

class NudgeModel {
  const NudgeModel({
    required this.title,
    required this.message,
    required this.riskLevel,
    required this.primaryActionLabel,
    required this.secondaryActionLabel,
    required this.impactLabel,
    this.dismissed = false,
  });

  final String title;
  final String message;
  final String riskLevel;
  final String primaryActionLabel;
  final String secondaryActionLabel;
  final String impactLabel;
  final bool dismissed;

  NudgeModel copyWith({
    String? title,
    String? message,
    String? riskLevel,
    String? primaryActionLabel,
    String? secondaryActionLabel,
    String? impactLabel,
    bool? dismissed,
  }) {
    return NudgeModel(
      title: title ?? this.title,
      message: message ?? this.message,
      riskLevel: riskLevel ?? this.riskLevel,
      primaryActionLabel: primaryActionLabel ?? this.primaryActionLabel,
      secondaryActionLabel: secondaryActionLabel ?? this.secondaryActionLabel,
      impactLabel: impactLabel ?? this.impactLabel,
      dismissed: dismissed ?? this.dismissed,
    );
  }
}
