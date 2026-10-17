import 'dart:convert';
import 'dart:io';

import 'models.dart';

final String sep = Platform.pathSeparator;

String joinPath(List<String> parts) => parts.where((p) => p.isNotEmpty).join(sep);

/// اجرای یک دستور و فرستادن خط‌به‌خط خروجی.
Future<int> runStreaming(
  String exe,
  List<String> args, {
  required void Function(String line) onLine,
  String? workingDirectory,
  Map<String, String>? environment,
}) async {
  onLine('> $exe ${args.join(' ')}');
  Process? started;
  try {
    started = await Process.start(exe, args,
        workingDirectory: workingDirectory, environment: environment, runInShell: true);
  } catch (e) {
    onLine('اجرا نشد: $e');
  }
  if (started == null) return -1;
  final p = started;
  final done1 = p.stdout.transform(systemEncoding.decoder).transform(const LineSplitter()).forEach(onLine);
  final done2 = p.stderr.transform(systemEncoding.decoder).transform(const LineSplitter()).forEach(onLine);
  final code = await p.exitCode;
  await done1;
  await done2;
  onLine('— پایان (کد خروج $code)');
  return code;
}

// ---------------------------------------------------------------- Flutter

class PubspecResult {
  PubspecResult(this.ok, this.message);
  final bool ok;
  final String message;
}

/// اضافه کردن کتابخانه به pubspec.yaml پروژه.
Future<PubspecResult> addToPubspec(String projectDir, Lib lib) async {
  final f = File(joinPath([projectDir, 'pubspec.yaml']));
  if (!await f.exists()) {
    return PubspecResult(false, 'فایل pubspec.yaml در این پوشه نیست. پوشه‌ی اصلی پروژه‌ی Flutter را انتخاب کن.');
  }
  final text = await f.readAsString();
  final nl = text.contains('\r\n') ? '\r\n' : '\n';
  final lines = text.split(RegExp(r'\r?\n'));
  final already = RegExp('^\\s{2}${RegExp.escape(lib.id)}\\s*:');
  if (lines.any(already.hasMatch)) {
    return PubspecResult(true, '${lib.id} از قبل در pubspec.yaml هست.');
  }
  final section = lib.dev ? 'dev_dependencies:' : 'dependencies:';
  final entry = '  ${lib.install}';
  final idx = lines.indexWhere((l) => l.trimRight() == section);
  if (idx >= 0) {
    lines.insert(idx + 1, entry);
  } else {
    if (lines.isNotEmpty && lines.last.trim().isEmpty) lines.removeLast();
    lines
      ..add('')
      ..add(section)
      ..add(entry)
      ..add('');
  }
  await f.writeAsString(lines.join(nl));
  return PubspecResult(true, '«${lib.install}» به $section اضافه شد.');
}

// ---------------------------------------------------------------- zip & copy

Future<bool> extractZip(String zip, String dest, void Function(String) onLine) async {
  await Directory(dest).create(recursive: true);
  if (Platform.isWindows) {
    // tar.exe ویندوز ۱۰ و ۱۱ فایل zip را هم باز می‌کند.
    final code = await runStreaming('tar', ['-xf', zip, '-C', dest], onLine: onLine);
    if (code == 0) return true;
    final ps = await runStreaming('powershell', [
      '-NoProfile',
      '-Command',
      "Expand-Archive -Force -LiteralPath '${zip.replaceAll("'", "''")}' -DestinationPath '${dest.replaceAll("'", "''")}'"
    ], onLine: onLine);
    return ps == 0;
  }
  final code = await runStreaming('unzip', ['-o', '-q', zip, '-d', dest], onLine: onLine);
  return code == 0;
}

Future<void> copyDir(Directory src, Directory dst) async {
  await dst.create(recursive: true);
  await for (final e in src.list(followLinks: false)) {
    final name = _baseName(e.path);
    final target = joinPath([dst.path, name]);
    if (e is Directory) {
      await copyDir(e, Directory(target));
    } else if (e is File) {
      await e.copy(target);
    }
  }
}

