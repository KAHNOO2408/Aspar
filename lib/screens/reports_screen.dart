import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction_model.dart';
import '../models/bank_model.dart';
import '../models/profit_model.dart' hide TransactionType;
import '../widgets/custom_app_bar.dart';
import '../utils/formatters.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  String _formatDateToJalali(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF4F6BF5), Color(0xFF2B3FBE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Column(
              children: [
                buildCustomAppBar(title: 'گزارشات', context: context),
                const TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelStyle: TextStyle(fontWeight: FontWeight.w700),
                  tabs: [
                    Tab(text: 'تراکنش‌ها'),
                    Tab(text: 'بانک‌ها'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildTransactionReports(context),
            _buildBankReports(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionReports(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final income = provider.getTotalIncome(null, null);
        final expense = provider.getTotalExpense(null, null);
        final net = provider.getNetBalance();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _MiniStat(icon: Icons.arrow_downward_rounded, label: 'درآمد', value: formatAmount(income), gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)])),
                  const SizedBox(width: 12),
                  Expanded(child: _MiniStat(icon: Icons.arrow_upward_rounded, label: 'خرج', value: formatAmount(expense), gradient: const [Color(0xFFFF7A59), Color(0xFFE64A19)])),
                ],
              ),
              const SizedBox(height: 12),
              _MiniStat(icon: Icons.account_balance_wallet_rounded, label: 'خالص', value: formatAmount(net), gradient: const [Color(0xFF4F6BF5), Color(0xFF2B3FBE)], fullWidth: true),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('توزیع درآمد و خرج', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.grey.shade800)),
                    const SizedBox(height: 20),
                    if (income > 0 && expense > 0)
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(color: const Color(0xFF11998E), value: income, title: 'درآمد', radius: 60, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                              PieChartSectionData(color: const Color(0xFFE64A19), value: expense, title: 'خرج', radius: 60, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                            ],
                          ),
                        ),
                      )
                    else
                      Padding(padding: const EdgeInsets.all(20), child: Text('داده‌ای برای نمایش وجود ندارد', style: TextStyle(color: Colors.grey.shade500))),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Align(alignment: Alignment.centerRight, child: Text('آخرین تراکنش‌ها', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.grey.shade800))),
              const SizedBox(height: 10),
              if (provider.transactions.isEmpty)
                Padding(padding: const EdgeInsets.all(20), child: Text('تراکنشی وجود ندارد', style: TextStyle(color: Colors.grey.shade500)))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.transactions.take(10).length,
                  itemBuilder: (context, index) {
                    final trans = provider.transactions[index];
                    final isIncome = trans.type == TransactionType.income;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))]),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(colors: isIncome ? const [Color(0xFF11998E), Color(0xFF38EF7D)] : const [Color(0xFFFF7A59), Color(0xFFE64A19)]),
                              ),
                              child: Icon(isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(trans.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                  Text(_formatDateToJalali(trans.date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Text(formatAmount(trans.amount), style: TextStyle(fontWeight: FontWeight.w800, color: isIncome ? const Color(0xFF11998E) : const Color(0xFFE64A19))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBankReports(BuildContext context) {
    return Consumer<BankProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(colors: [Color(0xFF11998E), Color(0xFF38EF7D)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  boxShadow: [BoxShadow(color: const Color(0xFF11998E).withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('کل موجودی بانک‌ها', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 15),
                        Text(formatAmount(provider.getTotalBalance()), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        const Text('تومان', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle), child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 30)),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              if (provider.banks.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('موجودی بانک‌ها', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.grey.shade800)),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            barGroups: List.generate(
                              provider.banks.length,
                              (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: (provider.banks[i].balance / 1000000).clamp(0, 100), color: const Color(0xFF4F6BF5), width: 18, borderRadius: BorderRadius.circular(6))]),
                            ),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text(provider.banks[value.toInt()].bankName, style: const TextStyle(fontSize: 10)))),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),
              Align(alignment: Alignment.centerRight, child: Text('جزئیات بانک‌ها', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.grey.shade800))),
              const SizedBox(height: 10),
              if (provider.banks.isEmpty)
                Padding(padding: const EdgeInsets.all(20), child: Text('بانکی وجود ندارد', style: TextStyle(color: Colors.grey.shade500)))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.banks.length,
                  itemBuilder: (context, index) {
                    final bank = provider.banks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))]),
                        child: Row(
                          children: [
                            Container(width: 42, height: 42, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(colors: [Color(0xFF11998E), Color(0xFF38EF7D)])), child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 20)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(bank.bankName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                  Text(bank.accountNumber, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Text(formatAmount(bank.balance), style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF11998E), fontSize: 13)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;
  final bool fullWidth;

  const _MiniStat({required this.icon, required this.label, required this.value, required this.gradient, this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(18),
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
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white, size: 16)),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
