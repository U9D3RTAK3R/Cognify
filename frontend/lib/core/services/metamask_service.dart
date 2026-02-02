import 'dart:convert';
import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:cognify/core/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// MetaMask wallet service for Web3 authentication (Web-only)
/// Uses dart:js_interop to communicate with MetaMask browser extension
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
    // Check if 'ethereum' property exists on the global window object
    return globalContext.has('ethereum');
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
      // eth_requestAccounts takes no parameters usually, but we pass empty list
      final accounts = await callMethod('eth_requestAccounts', []);

      // Result is a JSArray of strings
      // We need to verify what we get back. usually it's a List<dynamic> (from toDart)
      // or we might need to cast.

      final List<dynamic> accountList = (accounts as JSArray).toDart;

      if (accountList.isNotEmpty) {
        // The items in the list might be JSStrings, convert to Dart String
        final account = (accountList[0] as JSString).toDart;
        _connectedWallet = account;
        await _saveWallet(_connectedWallet!);
        return _connectedWallet;
      }

      return null;
    } catch (e) {
      debugPrint('Error connecting wallet: $e');
      throw Exception('MetaMask Error: $e');
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

      // personal_sign params: [message, address]
      // personal_sign params: [message, address]
      final signature = await callMethod('personal_sign', [
        hexMessage,
        _connectedWallet,
      ]);

      return (signature as JSString).toDart;
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
        Uri.parse(
          '${ApiConfig.apiUrl}/auth/nonce',
        ), // Use correct backend URL
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
        Uri.parse('${ApiConfig.apiUrl}/auth/login/wallet'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'walletAddress': _connectedWallet,
          'signature': signature,
          'email': email,
          'role': role,
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

  /// Call Ethereum method via MetaMask using dart:js_interop
  Future<JSAny?> callMethod(String method, List<dynamic> params) async {
    if (!kIsWeb) {
      throw UnsupportedError('MetaMask is only supported on web');
    }

    try {
      // Get ethereum object from global context
      final ethereum = globalContext['ethereum'] as JSObject?;

      if (ethereum == null) {
        throw Exception('MetaMask is not available');
      }

      // Create request object { method: '...', params: [...] }
      final requestObj = JSObject();
      requestObj['method'] = method.toJS;

      // Convert params list to Dart list of JSAny? first, then to JSArray
      final List<JSAny?> jsParamsList = [];
      for (var p in params) {
        if (p is String) {
          jsParamsList.add(p.toJS);
        } else if (p is Map) {
          // Convert Map to JSObject (e.g. for transaction params)
          final paramObj = JSObject();
          p.forEach((k, v) {
            if (v is String) paramObj[k.toString()] = v.toJS;
            // Add other types logic if needed
          });
          jsParamsList.add(paramObj);
        } else if (p == null) {
          jsParamsList.add(null);
        } else if (p is JSAny) {
          jsParamsList.add(p);
        }
      }

      requestObj['params'] = jsParamsList.toJS;

      // Call ethereum.request(requestObj)
      // request returns a Promise
      final promise = ethereum.callMethod('request'.toJS, requestObj);

      // Convert Promise to Dart Future
      final result = await (promise as JSPromise).toDart;
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
