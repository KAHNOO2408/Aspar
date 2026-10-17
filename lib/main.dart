import 'package:flutter/material.dart';

import 'app_state.dart';
import 'models.dart';
import 'settings.dart';
import 'ui/home_page.dart';
import 'ui/server_page.dart';
import 'ui/tools_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await Settings.load();
  final catalog = await Catalog.load(settings.libraryPath);
  app = AppState(settings, catalog);
  if (settings.autoStartServer && app.hasPub) {
    await app.startServer();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _theme(Brightness b) {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF00897B), brightness: b);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Vazirmatn',
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'کتابخانه‌ی آسپار',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const Shell(),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [
        NavigationRail(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          labelType: NavigationRailLabelType.all,
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Text('آ', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          ),
          destinations: const [
            NavigationRailDestination(icon: Icon(Icons.search), label: Text('کتابخانه')),
            NavigationRailDestination(icon: Icon(Icons.dns_outlined), selectedIcon: Icon(Icons.dns), label: Text('سرور Flutter')),
            NavigationRailDestination(icon: Icon(Icons.android_outlined), selectedIcon: Icon(Icons.android), label: Text('کش Kotlin')),
            NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('تنظیمات')),
          ],
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: ListenableBuilder(
            listenable: app,
            builder: (context, _) => Column(children: [
              if (!app.hasLibrary)
                MaterialBanner(
                  content: const Text('پوشه‌ی library پیدا نشد. راهنماها کار می‌کنند، ولی برای نصب آفلاین مسیرش را در تنظیمات مشخص کن.'),
                  actions: [TextButton(onPressed: () => setState(() => _index = 3), child: const Text('تنظیمات'))],
                ),
              Expanded(
                child: IndexedStack(index: _index, children: const [
                  HomePage(),
                  ServerPage(),
                  KotlinPage(),
                  SettingsPage(),
                ]),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
