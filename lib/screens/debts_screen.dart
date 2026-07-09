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

  Map<String, double> _groupByContact(List<Debt> debts) {
    final Map<String, double> grouped = {};
    for (final d in debts) {
      final key = '${d.personName}|${d.personFamily}';
      grouped[key] = (grouped[key] ?? 0) + d.remainder;
    }
    grouped.removeWhere((key, value) => value <= 0);
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: buildCustomAppBar(title: 'طلب و دهی', context: context),
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
          final owedDebts = provider.debts.where((d) => d.type == DebtType.owed).toList();
          final receivableDebts = provider.debts.where((d) => d.type == DebtType.receivable).toList();

          final totalOwed = owedDebts.fold(0.0, (sum, d) => sum + d.remainder);
          final totalReceivable = receivableDebts.fold(0.0, (sum, d) => sum + d.remainder);

          final groupedOwed = _groupByContact(owedDebts);
          final groupedReceivable = _groupByContact(receivableDebts);

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.arrow_upward_rounded,
                          label: 'بدهکاری',
                          value: formatAmount(totalOwed),
                          gradient: const [Color(0xFFFF7A59), Color(0xFFE64A19)],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          icon: Icons.arrow_downward_rounded,
                          label: 'طلبکاری',
                          value: formatAmount(totalReceivable),
                          gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                        ),
                      ),
                    ],
                  ),
                ),

                if (groupedOwed.isEmpty && groupedReceivable.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(60),
                    child: Column(
                      children: [
                        Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.card(context), shape: BoxShape.circle), child: Icon(Icons.account_balance_wallet_outlined, size: 55, color: AppColors.textMuted(context))),
                        const SizedBox(height: 20),
                        Text('طلب و دهی‌ای ثبت نشده', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'YekanBakh')),
                      ],
                    ),
                  )
                else
                  Column(
                    children: [
                      if (groupedReceivable.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                          child: Align(alignment: Alignment.centerRight, child: Text('طلب‌های من', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.text(context), fontFamily: 'YekanBakh'))),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: groupedReceivable.length,
                          itemBuilder: (context, index) {
                            final key = groupedReceivable.keys.elementAt(index);
                            final parts = key.split('|');
                            final personName = parts[0];
                            final personFamily = parts.length > 1 ? parts[1] : '';
                            final amount = groupedReceivable[key]!;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ContactSummaryCard(
                                personName: personName,
                                personFamily: personFamily,
                                amount: amount,
                                gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContactLedgerScreen(personName: personName, personFamily: personFamily))),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],

                      if (groupedOwed.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                          child: Align(alignment: Alignment.centerRight, child: Text('بدهی‌های من', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.text(context), fontFamily: 'YekanBakh'))),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: groupedOwed.length,
                          itemBuilder: (context, index) {
                            final key = groupedOwed.keys.elementAt(index);
                            final parts = key.split('|');
                            final personName = parts[0];
                            final personFamily = parts.length > 1 ? parts[1] : '';
                            final amount = groupedOwed[key]!;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ContactSummaryCard(
                                personName: personName,
                                personFamily: personFamily,
                                amount: amount,
                                gradient: const [Color(0xFFFF7A59), Color(0xFFE64A19)],
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContactLedgerScreen(personName: personName, personFamily: personFamily))),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),

                const SizedBox(height: 90),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: gradient[1].withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white, size: 16)),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'YekanBakh')),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'YekanBakh')),
          const SizedBox(height: 2),
          const Text('تومان', style: TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'YekanBakh')),
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
