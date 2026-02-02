import 'package:cognify/core/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:glass_kit/glass_kit.dart';
import '../../shared/widgets/academic_dna_visualizer.dart';
import '../../shared/widgets/trust_score_meter.dart';
import '../../shared/widgets/verification_badge.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/trust_score_card.dart';
import 'widgets/trust_trend_chart.dart';
import '../../core/models/trust_analytics.dart';

/// Public Certificate Verification Screen
/// No authentication required - anyone can verify certificates
class PublicCertificateVerificationScreen extends StatefulWidget {
  const PublicCertificateVerificationScreen({Key? key}) : super(key: key);

  @override
  State<PublicCertificateVerificationScreen> createState() =>
      _PublicCertificateVerificationScreenState();
}

class _PublicCertificateVerificationScreenState
    extends State<PublicCertificateVerificationScreen> {
  final TextEditingController _hashController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _verificationResult;

  @override
  void dispose() {
    _hashController.dispose();
    super.dispose();
  }

  Future<void> _verifyCertificate() async {
    if (_hashController.text.trim().isEmpty) {
      _showError('Please enter a certificate hash');
      return;
    }

    setState(() {
      _isLoading = true;
      _verificationResult = null;
    });

    try {
      // Call Backend API
      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/certificates/verify'),
        body: jsonEncode({'certificateHash': _hashController.text.trim()}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.body}');
      }
      
      final data = jsonDecode(response.body);
      
      setState(() {
        _verificationResult = {
          'verified': data['verified'] ?? false,
          'studentName': data['studentName'] ?? 'Unknown',
          'courseName': data['courseName'] ?? 'Unknown',
          'instructorName': data['instructorName'] ?? 'Unknown',
          'walletAddress': data['walletAddress'] ?? '',
          'issuedAt': DateTime.parse(data['issuedAt'] ?? DateTime.now().toIso8601String()),
          'blockchainTx': data['blockchainTx'] ?? '',
          'academicDNA': data['academicDNA'] ?? '',
          'trustScore': data['trustScore'] ?? 0,
          'trustLevel': data['trustLevel'] ?? 'Unknown',
          'trustBreakdown': data['trustBreakdown'] ?? {},
          'percentile': (data['percentile'] as num?)?.toDouble() ?? 0.0,
        };
      });
    } catch (e) {
      _showError('Verification failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Verify Certificate',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Certificate Verification',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Verify the authenticity of any Cognify certificate',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Input Section
            GlassContainer(
              height: null,
              width: double.infinity,
              borderRadius: BorderRadius.circular(20),
              blur: 20,
              frostedOpacity: 0.1,
              color: const Color(0xFF1E293B).withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter Certificate Hash',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Hash input
                    TextField(
                      controller: _hashController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter certificate hash or ID',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(
                          Icons.tag,
                          color: const Color(0xFF6366F1),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Verify button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyCertificate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Verify Certificate',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Alternative options
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Implement PDF upload
                            },
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload PDF'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF6366F1),
                              side: const BorderSide(
                                color: Color(0xFF6366F1),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Implement QR scanner
                            },
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text('Scan QR'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF8B5CF6),
                              side: const BorderSide(
                                color: Color(0xFF8B5CF6),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1),
            
            // Verification Result
            if (_verificationResult != null) ...[
              const SizedBox(height: 32),
              _buildVerificationResult(_verificationResult!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationResult(Map<String, dynamic> result) {
    final isVerified = result['verified'] as bool;
    
    return Column(
      children: [
        // Verification Badge
        VerificationBadge(isVerified: isVerified),
        
        const SizedBox(height: 32),
        
        // Certificate Details
        GlassContainer(
          height: null,
          width: double.infinity,
          borderRadius: BorderRadius.circular(20),
          blur: 20,
          frostedOpacity: 0.1,
          color: const Color(0xFF1E293B).withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Certificate Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                _buildDetailRow('Student', result['studentName']),
                _buildDetailRow('Course', result['courseName']),
                _buildDetailRow('Instructor', result['instructorName']),
                _buildDetailRow('Wallet', _formatWallet(result['walletAddress'])),
                _buildDetailRow('Issued', _formatDate(result['issuedAt'])),
                
                const SizedBox(height: 24),
                
                // Blockchain Transaction
                GestureDetector(
                  onTap: () {
                    // TODO: Open blockchain explorer
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.link,
                          color: const Color(0xFF6366F1),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Blockchain Transaction',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                result['blockchainTx'],
                                style: TextStyle(
                                  color: const Color(0xFF6366F1),
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.open_in_new,
                          color: const Color(0xFF6366F1),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
        
        const SizedBox(height: 24),
        
        // Trust Intelligence Card
        if (result['trustBreakdown'] != null) ...[
          TrustScoreCard(
            analytics: TrustAnalytics(
              certificateHash: _hashController.text,
              trustScore: result['trustScore'] ?? 0,
              trustLevel: result['trustLevel'] ?? 'Low',
              trustBreakdown: TrustScoreBreakdown.fromJson(
                result['trustBreakdown'] as Map<String, dynamic>,
              ),
              percentile: (result['percentile'] as num?)?.toDouble() ?? 0.0,
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
          
          const SizedBox(height: 24),

          // Trust History Trend
          const TrustTrendChart().animate().fadeIn(delay: 500.ms, duration: 600.ms),

          const SizedBox(height: 24),
        ],
        
        // Academic DNA
        GlassContainer(
          height: null,
          width: double.infinity,
          borderRadius: BorderRadius.circular(20),
          blur: 20,
          frostedOpacity: 0.1,
          color: const Color(0xFF1E293B).withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Academic DNA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: AcademicDNAVisualizer(
                    academicDNA: result['academicDNA'],
                    size: 150,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatWallet(String wallet) {
    if (wallet.length < 10) return wallet;
    return '${wallet.substring(0, 6)}...${wallet.substring(wallet.length - 4)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
