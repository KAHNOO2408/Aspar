import 'dart:convert';
import 'dart:io';

/// پنجره‌های انتخاب پوشه و فایل ویندوز بدون پکیج اضافه (با PowerShell).
Future<String?> _runPs(String script) async {
  if (!Platform.isWindows) return null;
  final full = '[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; '
      'Add-Type -AssemblyName System.Windows.Forms; $script';
  try {
    final r = await Process.run(
      'powershell',
      ['-NoProfile', '-STA', '-ExecutionPolicy', 'Bypass', '-Command', full],
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    final out = (r.stdout as String).trim();
    return out.isEmpty ? null : out.split('\n').last.trim();
  } catch (_) {
    return null;
  }
}

String _psQuote(String s) => "'${s.replaceAll("'", "''")}'";

Future<String?> pickFolder({String title = 'انتخاب پوشه', String initial = ''}) {
  final init = initial.isNotEmpty && Directory(initial).existsSync()
      ? '\$f.SelectedPath = ${_psQuote(initial)}; '
      : '';
  return _runPs('\$f = New-Object System.Windows.Forms.FolderBrowserDialog; '
      '\$f.Description = ${_psQuote(title)}; \$f.ShowNewFolderButton = \$true; $init'
      'if (\$f.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { \$f.SelectedPath }');
}

Future<String?> pickFile({String title = 'انتخاب فایل', String filter = 'Zip (*.zip)|*.zip'}) {
  return _runPs('\$f = New-Object System.Windows.Forms.OpenFileDialog; '
      '\$f.Title = ${_psQuote(title)}; \$f.Filter = ${_psQuote(filter)}; '
      'if (\$f.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { \$f.FileName }');
}

/// باز کردن پوشه در Explorer.
Future<void> openInExplorer(String path) async {
  if (Platform.isWindows) {
    await Process.run('explorer', [path]);
  } else if (Platform.isLinux) {
    await Process.run('xdg-open', [path]);
  } else if (Platform.isMacOS) {
    await Process.run('open', [path]);
  }
}
