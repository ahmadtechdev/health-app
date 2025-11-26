import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../profile/profile_controller.dart';
import '../profile/profile_model.dart';
import 'dashboard_stats_model.dart';

class DiaryDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<CalorieDayData> _daysData = <CalorieDayData>[].obs;
  final Rxn<DashboardStatsModel> _stats = Rxn<DashboardStatsModel>();
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxDouble _targetCalories = 2000.0.obs;

  List<CalorieDayData> get daysData => _daysData;
  DashboardStatsModel? get stats => _stats.value;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  bool get hasData => _daysData.isNotEmpty;

  List<CalorieDayData> get lastSevenDays =>
      _daysData.length >= 7 ? _daysData.sublist(_daysData.length - 7) : _daysData;

  double get targetCalories => _targetCalories.value;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final user = _auth.currentUser;
    if (user == null) {
      _hasError.value = true;
      return;
    }

    _isLoading.value = true;
    _hasError.value = false;

    try {
      await _loadTargetCalories();
      await _loadDaysData(user.uid);
      _computeStats();
    } catch (e) {
      _hasError.value = true;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadTargetCalories() async {
    ProfileModel? profile;
    if (Get.isRegistered<ProfileController>()) {
      profile = Get.find<ProfileController>().profile;
    }

    double? target = profile?.goalCalories;
    if (target == null) {
      final user = _auth.currentUser;
      if (user != null) {
        final profileDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('profile')
            .doc('data')
            .get();

        if (profileDoc.exists && profileDoc.data() != null) {
          target = (profileDoc.data()!['goalCalories'] as num?)?.toDouble();
        }
      }
    }

    _targetCalories.value = target ?? 2000;
  }

  Future<void> _loadDaysData(String userId) async {
    final now = DateTime.now();
    final List<CalorieDayData> result = [];
    for (int i = 29; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final calories = await _fetchDailyCalories(userId, date);
      result.add(
        CalorieDayData(
          date: date,
          calories: calories,
          target: _targetCalories.value,
        ),
      );
    }
    _daysData.assignAll(result);
  }

  Future<double> _fetchDailyCalories(String userId, DateTime date) async {
    final key = DateFormat('yyyy-MM-dd').format(date);
    final entriesSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('diary')
        .doc(key)
        .collection('entries')
        .get();

    double total = 0;
    for (final doc in entriesSnapshot.docs) {
      final calories = (doc.data()['calories'] as num?)?.toDouble() ?? 0;
      total += calories;
    }
    return total;
  }

  void _computeStats() {
    if (_daysData.isEmpty) {
      _stats.value = null;
      return;
    }

    final weekData = _daysData.length >= 7
        ? _daysData.sublist(_daysData.length - 7)
        : _daysData;

    final thisWeekCalories =
        weekData.fold<double>(0, (sum, day) => sum + day.calories);
    final thisWeekDifference =
        weekData.fold<double>(0, (sum, day) => sum + (day.target - day.calories));

    final bestStreak = _calculateBestStreak(_daysData);
    final averageDeviation = _daysData
            .map((day) => (day.calories - day.target).abs())
            .fold<double>(0, (sum, value) => sum + value) /
        _daysData.length;

    final highestDay =
        _daysData.reduce((a, b) => a.calories >= b.calories ? a : b);
    final lowestDay =
        _daysData.reduce((a, b) => a.calories <= b.calories ? a : b);

    final underCount = _daysData.where((day) => day.calories <= day.target).length;
    final overCount = _daysData.length - underCount;

    final underPercentage = (_daysData.isEmpty)
        ? 0.0
        : (underCount / _daysData.length) * 100.0;
    final overPercentage = 100.0 - underPercentage;

    final weeklyAverages = _calculateWeeklyAverages(_daysData);

    _stats.value = DashboardStatsModel(
      thisWeekCalories: thisWeekCalories,
      thisWeekDifference: thisWeekDifference,
      bestStreak: bestStreak,
      averageDeviation: averageDeviation,
      highestDay: highestDay,
      lowestDay: lowestDay,
      underPercentage: underPercentage,
      overPercentage: overPercentage,
      weeklyAverages: weeklyAverages,
    );
  }

  int _calculateBestStreak(List<CalorieDayData> days) {
    int best = 0;
    int current = 0;
    for (final day in days) {
      if (day.calories <= day.target) {
        current += 1;
        if (current > best) best = current;
      } else {
        current = 0;
      }
    }
    return best;
  }

  List<double> _calculateWeeklyAverages(List<CalorieDayData> days) {
    final List<double> averages = [];
    for (int i = 0; i < days.length; i += 7) {
      final slice = days.skip(i).take(7).toList();
      if (slice.isEmpty) continue;
      final avg =
          slice.fold<double>(0, (sum, day) => sum + day.calories) / slice.length;
      averages.add(avg);
    }
    return averages;
  }
}

