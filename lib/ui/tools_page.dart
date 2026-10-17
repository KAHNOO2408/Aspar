import 'dart:io';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../installers.dart';
import '../pickers.dart';
import '../settings.dart';
import 'widgets.dart';

/// کش Gradle برای کتابخانه‌های Kotlin.
class KotlinPage extends StatelessWidget {
  const KotlinPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warm = app.hasLibrary ? app.libPath(['kotlin_warmup']) : '';
    final exists = warm.isNotEmpty && Directory(warm).existsSync();
    return ListView(padding: const EdgeInsets.all(24), children: [
      Text('کش Gradle برای Kotlin و اندروید', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      const Text(
        'سرورهای Maven و Google از محیط ساخت این کتابخانه بسته بودند، به همین دلیل کتابخانه‌های Kotlin داخل بسته نیستند. '
        'یک پروژه‌ی آماده‌ی «گرم‌کردن کش» اینجا هست: یک بار با اینترنت یا VPN اجرایش کن تا همه‌ی کتابخانه‌های بخش Kotlin '
        '(حدود ۶۰ مورد) در کش Gradle کامپیوترت ذخیره شوند. بعد از آن پروژه‌هایت با Offline mode بیلد می‌شوند.',
        style: TextStyle(height: 1.9),
      ),
      const SizedBox(height: 16),
      InfoCard(title: 'دانلود همه برای آفلاین', icon: Icons.cloud_download, children: [
        Text(exists ? 'پروژه: $warm' : 'پوشه‌ی kotlin_warmup در کتابخانه پیدا نشد.'),
        const SizedBox(height: 10),
        Wrap(spacing: 10, runSpacing: 10, children: [
          FilledButton.icon(
            onPressed: !exists
                ? null
                : () => showRunDialog(context, 'دانلود کتابخانه‌های Kotlin', (log) async {
                      final cmd = Platform.isWindows ? 'gradlew.bat' : './gradlew';
                      final code = await runStreaming(cmd, ['warmup', 'assembleDebug', '--continue'],
                          workingDirectory: warm, onLine: log);
                      return code == 0
                          ? 'تمام شد ✅ حالا در Android Studio گزینه‌ی Offline mode را روشن کن.'
                          : 'بخشی خطا داد. اگر خط WARMUP_DONE را در گزارش می‌بینی، کتابخانه‌ها دانلود شده‌اند و خطای بیلد مهم نیست. '
                              'اگر خطای SDK location دیدی، README-fa.txt را بخوان.';
                    }),
            icon: const Icon(Icons.play_arrow),
            label: const Text('شروع دانلود (نیاز به اینترنت)'),
          ),
          OutlinedButton.icon(
            onPressed: exists ? () => openInExplorer(warm) : null,
            icon: const Icon(Icons.folder),
            label: const Text('باز کردن پوشه'),
          ),
        ]),
      ]),
      InfoCard(title: 'بعد از دانلود', icon: Icons.offline_bolt, children: const [
        Text('Android Studio: File → Settings → Build, Execution, Deployment → Gradle → Offline mode', style: TextStyle(height: 1.8)),
        CodeBox('gradlew assembleDebug --offline', label: 'خط فرمان'),
        Text('آفلاین فقط برای همین نسخه‌ها کار می‌کند. اگر پروژه‌ات نسخه‌ی دیگری بخواهد، آن را یک بار آنلاین بگیر.',
            style: TextStyle(height: 1.8)),
      ]),
    ]);
  }
}

