import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ledger_model.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/formatters.dart';
import 'contact_ledger_screen.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              buildCustomAppBar(title: 'حساب‌های باز', context: context),
              const TabBar(
                tabs: [
                  Tab(text: 'بدهی‌های من 📤'),
                  Tab(text: 'طلب‌های من 📥'),
                ],
              ),
            ],
          ),
        ),
        body: Consumer<LedgerProvider>(
          builder: (context, provider, _) {
            final allBalances = provider.getAllBalances();
            final owed = allBalances.where((b) => (b['balance'] as double) < 0).toList();
            final receivable = allBalances.where((b) => (b['balance'] as double) > 0).toList();

            return TabBarView(
              children: [
                _buildList(context, owed, Colors.red, 'کل بدهی‌های من', 'بدهی‌ای نداری', '📤'),
                _buildList(context, receivable, Colors.green, 'کل طلب‌های من', 'طلبی ندارم', '📥'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Map<String, dynamic>> list, Color color, String totalTitle, String emptyText, String emoji) {
    final total = list.fold(0.0, (sum, item) => sum + (item['balance'] as double).abs());

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
                  gradient: LinearGradient(colors: [color.withOpacity(0.9), color.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(totalTitle, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w400)),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(formatAmount(total), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                            const Text('ریال', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        Text(emoji, style: const TextStyle(fontSize: 48)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(alignment: Alignment.centerRight, child: Text('فهرست تفصیلی', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(height: 15),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.all(50),
              child: Column(
                children: [
                  Icon(Icons.done_all, size: 100, color: Colors.grey[200]),
                  const SizedBox(height: 20),
                  Text(emptyText, style: const TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500)),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                final personName = item['personName'] as String;
                final personFamily = item['personFamily'] as String;
                final balance = (item['balance'] as double).abs();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Icon(Icons.person, color: color, size: 24)),
                      ),
                      title: Text('$personName $personFamily', style: const TextStyle(fontWeight: FontWeight.w700)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(formatAmount(balance), style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 14)),
                          const Text('ریال', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ContactLedgerScreen(personName: personName, personFamily: personFamily)),
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
  }
}
