import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:waste_management_app/models/recycling_center.dart';
import 'package:waste_management_app/models/tutorial.dart';
import 'package:waste_management_app/models/user.dart';
import 'package:waste_management_app/models/waste_collection.dart';

class ApiService {
  // Changed from 10.0.2.2 to localhost
  static const String baseUrl = 'http://localhost:3000/api';

  // Authentication
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        print('Login error: ${response.statusCode} - ${response.body}');
        return {
          'success': false,
          'message':
              'Server error: ${response.statusCode}. Please try again later.'
        };
      }
    } catch (e) {
      print('Login exception: $e');
      return {
        'success': false,
        'message':
            'Connection error: $e. Please check your internet connection and server status.'
      };
    }
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password, String phone) async {
    try {
      print('Attempting to register user: $email');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message':
              'Server error: ${response.statusCode}. Please try again later.'
        };
      }
    } catch (e) {
      print('Register exception: $e');
      return {
        'success': false,
        'message':
            'Connection error: $e. Please check your internet connection and server status.'
      };
    }
  }

  // Waste Collection
  static Future<Map<String, dynamic>> createWasteCollection(
      WasteCollection collection) async {
    try {
      print('Sending collection data: ${jsonEncode(collection.toJson())}');

      final response = await http.post(
        Uri.parse('$baseUrl/collections'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(collection.toJson()),
      );

      print('Create collection response status: ${response.statusCode}');
      print('Create collection response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message':
              'Server error: ${response.statusCode}. Please try again later.'
        };
      }
    } catch (e) {
      print('Create collection exception: $e');
      return {
        'success': false,
        'message':
            'Connection error: $e. Please check your internet connection and server status.'
      };
    }
  }

  static Future<List<WasteCollection>> getUserCollections(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/collections/user/$userId'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['collections'] as List)
              .map((collection) => WasteCollection.fromJson(collection))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Get user collections error: $e');
      return [];
    }
  }

  static Future<List<WasteCollection>> getAllCollections() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/collections'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['collections'] as List)
              .map((collection) => WasteCollection.fromJson(collection))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Get all collections error: $e');
      return [];
    }
  }

  // Recycling Centers
  static Future<List<RecyclingCenter>> getRecyclingCenters() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/centers'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['collections'] as List? ?? data['centers'] as List)
              .map((center) => RecyclingCenter.fromJson(center))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Get recycling centers error: $e');
      return [];
    }
  }

  // Tutorials
  static Future<List<Tutorial>> getTutorials() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tutorials'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['tutorials'] as List)
              .map((tutorial) => Tutorial.fromJson(tutorial))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Get tutorials error: $e');
      return [];
    }
  }

  // Users (for manager)
  static Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['users'] as List)
              .map((user) => User.fromJson(user))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Get all users error: $e');
      return [];
    }
  }
}
