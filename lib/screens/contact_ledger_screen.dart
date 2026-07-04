import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/ledger_model.dart';
import '../models/bank_model.dart';
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

  void _showDetails(BuildContext context, LedgerEntry entry, double balanceAfter) {
    final bankProvider = context.read<BankProvider>();
    String bankName = 'ثبت نشده';
    if (entry.bankId != null) {
      try {
        bankName = bankProvider.banks.firstWhere((b) => b.id == entry.bankId).bankName;
      } catch (e) {
        bankName = 'ثبت نشده';
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('جزئیات فاکتور', style: TextStyle(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('شرح', entry.description),
              _detailRow('تاریخ', _formatJalali(entry.date)),
              if (entry.debitAmount > 0) _detailRow('پرداختی', formatAmount(entry.debitAmount)),
              if (entry.creditAmount > 0) _detailRow('دریافتی', formatAmount(entry.creditAmount)),
              _detailRow('بانک', bankName),
              _detailRow('مانده بعد از این فاکتور', formatAmount(balanceAfter.abs())),
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, LedgerProvider provider, LedgerEntry entry) {
    final descController = TextEditingController(text: entry.description);
    final debitController = TextEditingController(text: entry.debitAmount > 0 ? entry.debitAmount.toStringAsFixed(0) : '');
    final creditController = TextEditingController(text: entry.creditAmount > 0 ? entry.creditAmount.toStringAsFixed(0) : '');
    DateTime selectedDate = entry.date;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: const Text('ویرایش فاکتور', style: TextStyle(fontWeight: FontWeight.w700)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(labelText: 'شرح', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: debitController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'پرداختی', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: creditController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'دریافتی', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final picked = await showPersianDatePicker(
                        context: dialogContext,
                        initialDate: Jalali.fromDateTime(selectedDate),
                        firstDate: Jalali(1390, 1),
                        lastDate: Jalali(1420, 12, 29),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked.toDateTime());
                      }
                    },
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(_formatJalali(selectedDate)),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('انصراف')),
              ElevatedButton(
                onPressed: () {
                  final updated = LedgerEntry(
                    id: entry.id,
                    personName: entry.personName,
                    personFamily: entry.personFamily,
                    date: selectedDate,
                    description: descController.text,
                    debitAmount: double.tryParse(debitController.text) ?? 0,
                    creditAmount: double.tryParse(creditController.text) ?? 0,
                    bankId: entry.bankId,
                  );
                  provider.updateEntry(updated);
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ویرایش شد ✅')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                child: const Text('ذخیره', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, LedgerProvider provider, LedgerEntry entry) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف فاکتور', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red)),
        content: Text('آیا از حذف «${entry.description}» مطمئن هستید؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () {
              provider.deleteEntry(entry.id!);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حذف شد'), backgroundColor: Colors.red));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
                                const Text('دریافتی', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                const SizedBox(height: 6),
                                Text(formatAmount(totalCredit), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                              ],
                            ),
                            Container(width: 1, height: 30, color: Colors.white24),
                            Column(
                              children: [
                                const Text('پرداختی', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                const SizedBox(height: 6),
                                Text(formatAmount(totalDebit), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white24, height: 24),
                        Text(
                          finalBalance >= 0
                              ? 'در حال حاضر ${widget.personName} به شما ${formatAmount(finalBalance)} ریال بدهکار است'
                              : 'در حال حاضر شما به ${widget.personName} ${formatAmount(finalBalance.abs())} ریال بدهکارید',
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
                          final row = filtered[filtered.length - 1 - index];
                          final entry = row.entry;
                          final hasDebit = entry.debitAmount > 0;
                          final hasCredit = entry.creditAmount > 0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _showDetails(context, entry, row.balanceAfter),
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
                                          PopupMenuButton<String>(
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                                            onSelected: (value) {
                                              final provider = context.read<LedgerProvider>();
                                              if (value == 'edit') {
                                                _showEditDialog(context, provider, entry);
                                              } else if (value == 'delete') {
                                                _showDeleteConfirm(context, provider, entry);
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18, color: Colors.blue), SizedBox(width: 8), Text('ویرایش')])),
                                              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('حذف')])),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('دریافتی', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                              Text(hasCredit ? formatAmount(entry.creditAmount) : '-', style: const TextStyle(fontSize: 13, color: Colors.orange, fontWeight: FontWeight.w700)),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('پرداختی', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                              Text(hasDebit ? formatAmount(entry.debitAmount) : '-', style: const TextStyle(fontSize: 13, color: Colors.blue, fontWeight: FontWeight.w700)),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              const Text('مانده', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                              Text(
                                                formatAmount(row.balanceAfter.abs()),
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
