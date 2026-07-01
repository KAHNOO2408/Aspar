import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

class SecurityService {
  static final _secureStorage = 
      (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
      ? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            keyCipherAlgorithm:
                KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
            storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
          ),
        )
      : null;

  static late encrypt.Key _key;
  static late encrypt.IV _iv;
  static String _deviceId = '';

  static Future<bool> isDeviceSecure() async {
    if (kIsWeb) return true;
    if (Platform.isAndroid) return await _checkAndroidSecurity();
    if (Platform.isIOS) return await _checkIOSSecurity();
    return true;
  }

  static Future<bool> _checkAndroidSecurity() async {
    final files = [
      '/system/app/Superuser.apk', '/system/xbin/su', '/system/bin/su',
      '/data/local/xbin/su', '/data/local/bin/su', '/system/sd/xbin/su',
      '/system/bin/failsafe/su', '/data/local/su', '/su/bin/su',
    ];
    for (var file in files) {
      try {
        if (File(file).existsSync()) {
          debugPrint('⚠️ ROOT DETECTED');
          return false;
        }
      } catch (e) {}
    }
    return true;
  }

  static Future<bool> _checkIOSSecurity() async {
    final files = [
      '/Applications/Cydia.app', '/Library/MobileSubstrate/MobileSubstrate.dylib',
      '/bin/bash', '/usr/sbin/sshd', '/etc/apt',
    ];
    for (var file in files) {
      try {
        if (File(file).existsSync()) {
          debugPrint('⚠️ JAILBREAK DETECTED');
          return false;
        }
      } catch (e) {}
    }
    return true;
  }

  static Future<bool> verifyAppIntegrity() async {
    try {
      if (_secureStorage == null) return true;
      String? storedHash = await _secureStorage?.read(key: 'app_hash') ?? null;
      String currentHash = sha256.convert(utf8.encode('aspar-app')).toString();
      if (storedHash == null) {
        await _secureStorage?.write(key: 'app_hash', value: currentHash);
        return true;
      }
      return storedHash == currentHash;
    } catch (e) {
      debugPrint('❌ Integrity Check Failed: $e');
      return true;
    }
  }

  static Future<String> getDeviceId() async {
    if (_deviceId.isNotEmpty) return _deviceId;
    try {
      _deviceId = sha256.convert(utf8.encode('aspar-device-id')).toString();
      return _deviceId;
    } catch (e) {
      _deviceId = 'unknown';
      return _deviceId;
    }
  }

  static Future<void> init() async {
    try {
      debugPrint('🔐 Initializing Security Service (Web: $kIsWeb)...');
      await getDeviceId();
      if (kIsWeb) {
        _key = encrypt.Key.fromSecureRandom(32);
        _iv = encrypt.IV.fromSecureRandom(16);
        debugPrint('✅ Web Mode: In-Memory Encryption');
        return;
      }
      if (_secureStorage == null) {
        _key = encrypt.Key.fromSecureRandom(32);
        _iv = encrypt.IV.fromSecureRandom(16);
        debugPrint('✅ Desktop Mode: In-Memory Encryption');
        return;
      }
      String? keyString = await _secureStorage?.read(key: 'master_key');
      String? ivString = await _secureStorage?.read(key: 'master_iv');
      if (keyString == null || ivString == null) {
        _key = encrypt.Key.fromSecureRandom(32);
        _iv = encrypt.IV.fromSecureRandom(16);
        await _secureStorage?.write(key: 'master_key', value: _key.base64);
        await _secureStorage?.write(key: 'master_iv', value: _iv.base64);
        debugPrint('✅ Mobile Mode: Generated New Keys');
      } else {
        _key = encrypt.Key.fromBase64(keyString);
        _iv = encrypt.IV.fromBase64(ivString);
        debugPrint('✅ Mobile Mode: Loaded Existing Keys');
      }
      debugPrint('✅ Security Service Initialized');
    } catch (e) {
      debugPrint('❌ Security Init Failed: $e');
      rethrow;
    }
  }

  static String encryptSecure(String plainText) {
    try {
      final encrypter = encrypt.Encrypter(
        encrypt.AES(_key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
      );
      final encrypted = encrypter.encrypt(plainText, iv: _iv);
      final signature = sha256.convert(utf8.encode(encrypted.base64)).toString();
      return '${encrypted.base64}::$signature';
    } catch (e) {
      debugPrint('❌ Encryption Failed: $e');
      return '';
    }
  }

  static String decryptSecure(String encryptedWithSignature) {
    try {
      final parts = encryptedWithSignature.split('::');
      if (parts.length != 2) return '';
      final encryptedText = parts[0];
      final signature = parts[1];
      final computedSignature = sha256.convert(utf8.encode(encryptedText)).toString();
      if (computedSignature != signature) {
        debugPrint('🚨 SIGNATURE MISMATCH');
        return '';
      }
      final encrypter = encrypt.Encrypter(
        encrypt.AES(_key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
      );
      final decrypted = encrypter.decrypt64(encryptedText, iv: _iv);
      return decrypted;
    } catch (e) {
      debugPrint('❌ Decryption Failed: $e');
      return '';
    }
  }

  static Future<void> saveSecureData(String key, String value) async {
    try {
      final encrypted = encryptSecure(value);
      if (_secureStorage != null) {
        await _secureStorage?.write(key: key, value: encrypted);
      }
    } catch (e) {
      debugPrint('❌ Secure Save Failed: $e');
    }
  }

  static Future<String?> getSecureData(String key) async {
    try {
      if (_secureStorage == null) return null;
      final encrypted = await _secureStorage?.read(key: key);
      if (encrypted == null) return null;
      return decryptSecure(encrypted);
    } catch (e) {
      debugPrint('❌ Secure Read Failed: $e');
      return null;
    }
  }

  static Future<void> initializeSession() async {
    try {
      final deviceId = _deviceId.isNotEmpty ? _deviceId : await getDeviceId();
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final sessionToken = sha256.convert(utf8.encode('$deviceId:$timestamp')).toString();
      if (_secureStorage != null) {
        await _secureStorage?.write(key: 'session_token', value: sessionToken);
      }
      debugPrint('✅ Session Initialized');
    } catch (e) {
      debugPrint('❌ Session Init Failed: $e');
    }
  }

  static Future<bool> validateSession() async {
    try {
      if (_secureStorage == null) return true;
      final stored = await _secureStorage?.read(key: 'session_token');
      return stored != null && stored.isNotEmpty;
    } catch (e) {
      return true;
    }
  }
}
