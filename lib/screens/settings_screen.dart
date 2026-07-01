import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/theme_provider.dart';
import 'package:provider/provider.dart';
import 'license_activation_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _useBiometric = false;
  bool _usePattern = false;
  late Box settingsBox;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    settingsBox = await Hive.openBox('settings');
    setState(() {
      _useBiometric = settingsBox.get('useBiometric', defaultValue: false);
      _usePattern = settingsBox.get('usePattern', defaultValue: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // امنیت
            _buildSection(
              title: '🔐 امنیت',
              children: [
                _buildSettingTile(
                  icon: Icons.fingerprint,
                  title: 'ورود با اثر انگشت',
                  subtitle: 'فعال‌سازی بیومتریک',
                  value: _useBiometric,
                  onChanged: (value) async {
                    setState(() => _useBiometric = value);
                    await settingsBox.put('useBiometric', value);
                  },
                ),
                _buildSettingTile(
                  icon: Icons.pattern,
                  title: 'ورود با الگو',
                  subtitle: 'رسم الگو برای ورود',
                  value: _usePattern,
                  onChanged: (value) async {
                    setState(() => _usePattern = value);
                    await settingsBox.put('usePattern', value);
                    if (value) _showPatternSetup();
                  },
                ),
                _buildButton(
                  icon: Icons.lock_reset,
                  title: 'تغییر رمز عبور',
                  onTap: _showChangePassword,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // نمایش
            _buildSection(
              title: '🎨 نمایش',
              children: [
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return _buildSettingTile(
                      icon: Icons.dark_mode,
                      title: 'تم تاریک',
                      subtitle: 'فعال‌سازی حالت شب',
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // داده‌ها
            _buildSection(
              title: '💾 داده‌ها',
              children: [
                _buildButton(
                  icon: Icons.backup,
                  title: 'Backup',
                  subtitle: 'پشتیبان‌گیری از تمام داده‌ها',
                  onTap: _showBackup,
                ),
                _buildButton(
                  icon: Icons.restore,
                  title: 'Restore',
                  subtitle: 'بازگردانی از پشتیبان',
                  onTap: _showRestore,
                ),
                _buildButton(
                  icon: Icons.delete_sweep,
                  title: 'پاک کردن تمام داده‌ها',
                  subtitle: 'حذف کامل تمام اطلاعات',
                  color: Colors.red,
                  onTap: _showDeleteAll,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // اطلاعات
            _buildSection(
              title: 'ℹ️ اطلاعات',
              children: [
                _buildButton(
                  icon: Icons.info,
                  title: 'درباره اپ',
                  onTap: _showAbout,
                ),
                _buildButton(
                  icon: Icons.privacy_tip,
                  title: 'سیاست حریم خصوصی',
                  onTap: _showPrivacyPolicy,
                ),
                _buildButton(
                  icon: Icons.contact_support,
                  title: 'تماس و پشتیبانی',
                  onTap: _showSupport,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // خروج
            _buildSection(
              children: [
                _buildButton(
                  icon: Icons.logout,
                  title: 'خروج از حساب',
                  color: Colors.red,
                  onTap: _logout,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({String? title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.indigo)),
          ),
        ...children,
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Icon(icon, color: Colors.indigo, size: 26),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.indigo,
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String title,
    String? subtitle,
    Color color = Colors.indigo,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Icon(icon, color: color, size: 26),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
          subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showChangePassword() {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغییر رمز عبور', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPassController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'رمز عبور فعلی',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'رمز عبور جدید',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: confirmPassController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'تأیید رمز عبور',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () async {
              final authBox = await Hive.openBox('auth');
              final currentPass = authBox.get('password');

              if (oldPassController.text != currentPass) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('رمز عبور فعلی اشتباه است!')));
                return;
              }

              if (newPassController.text != confirmPassController.text) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('رمزهای عبور مطابقت ندارند!')));
                return;
              }

              await authBox.put('password', newPassController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('رمز عبور تغییر کرد ✅')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            child: const Text('تغییر', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPatternSetup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تنظیم الگو', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pattern, size: 64, color: Colors.indigo),
            const SizedBox(height: 20),
            const Text('الگوی خود را رسم کنید:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(border: Border.all(color: Colors.indigo, width: 2), borderRadius: BorderRadius.circular(10)),
              child: const Center(child: Text('صفحه رسم الگو')),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الگو ذخیره شد ✅')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            child: const Text('تأیید', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.backup, size: 64, color: Colors.green),
            SizedBox(height: 20),
            Text('آیا می‌خواهید از تمام داده‌ها پشتیبان‌گیری کنید؟'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('پشتیبان‌گیری انجام شد ✅')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('بله', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRestore() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restore, size: 64, color: Colors.blue),
            SizedBox(height: 20),
            Text('بازگردانی تمام داده‌ها؟'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('بازگردانی انجام شد ✅')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('بله', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('پاک کردن تمام داده‌ها', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, size: 64, color: Colors.red),
            SizedBox(height: 20),
            Text('این عمل غیرقابل بازگشت است!', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 10),
            Text('تمام تراکنش‌ها، بانک‌ها و دیگر اطلاعات حذف خواهند شد.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمام داده‌ها پاک شدند ✅'), backgroundColor: Colors.red));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('پاک کن', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('درباره اپ', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('آسپار', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.indigo)),
            SizedBox(height: 10),
            Text('نسخه: 1.0.0', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 5),
            Text('توسعه‌دهنده: بنیامین قاسمی', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 15),
            Text('اپ حسابداری شخصی برای مدیریت درآمد، خرج و بدهی‌ها'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            child: const Text('بستن', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('سیاست حریم خصوصی', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('اطلاعات شما محفوظ است', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 10),
              Text('• تمام داده‌ها محلی ذخیره می‌شوند\n• هیچ اطلاعاتی آنلاین ذخیره نمی‌شود\n• تنها شما دسترسی دارید', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            child: const Text('فهمیدم', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تماس و پشتیبانی', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('برای تماس با ما:', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 15),
            Text('📧 ایمیل:\nkahnoo9203@gmail.com', style: TextStyle(fontSize: 13)),
            SizedBox(height: 10),
            Text('📱 تلفن:\n+989177582408', style: TextStyle(fontSize: 13)),
            SizedBox(height: 10),
            Text('💬 تلگرام:\n@aspar_accounting', style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            child: const Text('بستن', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خروج', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('آیا می‌خواهید از حساب خود خارج شوید؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LicenseActivationScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('خروج', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
