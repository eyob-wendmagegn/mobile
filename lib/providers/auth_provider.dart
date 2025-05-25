import 'package:flutter/material.dart';
import 'package:waste_management_app/models/user.dart';
import 'package:waste_management_app/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String _error = '';
  bool _isManager = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isManager => _isManager;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Check if it's the manager
      if (email == "eyob@gmail.com" && password == "eyob1212") {
        _isManager = true;
        _currentUser = User(
          id: 'manager',
          name: 'Manager',
          email: email,
          phone: '',
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }

      // Regular user login
      final response = await ApiService.login(email, password);
      if (response['success']) {
        _currentUser = User.fromJson(response['user']);
        _isManager = false;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
      String name, String email, String password, String phone) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await ApiService.register(name, email, password, phone);
      if (response['success']) {
        _currentUser = User.fromJson(response['user']);
        _isManager = false;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _isManager = false;
    notifyListeners();
  }
}
