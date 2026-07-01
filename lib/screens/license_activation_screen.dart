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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade600, Colors.indigo.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // لوگو SVG
                    SvgPicture.asset(
                      'assets/logo.svg',
                      width: 120,
                      height: 120,
                    ),
                    const SizedBox(height: 20),

                    const Text('🔓 فعال‌سازی لایسنس', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.indigo)),
                    const SizedBox(height: 10),
                    const Text('برای استفاده از آسپار', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 30),

                    TextField(
                      controller: licenseCodeController,
                      decoration: InputDecoration(
                        labelText: 'کد لایسنس *',
                        prefixIcon: const Icon(Icons.vpn_key, color: Colors.indigo),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.indigo, width: 2)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.indigo, width: 2.5)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'نام کاربری *',
                        prefixIcon: const Icon(Icons.person, color: Colors.indigo),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.indigo, width: 2)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.indigo, width: 2.5)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'رمز عبور *',
                        prefixIcon: const Icon(Icons.lock, color: Colors.indigo),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.indigo),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.indigo, width: 2)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.indigo, width: 2.5)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 15),

                    TextField(
                      controller: confirmPasswordController,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'تأیید رمز عبور *',
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.indigo),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.indigo),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.indigo, width: 2)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.indigo, width: 2.5)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: isLoading ? null : _activateLicense,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo.shade600,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                      child: isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.verified_user, color: Colors.white),
                                SizedBox(width: 10),
                                Text('فعال‌سازی', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                              ],
                            ),
                    ),
                  ],
                ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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
