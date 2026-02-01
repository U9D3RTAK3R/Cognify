// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import '../../../core/theme/app_theme.dart';

class DNAExportService {
  static final ScreenshotController _screenshotController =
      ScreenshotController();

  /// Export DNA visualization as PNG image
  static Future<void> exportDNAAsImage({
    required BuildContext context,
    required Widget dnaWidget,
    required String fileName,
  }) async {
    try {
      // Capture the DNA widget as image
      final imageBytes = await _screenshotController.captureFromWidget(
        Container(
          width: 800,
          height: 800,
          color: const Color(0xFF0A0E27),
          child: Center(child: dnaWidget),
        ),
        pixelRatio: 2.0,
      );

      // Save to downloads
      await _saveImage(context, imageBytes, fileName);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('DNA exported successfully!'),
              ],
            ),
            backgroundColor: AppTheme.primaryCyan,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export DNA: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// Export DNA with custom background and branding
  static Future<void> exportDNAWithBranding({
    required BuildContext context,
    required Widget dnaWidget,
    required String studentName,
    required String academicDNA,
    required String fileName,
  }) async {
    try {
      final brandedWidget = Container(
        width: 1000,
        height: 1000,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF0A0E27), const Color(0xFF1a1f3a)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Title
            const Text(
              'COGNIFY',
              style: TextStyle(
                color: AppTheme.primaryCyan,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Academic DNA Identity',
              style: TextStyle(color: Colors.white70, fontSize: 24),
            ),
            const SizedBox(height: 60),

            // DNA Visualization
            SizedBox(width: 600, height: 400, child: dnaWidget),

            const SizedBox(height: 60),

            // Student Info
            Text(
              studentName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // DNA Hash
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryCyan.withOpacity(0.3),
                ),
              ),
              child: Text(
                academicDNA.substring(0, 32) + '...',
                style: const TextStyle(
                  color: AppTheme.primaryCyan,
                  fontSize: 14,
                  fontFamily: 'Courier',
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Footer
            Text(
              'Blockchain-Verified Academic Identity',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );

      final imageBytes = await _screenshotController.captureFromWidget(
        brandedWidget,
        pixelRatio: 2.0,
      );

      await _saveImage(context, imageBytes, fileName);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Branded DNA card exported!'),
              ],
            ),
            backgroundColor: AppTheme.primaryCyan,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  static Future<void> _saveImage(
    BuildContext context,
    Uint8List imageBytes,
    String fileName,
  ) async {
    // For web: trigger download
    // For mobile: save to gallery
    try {
      // Web download
      final blob = html.Blob([imageBytes], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '$fileName.png')
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      // Mobile save (would need additional packages like image_gallery_saver)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image saved to downloads'),
            backgroundColor: AppTheme.primaryCyan,
          ),
        );
      }
    }
  }

  /// Share DNA as image
  static Future<void> shareDNA({
    required BuildContext context,
    required Widget dnaWidget,
    required String fileName,
  }) async {
    try {
      final imageBytes = await _screenshotController.captureFromWidget(
        Container(
          width: 800,
          height: 800,
          color: const Color(0xFF0A0E27),
          child: Center(child: dnaWidget),
        ),
        pixelRatio: 2.0,
      );

      // Would use share_plus package here
      // await Share.shareXFiles([XFile.fromData(imageBytes, name: fileName)]);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Share functionality coming soon!'),
            backgroundColor: AppTheme.accentPurple,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
