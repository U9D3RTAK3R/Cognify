import 'package:cognify/core/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// API service for wallet-based certificate operations
class WalletCertificateService {
  static const String baseUrl = ApiConfig.apiUrl;
  
  /// Get certificate history for a wallet address
  static Future<Map<String, dynamic>?> getCertificateHistory(String walletAddress) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/certificate/history/$walletAddress?wallet=$walletAddress'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error fetching certificate history: $e');
      return null;
    }
  }
  
  /// Get user profile by wallet address
  static Future<Map<String, dynamic>?> getUserProfile(String walletAddress) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/$walletAddress'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }
  
  /// Generate certificate with wallet authentication
  static Future<Map<String, dynamic>?> generateCertificate({
    required String walletAddress,
    required String signature,
    required String message,
    required String studentName,
    required String courseId,
    required String courseName,
    required double marks,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/instructor/certificate/generate'),
        headers: {
          'Content-Type': 'application/json',
          'X-Wallet-Address': walletAddress,
          'X-Wallet-Signature': signature,
          'X-Signed-Message': message,
        },
        body: jsonEncode({
          'walletAddress': walletAddress,
          'studentName': studentName,
          'courseId': courseId,
          'courseName': courseName,
          'marks': marks,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error generating certificate: $e');
      return null;
    }
  }
}
