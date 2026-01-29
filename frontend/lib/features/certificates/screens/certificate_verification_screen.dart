import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CertificateVerificationScreen extends StatelessWidget {
  const CertificateVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgBlack,
      appBar: AppBar(
        title: Text('Verify Certificate', style: AppTheme.headlineMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryCyan),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified, color: Colors.greenAccent),
                  const SizedBox(width: 8),
                  Text(
                    "Verify Certificate",
                    style: AppTheme.headlineMedium.copyWith(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Verify the authenticity of a certificate by uploading the PDF or entering the hash ID.",
                style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
              ),
              const SizedBox(height: 20),
              
              // Upload Area
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 32,
                      color: AppTheme.primaryCyan.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Upload Certificate PDF",
                      style: TextStyle(
                        color: AppTheme.primaryCyan.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  const Expanded(child: Divider(color: Colors.white10)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text("OR", style: TextStyle(color: AppTheme.textGrey, fontSize: 10)),
                  ),
                  const Expanded(child: Divider(color: Colors.white10)),
                ],
              ),
              
              const SizedBox(height: 16),
              
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter Certificate Hash ID",
                  hintStyle: TextStyle(color: AppTheme.textGrey),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner, color: AppTheme.primaryCyan),
                    onPressed: () {},
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Verify Now"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
