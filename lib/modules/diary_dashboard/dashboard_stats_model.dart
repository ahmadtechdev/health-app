import 'package:intl/intl.dart';

class CalorieDayData {
  final DateTime date;
  final double calories;
  final double target;

  CalorieDayData({
    required this.date,
    required this.calories,
    required this.target,
  });

  double get deviation => calories - target;

  bool get isOver => deviation > 0;

  bool get isUnder => deviation < 0;

  String get label => DateFormat('MMM d').format(date);
}

class DashboardStatsModel {
  final double thisWeekCalories;
  final double thisWeekDifference;
  final int bestStreak;
  final double averageDeviation;
  final CalorieDayData? highestDay;
  final CalorieDayData? lowestDay;
  final double underPercentage;
  final double overPercentage;
  final List<double> weeklyAverages;

  DashboardStatsModel({
    required this.thisWeekCalories,
    required this.thisWeekDifference,
    required this.bestStreak,
    required this.averageDeviation,
    required this.highestDay,
    required this.lowestDay,
    required this.underPercentage,
    required this.overPercentage,
    required this.weeklyAverages,
  });
}

