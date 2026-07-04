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
        backgroundColor: const Color(0xFFF4F6FB),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF4F6BF5), Color(0xFF2B3FBE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Column(
              children: [
                buildCustomAppBar(title: 'حساب‌های باز', context: context),
                const TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelStyle: TextStyle(fontWeight: FontWeight.w700),
                  tabs: [
                    Tab(text: 'بدهی‌های من 📤'),
                    Tab(text: 'طلب‌های من 📥'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: Consumer<LedgerProvider>(
          builder: (context, provider, _) {
            final allBalances = provider.getAllBalances();
            final owed = allBalances.where((b) => (b['balance'] as double) < 0).toList();
            final receivable = allBalances.where((b) => (b['balance'] as double) > 0).toList();

            return TabBarView(
              children: [
                _buildList(context, owed, const [Color(0xFFFF7A59), Color(0xFFE64A19)], 'کل بدهی‌های من', 'بدهی‌ای نداری', Icons.arrow_upward_rounded),
                _buildList(context, receivable, const [Color(0xFF11998E), Color(0xFF38EF7D)], 'کل طلب‌های من', 'طلبی ندارم', Icons.arrow_downward_rounded),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Map<String, dynamic>> list, List<Color> gradient, String totalTitle, String emptyText, IconData emptyIcon) {
    final total = list.fold(0.0, (sum, item) => sum + (item['balance'] as double).abs());

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
            child: Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                boxShadow: [BoxShadow(color: gradient[1].withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                            child: Icon(emptyIcon, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Text(totalTitle, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(formatAmount(total), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      const Text('تومان', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                    child: Icon(emptyIcon, color: Colors.white, size: 30),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Align(alignment: Alignment.centerRight, child: Text('فهرست تفصیلی', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.grey.shade700))),
          ),
          const SizedBox(height: 8),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.all(50),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                    child: Icon(Icons.done_all_rounded, size: 50, color: Colors.grey.shade300),
                  ),
                  const SizedBox(height: 18),
                  Text(emptyText, style: TextStyle(color: Colors.grey.shade500, fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                final personName = item['personName'] as String;
                final personFamily = item['personFamily'] as String;
                final balance = (item['balance'] as double).abs();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    elevation: 2,
                    shadowColor: Colors.black12,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContactLedgerScreen(personName: personName, personFamily: personFamily))),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                              ),
                              child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text('$personName $personFamily', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(formatAmount(balance), style: TextStyle(fontWeight: FontWeight.w800, color: gradient[1], fontSize: 14)),
                                const Text('تومان', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          ],
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
  }
}
