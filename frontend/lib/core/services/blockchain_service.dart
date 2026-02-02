import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'metamask_service.dart';
import '../config/api_config.dart';

/// Contract address - should be loaded from environment/config
const String _contractAddress =
    '0x5FbDB2315678afecb367f032d93F642f64180aa3'; // Local Hardhat default

class BlockchainService {
  final MetaMaskService _metaMaskService = MetaMaskService();
  final String _backendUrl = ApiConfig.baseUrl;

  /// Orchestrates the full secure minting flow
  /// 1. Prepares mint on backend (generates Academic DNA)
  /// 2. Sends transaction to blockchain via MetaMask
  /// 3. Returns transaction hash for tracking
  Future<Map<String, dynamic>> mintCertificate({
    required String studentWallet,
    required String studentName,
    required String courseName,
    required String courseId,
    required String userId,
    required double marks,
    required String instructorWallet,
  }) async {
    if (!kIsWeb) {
      throw UnsupportedError('Blockchain minting is only supported on web');
    }

    // 1. Prepare Certificate on Backend (get Academic DNA and hash)
    debugPrint('📝 Preparing certificate on backend...');
    final prepareResponse = await http.post(
      Uri.parse('$_backendUrl/instructor/certificate/generate'),
      headers: {
        'Content-Type': 'application/json',
        'X-Wallet-Address': instructorWallet,
      },
      body: jsonEncode({
        'userId': userId,
        'userName': studentName,
        'courseId': courseId,
        'courseName': courseName,
        'marks': marks,
        'walletAddress': studentWallet,
      }),
    );

    if (prepareResponse.statusCode != 200) {
      final errorBody = jsonDecode(prepareResponse.body);
      throw Exception(
        'Failed to prepare certificate: ${errorBody['error'] ?? prepareResponse.body}',
      );
    }

    final prepareData = jsonDecode(prepareResponse.body);
    final certificateHash = prepareData['certificateHash'] as String;
    final academicDNA = prepareData['academicDNA'] as String;

    debugPrint('✅ Certificate prepared. Hash: $certificateHash');

    // 2. Send Transaction to Blockchain via MetaMask
    debugPrint('🔗 Sending transaction to blockchain...');
    final txHash = await _sendMintTransaction(
      certHash: certificateHash,
      studentWallet: studentWallet,
      academicDNA: academicDNA,
    );

    debugPrint('✅ Transaction sent. Hash: $txHash');

    return {
      'success': true,
      'certificateHash': certificateHash,
      'transactionHash': txHash,
      'academicDNA': academicDNA,
    };
  }

  /// Sends the actual mint transaction via MetaMask using eth_sendTransaction
  Future<String> _sendMintTransaction({
    required String certHash,
    required String studentWallet,
    required String academicDNA,
  }) async {
    if (!_metaMaskService.isMetaMaskInstalled) {
      throw Exception('MetaMask is not installed');
    }

    final connectedWallet = _metaMaskService.connectedWallet;
    if (connectedWallet == null) {
      throw Exception('Wallet not connected. Please connect MetaMask first.');
    }

    try {
      // Encode the function call data
      final data = _encodeMintFunctionCall(
        certHash,
        studentWallet,
        academicDNA,
      );

      // Build the transaction object
      final txParams = {
        'from': connectedWallet,
        'to': _contractAddress,
        'data': data,
        // 'gas': '0x493E0', // Let MetaMask estimate gas
      };

      // Call ethereum.request() via MetaMaskService
      final result = await _metaMaskService.callMethod('eth_sendTransaction', [
        txParams,
      ]);

      if (result != null) {
        // Cast to JSString and convert to Dart String
        // We need dart:js_interop for this
        return (result as JSString).toDart;
      }

      throw Exception('Transaction returned null');
    } catch (e) {
      if (e.toString().contains('User denied') ||
          e.toString().contains('rejected')) {
        throw Exception('Transaction rejected by user');
      }
      debugPrint('Error sending transaction: $e');
      throw Exception('Failed to send transaction: $e');
    }
  }

  /// Encodes the mintCertificate function call data
  /// Function: mintCertificate(bytes32 _certHash, address _owner, string _academicDNA)
  String _encodeMintFunctionCall(
    String certHash,
    String owner,
    String academicDNA,
  ) {
    // Function selector: keccak256("mintCertificate(bytes32,address,string)")[:4]
    const functionSelector =
        '0x6a627842'; // This is a placeholder - should be computed

    // For a proper implementation, you would use a library like web3dart
    // For now, we'll use a simplified encoding approach

    // Ensure certHash is 32 bytes (64 hex chars)
    String paddedCertHash = certHash.startsWith('0x')
        ? certHash.substring(2)
        : certHash;
    paddedCertHash = paddedCertHash.padLeft(64, '0');

    // Pad address to 32 bytes
    String paddedAddress = owner.startsWith('0x') ? owner.substring(2) : owner;
    paddedAddress = paddedAddress.toLowerCase().padLeft(64, '0');

    // String encoding (dynamic type)
    // Offset to string data (3 * 32 = 96 = 0x60)
    const stringOffset =
        '0000000000000000000000000000000000000000000000000000000000000060';

    // String length (in bytes)
    final stringLengthHex = academicDNA.length
        .toRadixString(16)
        .padLeft(64, '0');

    // String data (padded to 32-byte boundary)
    String stringData = '';
    for (int i = 0; i < academicDNA.length; i++) {
      stringData += academicDNA.codeUnitAt(i).toRadixString(16).padLeft(2, '0');
    }
    // Pad to 32-byte boundary
    final paddingNeeded = (32 - (academicDNA.length % 32)) % 32;
    stringData = stringData.padRight(
      stringData.length + paddingNeeded * 2,
      '0',
    );

    return functionSelector +
        paddedCertHash +
        paddedAddress +
        stringOffset +
        stringLengthHex +
        stringData;
  }

  /// Get the contract address
  String get contractAddress => _contractAddress;
}
