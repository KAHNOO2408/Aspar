import 'dart:async';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../pickers.dart';
import 'lib_page.dart';
import 'widgets.dart';

/// سرور پکیج آفلاین برای Flutter/Dart.
class ServerPage extends StatefulWidget {
  const ServerPage({super.key});

  @override
  State<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  final List<String> _log = [];
  StreamSubscription<String>? _sub;
  Object? _subscribedTo;

  @override
  void initState() {
    super.initState();
    _listen();
    app.addListener(_listen);
  }

  void _listen() {
    if (identical(_subscribedTo, app.server) && _sub != null) return;
    _subscribedTo = app.server;
    _sub?.cancel();
    _sub = app.server?.log.listen((l) {
      if (!mounted) return;
      setState(() {
        _log.add(l);
        if (_log.length > 200) _log.removeAt(0);
      });
    });
  }

  @override
  void dispose() {
    app.removeListener(_listen);
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final s = app.server;
        final running = s?.running ?? false;
        final url = running ? s!.url : 'http://127.0.0.1:${app.settings.port}';
        final theme = Theme.of(context);
        return ListView(padding: const EdgeInsets.all(24), children: [
          Text('سرور پکیج آفلاین Flutter', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text(
              'این سرور کوچک روی کامپیوتر خودت اجرا می‌شود و برای دستور flutter pub get نقش pub.dev را بازی می‌کند. '
              'تا وقتی این برنامه باز است، پروژه‌هایت می‌توانند بدون اینترنت پکیج‌های کتابخانه را نصب کنند.',
              style: TextStyle(height: 1.8)),
          const SizedBox(height: 16),
          InfoCard(title: 'وضعیت', icon: Icons.dns, children: [
            Row(children: [
              Icon(running ? Icons.check_circle : Icons.cancel, color: running ? Colors.green : Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(running
                    ? 'در حال اجرا روی $url (${s!.packageCount} پکیج)'
                    : (s == null ? 'پوشه‌ی پکیج‌ها پیدا نشد' : 'متوقف')),
              ),
              if (s != null)
                running
                    ? OutlinedButton.icon(onPressed: app.stopServer, icon: const Icon(Icons.stop), label: const Text('توقف'))
                    : FilledButton.icon(onPressed: app.startServer, icon: const Icon(Icons.play_arrow), label: const Text('اجرا')),
            ]),
            if (app.serverError != null) ...[
              const SizedBox(height: 8),
              Text(app.serverError!, style: TextStyle(color: theme.colorScheme.error)),
            ],
          ]),
          InfoCard(title: 'نصب پکیج‌های یک پروژه (یک کلیک)', icon: Icons.download_for_offline, children: [
            const Text('پوشه‌ی پروژه‌ی Flutter را انتخاب کن تا flutter pub get با همین سرور اجرا شود.'),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () async {
                final dir = await pickFolder(title: 'پوشه‌ی پروژه‌ی Flutter', initial: app.settings.lastFlutterProject);
                if (dir == null || !context.mounted) return;
                app.settings.lastFlutterProject = dir;
                await app.saveSettings();
                if (context.mounted) await runOfflinePubGet(context, dir);
              },
              icon: const Icon(Icons.folder_open),
              label: const Text('انتخاب پروژه و اجرای pub get'),
            ),
          ]),
          InfoCard(title: 'استفاده از خط فرمان', icon: Icons.terminal, children: [
            const Text('در CMD (فقط برای همان پنجره):'),
            CodeBox('set PUB_HOSTED_URL=$url\nflutter pub get', label: 'cmd'),
            const Text('در PowerShell:'),
            CodeBox('\$env:PUB_HOSTED_URL="$url"\nflutter pub get', label: 'PowerShell'),
            const Text('برای همیشه (همه‌ی پنجره‌ها). برای برگشتن به pub.dev، متغیر را از Environment Variables ویندوز پاک کن:'),
            CodeBox('setx PUB_HOSTED_URL $url', label: 'cmd'),
            const SizedBox(height: 6),
            const Text(
              'نکته: فایل pubspec.lock آدرس سرور را نگه می‌دارد. اگر بعداً خواستی پروژه را با pub.dev بسازی، pubspec.lock را پاک کن و دوباره pub get بزن. '
              'ابزارهای تولید کد (build_runner، freezed، json_serializable) در کتابخانه‌ی آفلاین نیستند.',
              style: TextStyle(height: 1.8),
            ),
          ]),
          InfoCard(title: 'گزارش سرور', icon: Icons.receipt_long, children: [
            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(8)),
              child: ListView(reverse: true, children: [
                for (final l in _log.reversed)
                  Text(l, style: const TextStyle(color: Color(0xFFD4D4D4), fontSize: 12)),
              ]),
            ),
          ]),
        ]);
      },
    );
  }
}
