import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models.dart';

const codeFont = 'Consolas';
const codeFallback = ['Cascadia Mono', 'Courier New', 'monospace'];

const Map<String, IconData> topicIcons = {
  'sports_esports': Icons.sports_esports,
  'science': Icons.science,
  'music_note': Icons.music_note,
  'map': Icons.map,
  'directions_car': Icons.directions_car,
  'videocam': Icons.videocam,
  'smart_toy': Icons.smart_toy,
  'forum': Icons.forum,
  'landscape': Icons.landscape,
  'gamepad': Icons.gamepad,
  'dashboard': Icons.dashboard,
  'save': Icons.save,
  'bug_report': Icons.bug_report,
  'rocket_launch': Icons.rocket_launch,
  'account_tree': Icons.account_tree,
  'cloud': Icons.cloud,
  'tune': Icons.tune,
  'storage': Icons.storage,
  'alt_route': Icons.alt_route,
  'widgets': Icons.widgets,
  'bar_chart': Icons.bar_chart,
  'image': Icons.image,
  'photo_camera': Icons.photo_camera,
  'description': Icons.description,
  'smartphone': Icons.smartphone,
  'place': Icons.place,
  'notifications': Icons.notifications,
  'calendar_month': Icons.calendar_month,
  'verified': Icons.verified,
  'android': Icons.android,
  'lan': Icons.lan,
  'memory': Icons.memory,
  'videogame_asset': Icons.videogame_asset,
  'hub': Icons.hub,
  'lock': Icons.lock,
  'enhanced_encryption': Icons.enhanced_encryption,
  'fingerprint': Icons.fingerprint,
  'vpn_lock': Icons.vpn_lock,
  'shield': Icons.shield,
};

IconData topicIcon(String name) => topicIcons[name] ?? Icons.menu_book;

Color ecoColor(Eco e) => switch (e) {
      Eco.flutter => const Color(0xFF0277BD),
      Eco.godot => const Color(0xFF478CBF),
      Eco.kotlin => const Color(0xFF7F52FF),
    };

Color catColor(String c) => switch (c) {
      'game' => const Color(0xFFE65100),
      'security' => const Color(0xFFC62828),
      _ => const Color(0xFF2E7D32),
    };

class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, required this.color, this.icon});
  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 13, color: color), const SizedBox(width: 4)],
        Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

void toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 3)));
}

Future<void> copyText(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) toast(context, 'کپی شد');
}

/// جعبه‌ی کد چپ‌به‌راست با دکمه‌ی کپی.
class CodeBox extends StatelessWidget {
  const CodeBox(this.code, {super.key, this.label});
  final String code;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Row(children: [
            Text(label ?? 'کد', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
            const Spacer(),
            TextButton.icon(
              onPressed: () => copyText(context, code),
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('کپی'),
            ),
          ]),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              code,
              style: const TextStyle(fontFamily: codeFont, fontFamilyFallback: codeFallback, fontSize: 13, height: 1.45),
            ),
          ),
        ),
      ]),
    );
  }
}

/// پنجره‌ای که خروجی یک کار طولانی را خط‌به‌خط نشان می‌دهد.
Future<void> showRunDialog(
  BuildContext context,
  String title,
  Future<String?> Function(void Function(String line) log) task,
) {
  final lines = ValueNotifier<List<String>>([]);
  final done = ValueNotifier<String?>(null);
  final running = ValueNotifier<bool>(true);
  final scroll = ScrollController();
  void log(String l) {
    lines.value = [...lines.value, l];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) scroll.jumpTo(scroll.position.maxScrollExtent);
    });
  }

  unawaited(() async {
    try {
      done.value = await task(log);
    } catch (e) {
      done.value = 'خطا: $e';
    }
    running.value = false;
  }());

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 720,
        height: 420,
        child: Column(children: [
          ValueListenableBuilder<String?>(
            valueListenable: done,
            builder: (_, msg, __) => msg == null
                ? const LinearProgressIndicator()
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(msg),
                  ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ValueListenableBuilder<List<String>>(
                valueListenable: lines,
                builder: (_, ls, __) => Directionality(
                  textDirection: TextDirection.ltr,
                  child: ListView.builder(
                    controller: scroll,
                    padding: const EdgeInsets.all(8),
                    itemCount: ls.length,
                    itemBuilder: (_, i) => SelectableText(
                      ls[i],
                      style: const TextStyle(
                          color: Color(0xFFD4D4D4),
                          fontFamily: codeFont,
                          fontFamilyFallback: codeFallback,
                          fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
      actions: [
        ValueListenableBuilder<bool>(
          valueListenable: running,
          builder: (_, r, __) => TextButton(
            onPressed: r ? null : () => Navigator.of(ctx).pop(),
            child: Text(r ? 'در حال اجرا…' : 'بستن'),
          ),
        ),
      ],
    ),
  );
}

/// کارت ساده با عنوان.
class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.title, required this.children, this.icon});
  final String title;
  final IconData? icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 10),
          ...children,
        ]),
      ),
    );
  }
}
