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
  String range = 'month';
  DateTime? customStart;
  DateTime? customEnd;

  DateTime? get _start {
    final now = DateTime.now();
    switch (range) {
      case 'today':
        return DateTime(now.year, now.month, now.day);
      case 'week':
        return now.subtract(const Duration(days: 7));
      case 'month':
        return now.subtract(const Duration(days: 30));
      case 'year':
        return now.subtract(const Duration(days: 365));
      case 'custom':
        return customStart;
      default:
        return null;
    }
  }

  DateTime? get _end => range == 'custom' ? customEnd : DateTime.now();

  String _formatJalali(DateTime date) {
    final j = Jalali.fromDateTime(date);
    return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickCustomDate(bool isStart) async {
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: Jalali.now(),
      firstDate: Jalali(1390, 1),
      lastDate: Jalali(1420, 12, 29),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          customStart = picked.toDateTime();
        } else {
          customEnd = picked.toDateTime();
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
          final report = provider.getProfitReport(_start, _end);
          final totalProfit = provider.getTotalProfit(_start, _end);
          final totalSales = report.fold(0.0, (sum, r) => sum + (r['totalSale'] as double));
          final totalPurchases = report.fold(0.0, (sum, r) => sum + (r['totalPurchase'] as double));

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      _rangeChip('امروز', 'today'),
                      _rangeChip('۷ روز اخیر', 'week'),
                      _rangeChip('۳۰ روز اخیر', 'month'),
                      _rangeChip('۱ سال اخیر', 'year'),
                      _rangeChip('دلخواه', 'custom'),
                    ],
                  ),
                ),

                if (range == 'custom')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickCustomDate(true),
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(customStart != null ? _formatJalali(customStart!) : 'از تاریخ'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickCustomDate(false),
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(customEnd != null ? _formatJalali(customEnd!) : 'تا تاریخ'),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Card(
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
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('سود به تفکیک محصول', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 10),

                if (report.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Text('در این بازه، معامله‌ای ثبت نشده', style: TextStyle(color: Colors.grey)),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(row['productName'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('خرید: ${formatAmount(row['totalPurchase'])}', style: const TextStyle(fontSize: 12, color: Colors.red)),
                                    Text('فروش: ${formatAmount(row['totalSale'])}', style: const TextStyle(fontSize: 12, color: Colors.green)),
                                    Text('سود: ${formatAmount(profit)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: profit >= 0 ? Colors.blue : Colors.red)),
                                  ],
                                ),
                              ],
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

  Widget _rangeChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: range == value,
      onSelected: (_) => setState(() => range = value),
    );
  }
}
