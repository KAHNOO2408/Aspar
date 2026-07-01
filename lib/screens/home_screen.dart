import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../models/bank_model.dart';
import '../models/debt_model.dart';
import '../widgets/custom_app_bar.dart';
import 'add_transaction_screen.dart';
import 'add_debt_screen.dart';
import 'add_bank_screen.dart';
import 'add_investment_screen.dart';
import 'debts_screen.dart';
import 'banks_screen.dart';
import 'contacts_screen.dart';
import 'settlement_screen.dart';
import 'investment_screen.dart';
import 'loans_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(title: 'خانه', context: context),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo, Colors.indigo.shade700],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/logo.svg', width: 80, height: 80),
                  const SizedBox(height: 10),
                  const Text('آسپار', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blue),
              title: const Text('خانه'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet, color: Colors.orange),
              title: const Text('حساب‌های باز'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DebtsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance, color: Colors.green),
              title: const Text('بانک'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BanksScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.contacts, color: Colors.purple),
              title: const Text('مخاطبین'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: Colors.amber),
              title: const Text('تسویه'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettlementScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up, color: Colors.blue),
              title: const Text('سود'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const InvestmentScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.handshake, color: Colors.red),
              title: const Text('وام'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoansScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.teal),
              title: const Text('گزارشات'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('تنظیمات'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo.withOpacity(0.9), Colors.indigo.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(30),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('خوش‌آمدی 👋', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      SizedBox(height: 8),
                      Text('آسپار', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                      SizedBox(height: 20),
                      Text('حسابداری شخصی و مدیریت درآمد', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
            Consumer3<TransactionProvider, BankProvider, DebtProvider>(
              builder: (context, transProvider, bankProvider, debtProvider, _) {
                final income = transProvider.getTotalIncome(null, null);
                final expense = transProvider.getTotalExpense(null, null);
                final balance = transProvider.getNetBalance();
                final bankBalance = bankProvider.getTotalBalance();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [Colors.green.withOpacity(0.7), Colors.green.shade400]),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('درآمد', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                    const SizedBox(height: 8),
                                    Text('${income.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Card(
                              elevation: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [Colors.red.withOpacity(0.7), Colors.red.shade400]),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('خرج', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                    const SizedBox(height: 8),
                                    Text('${expense.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Card(
                              elevation: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [Colors.blue.withOpacity(0.7), Colors.blue.shade400]),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('خالص', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                    const SizedBox(height: 8),
                                    Text('${balance.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [Colors.purple.withOpacity(0.7), Colors.purple.shade400]),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('موجودی بانک', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                    const SizedBox(height: 8),
                                    Text('${bankBalance.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Card(
                              elevation: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [Colors.orange.withOpacity(0.7), Colors.orange.shade400]),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('تعداد بانک', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                    const SizedBox(height: 8),
                                    Text('${bankProvider.banks.length}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('دسترسی های سریع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
                          child: Card(
                            elevation: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [Colors.green.withOpacity(0.8), Colors.green.shade600]),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: const Column(
                                children: [
                                  Icon(Icons.add, color: Colors.white, size: 32),
                                  SizedBox(height: 10),
                                  Text('تراکنش جدید', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddDebtScreen(type: DebtType.owed))),
                          child: Card(
                            elevation: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [Colors.red.withOpacity(0.8), Colors.red.shade600]),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: const Column(
                                children: [
                                  Icon(Icons.person, color: Colors.white, size: 32),
                                  SizedBox(height: 10),
                                  Text('بدهی جدید', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBankScreen())),
                          child: Card(
                            elevation: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [Colors.blue.withOpacity(0.8), Colors.blue.shade600]),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: const Column(
                                children: [
                                  Icon(Icons.account_balance, color: Colors.white, size: 32),
                                  SizedBox(height: 10),
                                  Text('بانک جدید', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddInvestmentScreen())),
                          child: Card(
                            elevation: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [Colors.amber.withOpacity(0.8), Colors.amber.shade600]),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: const Column(
                                children: [
                                  Icon(Icons.trending_up, color: Colors.white, size: 32),
                                  SizedBox(height: 10),
                                  Text('سود جدید', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