/// پوشه‌ی addons را داخل محتوای استخراج‌شده پیدا می‌کند (ریشه یا یک سطح پایین‌تر).
Future<Directory?> findAddonsDir(Directory root) async {
  final direct = Directory(joinPath([root.path, 'addons']));
  if (await direct.exists()) return direct;
  await for (final e in root.list()) {
    if (e is Directory) {
      final d = Directory(joinPath([e.path, 'addons']));
      if (await d.exists()) return d;
    }
  }
  return null;
}

String _baseName(String path) => path.split(RegExp(r'[\\/]')).where((s) => s.isNotEmpty).last;

// ---------------------------------------------------------------- Godot

class InstallResult {
  InstallResult(this.ok, this.message);
  final bool ok;
  final String message;
}

/// نصب افزونه در پوشه‌ی addons پروژه‌ی Godot و فعال کردن پلاگین‌ها.
Future<InstallResult> installGodotAddon(
    String libraryPath, Lib lib, String projectDir, void Function(String) onLine) async {
  final projectFile = File(joinPath([projectDir, 'project.godot']));
  if (!await projectFile.exists()) {
    return InstallResult(false, 'فایل project.godot در این پوشه نیست. پوشه‌ی اصلی پروژه‌ی Godot را انتخاب کن.');
  }
  final zip = joinPath([libraryPath, lib.file.replaceAll('/', sep)]);
  if (!await File(zip).exists()) return InstallResult(false, 'فایل افزونه پیدا نشد: $zip');

  final tmp = await Directory.systemTemp.createTemp('aspar_addon_');
  try {
    if (!await extractZip(zip, tmp.path, onLine)) {
      return InstallResult(false, 'باز کردن zip انجام نشد.');
    }
    final addons = await findAddonsDir(tmp);
    if (addons == null) return InstallResult(false, 'داخل این zip پوشه‌ی addons پیدا نشد.');
    final installed = <String>[];
    final cfgs = <String>[];
    await for (final e in addons.list()) {
      if (e is! Directory) continue;
      final name = _baseName(e.path);
      final target = Directory(joinPath([projectDir, 'addons', name]));
      onLine('کپی: addons/$name');
      await copyDir(e, target);
      installed.add(name);
      if (await File(joinPath([e.path, 'plugin.cfg'])).exists()) {
        cfgs.add('res://addons/$name/plugin.cfg');
      }
    }
    // فایل‌های gdextension کنار addons (مثلاً bin/) هم کپی شوند
    final parent = addons.parent;
    await for (final e in parent.list()) {
      if (e is Directory && _baseName(e.path) == 'bin') {
        onLine('کپی: bin/');
        await copyDir(e, Directory(joinPath([projectDir, 'bin'])));
      }
    }
    if (cfgs.isNotEmpty) {
      await enableGodotPlugins(projectFile, cfgs);
      onLine('فعال شد: ${cfgs.join('، ')}');
    }
    return InstallResult(true,
        'نصب شد: ${installed.join('، ')}${cfgs.isNotEmpty ? '\nپلاگین‌ها در project.godot فعال شدند. اگر Godot باز است، پروژه را دوباره باز کن (Project → Reload Current Project).' : ''}');
  } finally {
    try {
      await tmp.delete(recursive: true);
    } catch (_) {}
  }
}

/// اضافه کردن مسیر plugin.cfg به [editor_plugins] در project.godot.
Future<void> enableGodotPlugins(File projectFile, List<String> cfgs) async {
  final text = await projectFile.readAsString();
  final nl = text.contains('\r\n') ? '\r\n' : '\n';
  final lines = text.split(RegExp(r'\r?\n'));
  var sec = lines.indexWhere((l) => l.trim() == '[editor_plugins]');
  if (sec < 0) {
    while (lines.isNotEmpty && lines.last.trim().isEmpty) {
      lines.removeLast();
    }
    lines
      ..add('')
      ..add('[editor_plugins]')
      ..add('')
      ..add('enabled=PackedStringArray(${cfgs.map((c) => '"$c"').join(', ')})')
      ..add('');
    await projectFile.writeAsString(lines.join(nl));
    return;
  }
  var end = lines.length;
  for (var i = sec + 1; i < lines.length; i++) {
    if (lines[i].trim().startsWith('[')) {
      end = i;
      break;
    }
  }
  final idx = lines.sublist(sec + 1, end).indexWhere((l) => l.trim().startsWith('enabled='));
  if (idx < 0) {
    lines.insert(sec + 1, 'enabled=PackedStringArray(${cfgs.map((c) => '"$c"').join(', ')})');
  } else {
    final li = sec + 1 + idx;
    final existing = RegExp(r'"([^"]*)"').allMatches(lines[li]).map((m) => m.group(1)!).toList();
    for (final c in cfgs) {
      if (!existing.contains(c)) existing.add(c);
    }
    lines[li] = 'enabled=PackedStringArray(${existing.map((c) => '"$c"').join(', ')})';
  }
  await projectFile.writeAsString(lines.join(nl));
}

