import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  ImageProvider? _profileImage;
  bool _isLoading = false;
  String? _userId;

  // Getters
  ImageProvider? get profileImage => _profileImage;
  bool get isLoading => _isLoading;

  // Set the current user ID
  void setUserId(String userId) {
    _userId = userId;
    loadProfileImage();
  }

  // Check if profile image exists
  bool hasProfileImage() {
    return _profileImage != null;
  }

  // Get profile image
  ImageProvider? getProfileImage() {
    return _profileImage;
  }

  // Load profile image from storage
  Future<void> loadProfileImage() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Check for web image
      final base64Image = prefs.getString('profileImageBase64_$_userId');
      if (base64Image != null && base64Image.isNotEmpty) {
        if (base64Image.startsWith('data:image')) {
          // Handle data URL format
          final base64String = base64Image.split(',')[1];
          final bytes = base64Decode(base64String);
          _profileImage = MemoryImage(bytes);
        } else {
          // Handle raw base64
          final bytes = base64Decode(base64Image);
          _profileImage = MemoryImage(bytes);
        }
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Check for mobile image
      final imagePath = prefs.getString('profileImagePath_$_userId');
      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) {
          _profileImage = FileImage(file);
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // No image found
      _profileImage = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading profile image: $e');
      _profileImage = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile image
  Future<void> updateProfileImage(dynamic newImage) async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Handle web platform
      if (kIsWeb) {
        if (newImage is String && newImage.startsWith('data:image')) {
          // Handle data URL format
          final base64String = newImage.split(',')[1];
          await prefs.setString('profileImageBase64_$_userId', newImage);
          final bytes = base64Decode(base64String);
          _profileImage = MemoryImage(bytes);
        }
      }
      // Handle mobile platform
      else {
        if (newImage is File) {
          await prefs.setString('profileImagePath_$_userId', newImage.path);
          _profileImage = FileImage(newImage);
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error updating profile image: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear profile image
  Future<void> clearProfileImage() async {
    if (_userId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profileImageBase64_$_userId');
      await prefs.remove('profileImagePath_$_userId');

      _profileImage = null;
      notifyListeners();
    } catch (e) {
      print('Error clearing profile image: $e');
    }
  }
}
