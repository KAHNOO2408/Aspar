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

  String _formatTime(DateTime date) => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

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
    final amount = entry.debitAmount > 0 ? entry.debitAmount : entry.creditAmount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('جزئیات فاکتور', style: TextStyle(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('شرح', entry.description),
              _detailRow('بانک', bankName),
              _detailRow('مبلغ', '${formatAmount(amount)} تومان'),
              if (entry.trackingCode != null && entry.trackingCode!.isNotEmpty) _detailRow('کد پیگیری', entry.trackingCode!),
              _detailRow('مانده نهایی', '${formatAmount(balanceAfter.abs())} تومان'),
              _detailRow('تاریخ', _formatJalali(entry.date)),
              _detailRow('ساعت', _formatTime(entry.date)),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B3FBE), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('ویرایش فاکتور', style: TextStyle(fontWeight: FontWeight.w700)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: descController, decoration: InputDecoration(labelText: 'شرح', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 12),
                  TextField(controller: debitController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'پرداختی (تومان)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 12),
                  TextField(controller: creditController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'دریافتی (تومان)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final picked = await showPersianDatePicker(
                        context: dialogContext,
                        initialDate: Jalali.fromDateTime(selectedDate),
                        firstDate: Jalali(1390, 1),
                        lastDate: Jalali(1420, 12, 29),
                      );
                      if (picked != null) setState(() => selectedDate = picked.toDateTime());
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
                    trackingCode: entry.trackingCode,
                  );
                  provider.updateEntry(updated);
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ویرایش شد ✅')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B3FBE), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
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
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
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
                      IconButton(onPressed: () => setState(() { startDate = null; endDate = null; }), icon: const Icon(Icons.clear, color: Colors.red)),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(colors: [Color(0xFF4F6BF5), Color(0xFF2B3FBE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    boxShadow: [BoxShadow(color: const Color(0xFF2B3FBE).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('دریافتی', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 6),
                              Text('${formatAmount(totalCredit)} تومان', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                            ],
                          ),
                          Container(width: 1, height: 30, color: Colors.white24),
                          Column(
                            children: [
                              const Text('پرداختی', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 6),
                              Text('${formatAmount(totalDebit)} تومان', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 24),
                      Text(
                        finalBalance >= 0
                            ? 'در حال حاضر ${widget.personName} به شما ${formatAmount(finalBalance)} تومان بدهکار است'
                            : 'در حال حاضر شما به ${widget.personName} ${formatAmount(finalBalance.abs())} تومان بدهکارید',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                              child: Icon(Icons.receipt_long, size: 50, color: Colors.grey.shade300),
                            ),
                            const SizedBox(height: 18),
                            Text('موردی برای نمایش وجود ندارد', style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
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
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              elevation: 2,
                              shadowColor: Colors.black12,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
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
                                              if (value == 'edit') _showEditDialog(context, provider, entry);
                                              if (value == 'delete') _showDeleteConfirm(context, provider, entry);
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
                                              Text(hasDebit ? formatAmount(entry.debitAmount) : '-', style: const TextStyle(fontSize: 13, color: Color(0xFF2B3FBE), fontWeight: FontWeight.w700)),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              const Text('مانده', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                              Text(
                                                formatAmount(row.balanceAfter.abs()),
                                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: row.balanceAfter >= 0 ? const Color(0xFF11998E) : const Color(0xFFE64A19)),
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
