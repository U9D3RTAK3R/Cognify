import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/instructor_state.dart';

class InstructorCertificatesScreen extends ConsumerStatefulWidget {
  const InstructorCertificatesScreen({super.key});

  @override
  ConsumerState<InstructorCertificatesScreen> createState() =>
      _InstructorCertificatesScreenState();
}

class _InstructorCertificatesScreenState
    extends ConsumerState<InstructorCertificatesScreen> {
  int _selectedTemplate = 0;
  final _studentNameController = TextEditingController(text: 'John Doe');
  final _courseNameController = TextEditingController(text: 'Flutter Mastery');
  bool _isGenerating = false;

  final List<Map<String, dynamic>> _templates = [
    {
      'name': 'Classic',
      'gradient': [Colors.blue.shade800, Colors.blue.shade600],
      'icon': Icons.stars,
    },
    {
      'name': 'Gold',
      'gradient': [Colors.amber.shade700, Colors.orange.shade600],
      'icon': Icons.emoji_events,
    },
    {
      'name': 'Tech',
      'gradient': [Colors.purple.shade800, Colors.indigo.shade600],
      'icon': Icons.code,
    },
    {
      'name': 'Minimal',
      'gradient': [Colors.grey.shade800, Colors.grey.shade600],
      'icon': Icons.verified,
    },
  ];

  void _generateWithAI() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _selectedTemplate = DateTime.now().millisecond % _templates.length;
      _isGenerating = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI generated your certificate! 🎨'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _issueCertificate({required bool isAiGenerated}) {
    final cert = GeneratedCertificate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      studentName: _studentNameController.text,
      courseName: _courseNameController.text,
      templateName: _templates[_selectedTemplate]['name'] as String,
      isAiGenerated: isAiGenerated,
      createdAt: DateTime.now(),
    );
    ref.read(instructorStateProvider.notifier).addCertificate(cert);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Certificate issued! 🎉'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final template = _templates[_selectedTemplate];
    final certCount = ref.watch(instructorStateProvider).certificates.length;

    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Certificate Generator", style: AppTheme.headlineMedium),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/instructor/certificates/history'),
            icon: const Icon(Icons.history, color: Colors.orange, size: 18),
            label: Text(
              'History ($certCount)',
              style: const TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Certificate Preview
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: template['gradient'] as List<Color>,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (template['gradient'] as List<Color>)[0].withOpacity(
                      0.4,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _CertificateBorderPainter()),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          template['icon'] as IconData,
                          color: Colors.white.withOpacity(0.3),
                          size: 60,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'CERTIFICATE OF COMPLETION',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _studentNameController.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'has successfully completed',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _courseNameController.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1, 1),
            ),
            const SizedBox(height: 24),

            // Template Selector
            Text(
              'TEMPLATE',
              style: AppTheme.labelLarge.copyWith(color: Colors.orange),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _templates.length,
                itemBuilder: (context, index) {
                  final t = _templates[index];
                  final isSelected = index == _selectedTemplate;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTemplate = index),
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: t['gradient'] as List<Color>,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            t['icon'] as IconData,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t['name'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Input Fields
            Text(
              'DETAILS',
              style: AppTheme.labelLarge.copyWith(color: Colors.orange),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _studentNameController,
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Student Name',
                labelStyle: TextStyle(color: AppTheme.textGrey),
                prefixIcon: const Icon(Icons.person, color: Colors.orange),
                filled: true,
                fillColor: AppTheme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _courseNameController,
              style: const TextStyle(color: Colors.white),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Course Name',
                labelStyle: TextStyle(color: AppTheme.textGrey),
                prefixIcon: const Icon(Icons.book, color: Colors.orange),
                filled: true,
                fillColor: AppTheme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // AI Generate Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isGenerating
                    ? null
                    : () {
                        _generateWithAI();
                      },
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  _isGenerating ? 'Generating...' : 'Generate with AI',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Issue Certificate Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _issueCertificate(isAiGenerated: false),
                icon: const Icon(Icons.check_circle),
                label: const Text('Issue Certificate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _CertificateBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rect = Rect.fromLTWH(16, 16, size.width - 32, size.height - 32);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
