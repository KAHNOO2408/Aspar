import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/bank_model.dart';
import '../models/transaction_model.dart';
import '../utils/formatters.dart';
import '../utils/app_colors.dart';

class BankLedgerScreen extends StatefulWidget {
  final Bank bank;
  const BankLedgerScreen({Key? key, required this.bank}) : super(key: key);

  @override
  State<BankLedgerScreen> createState() => _BankLedgerScreenState();
}

class _BankLedgerScreenState extends State<BankLedgerScreen> {
  final searchController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  String _formatJalali(DateTime date) {
    final j = Jalali.fromDateTime(date);
    return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showPersianDatePicker(context: context, initialDate: Jalali.now(), firstDate: Jalali(1390, 1), lastDate: Jalali(1420, 12, 29));
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

  void _showDetails(BuildContext context, Transaction tx) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('جزئیات تراکنش', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(context, 'عنوان', tx.title),
              if (tx.description.isNotEmpty) _detailRow(context, 'توضیح', tx.description),
              if (tx.contactName != null && tx.contactName!.isNotEmpty) _detailRow(context, 'مخاطب', tx.contactName!),
              _detailRow(context, 'دسته', tx.category),
              _detailRow(context, 'نوع', tx.type == TransactionType.income ? 'واریز' : 'برداشت'),
              _detailRow(context, 'مبلغ', '${formatAmount(tx.amount)} تومان'),
              _detailRow(context, 'تاریخ', _formatJalali(tx.date)),
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

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary(context)))),
          Expanded(child: Text(value, style: TextStyle(color: AppColors.text(context)))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCashbox = widget.bank.accountNumber == 'صندوق';

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: Text('گردش حساب ${widget.bank.bankName}')),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          final allTx = provider.transactions.where((t) => t.bankId == widget.bank.id).toList()..sort((a, b) => a.date.compareTo(b.date));

          double running = 0;
          final withBalance = allTx.map((t) {
            running += t.type == TransactionType.income ? t.amount : -t.amount;
            return _TxRow(tx: t, balanceAfter: running);
          }).toList();

          var filtered = withBalance;
          final query = searchController.text.trim();
          if (query.isNotEmpty) {
            filtered = filtered.where((row) => row.tx.title.contains(query) || row.tx.description.contains(query) || (row.tx.contactName ?? '').contains(query)).toList();
          }
          if (startDate != null) {
            filtered = filtered.where((row) => row.tx.date.isAfter(startDate!.subtract(const Duration(days: 1)))).toList();
          }
          if (endDate != null) {
            filtered = filtered.where((row) => row.tx.date.isBefore(endDate!.add(const Duration(days: 1)))).toList();
          }

          final totalIncome = filtered.fold(0.0, (sum, r) => sum + (r.tx.type == TransactionType.income ? r.tx.amount : 0));
          final totalExpense = filtered.fold(0.0, (sum, r) => sum + (r.tx.type == TransactionType.expense ? r.tx.amount : 0));
          final currentBalance = isCashbox ? widget.bank.cashBox : widget.bank.balance;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: TextField(
                  controller: searchController,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(color: AppColors.text(context)),
                  decoration: InputDecoration(
                    hintText: 'جستجو...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.card(context),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    isDense: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Expanded(child: OutlinedButton.icon(onPressed: () => _pickDate(true), icon: const Icon(Icons.calendar_today, size: 16), label: Text(startDate != null ? 'از: ${_formatJalali(startDate!)}' : 'از تاریخ'))),
                    const SizedBox(width: 10),
                    Expanded(child: OutlinedButton.icon(onPressed: () => _pickDate(false), icon: const Icon(Icons.calendar_today, size: 16), label: Text(endDate != null ? 'تا: ${_formatJalali(endDate!)}' : 'تا تاریخ'))),
                    if (startDate != null || endDate != null) IconButton(onPressed: () => setState(() { startDate = null; endDate = null; }), icon: const Icon(Icons.clear, color: Colors.red)),
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
                          Column(children: [const Text('واریز', style: TextStyle(color: Colors.white70, fontSize: 12)), const SizedBox(height: 6), Text('${formatAmount(totalIncome)} تومان', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800))]),
                          Container(width: 1, height: 30, color: Colors.white24),
                          Column(children: [const Text('برداشت', style: TextStyle(color: Colors.white70, fontSize: 12)), const SizedBox(height: 6), Text('${formatAmount(totalExpense)} تومان', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800))]),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 24),
                      Text('موجودی فعلی: ${formatAmount(currentBalance)} تومان', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13), textAlign: TextAlign.center),
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
                            Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.card(context), shape: BoxShape.circle), child: Icon(Icons.receipt_long, size: 50, color: AppColors.textMuted(context))),
                            const SizedBox(height: 18),
                            Text('تراکنشی ثبت نشده', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 15)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final row = filtered[filtered.length - 1 - index];
                          final tx = row.tx;
                          final isIncome = tx.type == TransactionType.income;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Material(
                              color: AppColors.card(context),
                              borderRadius: BorderRadius.circular(16),
                              elevation: 2,
                              shadowColor: Colors.black12,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _showDetails(context, tx),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(color: (isIncome ? Colors.green : Colors.red).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                                        child: Icon(isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: isIncome ? Colors.green : Colors.red, size: 18),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(tx.title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.text(context))),
                                            if (tx.contactName != null && tx.contactName!.isNotEmpty) Text(tx.contactName!, style: TextStyle(fontSize: 11, color: AppColors.textSecondary(context))),
                                            Text(_formatJalali(tx.date), style: TextStyle(fontSize: 10, color: AppColors.textMuted(context))),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('${isIncome ? '+' : '-'}${formatAmount(tx.amount)}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isIncome ? Colors.green : Colors.red)),
                                          Text('مانده: ${formatAmount(row.balanceAfter)}', style: TextStyle(fontSize: 10, color: AppColors.textMuted(context))),
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

class _TxRow {
  final Transaction tx;
  final double balanceAfter;
  _TxRow({required this.tx, required this.balanceAfter});
}
