import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../models/bank_model.dart';
import '../models/debt_model.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/formatters.dart';
import 'add_transaction_screen.dart';
import 'add_debt_screen.dart';
import 'add_bank_screen.dart';
import 'debts_screen.dart';
import 'banks_screen.dart';
import 'contacts_screen.dart';
import 'investment_screen.dart';
import 'products_screen.dart';
import 'loans_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'transfer_between_accounts_screen.dart';
import 'bank_deposit_screen.dart';
import 'bank_withdrawal_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: buildCustomAppBar(title: 'خانه', context: context),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF4F6BF5), Color(0xFF2B3FBE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
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
            ListTile(leading: const Icon(Icons.home, color: Colors.blue), title: const Text('خانه'), onTap: () => Navigator.pop(context)),
            ListTile(
              leading: const Icon(Icons.shopping_cart, color: Colors.red),
              title: const Text('ثبت خرید'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddDebtScreen(type: DebtType.owed)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.sell, color: Colors.green),
              title: const Text('ثبت فروش'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddDebtScreen(type: DebtType.receivable)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet, color: Colors.orange),
              title: const Text('بدهی و طلب'),
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
              leading: const Icon(Icons.call_received, color: Colors.teal),
              title: const Text('واریز به بانک'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BankDepositScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.call_made, color: Colors.deepOrange),
              title: const Text('برداشت از بانک'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BankWithdrawalScreen()));
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
              leading: const Icon(Icons.compare_arrows, color: Colors.deepPurple),
              title: const Text('دریافت و پرداخت بین حساب‌ها'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferBetweenAccountsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2, color: Colors.brown),
              title: const Text('انبار محصولات'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen()));
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
            // کارت خوش‌آمدگویی
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F6BF5), Color(0xFF2B3FBE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [BoxShadow(color: const Color(0xFF2B3FBE).withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('خوش‌آمدی 👋', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                        SizedBox(height: 8),
                        Text('آسپار', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                        SizedBox(height: 16),
                        Text('حسابداری شخصی و مدیریت درآمد', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                      child: const Icon(Icons.insights_rounded, color: Colors.white, size: 34),
                    ),
                  ],
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.arrow_downward_rounded,
                              label: 'درآمد',
                              value: formatAmount(income),
                              gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.arrow_upward_rounded,
                              label: 'خرج',
                              value: formatAmount(expense),
                              gradient: const [Color(0xFFFF7A59), Color(0xFFE64A19)],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.account_balance_wallet_rounded,
                              label: 'خالص',
                              value: formatAmount(balance),
                              gradient: const [Color(0xFF4F6BF5), Color(0xFF2B3FBE)],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.account_balance_rounded,
                              label: 'موجودی بانک',
                              value: formatAmount(bankBalance),
                              gradient: const [Color(0xFF9B6DFF), Color(0xFF6A3DE8)],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: _StatCard(
                        icon: Icons.account_balance_rounded,
                        label: 'تعداد بانک',
                        value: '${bankProvider.banks.length}',
                        gradient: const [Color(0xFFFF5C8A), Color(0xFFD81B60)],
                        fullWidth: true,
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
                  Text('دسترسی های سریع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey.shade800)),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.add_rounded,
                          label: 'تراکنش جدید',
                          gradient: const [Color(0xFF4F6BF5), Color(0xFF2B3FBE)],
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.shopping_cart_rounded,
                          label: 'ثبت خرید',
                          gradient: const [Color(0xFFFF7A59), Color(0xFFE64A19)],
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddDebtScreen(type: DebtType.owed))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.sell_rounded,
                          label: 'ثبت فروش',
                          gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddDebtScreen(type: DebtType.receivable))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.account_balance_rounded,
                          label: 'بانک جدید',
                          gradient: const [Color(0xFF9B6DFF), Color(0xFF6A3DE8)],
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBankScreen())),
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;
  final bool fullWidth;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: gradient[1].withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 7))],
      ),
      child: fullWidth
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(10)),
                      child: Icon(icon, color: Colors.white, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              ],
            ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: gradient[1].withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 7))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 22),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 10),
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
