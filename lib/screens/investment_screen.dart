import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/profit_model.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/formatters.dart';
import 'add_investment_screen.dart';

class InvestmentScreen extends StatelessWidget {
  const InvestmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(title: 'سود', context: context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddInvestmentScreen())),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      body: Consumer<ProfitProvider>(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(formatAmount(profit), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                              const Text('📈', style: TextStyle(fontSize: 48)),
                            ],
                          ),
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

                const SizedBox(height: 20),

                if (provider.transactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(50),
                    child: Column(
                      children: [
                        Icon(Icons.trending_up, size: 100, color: Colors.grey[200]),
                        const SizedBox(height: 20),
                        const Text('سود‌ای ثبت نکردی', style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.transactions.length,
                    itemBuilder: (context, index) {
                      final trans = provider.transactions[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: trans.type == TransactionType.sale ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Icon(
                                  trans.type == TransactionType.sale ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: trans.type == TransactionType.sale ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                            title: Text(trans.productName, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text('${trans.quantity.toStringAsFixed(2)} × ${formatAmount(trans.pricePerUnit)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            trailing: Text(formatAmount(trans.totalAmount), style: TextStyle(fontWeight: FontWeight.w800, color: trans.type == TransactionType.sale ? Colors.green : Colors.red)),
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
      ),
    );
  }
}
