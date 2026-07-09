import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/debt_model.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/formatters.dart';
import '../utils/app_colors.dart';
import 'add_simple_debt_screen.dart';
import 'contact_ledger_screen.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({Key? key}) : super(key: key);

  Map<String, double> _computeNetBalances(List<Debt> debts) {
    final Map<String, double> net = {};
    for (final d in debts) {
      final key = '${d.personName}|${d.personFamily}';
      final delta = d.type == DebtType.receivable ? d.remainder : -d.remainder;
      net[key] = (net[key] ?? 0) + delta;
    }
    net.removeWhere((key, value) => value.abs() < 0.01);
    return net;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Container(
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF9B6DFF), Color(0xFF6A3DE8)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Column(
              children: [
                buildCustomAppBar(title: 'طلب و دهی', context: context),
                const TabBar(labelColor: Colors.white, unselectedLabelColor: Colors.white60, indicatorColor: Colors.white, indicatorWeight: 3, labelStyle: TextStyle(fontWeight: FontWeight.w700), tabs: [Tab(text: 'بدهی‌های من'), Tab(text: 'طلب‌های من')]),
              ],
            ),
          ),
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(colors: [Color(0xFF9B6DFF), Color(0xFF6A3DE8)]),
            boxShadow: [BoxShadow(color: const Color(0xFF6A3DE8).withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 6))],
          ),
          child: Material(
            color: Colors.transparent,
            child: PopupMenuButton(
              iconColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onSelected: (value) {
                if (value == 'owed') Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSimpleDebtScreen(type: DebtType.owed)));
                if (value == 'receivable') Navigator.push(context, MaterialPageRoute(builder: (_) => const AddSimpleDebtScreen(type: DebtType.receivable)));
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(value: 'owed', child: Row(children: [Icon(Icons.arrow_upward, size: 16), SizedBox(width: 8), Text('ثبت دهی', style: TextStyle(fontFamily: 'YekanBakh'))])),
                const PopupMenuItem(value: 'receivable', child: Row(children: [Icon(Icons.arrow_downward, size: 16), SizedBox(width: 8), Text('ثبت طلب', style: TextStyle(fontFamily: 'YekanBakh'))])),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.add, color: Colors.white), const SizedBox(width: 8), const Text('افزودن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'YekanBakh'))]),
              ),
            ),
          ),
        ),
        body: Consumer<DebtProvider>(
          builder: (context, provider, _) {
            final net = _computeNetBalances(provider.debts);

            final owedEntries = <MapEntry<String, double>>[];
            final receivableEntries = <MapEntry<String, double>>[];
            for (final entry in net.entries) {
              if (entry.value < 0) {
                owedEntries.add(MapEntry(entry.key, -entry.value));
              } else {
                receivableEntries.add(MapEntry(entry.key, entry.value));
              }
            }

            final totalOwed = owedEntries.fold(0.0, (sum, e) => sum + e.value);
            final totalReceivable = receivableEntries.fold(0.0, (sum, e) => sum + e.value);

            return TabBarView(
              children: [
                _DebtsTab(
                  entries: owedEntries,
                  total: totalOwed,
                  emptyText: 'بدهی‌ای ثبت نشده',
                  gradient: const [Color(0xFFFF7A59), Color(0xFFE64A19)],
                  totalLabel: 'مجموع بدهکاری',
                ),
                _DebtsTab(
                  entries: receivableEntries,
                  total: totalReceivable,
                  emptyText: 'طلبی ثبت نشده',
                  gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                  totalLabel: 'مجموع طلبکاری',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DebtsTab extends StatelessWidget {
  final List<MapEntry<String, double>> entries;
  final double total;
  final String emptyText;
  final List<Color> gradient;
  final String totalLabel;

  const _DebtsTab({
    required this.entries,
    required this.total,
    required this.emptyText,
    required this.gradient,
    required this.totalLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                boxShadow: [BoxShadow(color: gradient[1].withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(totalLabel, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'YekanBakh')),
                  const SizedBox(height: 10),
                  Text('${formatAmount(total)} تومان', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'YekanBakh')),
                ],
              ),
            ),
          ),

          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(60),
              child: Column(
                children: [
                  Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.card(context), shape: BoxShape.circle), child: Icon(Icons.account_balance_wallet_outlined, size: 55, color: AppColors.textMuted(context))),
                  const SizedBox(height: 20),
                  Text(emptyText, style: TextStyle(color: AppColors.textSecondary(context), fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'YekanBakh')),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final key = entries[index].key;
                final amount = entries[index].value;
                final parts = key.split('|');
                final personName = parts[0];
                final personFamily = parts.length > 1 ? parts[1] : '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ContactSummaryCard(
                    personName: personName,
                    personFamily: personFamily,
                    amount: amount,
                    gradient: gradient,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContactLedgerScreen(personName: personName, personFamily: personFamily))),
                  ),
                );
              },
            ),

          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

class _ContactSummaryCard extends StatelessWidget {
  final String personName;
  final String personFamily;
  final double amount;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ContactSummaryCard({
    required this.personName,
    required this.personFamily,
    required this.amount,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card(context),
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(gradient: LinearGradient(colors: gradient), shape: BoxShape.circle),
                child: const Icon(Icons.person, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('$personName $personFamily', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.text(context), fontFamily: 'YekanBakh')),
              ),
              Text('${formatAmount(amount)} تومان', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: gradient[1], fontFamily: 'YekanBakh')),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted(context)),
            ],
          ),
        ),
      ),
    );
  }
}
