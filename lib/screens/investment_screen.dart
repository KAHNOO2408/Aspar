import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/product_model.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/formatters.dart';

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({Key? key}) : super(key: key);

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  DateTime? startDate;
  DateTime? endDate;

  String _formatJalali(DateTime date) {
    final j = Jalali.fromDateTime(date);
    return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: Jalali.now(),
      firstDate: Jalali(1390, 1),
      lastDate: Jalali(1420, 12, 29),
    );
    if (picked != null) {
      final converted = picked.toDateTime();
      setState(() {
        if (isStart) {
          startDate = converted;
        } else {
          endDate = DateTime(converted.year, converted.month, converted.day, 23, 59, 59);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: buildCustomAppBar(title: 'سود', context: context),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          final report = provider.getProfitReport(startDate, endDate);
          final totalProfit = provider.getTotalProfit(startDate, endDate);
          final totalSales = report.fold(0.0, (sum, r) => sum + (r['totalSale'] as double));
          final totalPurchases = report.fold(0.0, (sum, r) => sum + (r['totalPurchase'] as double));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('بازه‌ی زمانی گزارش', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.grey.shade800)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickDate(true),
                              icon: const Icon(Icons.calendar_today, size: 16),
                              label: Text(startDate != null ? _formatJalali(startDate!) : 'از تاریخ'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickDate(false),
                              icon: const Icon(Icons.calendar_today, size: 16),
                              label: Text(endDate != null ? _formatJalali(endDate!) : 'تا تاریخ'),
                            ),
                          ),
                          if (startDate != null || endDate != null) ...[
                            const SizedBox(width: 6),
                            IconButton(onPressed: () => setState(() { startDate = null; endDate = null; }), icon: const Icon(Icons.clear, color: Colors.red)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(colors: [Color(0xFFFFB74D), Color(0xFFFF8A00)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    boxShadow: [BoxShadow(color: const Color(0xFFFF8A00).withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('کل سود', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 15),
                          Text(formatAmount(totalProfit), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          const Text('تومان', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle),
                        child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 30),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: _MiniStat(icon: Icons.arrow_upward_rounded, label: 'کل خرید', value: formatAmount(totalPurchases), gradient: const [Color(0xFFFF7A59), Color(0xFFE64A19)]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MiniStat(icon: Icons.arrow_downward_rounded, label: 'کل فروش', value: formatAmount(totalSales), gradient: const [Color(0xFF11998E), Color(0xFF38EF7D)]),
                    ),
                  ],
                ),

                const SizedBox(height: 25),
                Text('سود به تفکیک محصول', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.grey.shade800)),
                const SizedBox(height: 12),

                if (report.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                          child: Icon(Icons.inventory_2_outlined, size: 50, color: Colors.grey.shade300),
                        ),
                        const SizedBox(height: 14),
                        Text('در این بازه، معامله‌ای ثبت نشده', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: report.length,
                    itemBuilder: (context, index) {
                      final row = report[index];
                      final profit = row['profit'] as double;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(row['productName'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('خرید', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      Text(formatAmount(row['totalPurchase']), style: const TextStyle(fontSize: 13, color: Color(0xFFE64A19), fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('فروش', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      Text(formatAmount(row['totalSale']), style: const TextStyle(fontSize: 13, color: Color(0xFF11998E), fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('سود', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      Text(formatAmount(profit), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: profit >= 0 ? const Color(0xFF2B3FBE) : const Color(0xFFE64A19))),
                                    ],
                                  ),
                                ],
                              ),
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
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;

  const _MiniStat({required this.icon, required this.label, required this.value, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
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
