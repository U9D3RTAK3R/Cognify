import 'dart:convert';
import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// MetaMask wallet service for Web3 authentication (Web-only)
/// Uses JavaScript interop to communicate with MetaMask browser extension
class MetaMaskService {
  static const String _walletKey = 'connected_wallet';
  static const String _userKey = 'user_data';

  String? _connectedWallet;

  // Singleton pattern
  static final MetaMaskService _instance = MetaMaskService._internal();
  factory MetaMaskService() => _instance;
  MetaMaskService._internal();

  /// Initialize service
  Future<void> initialize() async {
    await _loadSavedWallet();
  }

  /// Check if MetaMask is installed
  bool get isMetaMaskInstalled {
    if (!kIsWeb) return false;
    try {
      final ethereum = (html.window as dynamic).ethereum;
      return ethereum != null;
    } catch (e) {
      return false;
    }
  }

  /// Get connected wallet address
  String? get connectedWallet => _connectedWallet;

  /// Connect to MetaMask wallet
  Future<String?> connectWallet() async {
    if (!kIsWeb) {
      throw UnsupportedError('MetaMask is only supported on web');
    }

    if (!isMetaMaskInstalled) {
      throw Exception('MetaMask is not installed');
    }

    try {
      // Request accounts from MetaMask
      final accounts = await _callEthereumMethod('eth_requestAccounts', []);

      if (accounts != null && accounts is List && accounts.isNotEmpty) {
        _connectedWallet = accounts[0] as String;
        await _saveWallet(_connectedWallet!);
        return _connectedWallet;
      }

      return null;
    } catch (e) {
      debugPrint('Error connecting wallet: $e');
      throw Exception('MetaMask Error: $e');
    }
  }

  /// Listen for account changes
  void listenToAccountChanges(Function(String?) onAccountChanged) {
    if (!kIsWeb) return;

    try {
      final ethereum = (html.window as dynamic).ethereum;
      if (ethereum == null) return;

      // Use JavaScript callback for account changes
      // Note: This requires the callback to be set up on the JS side
      // For now, we'll skip this as it requires complex interop
      debugPrint(
        'Account change listener not fully implemented with dynamic invocation',
      );
    } catch (e) {
      debugPrint('Error setting up account listener: $e');
    }
  }

  /// Sign authentication message
  Future<String?> signMessage(String message) async {
    if (_connectedWallet == null) {
      throw Exception('Wallet not connected');
    }

    if (!kIsWeb) {
      throw UnsupportedError('MetaMask is only supported on web');
    }

    try {
      // Hex-encode the message for personal_sign
      final hexMessage = _toHex(message);

      final signature = await _callEthereumMethod('personal_sign', [
        hexMessage,
        _connectedWallet,
      ]);

      return signature as String?;
    } catch (e) {
      debugPrint('Error signing message: $e');
      return null;
    }
  }

  /// Helper to convert string to hex with 0x prefix
  String _toHex(String input) {
    if (input.startsWith('0x')) return input;
    return '0x${input.codeUnits.map((c) => c.toRadixString(16).padLeft(2, '0')).join()}';
  }

  /// Authenticate with backend using wallet signature
  Future<Map<String, dynamic>?> authenticate({
    required String studentName,
    String? email,
    String? role,
  }) async {
    if (_connectedWallet == null) {
      throw Exception('Wallet not connected');
    }

    try {
      // 1. Get Nonce from Backend
      final nonceResponse = await http.post(
        Uri.parse('http://localhost:8080/api/auth/nonce'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'walletAddress': _connectedWallet}),
      );

      if (nonceResponse.statusCode != 200) {
        throw Exception('Failed to get nonce from backend');
      }

      final nonceData = jsonDecode(nonceResponse.body);
      final messageToSign = nonceData['message'];

      // 2. Sign the Nonce Message
      final signature = await signMessage(messageToSign);
      if (signature == null) {
        return null;
      }

      // 3. Send Signature to Backend
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/auth/login/wallet'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'walletAddress': _connectedWallet,
          'signature': signature,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        await _saveUserData(userData);
        return userData;
      }

      return null;
    } catch (e) {
      debugPrint('Error authenticating: $e');
      return null;
    }
  }

  /// Disconnect wallet
  Future<void> disconnect() async {
    _connectedWallet = null;
    await _clearSavedData();
  }

  /// Call Ethereum method via MetaMask using dynamic invocation
  Future<dynamic> _callEthereumMethod(
    String method,
    List<dynamic> params,
  ) async {
    if (!kIsWeb) {
      throw UnsupportedError('MetaMask is only supported on web');
    }

    try {
      // Get ethereum object from window
      final ethereum = (html.window as dynamic).ethereum;
      if (ethereum == null) {
        throw Exception('MetaMask is not available');
      }

      // Create request object
      final request = {'method': method, 'params': params};

      // Call ethereum.request() and await the result
      final result = await (ethereum.request(request) as Future);
      return result;
    } catch (e) {
      debugPrint('Error calling Ethereum method: $e');
      throw Exception('MetaMask Error: $e');
    }
  }

  /// Save wallet address to local storage
  Future<void> _saveWallet(String wallet) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_walletKey, wallet.toLowerCase());
  }

  /// Load saved wallet from local storage
  Future<void> _loadSavedWallet() async {
    final prefs = await SharedPreferences.getInstance();
    _connectedWallet = prefs.getString(_walletKey);
  }

  /// Save user data to local storage
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  /// Get saved user data
  Future<Map<String, dynamic>?> getSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  /// Clear all saved data
  Future<void> _clearSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_walletKey);
    await prefs.remove(_userKey);
  }

  /// Format wallet address for display (0x1234...5678)
  static String formatAddress(String address) {
    if (address.length < 10) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }
}
