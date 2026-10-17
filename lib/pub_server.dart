import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// سرور محلی سازگار با pub (Hosted Pub Repository Specification v2).
/// با تنظیم PUB_HOSTED_URL=http://127.0.0.1:<port> دستور flutter pub get
/// پکیج‌ها را بدون اینترنت از پوشه‌ی library/pub می‌گیرد.
class PubServer {
  PubServer(this.pubDir);

  final String pubDir;
  HttpServer? _server;
  Map<String, dynamic> _index = {};
  final _log = StreamController<String>.broadcast();

  Stream<String> get log => _log.stream;
  bool get running => _server != null;
  int? get port => _server?.port;
  String get url => 'http://127.0.0.1:${_server?.port ?? 0}';
  int get packageCount => _index.length;

  Future<void> start(int port) async {
    if (_server != null) return;
    final f = File('$pubDir${Platform.pathSeparator}index.json');
    _index = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
    final s = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    _server = s;
    s.listen(_handle, onError: (Object e) => _log.add('خطا: $e'));
    _log.add('سرور روی $url اجرا شد (${_index.length} پکیج)');
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _log.add('سرور متوقف شد');
  }

  static int _cmpVersion(String a, String b) {
    List<int> nums(String v) => v
        .split('+')
        .first
        .split('-')
        .first
        .split('.')
        .map((p) => int.tryParse(p) ?? 0)
        .toList();
    final x = nums(a), y = nums(b);
    for (var i = 0; i < 3; i++) {
      final c = (i < x.length ? x[i] : 0).compareTo(i < y.length ? y[i] : 0);
      if (c != 0) return c;
    }
    final pa = a.split('+').first.contains('-');
    final pb = b.split('+').first.contains('-');
    if (pa != pb) return pa ? -1 : 1; // نسخه‌ی پیش‌انتشار کوچک‌تر است
    return a.compareTo(b);
  }

  Map<String, dynamic> _versionJson(String name, Map<String, dynamic> v) {
    final ver = v['version'] as String;
    return {
      'version': ver,
      'pubspec': v['pubspec'],
      'archive_url': '$url/packages/${Uri.encodeComponent(name)}/versions/${Uri.encodeComponent(ver)}.tar.gz',
      'archive_sha256': v['sha256'],
      'published': '2026-01-01T00:00:00.000Z',
    };
  }

  Future<void> _handle(HttpRequest req) async {
    final res = req.response;
    try {
      final seg = req.uri.pathSegments.map(Uri.decodeComponent).toList();
      // GET /api/packages/<name>
      if (seg.length == 3 && seg[0] == 'api' && seg[1] == 'packages') {
        final name = seg[2];
        final p = _index[name] as Map<String, dynamic>?;
        if (p == null) {
          _log.add('پیدا نشد: $name');
          return _json(res, 404, {
            'error': {'code': 'NotFound', 'message': 'Package "$name" is not in the offline library.'}
          });
        }
        final versions = (p['versions'] as List).cast<Map<String, dynamic>>();
        final sorted = [...versions]..sort((a, b) => _cmpVersion(a['version'] as String, b['version'] as String));
        final stable = sorted.where((v) => !(v['version'] as String).split('+').first.contains('-')).toList();
        final latest = stable.isNotEmpty ? stable.last : sorted.last;
        _log.add('درخواست: $name');
        return _json(res, 200, {
          'name': name,
          'latest': _versionJson(name, latest),
          'versions': [for (final v in sorted) _versionJson(name, v)],
        });
      }
      // GET /api/packages/<name>/advisories
      if (seg.length == 4 && seg[0] == 'api' && seg[1] == 'packages' && seg[3] == 'advisories') {
        return _json(res, 200, {'advisories': [], 'advisoriesUpdated': '2026-01-01T00:00:00.000Z'});
      }
      // GET /packages/<name>/versions/<version>.tar.gz
      if (seg.length == 4 && seg[0] == 'packages' && seg[2] == 'versions' && seg[3].endsWith('.tar.gz')) {
        final name = seg[1];
        final ver = seg[3].substring(0, seg[3].length - '.tar.gz'.length);
        final p = _index[name] as Map<String, dynamic>?;
        final v = p == null
            ? null
            : (p['versions'] as List).cast<Map<String, dynamic>>().where((e) => e['version'] == ver).firstOrNull;
        if (v == null) return _json(res, 404, {'error': {'code': 'NotFound', 'message': 'not found'}});
        final file = File('$pubDir${Platform.pathSeparator}${(v['file'] as String).replaceAll('/', Platform.pathSeparator)}');
        res.headers.contentType = ContentType('application', 'octet-stream');
        res.contentLength = await file.length();
        await res.addStream(file.openRead());
        await res.close();
        _log.add('دانلود: $name $ver');
        return;
      }
      return _json(res, 404, {'error': {'code': 'NotFound', 'message': 'unknown path'}});
    } catch (e) {
      _log.add('خطا: $e');
      try {
        await _json(res, 500, {'error': {'code': 'Internal', 'message': '$e'}});
      } catch (_) {}
    }
  }

  Future<void> _json(HttpResponse res, int code, Object body) async {
    res.statusCode = code;
    res.headers.contentType = ContentType('application', 'vnd.pub.v2+json', charset: 'utf-8');
    res.write(jsonEncode(body));
    await res.close();
  }
}