/// تنظیمات و افزودن افزونه‌ی کاربر.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final _port = TextEditingController(text: '${app.settings.port}');
  late final _flutter = TextEditingController(text: app.settings.flutterCmd);

  @override
  void dispose() {
    _port.dispose();
    _flutter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) => ListView(padding: const EdgeInsets.all(24), children: [
        Text('تنظیمات و افزودن افزونه', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        InfoCard(title: 'افزودن افزونه‌ی Godot از فایل zip', icon: Icons.add_circle, children: [
          const Text(
            'افزونه‌هایی که فایل کامپایل‌شده دارند (مثل Terrain3D، LimboAI و Debug Draw 3D) را از صفحه‌ی Releases در GitHub دانلود کن '
            'و اینجا اضافه کن. از این به بعد مثل بقیه‌ی افزونه‌ها در جستجو پیدا می‌شوند و با یک کلیک نصب می‌شوند.',
            style: TextStyle(height: 1.8),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: !app.hasLibrary
                ? null
                : () async {
                    final zip = await pickFile(title: 'فایل zip افزونه');
                    if (zip == null || !context.mounted) return;
                    await showRunDialog(context, 'افزودن افزونه', (log) async {
                      final r = await addUserGodotZip(app.libraryPath!, zip, log);
                      await app.reloadCatalog();
                      return r.message;
                    });
                  },
            icon: const Icon(Icons.upload_file),
            label: const Text('انتخاب فایل zip'),
          ),
        ]),
        InfoCard(title: 'پوشه‌ی کتابخانه', icon: Icons.folder_special, children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: SelectableText(app.libraryPath ?? '(پیدا نشد)'),
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 10, children: [
            OutlinedButton.icon(
              onPressed: () async {
                final d = await pickFolder(title: 'پوشه‌ی library را انتخاب کن');
                if (d == null || !context.mounted) return;
                if (!Settings.isLibrary(d)) {
                  toast(context, 'این پوشه کتابخانه نیست (باید داخلش pub یا godot باشد).');
                  return;
                }
                await app.setLibraryPath(d);
              },
              icon: const Icon(Icons.folder_open),
              label: const Text('تغییر'),
            ),
            if (app.libraryPath != null)
              OutlinedButton.icon(
                onPressed: () => openInExplorer(app.libraryPath!),
                icon: const Icon(Icons.launch),
                label: const Text('باز کردن'),
              ),
          ]),
        ]),
        InfoCard(title: 'سرور و Flutter', icon: Icons.settings, children: [
          Row(children: [
            const Text('پورت سرور: '),
            SizedBox(
              width: 120,
              child: TextField(controller: _port, keyboardType: TextInputType.number, textDirection: TextDirection.ltr),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Text('دستور Flutter: '),
            SizedBox(
              width: 320,
              child: TextField(controller: _flutter, textDirection: TextDirection.ltr),
            ),
          ]),
          const Text('اگر flutter در PATH نیست، مسیر کامل flutter.bat را بنویس.', style: TextStyle(fontSize: 12)),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('اجرای خودکار سرور هنگام باز شدن برنامه'),
            value: app.settings.autoStartServer,
            onChanged: (v) {
              app.settings.autoStartServer = v;
              app.saveSettings();
            },
          ),
          FilledButton(
            onPressed: () async {
              final p = int.tryParse(_port.text.trim());
              if (p == null || p < 1024 || p > 65535) {
                toast(context, 'پورت باید عددی بین ۱۰۲۴ و ۶۵۵۳۵ باشد.');
                return;
              }
              final changed = p != app.settings.port;
              app.settings.port = p;
              app.settings.flutterCmd = _flutter.text.trim().isEmpty ? 'flutter' : _flutter.text.trim();
              await app.saveSettings();
              if (changed && (app.server?.running ?? false)) {
                await app.stopServer();
                await app.startServer();
              }
              if (context.mounted) toast(context, 'ذخیره شد');
            },
            child: const Text('ذخیره'),
          ),
        ]),
        InfoCard(title: 'درباره', icon: Icons.info_outline, children: [
          Text(
            'کتابخانه‌ی آفلاین آسپار — ساخته‌شده در مهر ۱۴۰۵.\n'
            '${app.catalog.libs.length} کتابخانه، ${app.catalog.topics.length} راهنما، '
            '${app.catalog.stats['pub_packages'] ?? 0} پکیج Dart (${app.catalog.stats['pub_versions'] ?? 0} نسخه) برای کار آفلاین.\n'
            'همه‌ی کتابخانه‌ها متن‌باز هستند (MIT، BSD، Apache یا CC0) و مجوز هر کدام داخل فایل خودش است.',
            style: const TextStyle(height: 1.9),
          ),
        ]),
      ]),
    );
  }
}
