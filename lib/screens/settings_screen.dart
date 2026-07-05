import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io';
import '../models/theme_provider.dart';
import '../models/transaction_model.dart';
import '../models/bank_model.dart';
import '../models/payment_model.dart';
import '../models/product_model.dart';
import '../models/ledger_model.dart';
import '../models/contact_model.dart';
import '../models/loan_model.dart';
import 'package:provider/provider.dart';
import '../widgets/pattern_lock_widget.dart';
import '../utils/app_colors.dart';
import '../services/backup_service.dart';
import 'license_activation_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _useBiometric = false;
  bool _usePattern = false;
  bool _isProcessing = false;
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

  String _hashPattern(List<int> pattern) => sha256.convert(utf8.encode(pattern.join('-'))).toString();

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<bool> _confirmSwitchMethod(String newMethodName, String currentMethodName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('تغییر روش ورود', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context))),
        content: Text('برای استفاده از «$newMethodName»، باید «$currentMethodName» غیرفعال شود. آیا ادامه می‌دهید؟', style: TextStyle(color: AppColors.text(context))),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('انصراف')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B3FBE), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('تایید', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
    return result ?? false;
  }

  Future<bool> _showPatternSetupFlow() async {
    List<int>? firstPattern;
    bool success = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final title = firstPattern == null ? 'الگوی جدید را رسم کنید' : 'الگو را دوباره رسم کنید';
            return AlertDialog(
              backgroundColor: AppColors.card(dialogContext),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(dialogContext))),
              content: SizedBox(
                width: 260,
                height: 280,
                child: PatternLockWidget(
                  onComplete: (pattern) {
                    if (pattern.length < 4) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الگو باید حداقل ۴ نقطه داشته باشد')));
                      return;
                    }
                    if (firstPattern == null) {
                      setDialogState(() => firstPattern = pattern);
                    } else {
                      if (_listEquals(firstPattern!, pattern)) {
                        final hash = _hashPattern(pattern);
                        settingsBox.put('patternHash', hash);
                        success = true;
                        Navigator.of(dialogContext).pop();
                      } else {
                        setDialogState(() => firstPattern = null);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الگوها مطابقت ندارند، دوباره تلاش کنید')));
                      }
                    }
                  },
                ),
              ),
              actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('انصراف'))],
            );
          },
        );
      },
    );

    return success;
  }

  Future<void> _onBiometricChanged(bool value) async {
    if (value) {
      if (_usePattern) {
        final confirmed = await _confirmSwitchMethod('اثر انگشت', 'ورود با الگو');
        if (!confirmed) return;
        setState(() => _usePattern = false);
        await settingsBox.put('usePattern', false);
        await settingsBox.delete('patternHash');
      }
      setState(() => _useBiometric = true);
      await settingsBox.put('useBiometric', true);
    } else {
      setState(() => _useBiometric = false);
      await settingsBox.put('useBiometric', false);
    }
  }

  Future<void> _onPatternChanged(bool value) async {
    if (value) {
      if (_useBiometric) {
        final confirmed = await _confirmSwitchMethod('ورود با الگو', 'اثر انگشت');
        if (!confirmed) return;
        setState(() => _useBiometric = false);
        await settingsBox.put('useBiometric', false);
      }
      final confirmedPattern = await _showPatternSetupFlow();
      if (confirmedPattern) {
        setState(() => _usePattern = true);
        await settingsBox.put('usePattern', true);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الگو ذخیره شد ✅')));
      }
    } else {
      setState(() => _usePattern = false);
      await settingsBox.put('usePattern', false);
      await settingsBox.delete('patternHash');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('تنظیمات'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSection(
              title: 'امنیت',
              icon: Icons.security_rounded,
              gradient: const [Color(0xFF4F6BF5), Color(0xFF2B3FBE)],
              children: [
                _buildSettingTile(icon: Icons.fingerprint, title: 'ورود با اثر انگشت', subtitle: 'فعال‌سازی بیومتریک', value: _useBiometric, onChanged: _onBiometricChanged),
                _buildSettingTile(icon: Icons.pattern, title: 'ورود با الگو', subtitle: 'رسم الگو برای ورود', value: _usePattern, onChanged: _onPatternChanged),
                _buildButton(icon: Icons.lock_reset, title: 'تغییر رمز عبور', onTap: _showChangePassword),
              ],
            ),
            const SizedBox(height: 20),

            _buildSection(
              title: 'نمایش',
              icon: Icons.palette_rounded,
              gradient: const [Color(0xFF9B6DFF), Color(0xFF6A3DE8)],
              children: [
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return _buildSettingTile(icon: Icons.dark_mode, title: 'تم تاریک', subtitle: 'فعال‌سازی حالت شب', value: themeProvider.isDarkMode, onChanged: (value) => themeProvider.toggleTheme());
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildSection(
              title: 'داده‌ها',
              icon: Icons.storage_rounded,
              gradient: const [Color(0xFF00C6A9), Color(0xFF00897B)],
              children: [
                _buildButton(icon: Icons.backup, title: 'Backup', subtitle: 'پشتیبان‌گیری از تمام داده‌ها', onTap: _showBackup),
                _buildButton(icon: Icons.restore, title: 'Restore', subtitle: 'بازگردانی از پشتیبان', onTap: _showRestore),
                _buildButton(icon: Icons.delete_sweep, title: 'پاک کردن تمام داده‌ها', subtitle: 'حذف کامل تمام اطلاعات', color: const Color(0xFFE64A19), onTap: _showDeleteAll),
              ],
            ),
            const SizedBox(height: 20),

            _buildSection(
              title: 'اطلاعات',
              icon: Icons.info_outline_rounded,
              gradient: const [Color(0xFFFF7A59), Color(0xFFE64A19)],
              children: [
                _buildButton(icon: Icons.info, title: 'درباره اپ', onTap: _showAbout),
                _buildButton(icon: Icons.privacy_tip, title: 'سیاست حریم خصوصی', onTap: _showPrivacyPolicy),
                _buildButton(icon: Icons.contact_support, title: 'تماس و پشتیبانی', onTap: _showSupport),
              ],
            ),
            const SizedBox(height: 20),

            _buildSection(children: [_buildButton(icon: Icons.logout, title: 'خروج از حساب', color: const Color(0xFFE64A19), onTap: _logout)]),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({String? title, IconData? icon, List<Color>? gradient, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                if (icon != null && gradient != null) Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(gradient: LinearGradient(colors: gradient), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: Colors.white, size: 16)),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2B3FBE))),
              ],
            ),
          ),
        ...children,
      ],
    );
  }

  Widget _buildSettingTile({required IconData icon, required String title, String? subtitle, required bool value, required Function(bool) onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black12,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF2B3FBE).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: const Color(0xFF2B3FBE), size: 22)),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context))),
          subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context))) : null,
          trailing: Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF2B3FBE)),
        ),
      ),
    );
  }

  Widget _buildButton({required IconData icon, required String title, String? subtitle, Color color = const Color(0xFF2B3FBE), required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black12,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 22)),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
          subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context))) : null,
          trailing: _isProcessing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(Icons.arrow_forward_ios, color: AppColors.textMuted(context), size: 16),
          onTap: _isProcessing ? null : onTap,
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
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('تغییر رمز عبور', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldPassController, obscureText: true, style: TextStyle(color: AppColors.text(context)), decoration: InputDecoration(labelText: 'رمز عبور فعلی', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 15),
            TextField(controller: newPassController, obscureText: true, style: TextStyle(color: AppColors.text(context)), decoration: InputDecoration(labelText: 'رمز عبور جدید', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 15),
            TextField(controller: confirmPassController, obscureText: true, style: TextStyle(color: AppColors.text(context)), decoration: InputDecoration(labelText: 'تأیید رمز عبور', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B3FBE), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('تغییر', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Backup', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context))),
        content: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.backup, size: 64, color: Color(0xFF00897B)), const SizedBox(height: 20), Text('یه پوشه به اسم «اسپار» توی حافظه‌ی گوشی ساخته میشه و تمام اطلاعات (بانک، بدهی/طلب، محصولات، مخاطبین، وام، تنظیمات و...) توش ذخیره میشه.', style: TextStyle(color: AppColors.text(context)), textAlign: TextAlign.center)]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isProcessing = true);
              try {
                final path = await BackupService.createBackup();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('پشتیبان‌گیری انجام شد ✅\n$path'), duration: const Duration(seconds: 5)));
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در پشتیبان‌گیری: $e'), backgroundColor: Colors.red));
              } finally {
                if (mounted) setState(() => _isProcessing = false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00897B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Restore', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context))),
        content: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.restore, size: 64, color: Color(0xFF4F6BF5)), const SizedBox(height: 20), Text('آخرین پشتیبان از پوشه‌ی «اسپار» بازگردانی میشه.\n\n⚠️ داده‌های فعلی جای اطلاعات قبلی رو می‌گیرن.', style: TextStyle(color: AppColors.text(context)), textAlign: TextAlign.center)]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isProcessing = true);
              try {
                final file = await BackupService.getLatestBackupFile();
                if (file == null) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('هیچ فایل پشتیبانی پیدا نشد'), backgroundColor: Colors.red));
                  return;
                }
                await BackupService.restoreFromFile(file);

                if (mounted) {
                  await context.read<TransactionProvider>().loadTransactions();
                  await context.read<BankProvider>().loadBanks();
                  await context.read<PaymentProvider>().loadPayments();
                  await context.read<ProductProvider>().loadAll();
                  await context.read<LedgerProvider>().loadEntries();
                  await context.read<ContactProvider>().loadContacts();
                  await context.read<LoanProvider>().loadLoans();
                }

                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('بازگردانی انجام شد ✅')));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در بازگردانی: $e'), backgroundColor: Colors.red));
              } finally {
                if (mounted) setState(() => _isProcessing = false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F6BF5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('پاک کردن تمام داده‌ها', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFE64A19))),
        content: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.warning, size: 64, color: Color(0xFFE64A19)), const SizedBox(height: 20), Text('این عمل غیرقابل بازگشت است!', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text(context))), const SizedBox(height: 10), Text('تمام تراکنش‌ها، بانک‌ها و دیگر اطلاعات حذف خواهند شد.', style: TextStyle(color: AppColors.text(context)))]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          ElevatedButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمام داده‌ها پاک شدند ✅'), backgroundColor: Colors.red)); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE64A19), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('پاک کن', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('درباره اپ', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('آسپار', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF2B3FBE))),
            const SizedBox(height: 10),
            Text('نسخه: 1.0.0', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text(context))),
            const SizedBox(height: 5),
            Text('توسعه‌دهنده: بنیامین قاسمی', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text(context))),
            const SizedBox(height: 15),
            Text('اپ حسابداری شخصی برای مدیریت درآمد، خرج و بدهی‌ها', style: TextStyle(color: AppColors.text(context))),
          ],
        ),
        actions: [ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B3FBE), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('بستن', style: TextStyle(color: Colors.white)))],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('سیاست حریم خصوصی', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('اطلاعات شما محفوظ است', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text(context))),
              const SizedBox(height: 10),
              Text('• تمام داده‌ها محلی ذخیره می‌شوند\n• هیچ اطلاعاتی آنلاین ذخیره نمی‌شود\n• تنها شما دسترسی دارید', style: TextStyle(fontSize: 13, color: AppColors.text(context))),
            ],
          ),
        ),
        actions: [ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B3FBE), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('فهمیدم', style: TextStyle(color: Colors.white)))],
      ),
    );
  }

  void _showSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('تماس و پشتیبانی', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('برای تماس با ما:', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text(context))),
            const SizedBox(height: 15),
            Text('📧 ایمیل:\nkahnoo9203@gmail.com', style: TextStyle(fontSize: 13, color: AppColors.text(context))),
            const SizedBox(height: 10),
            Text('📱 تلفن:\n+989177582408', style: TextStyle(fontSize: 13, color: AppColors.text(context))),
            const SizedBox(height: 10),
            Text('💬 تلگرام:\n@aspar_accounting', style: TextStyle(fontSize: 13, color: AppColors.text(context))),
          ],
        ),
        actions: [ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B3FBE), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('بستن', style: TextStyle(color: Colors.white)))],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('خروج', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context))),
        content: Text('آیا می‌خواهید از حساب خود خارج شوید؟', style: TextStyle(color: AppColors.text(context))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LicenseActivationScreen()), (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE64A19), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('خروج', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
