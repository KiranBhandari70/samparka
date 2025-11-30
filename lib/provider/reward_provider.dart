import 'package:flutter/foundation.dart';
import '../data/models/reward_transaction_model.dart';
import '../data/services/reward_service.dart';

class RewardProvider extends ChangeNotifier {
  RewardProvider() : _rewardService = RewardService.instance;

  final RewardService _rewardService;

  RewardDashboardData? _dashboardData;
  List<RewardTransaction> _rewardHistory = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  RewardDashboardData? get dashboardData => _dashboardData;
  List<RewardTransaction> get rewardHistory => _rewardHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get currentBalance => _dashboardData?.balance ?? 0;
  int get monthlyEarned => _dashboardData?.monthlyEarned ?? 0;
  List<RewardTransaction> get recentActivity => _dashboardData?.recentActivity ?? [];

  // Load reward dashboard data
  Future<void> loadRewardDashboard(String userId) async {
    if (userId.isEmpty) return;

    _setLoading(true);
    _clearError();

    try {
      _dashboardData = await _rewardService.getRewardDashboard(userId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load reward history with pagination
  Future<void> loadRewardHistory(String userId, {bool refresh = false}) async {
    if (userId.isEmpty) return;

    if (refresh) {
      _rewardHistory.clear();
    }

    _setLoading(true);
    _clearError();

    try {
      final newTransactions = await _rewardService.getRewardHistory(
        userId,
        limit: 20,
        offset: refresh ? 0 : _rewardHistory.length,
      );

      if (refresh) {
        _rewardHistory = newTransactions;
      } else {
        _rewardHistory.addAll(newTransactions);
      }

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Redeem reward points
  Future<bool> redeemPoints({
    required String userId,
    required int amount,
    required String partnerName,
    required String offerDescription,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _rewardService.redeemRewardPoints(
        userId: userId,
        amount: amount,
        partnerName: partnerName,
        offerDescription: offerDescription,
      );

      // Refresh dashboard data after redemption
      await loadRewardDashboard(userId);
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh all data
  Future<void> refreshData(String userId) async {
    await Future.wait([
      loadRewardDashboard(userId),
      loadRewardHistory(userId, refresh: true),
    ]);
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Clear all data (for logout)
  void clearData() {
    _dashboardData = null;
    _rewardHistory.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
