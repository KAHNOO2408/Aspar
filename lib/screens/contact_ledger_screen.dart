import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/ledger_model.dart';
import '../utils/formatters.dart';

class ContactLedgerScreen extends StatefulWidget {
  final String personName;
  final String personFamily;
  const ContactLedgerScreen({Key? key, required this.personName, required this.personFamily}) : super(key: key);

  @override
  State<ContactLedgerScreen> createState() => _ContactLedgerScreenState();
}

class _ContactLedgerScreenState extends State<ContactLedgerScreen> {
  final searchController = TextEditingController();
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
          endDate = picked.toDateTime();
        }
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.personName} ${widget.personFamily}')),
      body: Consumer<LedgerProvider>(
        builder: (context, provider, _) {
          final allEntries = provider.getEntriesForContact(widget.personName, widget.personFamily);

          double running = 0;
          final withBalance = allEntries.map((e) {
            running += e.debitAmount - e.creditAmount;
            return _LedgerRow(entry: e, balanceAfter: running);
          }).toList();

          final finalBalance = withBalance.isNotEmpty ? withBalance.last.balanceAfter : 0.0;

          var filtered = withBalance;

          final query = searchController.text.trim();
          if (query.isNotEmpty) {
            filtered = filtered.where((row) => row.entry.description.contains(query)).toList();
          }
          if (startDate != null) {
            filtered = filtered.where((row) => row.entry.date.isAfter(startDate!.subtract(const Duration(days: 1)))).toList();
          }
          if (endDate != null) {
            filtered = filtered.where((row) => row.entry.date.isBefore(endDate!.add(const Duration(days: 1)))).toList();
          }

          final totalDebit = filtered.fold(0.0, (sum, r) => sum + r.entry.debitAmount);
          final totalCredit = filtered.fold(0.0, (sum, r) => sum + r.entry.creditAmount);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: TextField(
                  controller: searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'جستجوی محصول...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    isDense: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(true),
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(startDate != null ? 'از: ${_formatJalali(startDate!)}' : 'از تاریخ'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(false),
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(endDate != null ? 'تا: ${_formatJalali(endDate!)}' : 'تا تاریخ'),
                      ),
                    ),
                    if (startDate != null || endDate != null)
                      IconButton(
                        onPressed: () => setState(() {
                          startDate = null;
                          endDate = null;
                        }),
                        icon: const Icon(Icons.clear, color: Colors.red),
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.indigo.withOpacity(0.9), Colors.indigo.shade700]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text('بدهکار', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                const SizedBox(height: 6),
                                Text(formatAmount(totalDebit), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                              ],
                            ),
                            Container(width: 1, height: 30, color: Colors.white24),
                            Column(
                              children: [
                                const Text('بستانکار', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                const SizedBox(height: 6),
                                Text(formatAmount(totalCredit), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white24, height: 24),
                        Text(
                          finalBalance >= 0 ? 'در حال حاضر او به شما ${formatAmount(finalBalance)} ریال بدهکار است' : 'در حال حاضر شما به او ${formatAmount(finalBalance.abs())} ریال بدهکارید',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, size: 90, color: Colors.grey[200]),
                            const SizedBox(height: 16),
                            const Text('موردی برای نمایش وجود ندارد', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final row = filtered[filtered.length - 1 - index]; // جدیدترین بالا
                          final entry = row.entry;
                          final isDebit = entry.debitAmount > 0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: Text(entry.description, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
                                        Text(_formatJalali(entry.date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('بدهکار', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                            Text(isDebit ? formatAmount(entry.debitAmount) : '-', style: const TextStyle(fontSize: 13, color: Colors.blue, fontWeight: FontWeight.w700)),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('بستانکار', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                            Text(!isDebit ? formatAmount(entry.creditAmount) : '-', style: const TextStyle(fontSize: 13, color: Colors.orange, fontWeight: FontWeight.w700)),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            const Text('مانده', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                            Text(
                                              '${formatAmount(row.balanceAfter.abs())} ${row.balanceAfter >= 0 ? '(بس)' : '(بد)'}',
                                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: row.balanceAfter >= 0 ? Colors.green : Colors.red),
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
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LedgerRow {
  final LedgerEntry entry;
  final double balanceAfter;
  _LedgerRow({required this.entry, required this.balanceAfter});
}