/// استخراج پروژه‌ی آماده در پوشه‌ی مقصد.
Future<InstallResult> extractTemplate(
    String libraryPath, Lib lib, String destParent, void Function(String) onLine) async {
  final zip = joinPath([libraryPath, lib.file.replaceAll('/', sep)]);
  final dest = joinPath([destParent, lib.id.replaceFirst('tpl_', '')]);
  if (await Directory(dest).exists()) {
    return InstallResult(false, 'پوشه‌ی $dest از قبل وجود دارد. پوشه‌ی دیگری انتخاب کن یا آن را پاک کن.');
  }
  if (!await extractZip(zip, dest, onLine)) return InstallResult(false, 'باز کردن zip انجام نشد.');
  return InstallResult(true, 'پروژه در این مسیر استخراج شد:\n$dest\nدر Godot روی Import بزن و فایل project.godot همین پوشه را انتخاب کن.');
}

/// افزودن zip افزونه‌ای که کاربر دانلود کرده (مثلاً Terrain3D) به کتابخانه.
Future<InstallResult> addUserGodotZip(String libraryPath, String zipPath, void Function(String) onLine) async {
  final userDir = Directory(joinPath([libraryPath, 'user_godot']));
  await userDir.create(recursive: true);
  final tmp = await Directory.systemTemp.createTemp('aspar_inspect_');
  try {
    if (!await extractZip(zipPath, tmp.path, onLine)) return InstallResult(false, 'باز کردن zip انجام نشد.');
    final addons = await findAddonsDir(tmp);
    if (addons == null) {
      return InstallResult(false, 'این zip پوشه‌ی addons ندارد، پس افزونه‌ی Godot نیست. (اگر سورس‌کد است، نسخه‌ی Release را دانلود کن.)');
    }
    final folders = <String>[];
    await for (final e in addons.list()) {
      if (e is Directory) folders.add(_baseName(e.path));
    }
    final fileName = _baseName(zipPath);
    final id = 'user_${fileName.replaceAll(RegExp(r'\.zip$', caseSensitive: false), '').replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_')}';
    await File(zipPath).copy(joinPath([userDir.path, '$id.zip']));
    final manifest = File(joinPath([userDir.path, 'manifest.json']));
    final list = await manifest.exists()
        ? (jsonDecode(await manifest.readAsString()) as List).cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];
    list.removeWhere((m) => m['id'] == id);
    list.add({
      'id': id,
      'eco': 'godot',
      'cat': 'game',
      'topics': <String>[],
      'title': '${folders.join(' + ')} (اضافه‌شده توسط شما)',
      'desc': 'افزونه‌ای که خودت از فایل $fileName اضافه کردی.',
      'when': '',
      'kw': '${folders.join(' ')} $fileName افزونه کاربر',
      'example': '',
      'version': DateTime.now().toIso8601String().substring(0, 10),
      'install': folders.map((f) => 'res://addons/$f').join(', '),
      'offline': true,
      'repo': '',
      'kind': 'addon',
      'file': 'user_godot/$id.zip',
      'folders': folders,
      'size': await File(zipPath).length(),
      'user': true,
    });
    await manifest.writeAsString(const JsonEncoder.withIndent(' ').convert(list));
    return InstallResult(true, 'اضافه شد: ${folders.join('، ')}');
  } finally {
    try {
      await tmp.delete(recursive: true);
    } catch (_) {}
  }
}
