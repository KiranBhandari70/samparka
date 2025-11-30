import 'dart:io';
import 'package:flutter/foundation.dart';
import '../data/models/offer_model.dart';
import '../data/services/offer_service.dart';

class OfferProvider extends ChangeNotifier {
  OfferProvider() : _offerService = OfferService.instance;

  final OfferService _offerService;

  List<OfferModel> _allOffers = [];
  List<OfferModel> _businessOffers = [];
  List<OfferCategory> _categories = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<OfferModel> get allOffers => _allOffers;
  List<OfferModel> get businessOffers => _businessOffers;
  List<OfferCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all offers with filters
  Future<void> loadOffers({
    String? category,
    int? minPoints,
    int? maxPoints,
    bool refresh = false,
  }) async {
    if (refresh) {
      _allOffers.clear();
    }

    _setLoading(true);
    _clearError();

    try {
      final newOffers = await _offerService.getAllOffers(
        category: category,
        minPoints: minPoints,
        maxPoints: maxPoints,
        limit: 20,
        offset: refresh ? 0 : _allOffers.length,
      );

      if (refresh) {
        _allOffers = newOffers;
      } else {
        _allOffers.addAll(newOffers);
      }

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load offers for a specific business
  Future<void> loadBusinessOffers(String businessId, {bool includeInactive = false}) async {
    _setLoading(true);
    _clearError();

    try {
      _businessOffers = await _offerService.getBusinessOffers(
        businessId,
        includeInactive: includeInactive,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create a new offer
  Future<bool> createOffer({
    required String userId,
    required String title,
    required String description,
    required String businessName,
    required String category,
    required String discountType,
    required double discountValue,
    required int pointsRequired,
    required DateTime validUntil,
    File? imageFile,
    String? termsAndConditions,
    int? maxRedemptions,
    Map<String, dynamic>? location,
    Map<String, dynamic>? contactInfo,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final newOffer = await _offerService.createOffer(
        userId: userId,
        title: title,
        description: description,
        businessName: businessName,
        category: category,
        discountType: discountType,
        discountValue: discountValue,
        pointsRequired: pointsRequired,
        validUntil: validUntil,
        imageFile: imageFile,
        termsAndConditions: termsAndConditions,
        maxRedemptions: maxRedemptions,
        location: location,
        contactInfo: contactInfo,
      );

      // Add to business offers if we're viewing them
      _businessOffers.insert(0, newOffer);
      
      // Add to all offers if it matches current filters
      _allOffers.insert(0, newOffer);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update an offer
  Future<bool> updateOffer({
    required String offerId,
    required String userId,
    String? title,
    String? description,
    String? businessName,
    String? category,
    String? discountType,
    double? discountValue,
    int? pointsRequired,
    DateTime? validUntil,
    File? imageFile,
    String? termsAndConditions,
    int? maxRedemptions,
    bool? isActive,
    Map<String, dynamic>? location,
    Map<String, dynamic>? contactInfo,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedOffer = await _offerService.updateOffer(
        offerId: offerId,
        userId: userId,
        title: title,
        description: description,
        businessName: businessName,
        category: category,
        discountType: discountType,
        discountValue: discountValue,
        pointsRequired: pointsRequired,
        validUntil: validUntil,
        imageFile: imageFile,
        termsAndConditions: termsAndConditions,
        maxRedemptions: maxRedemptions,
        isActive: isActive,
        location: location,
        contactInfo: contactInfo,
      );

      // Update in business offers
      final businessIndex = _businessOffers.indexWhere((offer) => offer.id == offerId);
      if (businessIndex != -1) {
        _businessOffers[businessIndex] = updatedOffer;
      }

      // Update in all offers
      final allIndex = _allOffers.indexWhere((offer) => offer.id == offerId);
      if (allIndex != -1) {
        _allOffers[allIndex] = updatedOffer;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete an offer
  Future<bool> deleteOffer(String offerId, String userId) async {
    _setLoading(true);
    _clearError();

    try {
      await _offerService.deleteOffer(offerId, userId);

      // Remove from business offers
      _businessOffers.removeWhere((offer) => offer.id == offerId);
      
      // Remove from all offers
      _allOffers.removeWhere((offer) => offer.id == offerId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Redeem an offer
  Future<RedemptionResult?> redeemOffer(String offerId, String userId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _offerService.redeemOffer(offerId, userId);

      // Update the offer's redemption count in local lists
      final updateRedemptionCount = (List<OfferModel> offers) {
        final index = offers.indexWhere((offer) => offer.id == offerId);
        if (index != -1) {
          offers[index] = offers[index].copyWith(
            currentRedemptions: offers[index].currentRedemptions + 1,
          );
        }
      };

      updateRedemptionCount(_allOffers);
      updateRedemptionCount(_businessOffers);

      notifyListeners();
      return result;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Load offer categories
  Future<void> loadCategories() async {
    if (_categories.isNotEmpty) return; // Already loaded

    try {
      _categories = await _offerService.getOfferCategories();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Filter offers by category

  // Get available offers only
  List<OfferModel> get availableOffers {
    return _allOffers.where((offer) => offer.isAvailable).toList();
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
    _allOffers.clear();
    _businessOffers.clear();
    _categories.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshData({String? businessId}) async {
    await Future.wait([
      loadOffers(refresh: true),
      loadCategories(),
      if (businessId != null) loadBusinessOffers(businessId),
    ]);
  }
}
