import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../widgets/custom_app_bar.dart';

class SettlementScreen extends StatelessWidget {
  const SettlementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(title: 'تسویه', context: context),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          final transactions = provider.transactions;
          final income = provider.getTotalIncome(null, null);
          final expense = provider.getTotalExpense(null, null);
          final balance = provider.getNetBalance();

          return SingleChildScrollView(
            child: Column(
              children: [
                // خلاصه
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('خلاصه تسویه', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('درآمد', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  Text('${income.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('خرج', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  Text('${expense.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('خالص', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  Text('${balance.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (transactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(50),
                    child: Column(
                      children: [
                        Icon(Icons.receipt, size: 100, color: Colors.grey[200]),
                        const SizedBox(height: 20),
                        const Text('تراکنشی وجود ندارد', style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final trans = transactions[index];
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
                                color: trans.type == TransactionType.income ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Icon(
                                  trans.type == TransactionType.income ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: trans.type == TransactionType.income ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                            title: Text(trans.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text(trans.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            trailing: Text(
                              '${trans.amount.toStringAsFixed(0)}',
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
      ),
    );
  }
}
