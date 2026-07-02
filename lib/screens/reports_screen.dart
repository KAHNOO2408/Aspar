import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              buildCustomAppBar(title: 'گزارشات', context: context),
              const TabBar(
                tabs: [
                  Tab(text: 'تراکنش‌ها'),
                  Tab(text: 'سود'),
                  Tab(text: 'بانک‌ها'),
                ],
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTransactionReports(context),
            _buildProfitReports(context),
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
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
                              Text(formatAmount(income), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
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
                              Text(formatAmount(expense), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
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
                              Text(formatAmount(net), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('توزیع درآمد و خرج', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 20),
                        if (income > 0 && expense > 0)
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    color: Colors.green,
                                    value: income,
                                    title: 'درآمد',
                                    radius: 60,
                                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                                  ),
                                  PieChartSectionData(
                                    color: Colors.red,
                                    value: expense,
                                    title: 'خرج',
                                    radius: 60,
                                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('داده‌ای برای نمایش وجود ندارد', style: TextStyle(color: Colors.grey)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text('آخرین تراکنش‌ها', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              const SizedBox(height: 10),
              if (provider.transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('تراکنشی وجود ندارد', style: TextStyle(color: Colors.grey)),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.transactions.take(10).length,
                  itemBuilder: (context, index) {
                    final trans = provider.transactions[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: trans.type == TransactionType.income ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Icon(
                                trans.type == TransactionType.income ? Icons.arrow_downward : Icons.arrow_upward,
                                color: trans.type == TransactionType.income ? Colors.green : Colors.red,
                                size: 20,
                              ),
                            ),
                          ),
                          title: Text(trans.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(_formatDateToJalali(trans.date), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          trailing: Text(
                            formatAmount(trans.amount),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: trans.type == TransactionType.income ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfitReports(BuildContext context) {
    return Consumer<ProfitProvider>(
      builder: (context, provider, _) {
        final totalSales = provider.getTotalSales(null, null);
        final totalPurchases = provider.getTotalPurchases(null, null);
        final profit = provider.getTotalProfit();

        return SingleChildScrollView(
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
                        colors: [Colors.amber.withOpacity(0.9), Colors.orange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('کل سود', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 15),
                        Text(formatAmount(profit), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
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
                              const Text('خریدها', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 8),
                              Text(formatAmount(totalPurchases), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
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
                              const Text('فروش‌ها', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 8),
                              Text(formatAmount(totalSales), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (provider.transactions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('خرید و فروش', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                barGroups: [
                                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: (totalPurchases / 1000000).clamp(0, 100), color: Colors.red)]),
                                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: (totalSales / 1000000).clamp(0, 100), color: Colors.green)]),
                                ],
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        return value == 0 ? const Text('خریدها') : const Text('فروش‌ها');
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 20),
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
                        colors: [Colors.green.withOpacity(0.9), Colors.green.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('کل موجودی بانک‌ها', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 15),
                        Text(formatAmount(provider.getTotalBalance()), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              ),

              if (provider.banks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('موجودی بانک‌ها', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                barGroups: List.generate(
                                  provider.banks.length,
                                  (i) => BarChartGroupData(
                                    x: i,
                                    barRods: [BarChartRodData(toY: (provider.banks[i].balance / 1000000).clamp(0, 100), color: Colors.blue)],
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        return Text(provider.banks[value.toInt()].bankName, style: const TextStyle(fontSize: 10));
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text('جزئیات بانک‌ها', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              const SizedBox(height: 10),
              if (provider.banks.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('بانکی وجود ندارد', style: TextStyle(color: Colors.grey)),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.banks.length,
                  itemBuilder: (context, index) {
                    final bank = provider.banks[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(Icons.account_balance, color: Colors.green, size: 20),
                            ),
                          ),
                          title: Text(bank.bankName, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(bank.accountNumber, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          trailing: Text(formatAmount(bank.balance), style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.green, fontSize: 14)),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
