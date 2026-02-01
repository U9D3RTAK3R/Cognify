import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import 'metamask_service.dart';

// Standalone service for Nonce-based Auth
class NonceAuthService {
  final MetaMaskService _metaMask = MetaMaskService();

  Future<Map<String, dynamic>> loginWithWallet(String walletAddress) async {
    try {
      // 1. Request Nonce
      final nonceRes = await ApiService.post('/api/auth/nonce', {
        'walletAddress': walletAddress,
      });

      if (nonceRes['nonce'] == null) throw Exception("Failed to get nonce");
      final nonce = nonceRes['nonce'];
      final message = nonceRes['message'];

      // 2. Sign Message
      // Using MetaMaskService to sign
      final signature = await _metaMask.signMessage(message);

      if (signature == null) throw Exception("User rejected signature");

      // 3. Verify Signature & Login
      final loginRes = await ApiService.post('/api/auth/login/wallet', {
        'walletAddress': walletAddress,
        'signature': signature,
      });

      if (loginRes['success'] == true) {
        return loginRes;
      } else {
        throw Exception(loginRes['message'] ?? "Wallet login failed");
      }
    } catch (e) {
      rethrow;
    }
  }
}

final nonceAuthProvider = Provider((ref) => NonceAuthService());
