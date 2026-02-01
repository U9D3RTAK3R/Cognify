import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/api_service.dart';
import '../../../core/providers/auth_state.dart';

class InstructorAnalyticsDashboard extends ConsumerStatefulWidget {
  const InstructorAnalyticsDashboard({super.key});

  @override
  ConsumerState<InstructorAnalyticsDashboard> createState() =>
      _InstructorAnalyticsDashboardState();
}

class _InstructorAnalyticsDashboardState
    extends ConsumerState<InstructorAnalyticsDashboard> {
  bool _isLoading = true;
  Map<String, dynamic>? _stats;
  List<ChartData> _monthlyData = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      final authState = ref.read(authProvider);
      final walletAddress = authState.walletAddress;

      if (walletAddress != null) {
        final response = await ApiService.get(
          '/api/instructor/stats?wallet=$walletAddress',
        );

        if (response['success'] == true) {
          setState(() {
            _stats = response;
            _monthlyData = _generateMockMonthlyData();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      // Fall through to mock data
    }

    // Mock data
    setState(() {
      _stats = {
        'certificatesIssued': 42,
        'totalStudents': 38,
        'averageTrustScore': 82.5,
        'totalVerifications': 156,
      };
      _monthlyData = _generateMockMonthlyData();
      _isLoading = false;
    });
  }

  List<ChartData> _generateMockMonthlyData() {
    return [
      ChartData('Jan', 5),
      ChartData('Feb', 8),
      ChartData('Mar', 12),
      ChartData('Apr', 15),
      ChartData('May', 18),
      ChartData('Jun', 22),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryCyan),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Analytics Dashboard',
            style: AppTheme.headlineMedium.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your certificate issuance and DNA usage',
            style: TextStyle(color: AppTheme.textGrey, fontSize: 14),
          ),
          const SizedBox(height: 32),

          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                'Certificates Issued',
                '${_stats!['certificatesIssued']}',
                Icons.workspace_premium,
                AppTheme.primaryCyan,
              ),
              _buildStatCard(
                'Total Students',
                '${_stats!['totalStudents']}',
                Icons.people,
                AppTheme.accentPurple,
              ),
              _buildStatCard(
                'Avg Trust Score',
                '${_stats!['averageTrustScore'].toStringAsFixed(1)}',
                Icons.verified,
                Colors.greenAccent,
              ),
              _buildStatCard(
                'Verifications',
                '${_stats!['totalVerifications']}',
                Icons.remove_red_eye,
                Colors.orangeAccent,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Monthly Trend Chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Certificate Issuance',
                  style: AppTheme.headlineMedium.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 250,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      labelStyle: const TextStyle(color: Colors.white70),
                      majorGridLines: const MajorGridLines(width: 0),
                    ),
                    primaryYAxis: NumericAxis(
                      labelStyle: const TextStyle(color: Colors.white70),
                      majorGridLines: MajorGridLines(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    plotAreaBorderWidth: 0,
                    series: <CartesianSeries<ChartData, String>>[
                      SplineAreaSeries<ChartData, String>(
                        dataSource: _monthlyData,
                        xValueMapper: (ChartData data, _) => data.month,
                        yValueMapper: (ChartData data, _) => data.count,
                        gradient: const LinearGradient(
                          colors: [
                            Color(
                              0x8000D9FF,
                            ), // AppTheme.primaryCyan with 50% opacity
                            Color(
                              0x1AA855F7,
                            ), // AppTheme.accentPurple with 10% opacity
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderColor: AppTheme.primaryCyan,
                        borderWidth: 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),

          const SizedBox(height: 32),

          // DNA Usage Stats
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.fingerprint,
                      color: AppTheme.primaryCyan,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Academic DNA Usage',
                      style: AppTheme.headlineMedium.copyWith(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDNAStatRow('Unique DNA Patterns', '38'),
                _buildDNAStatRow('DNA Verifications', '156'),
                _buildDNAStatRow('Average DNA Trust', '82.5%'),
                _buildDNAStatRow('DNA Fraud Detected', '0'),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildDNAStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textGrey, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final String month;
  final int count;

  ChartData(this.month, this.count);
}
