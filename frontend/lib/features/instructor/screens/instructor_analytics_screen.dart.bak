import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glass_kit/glass_kit.dart';
import '../../../core/services/trust_analytics_service.dart';
import '../../../core/theme/app_theme.dart'; // Assuming this exists or using standard colors

class InstructorAnalyticsScreen extends StatefulWidget {
  final String walletAddress;

  const InstructorAnalyticsScreen({Key? key, required this.walletAddress}) : super(key: key);

  @override
  State<InstructorAnalyticsScreen> createState() => _InstructorAnalyticsScreenState();
}

class _InstructorAnalyticsScreenState extends State<InstructorAnalyticsScreen> {
  final _analyticsService = TrustAnalyticsService();
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _analyticsService.getInstructorAnalytics(widget.walletAddress);
    if (mounted) {
      setState(() {
        _data = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Instructor Analytics', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : _data == null
              ? const Center(child: Text('Failed to load data', style: TextStyle(color: Colors.white)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Reputation Header
                      _buildReputationHeader(),
                      const SizedBox(height: 24),

                      // 2. Stats Grid
                      _buildStatsGrid(),
                      const SizedBox(height: 24),

                      // 3. Trust Score Distribution (Pie Chart)
                      Text(
                        'Trust Score Distribution',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: _buildDistributionChart(),
                      ),
                      const SizedBox(height: 32),

                      // 4. Top Certificates
                      Text(
                        'Top Performing Certificates',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildTopCertificatesList(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildReputationHeader() {
    final reputation = _data!['reputation'] as Map<String, dynamic>?;
    final score = reputation != null ? (reputation['reputationScore'] as num).toDouble() : 0.0;
    
    // Determine badge color/text
    String badgeText = "Low";
    Color badgeColor = Colors.red;
    if (score >= 90) { badgeText = "Excellent"; badgeColor = const Color(0xFF10B981); }
    else if (score >= 75) { badgeText = "High"; badgeColor = const Color(0xFF3B82F6); }
    else if (score >= 50) { badgeText = "Moderate"; badgeColor = Colors.orange; }

    return GlassContainer(
      height: 120,
      width: double.infinity,
      borderRadius: BorderRadius.circular(20),
      blur: 20,
      frostedOpacity: 0.1,
      color: const Color(0xFF1E293B).withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Circular Indicator
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: badgeColor, width: 4),
              ),
              child: Center(
                child: Text(
                  score.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Text Details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Reputation Score',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: badgeColor),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Certificates', '${_data!['totalCertificates']}', Icons.school),
        _buildStatCard('Revoked', '${_data!['revokedCount']}', Icons.block, isError: true),
        _buildStatCard('Active', '${_data!['activeCertificates']}', Icons.check_circle),
        _buildStatCard('Avg Trust', '${(_data!['averageTrustScore'] as num).toStringAsFixed(1)}', Icons.verified_user),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {bool isError = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: isError ? Colors.redAccent : const Color(0xFF6366F1), size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                title,
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionChart() {
    // Determine sections based on average score (Mocking distribution logic for demo)
    // Real implementation would need an aggregate endpoint
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(color: const Color(0xFF10B981), value: 40, title: 'Excel.', radius: 50),
          PieChartSectionData(color: const Color(0xFF3B82F6), value: 30, title: 'High', radius: 50),
          PieChartSectionData(color: Colors.orange, value: 20, title: 'Mod.', radius: 50),
          PieChartSectionData(color: Colors.red, value: 10, title: 'Low', radius: 50),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildTopCertificatesList() {
    final topCerts = _data!['topCertificates'] as List<dynamic>?;
    if (topCerts == null || topCerts.isEmpty) {
      return const Text('No certificates issued yet.', style: TextStyle(color: Colors.white70));
    }

    return Column(
      children: topCerts.map((cert) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
                child: const Icon(Icons.verified, color: Color(0xFF6366F1), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cert['studentName'] ?? 'Unknown',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      cert['courseName'] ?? 'Unknown Course',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${cert['trustScore']}',
                    style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Trust Score',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    ).animate().fadeIn(duration: 800.ms);
  }
}
