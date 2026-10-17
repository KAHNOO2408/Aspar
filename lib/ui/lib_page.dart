import 'dart:io';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../installers.dart';
import '../models.dart';
import '../pickers.dart';
import 'topic_page.dart';
import 'widgets.dart';

class LibPage extends StatelessWidget {
  const LibPage(this.l, {super.key});
  final Lib l;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topics = [for (final t in l.topics) if (app.catalog.topicById[t] != null) app.catalog.topicById[t]!];
    return Scaffold(
      appBar: AppBar(title: Text(l.title)),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        Wrap(spacing: 8, runSpacing: 6, children: [
          Tag(ecoLabel(l.eco), color: ecoColor(l.eco)),
          Tag(catLabel(l.cat), color: catColor(l.cat)),
          l.offline
              ? const Tag('داخل کتابخانه‌ی آفلاین', color: Color(0xFF2E7D32), icon: Icons.offline_pin)
              : const Tag('با «کش Gradle» آفلاین می‌شود', color: Color(0xFF8D6E63), icon: Icons.cloud_download),
          if (l.version.isNotEmpty)
            Tag(l.eco == Eco.godot ? 'به‌روزرسانی: ${l.version}' : 'نسخه: ${l.version}', color: theme.colorScheme.primary),
          if (l.size > 0) Tag('${(l.size / 1024 / 1024).toStringAsFixed(1)} MB', color: theme.colorScheme.secondary),
        ]),
        const SizedBox(height: 18),
        Text(l.desc, style: theme.textTheme.bodyLarge?.copyWith(height: 1.8)),
        if (l.usage.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.lightbulb_outline, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text('کی استفاده کنم؟ ${l.usage}', style: const TextStyle(height: 1.7))),
            ]),
          ),
        ],
        const SizedBox(height: 20),
        _actions(context),
        const SizedBox(height: 12),
        if (l.install.isNotEmpty && !l.isTemplate)
          CodeBox(l.install,
              label: switch (l.eco) {
                Eco.flutter => l.dev ? 'pubspec.yaml → dev_dependencies' : 'pubspec.yaml → dependencies',
                Eco.godot => 'پوشه‌های نصب',
                Eco.kotlin => 'app/build.gradle.kts → dependencies',
              }),
        if (l.note.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('نکته: ${l.note}', style: TextStyle(color: theme.colorScheme.tertiary)),
          ),
        if (l.example.isNotEmpty) CodeBox(l.example, label: 'نمونه‌ی استفاده'),
        if (topics.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('راهنماهای مرتبط', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final t in topics)
              ActionChip(
                avatar: Icon(topicIcon(t.icon), size: 18),
                label: Text(t.title),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TopicPage(t))),
              ),
          ]),
        ],
        if (l.repo.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(children: [
            const Text('منبع: '),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: SelectableText(l.repo, style: const TextStyle(fontSize: 12)),
              ),
            ),
          ]),
        ],
      ]),
    );
  }

  Widget _actions(BuildContext context) {
    switch (l.eco) {
      case Eco.flutter:
        return Wrap(spacing: 10, runSpacing: 10, children: [
          FilledButton.icon(
            onPressed: () => _addToFlutter(context),
            icon: const Icon(Icons.add_box),
            label: const Text('افزودن به پروژه‌ی Flutter'),
          ),
          OutlinedButton.icon(
            onPressed: () => copyText(context, l.install),
            icon: const Icon(Icons.copy),
            label: const Text('کپی خط pubspec'),
          ),
        ]);
      case Eco.godot:
        return Wrap(spacing: 10, runSpacing: 10, children: [
          if (l.isTemplate)
            FilledButton.icon(
              onPressed: () => _extractTemplate(context),
              icon: const Icon(Icons.folder_open),
              label: const Text('استخراج پروژه در یک پوشه'),
            )
          else
            FilledButton.icon(
              onPressed: () => _installGodot(context),
              icon: const Icon(Icons.extension),
              label: const Text('نصب در پروژه‌ی Godot'),
            ),
        ]);
      case Eco.kotlin:
        return Wrap(spacing: 10, runSpacing: 10, children: [
          FilledButton.icon(
            onPressed: () => copyText(context, l.install),
            icon: const Icon(Icons.copy),
            label: const Text('کپی خطوط Gradle'),
          ),
        ]);
    }
  }

  Future<void> _addToFlutter(BuildContext context) async {
    final dir = await pickFolder(title: 'پوشه‌ی پروژه‌ی Flutter (جایی که pubspec.yaml هست)', initial: app.settings.lastFlutterProject);
    if (dir == null || !context.mounted) return;
    app.settings.lastFlutterProject = dir;
    await app.saveSettings();
    final r = await addToPubspec(dir, l);
    if (!context.mounted) return;
    if (!r.ok) {
      toast(context, r.message);
      return;
    }
    final run = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('انجام شد'),
        content: Text('${r.message}\n\nالان flutter pub get را با سرور آفلاین اجرا کنم؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('بعداً')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('اجرا کن')),
        ],
      ),
    );
    if (run == true && context.mounted) await runOfflinePubGet(context, dir);
  }

  Future<void> _installGodot(BuildContext context) async {
    final lp = app.libraryPath;
    if (lp == null) {
      toast(context, 'مسیر کتابخانه مشخص نیست (تنظیمات).');
      return;
    }
    final dir = await pickFolder(title: 'پوشه‌ی پروژه‌ی Godot (جایی که project.godot هست)', initial: app.settings.lastGodotProject);
    if (dir == null || !context.mounted) return;
    app.settings.lastGodotProject = dir;
    await app.saveSettings();
    if (!context.mounted) return;
    await showRunDialog(context, 'نصب ${l.title}', (log) async {
      final r = await installGodotAddon(lp, l, dir, log);
      return r.message;
    });
  }

  Future<void> _extractTemplate(BuildContext context) async {
    final lp = app.libraryPath;
    if (lp == null) {
      toast(context, 'مسیر کتابخانه مشخص نیست (تنظیمات).');
      return;
    }
    final dir = await pickFolder(title: 'پروژه در کدام پوشه ساخته شود؟', initial: app.settings.lastTemplateFolder);
    if (dir == null || !context.mounted) return;
    app.settings.lastTemplateFolder = dir;
    await app.saveSettings();
    if (!context.mounted) return;
    await showRunDialog(context, 'استخراج ${l.title}', (log) async {
      final r = await extractTemplate(lp, l, dir, log);
      if (r.ok) await openInExplorer(joinPath([dir, l.id.replaceFirst('tpl_', '')]));
      return r.message;
    });
  }
}

/// اجرای flutter pub get با سرور آفلاین برای یک پروژه.
Future<void> runOfflinePubGet(BuildContext context, String dir) async {
  if (app.server == null) {
    toast(context, 'سرور پکیج در دسترس نیست (پوشه‌ی library/pub).');
    return;
  }
  if (!app.server!.running) await app.startServer();
  if (!context.mounted) return;
  final url = app.server!.url;
  await showRunDialog(context, 'flutter pub get (آفلاین)', (log) async {
    final env = Map<String, String>.from(Platform.environment)..['PUB_HOSTED_URL'] = url;
    final code = await runStreaming(app.settings.flutterCmd, ['pub', 'get'],
        workingDirectory: dir, environment: env, onLine: log);
    return code == 0
        ? 'پکیج‌ها با موفقیت نصب شدند ✅'
        : 'pub get خطا داد. اگر پکیجی «پیدا نشد»، آن پکیج در کتابخانه‌ی آفلاین نیست و یک بار به اینترنت نیاز داری.';
  });
}
