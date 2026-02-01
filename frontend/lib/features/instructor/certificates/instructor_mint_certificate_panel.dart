import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glass_kit/glass_kit.dart';
import '../../../shared/animations/animated_neon_button.dart';
import '../../../core/services/blockchain_service.dart';

/// Instructor Mint Certificate Panel
/// Only authorized instructors can mint certificates
class InstructorMintCertificatePanel extends StatefulWidget {
  final String instructorWallet;
  final String instructorName;

  const InstructorMintCertificatePanel({
    Key? key,
    required this.instructorWallet,
    required this.instructorName,
  }) : super(key: key);

  @override
  State<InstructorMintCertificatePanel> createState() =>
      _InstructorMintCertificatePanelState();
}

class _InstructorMintCertificatePanelState
    extends State<InstructorMintCertificatePanel> {
  final _formKey = GlobalKey<FormState>();
  final _studentWalletController = TextEditingController();
  final _studentNameController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _marksController = TextEditingController();

  bool _isMinting = false;

  @override
  void dispose() {
    _studentWalletController.dispose();
    _studentNameController.dispose();
    _courseNameController.dispose();
    _marksController.dispose();
    super.dispose();
  }

  Future<void> _mintCertificate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isMinting = true);

    try {
      // Call Backend & Blockchain via Service
      final blockchainService = BlockchainService();
      final mintResponse = await blockchainService.mintCertificate(
        studentWallet: _studentWalletController.text,
        studentName: _studentNameController.text,
        courseName: _courseNameController.text,
        courseId:
            'COURSE_${DateTime.now().millisecondsSinceEpoch}', // Generate or get from context
        userId: _studentWalletController.text, // Use wallet as user ID for now
        marks: double.parse(_marksController.text),
        instructorWallet: widget.instructorWallet,
      );

      if (mounted) {
        final academicDNA = mintResponse['academicDNA'] as String? ?? '';
        final txHash = mintResponse['transactionHash'] as String? ?? '';
        _showSuccess(
          'Certificate minted successfully!\n'
          'DNA: ${academicDNA.length > 16 ? '${academicDNA.substring(0, 8)}...${academicDNA.substring(academicDNA.length - 8)}' : academicDNA}\n'
          'TX: ${txHash.length > 16 ? '${txHash.substring(0, 10)}...' : txHash}',
        );
        _clearForm();
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to mint certificate: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isMinting = false);
      }
    }
  }

  void _clearForm() {
    _studentWalletController.clear();
    _studentNameController.clear();
    _courseNameController.clear();
    _marksController.clear();
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_card,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mint Certificate',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Issue blockchain certificate',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Student Wallet Address
              _buildTextField(
                controller: _studentWalletController,
                label: 'Student Wallet Address',
                hint: '0x...',
                icon: Icons.account_balance_wallet,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter student wallet address';
                  }
                  if (!value.startsWith('0x')) {
                    return 'Invalid wallet address format';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Student Name
              _buildTextField(
                controller: _studentNameController,
                label: 'Student Name',
                hint: 'John Doe',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter student name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Course Name
              _buildTextField(
                controller: _courseNameController,
                label: 'Course Name',
                hint: 'Advanced Blockchain Development',
                icon: Icons.school,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter course name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Marks
              _buildTextField(
                controller: _marksController,
                label: 'Marks (%)',
                hint: '95',
                icon: Icons.grade,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter marks';
                  }
                  final marks = double.tryParse(value);
                  if (marks == null || marks < 0 || marks > 100) {
                    return 'Please enter valid marks (0-100)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Info box
              Container(
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
                      Icons.info_outline,
                      color: const Color(0xFF6366F1),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Certificate will be minted on blockchain and Academic DNA will be generated for the student.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Mint Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: AnimatedNeonButton(
                  text: _isMinting
                      ? 'Minting...'
                      : 'Mint Blockchain Certificate',
                  icon: _isMinting ? null : Icons.rocket_launch,
                  onPressed: _isMinting ? null : _mintCertificate,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF6366F1).withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            prefixIcon: Icon(icon, color: const Color(0xFF6366F1)),
          ),
        ),
      ],
    );
  }
}
