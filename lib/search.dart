import 'models.dart';

/// یکسان‌سازی متن فارسی برای جستجو: ی و ک عربی، اعراب، نیم‌فاصله، اعداد فارسی.
String normalizeFa(String s) {
  final b = StringBuffer();
  for (final r in s.toLowerCase().runes) {
    var c = String.fromCharCode(r);
    switch (c) {
      case 'ي':
      case 'ى':
      case 'ئ':
        c = 'ی';
      case 'ك':
        c = 'ک';
      case 'ة':
      case 'ۀ':
        c = 'ه';
      case 'أ':
      case 'إ':
      case 'آ':
      case 'ٱ':
        c = 'ا';
      case 'ؤ':
        c = 'و';
      case '\u200c':
      case '\u200d':
      case '-':
      case '_':
        c = ' ';
    }
    // اعراب و تنوین
    if (r >= 0x064B && r <= 0x065F) continue;
    if (r == 0x0640) continue; // کشیده
    // اعداد فارسی و عربی
    if (r >= 0x06F0 && r <= 0x06F9) c = String.fromCharCode(r - 0x06F0 + 0x30);
    if (r >= 0x0660 && r <= 0x0669) c = String.fromCharCode(r - 0x0660 + 0x30);
    b.write(c);
  }
  return b.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// کلمات هم‌معنی تا جستجو با واژه‌های مختلف هم نتیجه بدهد.
const Map<String, List<String>> _synonymsRaw = {
  'دیتابیس': ['پایگاه داده', 'database', 'sqlite', 'sql', 'جدول'],
  'پایگاه': ['دیتابیس', 'database'],
  'ماشین': ['خودرو', 'رانندگی', 'vehicle', 'car', 'ماشین'],
  'خودرو': ['رانندگی', 'vehicle', 'car'],
  'رانندگی': ['ماشین', 'vehicle'],
  'عکس': ['تصویر', 'image', 'گالری'],
  'تصویر': ['عکس', 'image'],
  'رمز': ['رمزنگاری', 'پسورد', 'امنیت', 'crypto'],
  'رمزنگاری': ['رمز', 'crypto', 'aes', 'encrypt'],
  'پسورد': ['رمز', 'password', 'argon2'],
  'امنیت': ['امن', 'security', 'رمزنگاری'],
  'اینترنت': ['شبکه', 'api', 'سرور', 'http', 'درخواست'],
  'سرور': ['api', 'اینترنت', 'http'],
  'شبکه': ['اینترنت', 'http', 'network'],
  'نقشه': ['map', 'مکان', 'مرحله', 'tiled'],
  'دشمن': ['npc', 'هوش مصنوعی', 'ai'],
  'هوش': ['ai', 'npc', 'مدل'],
  'صدا': ['موسیقی', 'audio', 'sound', 'آهنگ'],
  'موسیقی': ['صدا', 'آهنگ', 'music'],
  'آهنگ': ['صدا', 'موسیقی'],
  'ذخیره': ['دیتابیس', 'save', 'تنظیمات', 'storage'],
  'تاریخ': ['شمسی', 'تقویم', 'جلالی', 'date'],
  'شمسی': ['تاریخ', 'جلالی'],
  'نمودار': ['چارت', 'chart', 'گزارش'],
  'چارت': ['نمودار', 'chart'],
  'فیزیک': ['physics', 'برخورد', 'جاذبه', 'box2d'],
  'دوربین': ['camera', 'عکس'],
  'اعلان': ['نوتیفیکیشن', 'notification'],
  'نوتیفیکیشن': ['اعلان', 'notification'],
  'صفحه': ['ناوبری', 'route', 'page'],
  'ورود': ['لاگین', 'login', 'احراز', 'jwt'],
  'لاگین': ['ورود', 'login'],
  'بازی': ['game', 'بازی سازی'],
  'جوی': ['joystick', 'جوی استیک'],
  'زمین': ['terrain', 'محیط'],
  'درخت': ['گیاه', 'scatter'],
  'منو': ['menu', 'تنظیمات'],
  'فاکتور': ['pdf', 'چاپ', 'رسید'],
  'اکسل': ['excel', 'xlsx'],
  'تست': ['test', 'دیباگ'],
};

final Map<String, List<String>> _synonyms = {
  for (final e in _synonymsRaw.entries) normalizeFa(e.key): e.value,
};

class SearchHit<T> {
  SearchHit(this.item, this.score);
  final T item;
  final int score;
}

class _Doc {
  _Doc(String title, String kw, String body, String id)
      : title = normalizeFa(title),
        kw = normalizeFa(kw),
        body = normalizeFa(body),
        id = id.toLowerCase();
  final String title, kw, body, id;
  late final String compact = '$title $kw $body'.replaceAll(' ', '');
  late final Set<String> words = '$id $title $kw $body'.split(' ').toSet();
}

final _shortAscii = RegExp(r'^[a-z0-9.]{1,3}$');

int _scoreToken(_Doc d, String token) {
  var best = 0;
  final alts = <String>[token, ...?_synonyms[token]];
  for (var i = 0; i < alts.length; i++) {
    final a = normalizeFa(alts[i]);
    if (a.isEmpty) continue;
    final factor = i == 0 ? 2 : 1; // خود کلمه از هم‌معنی مهم‌تر است
    var s = 0;
    if (_shortAscii.hasMatch(a)) {
      // کلمه‌ی کوتاه انگلیسی (مثل ai یا dio) فقط به‌صورت کلمه‌ی کامل
      if (d.id == a) {
        s = 30;
      } else if (d.words.contains(a)) {
        s = 6;
      }
      s *= factor;
      if (s > best) best = s;
      continue;
    }
    if (d.id == a) {
      s = 30;
    } else if (d.id.contains(a)) {
      s = 12;
    }
    if (d.title.contains(a)) s = s > 10 ? s : 10;
    if (s < 6 && d.kw.contains(a)) s = 6;
    if (s < 3 && d.body.contains(a)) s = 3;
    if (s == 0 && d.compact.contains(a.replaceAll(' ', ''))) s = 2;
    s *= factor;
    if (s > best) best = s;
  }
  return best;
}

int scoreDoc(_Doc d, List<String> tokens) {
  var total = 0;
  for (final t in tokens) {
    final s = _scoreToken(d, t);
    if (s == 0) return 0; // همه‌ی کلمات باید پیدا شوند
    total += s;
  }
  return total;
}

/// کلمات و پسوندهای پرتکرار که در جستجو نادیده گرفته می‌شوند.
const Set<String> _stop = {
  'ی', 'ای', 'ها', 'های', 'هایی', 'را', 'و', 'با', 'در', 'به', 'از', 'برای', 'که', 'یک', 'این', 'اون', 'ان',
  'می', 'خوام', 'خواهم', 'میخوام', 'کنم', 'کن', 'بکنم', 'بسازم', 'چطور', 'چگونه', 'چی', 'چه', 'رو', 'تو', 'هم',
  'the', 'a', 'an', 'to', 'for', 'how', 'in', 'of',
};

List<String> tokenize(String q) {
  final all = normalizeFa(q).split(' ').where((t) => t.isNotEmpty).toList();
  final kept = all.where((t) => !_stop.contains(t)).toList();
  return kept.isEmpty ? all : kept;
}

class SearchIndex {
  SearchIndex(Catalog c)
      : _libs = [
          for (final l in c.libs)
            (l, _Doc(l.title, '${l.kw} ${ecoLabel(l.eco)} ${catLabel(l.cat)}', '${l.desc} ${l.usage}', l.id)),
        ],
        _topics = [
          for (final t in c.topics)
            (t, _Doc(t.title, '${t.kw} ${catLabel(t.cat)}', t.sections.map((s) => '${s.h} ${s.p}').join(' '), t.id)),
        ];

  final List<(Lib, _Doc)> _libs;
  final List<(Topic, _Doc)> _topics;

  List<Lib> libs(String q, bool Function(Lib) filter) {
    final tokens = tokenize(q);
    final hits = <SearchHit<Lib>>[];
    for (final (l, d) in _libs) {
      if (!filter(l)) continue;
      final s = tokens.isEmpty ? 1 : scoreDoc(d, tokens);
      if (s > 0) hits.add(SearchHit(l, s));
    }
    if (tokens.isNotEmpty) hits.sort((a, b) => b.score.compareTo(a.score));
    return [for (final h in hits) h.item];
  }

  List<Topic> topics(String q, bool Function(Topic) filter) {
    final tokens = tokenize(q);
    final hits = <SearchHit<Topic>>[];
    for (final (t, d) in _topics) {
      if (!filter(t)) continue;
      final s = tokens.isEmpty ? 1 : scoreDoc(d, tokens);
      if (s > 0) hits.add(SearchHit(t, s));
    }
    if (tokens.isNotEmpty) hits.sort((a, b) => b.score.compareTo(a.score));
    return [for (final h in hits) h.item];
  }
}
