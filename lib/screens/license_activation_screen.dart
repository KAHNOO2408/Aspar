import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'login_screen.dart';

class LicenseActivationScreen extends StatefulWidget {
  const LicenseActivationScreen({Key? key}) : super(key: key);

  @override
  State<LicenseActivationScreen> createState() => _LicenseActivationScreenState();
}

class _LicenseActivationScreenState extends State<LicenseActivationScreen> {
  final licenseCodeController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool isLoading = false;

  final validLicenseCodes = [
    'ASPAR-2024-BASIC',
    'ASPAR-2024-PRO',
    'ASPAR-2024-PREMIUM',
  ];

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
                  SvgPicture.asset('assets/logo.svg', width: 110, height: 110),
                  const SizedBox(height: 20),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFF4F6BF5), Color(0xFF2B3FBE)]).createShader(bounds),
                    child: const Text('🔓 فعال‌سازی لایسنس', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  const Text('برای استفاده از آسپار', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 30),

                  TextField(controller: licenseCodeController, decoration: _decoration('کد لایسنس *', Icons.vpn_key)),
                  const SizedBox(height: 15),
                  TextField(controller: usernameController, decoration: _decoration('نام کاربری *', Icons.person)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: _decoration('رمز عبور *', Icons.lock,
                        suffix: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF4F6BF5)), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: _obscureConfirm,
                    decoration: _decoration('تأیید رمز عبور *', Icons.lock_outline,
                        suffix: IconButton(icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF4F6BF5)), onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm))),
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
                        onTap: isLoading ? null : _activateLicense,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: isLoading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.verified_user, color: Colors.white),
                                      SizedBox(width: 10),
                                      Text('فعال‌سازی', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _activateLicense() async {
    final licenseCode = licenseCodeController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (licenseCode.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError('تمام فیلدها الزامی هستند!');
      return;
    }
    if (!validLicenseCodes.contains(licenseCode)) {
      _showError('کد لایسنس نامعتبر است!');
      return;
    }
    if (password != confirmPassword) {
      _showError('رمزهای عبور مطابقت ندارند!');
      return;
    }
    if (password.length < 6) {
      _showError('رمز عبور حداقل 6 کاراکتر باید باشد!');
      return;
    }

    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    final authBox = await Hive.openBox('auth');
    await authBox.put('username', username);
    await authBox.put('password', password);
    await authBox.put('licenseCode', licenseCode);
    await authBox.put('activated', true);

    setState(() => isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لایسنس فعال شد! ✅')));
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  void dispose() {
    licenseCodeController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
