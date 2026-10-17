import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

/// اکوسیستم هر کتابخانه.
enum Eco { flutter, godot, kotlin }

Eco ecoFrom(String s) => switch (s) {
      'godot' => Eco.godot,
      'kotlin' => Eco.kotlin,
      _ => Eco.flutter,
    };

String ecoLabel(Eco e) => switch (e) {
      Eco.flutter => 'Flutter',
      Eco.godot => 'Godot',
      Eco.kotlin => 'Kotlin',
    };

String catLabel(String c) => switch (c) {
      'game' => 'بازی‌سازی',
      'security' => 'امنیت',
      _ => 'برنامه‌نویسی',
    };

class Lib {
  Lib({
    required this.id,
    required this.eco,
    required this.cat,
    required this.topics,
    required this.title,
    required this.desc,
    required this.usage,
    required this.kw,
    required this.example,
    required this.version,
    required this.install,
    required this.offline,
    required this.repo,
    this.dev = false,
    this.kind = '',
    this.file = '',
    this.folders = const [],
    this.size = 0,
    this.note = '',
    this.userAdded = false,
  });

  final String id;
  final Eco eco;
  final String cat;
  final List<String> topics;
  final String title;
  final String desc;
  final String usage;
  final String kw;
  final String example;
  final String version;
  final String install;
  final bool offline;
  final String repo;
  final bool dev;
  final String kind; // godot: addon | template
  final String file; // godot zip, relative to library folder
  final List<String> folders;
  final int size;
  final String note;
  final bool userAdded;

  bool get isTemplate => kind == 'template';

  factory Lib.fromJson(Map<String, dynamic> j) => Lib(
        id: j['id'] as String,
        eco: ecoFrom(j['eco'] as String),
        cat: j['cat'] as String,
        topics: (j['topics'] as List).cast<String>(),
        title: j['title'] as String,
        desc: j['desc'] as String,
        usage: (j['when'] ?? '') as String,
        kw: (j['kw'] ?? '') as String,
        example: (j['example'] ?? '') as String,
        version: (j['version'] ?? '') as String,
        install: (j['install'] ?? '') as String,
        offline: (j['offline'] ?? false) as bool,
        repo: (j['repo'] ?? '') as String,
        dev: (j['dev'] ?? false) as bool,
        kind: (j['kind'] ?? '') as String,
        file: (j['file'] ?? '') as String,
        folders: ((j['folders'] ?? const []) as List).cast<String>(),
        size: (j['size'] ?? 0) as int,
        note: (j['note'] ?? '') as String,
        userAdded: (j['user'] ?? false) as bool,
      );
}

class Section {
  Section(this.h, this.p, this.code);
  final String h;
  final String p;
  final String code;
}

class Topic {
  Topic({
    required this.id,
    required this.cat,
    required this.icon,
    required this.title,
    required this.kw,
    required this.sections,
    required this.libs,
  });

  final String id;
  final String cat;
  final String icon;
  final String title;
  final String kw;
  final List<Section> sections;
  final List<String> libs;

  factory Topic.fromJson(Map<String, dynamic> j) => Topic(
        id: j['id'] as String,
        cat: j['cat'] as String,
        icon: j['icon'] as String,
        title: j['title'] as String,
        kw: (j['kw'] ?? '') as String,
        sections: [
          for (final s in (j['sections'] as List).cast<Map<String, dynamic>>())
            Section(s['h'] as String, s['p'] as String, (s['code'] ?? '') as String),
        ],
        libs: (j['libs'] as List).cast<String>(),
      );
}

class Catalog {
  Catalog(this.libs, this.topics, this.stats);

  final List<Lib> libs;
  final List<Topic> topics;
  final Map<String, dynamic> stats;

  late final Map<String, Lib> byId = {for (final l in libs) l.id: l};
  late final Map<String, Topic> topicById = {for (final t in topics) t.id: t};

  static Future<Catalog> load(String? libraryPath) async {
    final raw = await rootBundle.loadString('assets/catalog.json');
    final j = jsonDecode(raw) as Map<String, dynamic>;
    final libs = [
      for (final l in (j['libs'] as List).cast<Map<String, dynamic>>()) Lib.fromJson(l),
    ];
    final topics = [
      for (final t in (j['topics'] as List).cast<Map<String, dynamic>>()) Topic.fromJson(t),
    ];
    if (libraryPath != null) {
      libs.addAll(await loadUserGodot(libraryPath));
    }
    return Catalog(libs, topics, (j['stats'] ?? <String, dynamic>{}) as Map<String, dynamic>);
  }

  /// افزونه‌هایی که کاربر خودش (مثلاً از GitHub Releases) اضافه کرده.
  static Future<List<Lib>> loadUserGodot(String libraryPath) async {
    final f = File('$libraryPath${Platform.pathSeparator}user_godot${Platform.pathSeparator}manifest.json');
    if (!await f.exists()) return [];
    try {
      final list = jsonDecode(await f.readAsString()) as List;
      return [for (final e in list.cast<Map<String, dynamic>>()) Lib.fromJson(e)];
    } catch (_) {
      return [];
    }
  }
}
