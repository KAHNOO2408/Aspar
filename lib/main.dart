import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'models/transaction_model.dart';
import 'models/debt_model.dart';
import 'models/bank_model.dart';
import 'models/contact_model.dart';
import 'models/profit_model.dart';
import 'models/loan_model.dart';
import 'models/payment_model.dart';
import 'models/product_model.dart';
import 'models/ledger_model.dart';
import 'models/savings_model.dart';
import 'models/theme_provider.dart';
import 'screens/license_activation_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'database/db_helper.dart';
import 'services/security_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await SecurityService.init();
    await SecurityService.initializeSession();
    await Hive.initFlutter();
    await DatabaseHelper.init();
    final authBox = DatabaseHelper.authBox;
    final isActivated = authBox.get('activated', defaultValue: false);
    runApp(MyApp(isActivated: isActivated));
  } catch (e) {
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  final bool isActivated;
  const MyApp({Key? key, required this.isActivated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => DebtProvider()),
        ChangeNotifierProvider(create: (_) => BankProvider()),
        ChangeNotifierProvider(create: (_) => ContactProvider()),
        ChangeNotifierProvider(create: (_) => ProfitProvider()),
        ChangeNotifierProvider(create: (_) => LoanProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => LedgerProvider()),
        ChangeNotifierProvider(create: (_) => SavingsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'آسپار',
            theme: themeProvider.getLightTheme(),
            darkTheme: themeProvider.getDarkTheme(),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: const Locale('fa', 'IR'),
            supportedLocales: const [
              Locale('fa', 'IR'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: [
              PersianMaterialLocalizations.delegate,
              PersianCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: isActivated ? const LoginScreen() : const LicenseActivationScreen(),
          );
        },
      ),
    );
  }
}
