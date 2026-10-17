import 'dart:convert';
import 'dart:io';

/// تنظیمات برنامه در %APPDATA%\AsparLibrary\settings.json ذخیره می‌شود.
class Settings {
  String? libraryPath;
  int port = 8765;
  bool autoStartServer = true;
  String flutterCmd = 'flutter';
  String lastFlutterProject = '';
  String lastGodotProject = '';
  String lastTemplateFolder = '';

  static String get _dir {
    final base = Platform.environment['APPDATA'] ??
        Platform.environment['HOME'] ??
        Directory.systemTemp.path;
    return '$base${Platform.pathSeparator}AsparLibrary';
  }

  static File get _file => File('$_dir${Platform.pathSeparator}settings.json');

  static Future<Settings> load() async {
    final s = Settings();
    try {
      if (await _file.exists()) {
        final j = jsonDecode(await _file.readAsString()) as Map<String, dynamic>;
        s.libraryPath = j['libraryPath'] as String?;
        s.port = (j['port'] ?? 8765) as int;
        s.autoStartServer = (j['autoStartServer'] ?? true) as bool;
        s.flutterCmd = (j['flutterCmd'] ?? 'flutter') as String;
        s.lastFlutterProject = (j['lastFlutterProject'] ?? '') as String;
        s.lastGodotProject = (j['lastGodotProject'] ?? '') as String;
        s.lastTemplateFolder = (j['lastTemplateFolder'] ?? '') as String;
      }
    } catch (_) {}
    if (s.libraryPath == null || !isLibrary(s.libraryPath!)) {
      s.libraryPath = findLibrary();
    }
    return s;
  }

  Future<void> save() async {
    try {
      await Directory(_dir).create(recursive: true);
      await _file.writeAsString(const JsonEncoder.withIndent('  ').convert({
        'libraryPath': libraryPath,
        'port': port,
        'autoStartServer': autoStartServer,
        'flutterCmd': flutterCmd,
        'lastFlutterProject': lastFlutterProject,
        'lastGodotProject': lastGodotProject,
        'lastTemplateFolder': lastTemplateFolder,
      }));
    } catch (_) {}
  }

  static bool isLibrary(String path) {
    final sep = Platform.pathSeparator;
    return File('$path${sep}pub${sep}index.json').existsSync() ||
        File('$path${sep}godot${sep}manifest.json').existsSync();
  }

  /// پوشه‌ی library را از کنار فایل exe به بالا جستجو می‌کند.
  static String? findLibrary() {
    var dir = File(Platform.resolvedExecutable).parent;
    for (var i = 0; i < 10; i++) {
      final cand = '${dir.path}${Platform.pathSeparator}library';
      if (isLibrary(cand)) return cand;
      if (isLibrary(dir.path)) return dir.path;
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }
    final cwd = '${Directory.current.path}${Platform.pathSeparator}library';
    if (isLibrary(cwd)) return cwd;
    return null;
  }
}
