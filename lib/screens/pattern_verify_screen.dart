import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../widgets/pattern_lock_widget.dart';

class PatternVerifyScreen extends StatefulWidget {
  const PatternVerifyScreen({Key? key}) : super(key: key);

  @override
  State<PatternVerifyScreen> createState() => _PatternVerifyScreenState();
}

class _PatternVerifyScreenState extends State<PatternVerifyScreen> {
  String? _errorMessage;
  int _attempts = 0;

  String _hashPattern(List<int> pattern) {
    return sha256.convert(utf8.encode(pattern.join('-'))).toString();
  }

  void _onPatternComplete(List<int> pattern) async {
    if (pattern.length < 4) {
      setState(() => _errorMessage = 'الگو خیلی کوتاه است، دوباره تلاش کنید');
      return;
    }
    final settingsBox = await Hive.openBox('settings');
    final savedHash = settingsBox.get('patternHash');
    final enteredHash = _hashPattern(pattern);

    if (enteredHash == savedHash) {
      if (mounted) Navigator.of(context).pop(true);
    } else {
      setState(() {
        _attempts++;
        _errorMessage = 'الگو اشتباه است، دوباره تلاش کنید';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pattern, size: 60, color: Colors.white),
              const SizedBox(height: 20),
              const Text('الگوی خود را رسم کنید', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: PatternLockWidget(
                  key: ValueKey(_attempts),
                  onComplete: _onPatternComplete,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('ورود با نام کاربری و رمز عبور', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
