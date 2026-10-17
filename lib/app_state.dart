import 'dart:io';

import 'package:flutter/foundation.dart';

import 'models.dart';
import 'pub_server.dart';
import 'search.dart';
import 'settings.dart';

class AppState extends ChangeNotifier {
  AppState(this.settings, this.catalog) : index = SearchIndex(catalog) {
    _initServer();
  }

  final Settings settings;
  Catalog catalog;
  SearchIndex index;
  PubServer? server;
  String? serverError;

  String? get libraryPath => settings.libraryPath;
  bool get hasLibrary => libraryPath != null;

  String libPath(List<String> parts) =>
      [libraryPath ?? '', ...parts].join(Platform.pathSeparator);

  bool get hasPub => hasLibrary && File(libPath(['pub', 'index.json'])).existsSync();

  void _initServer() {
    server = hasPub ? PubServer(libPath(['pub'])) : null;
  }

  Future<void> startServer() async {
    final s = server;
    if (s == null) {
      serverError = 'پوشه‌ی library/pub پیدا نشد. مسیر کتابخانه را در تنظیمات مشخص کن.';
      notifyListeners();
      return;
    }
    try {
      await s.start(settings.port);
      serverError = null;
    } catch (e) {
      serverError = 'اجرای سرور روی پورت ${settings.port} ممکن نشد ($e). شاید برنامه‌ی دیگری از این پورت استفاده می‌کند؛ پورت را در تنظیمات عوض کن.';
    }
    notifyListeners();
  }

  Future<void> stopServer() async {
    await server?.stop();
    notifyListeners();
  }

  Future<void> setLibraryPath(String path) async {
    await server?.stop();
    settings.libraryPath = path;
    await settings.save();
    await reloadCatalog();
    _initServer();
    if (settings.autoStartServer) await startServer();
    notifyListeners();
  }

  Future<void> reloadCatalog() async {
    catalog = await Catalog.load(libraryPath);
    index = SearchIndex(catalog);
    notifyListeners();
  }

  Future<void> saveSettings() async {
    await settings.save();
    notifyListeners();
  }
}

late AppState app;
