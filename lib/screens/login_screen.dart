import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';
import 'main_screen.dart';
import 'pattern_verify_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool isLoading = false;

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _biometricAvailable = false;
  bool _useBiometric = false;
  bool _usePattern = false;

  @override
  void initState() {
    super.initState();
    _initSecuritySettings();
  }

  Future<void> _initSecuritySettings() async {
    try {
      final settingsBox = await Hive.openBox('settings');
      final useBiometric = settingsBox.get('useBiometric', defaultValue: false);
      final usePattern = settingsBox.get('usePattern', defaultValue: false);

      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      setState(() {
        _useBiometric = useBiometric;
        _usePattern = usePattern;
        _biometricAvailable = canCheckBiometrics && isDeviceSupported;
      });

      if (_useBiometric && _biometricAvailable) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _authenticateWithBiometrics());
      }
    } catch (e) {
      debugPrint('Security init error: $e');
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'برای ورود، هویت خود را تایید کنید',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
      if (didAuthenticate && mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
      }
    } catch (e) {
      debugPrint('Biometric auth error: $e');
      if (mounted) _showError('احراز هویت بیومتریک ناموفق بود، لطفاً با رمز عبور وارد شوید');
    }
  }

  Future<void> _authenticateWithPattern() async {
    final result = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const PatternVerifyScreen()));
    if (result == true && mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    }
  }

  InputDecoration _decoration(String label, IconData icon, {Widget? suffix}) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4F6BF5)),
        suffixIcon: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF4F6BF5), Color(0xFF2B3FBE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 15))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('assets/logo.svg', width: 100, height: 100),
                  const SizedBox(height: 20),
                  const Text('🔐 آسپار', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF2B3FBE))),
                  const SizedBox(height: 10),
                  const Text('وارد حساب خود شوید', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 30),

                  TextField(controller: usernameController, decoration: _decoration('نام کاربری', Icons.person)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: _decoration('رمز عبور', Icons.lock,
                        suffix: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF4F6BF5)), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))),
                  ),
                  const SizedBox(height: 30),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(colors: [Color(0xFF4F6BF5), Color(0xFF2B3FBE)]),
                      boxShadow: [BoxShadow(color: const Color(0xFF2B3FBE).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 8))],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: isLoading ? null : _login,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: isLoading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.login, color: Colors.white),
                                      SizedBox(width: 10),
                                      Text('ورود', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  if ((_useBiometric && _biometricAvailable) || _usePattern) ...[
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_useBiometric && _biometricAvailable)
                          TextButton.icon(
                            onPressed: _authenticateWithBiometrics,
                            icon: const Icon(Icons.fingerprint, color: Color(0xFF4F6BF5), size: 26),
                            label: const Text('اثر انگشت', style: TextStyle(color: Color(0xFF2B3FBE), fontWeight: FontWeight.w600)),
                          ),
                        if (_usePattern)
                          TextButton.icon(
                            onPressed: _authenticateWithPattern,
                            icon: const Icon(Icons.pattern, color: Color(0xFF4F6BF5), size: 26),
                            label: const Text('الگو', style: TextStyle(color: Color(0xFF2B3FBE), fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showError('نام کاربری و رمز عبور الزامی هستند!');
      return;
    }

    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    final authBox = await Hive.openBox('auth');
    final savedUsername = authBox.get('username');
    final savedPassword = authBox.get('password');

    setState(() => isLoading = false);

    if (username == savedUsername && password == savedPassword) {
      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    } else {
      _showError('نام کاربری یا رمز عبور اشتباه است!');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
