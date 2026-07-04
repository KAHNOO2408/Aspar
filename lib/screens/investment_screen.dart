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
      setState(() {
        if (isStart) {
          startDate = picked.toDateTime();
        } else {
          endDate = picked.toDateTime(hour: 23, minute: 59, second: 59);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                // فیلتر بازه‌ی تاریخ
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('بازه‌ی زمانی گزارش', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
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
                              IconButton(
                                onPressed: () => setState(() {
                                  startDate = null;
                                  endDate = null;
                                }),
                                icon: const Icon(Icons.clear, color: Colors.red),
                                tooltip: 'پاک کردن فیلتر',
                              ),
                            ],
                          ],
                        ),
                        if (startDate == null && endDate == null) ...[
                          const SizedBox(height: 8),
                          const Text('بدون فیلتر، سود کل تاریخچه نشون داده میشه', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // کارت سود کل
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.amber.withOpacity(0.9), Colors.orange]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('کل سود', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 15),
                        Text(formatAmount(totalProfit), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // خرید و فروش
                Row(
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
                              const Text('کل خرید', style: TextStyle(color: Colors.white70, fontSize: 12)),
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
                              const Text('کل فروش', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 8),
                              Text(formatAmount(totalSales), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                const Text('سود به تفکیک محصول', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 12),

                if (report.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    child: const Column(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('در این بازه، معامله‌ای ثبت نشده', style: TextStyle(color: Colors.grey)),
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
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
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
                                        Text(formatAmount(row['totalPurchase']), style: const TextStyle(fontSize: 13, color: Colors.red, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('فروش', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                        Text(formatAmount(row['totalSale']), style: const TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('سود', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                        Text(
                                          formatAmount(profit),
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: profit >= 0 ? Colors.blue : Colors.red),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
