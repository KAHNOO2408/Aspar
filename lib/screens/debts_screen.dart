import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/debt_model.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/formatters.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({Key? key}) : super(key: key);

  String _formatDateToJalali(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
  }

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
        body: Consumer<DebtProvider>(
          builder: (context, provider, _) {
            final owedDebts = provider.debts.where((d) => d.type == DebtType.owed && d.remainder > 0).toList();
            final receivableDebts = provider.debts.where((d) => d.type == DebtType.receivable && d.remainder > 0).toList();

            return TabBarView(
              children: [
                _buildDebtList(context, provider, owedDebts, DebtType.owed, Colors.red, 'کل بدهی‌های من', 'بدهی‌ای نداری', '📤'),
                _buildDebtList(context, provider, receivableDebts, DebtType.receivable, Colors.green, 'کل طلب‌های من', 'طلبی ندارم', '📥'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDebtList(BuildContext context, DebtProvider provider, List<Debt> debts, DebtType type, Color color, String totalTitle, String emptyText, String emoji) {
    final total = type == DebtType.owed ? provider.getTotalOwed(null, null) : provider.getTotalReceivable(null, null);

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
                    colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('فهرست تفصیلی', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 15),
          if (debts.isEmpty)
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
              itemCount: debts.length,
              itemBuilder: (context, index) {
                final debt = debts[index];
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
                      title: Text('${debt.personName} ${debt.personFamily}', style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(_formatDateToJalali(debt.date), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(formatAmount(debt.remainder), style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 14)),
                          const Text('ریال', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      onTap: () => _showContactSummary(context, provider, debt.personName, debt.personFamily),
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

  void _showContactSummary(BuildContext context, DebtProvider provider, String personName, String personFamily) {
    final personDebts = provider.debts.where((d) => d.personName == personName && d.personFamily == personFamily).toList();
    final purchases = personDebts.where((d) => d.type == DebtType.owed).toList();
    final sales = personDebts.where((d) => d.type == DebtType.receivable).toList();

    final totalPurchaseAmount = purchases.fold(0.0, (sum, d) => sum + d.totalAmount);
    final totalSaleAmount = sales.fold(0.0, (sum, d) => sum + d.totalAmount);
    final currentOwed = purchases.fold(0.0, (sum, d) => sum + d.remainder);
    final currentReceivable = sales.fold(0.0, (sum, d) => sum + d.remainder);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$personName $personFamily', style: const TextStyle(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryRow('تعداد خرید (من از او)', '${purchases.length}'),
              _summaryRow('مجموع خرید', formatAmount(totalPurchaseAmount), Colors.red),
              const Divider(),
              _summaryRow('تعداد فروش (من به او)', '${sales.length}'),
              _summaryRow('مجموع فروش', formatAmount(totalSaleAmount), Colors.green),
              const Divider(),
              _summaryRow('مانده بدهی من به او', formatAmount(currentOwed), Colors.red),
              _summaryRow('مانده طلب او از من', formatAmount(currentReceivable), Colors.green),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            child: const Text('بستن', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: color ?? Colors.black)),
        ],
      ),
    );
  }
}
