import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../models/trust_analytics.dart';
import '../config/api_config.dart';

class TrustAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch detailed trust analytics for a certificate (HTTP)
  Future<TrustAnalytics?> getTrustAnalytics(String certificateHash) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiUrl}/analytics/trust?hash=$certificateHash'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TrustAnalytics.fromJson(data);
      } else {
        print('Failed to fetch trust analytics: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching trust analytics: $e');
      return null;
    }
  }

  /// Get real-time updates for trust analytics (Firestore Stream)
  Stream<TrustAnalytics?> getTrustAnalyticsStream(String certificateHash) {
    // Listen to certificate document changes
    return _firestore
        .collection('certificates')
        .doc(certificateHash)
        .snapshots()
        .asyncMap((certDoc) async {
      if (!certDoc.exists) return null;

      // When the certificate changes (e.g. verification count increments), 
      // we should re-fetch the full analytics from the API to get the computed breakdown
      // OR, ideally, the backend updates a dedicated 'public_analytics' doc. 
      // For now, let's trigger an API refresh or manual construction. 
      // For simplicity/performance in this demo phase: 
      // We will pull the latest Verification Count and Score directly from Firestore 
      // and merge it, or just call the API again.
      
      // Better approach for Real-time: Listen to verification_metrics collection
      final metricsDoc = await _firestore.collection('verification_metrics').doc(certificateHash).get();
      
      // We still need the full breakdown which is complex to calc on client.
      // So valid approach: When stream triggers, call API.
      // Note: This creates read amplification but ensures fresh logic.
      return await getTrustAnalytics(certificateHash);
    });
  }

  /// Fetch instructor analytics
  Future<Map<String, dynamic>?> getInstructorAnalytics(String walletAddress) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.apiUrl}/analytics/instructor?wallet=$walletAddress'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to fetch instructor analytics: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching instructor analytics: $e');
      return null;
    }
  }

  /// Trigger reputation update for an instructor
  Future<bool> updateInstructorReputation(String walletAddress) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/analytics/instructor/update-reputation?wallet=$walletAddress'),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update reputation: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating reputation: $e');
      return false;
    }
  }
}
