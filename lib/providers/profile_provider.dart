import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/storage/local_storage.dart';
import '../models/user_profile.dart';

class ProfileProvider extends ChangeNotifier {
  UserProfile _profile = UserProfile();
  bool _isLoading = true;

  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;

  ProfileProvider() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await LocalStorage.readJson(AppConstants.profileFile);
      if (data != null && data is Map<String, dynamic>) {
        _profile = UserProfile.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? bio,
    String? avatarKey,
  }) async {
    _profile = _profile.copyWith(
      name: name,
      bio: bio,
      avatarKey: avatarKey,
    );
    await LocalStorage.writeJson(AppConstants.profileFile, _profile.toJson());
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _profile = _profile.copyWith(hasCompletedOnboarding: true);
    await LocalStorage.writeJson(AppConstants.profileFile, _profile.toJson());
    notifyListeners();
  }

  Future<void> resetProfile() async {
    _profile = UserProfile(hasCompletedOnboarding: false);
    await LocalStorage.deleteFile(AppConstants.profileFile);
    notifyListeners();
  }
}

