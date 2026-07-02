import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/payment_model.dart';
import '../models/debt_model.dart';
import '../models/bank_model.dart';
import '../widgets/custom_app_bar.dart';

class SettlementScreen extends StatefulWidget {
  const SettlementScreen({Key? key}) : super(key: key);

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  final searchController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String typeFilter = 'all';

  String _formatJalali(DateTime date) {
    final j = Jalali.fromDateTime(date);
    return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
  }

  Debt? _findDebt(List<Debt> debts, int debtId) {
    try {
      return debts.firstWhere((d) => d.id == debtId);
    } catch (e) {
      return null;
    }
  }

  Bank? _findBank(List<Bank> banks, int? bankId) {
    if (bankId == null) return null;
    try {
      return banks.firstWhere((b) => b.id == bankId);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: Jalali.now(),
      firstDate: Jalali(1390, 1),
      lastDate: Jalali(1420, 12, 29),
    );
    if (picked != null) {
      final gregorian = picked.toDateTime();
      setState(() {
        if (isStart) {
          startDate = gregorian;
        } else {
          endDate = gregorian;
        }
      });
    }
  }

  void _showDetails(BuildContext context, Payment payment, Debt? debt, Bank? bank) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('جزئیات تسویه', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('نام و نام خانوادگی', debt != null ? '${debt.personName} ${debt.personFamily}' : 'نامشخص'),
            _detailRow('مبلغ', '${payment.amount.toStringAsFixed(0)} ریال'),
            _detailRow('تاریخ', _formatJalali(payment.date)),
            _detailRow('نوع', payment.type == PaymentType.debtPayment ? 'پرداختی' : 'دریافتی'),
            _detailRow('بانک', bank != null ? bank.bankName : 'ثبت نشده'),
            if (payment.description.isNotEmpty) _detailRow('یادداشت', payment.description),
            if (debt != null && debt.description.isNotEmpty) _detailRow('بابت', debt.description),
          ],
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
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(title: 'تسویه', context: context),
      body: Consumer3<PaymentProvider, DebtProvider, BankProvider>(
        builder: (context, paymentProvider, debtProvider, bankProvider, _) {
          final combined = paymentProvider.payments.map((p) {
            final debt = _findDebt(debtProvider.debts, p.debtId);
            final bank = _findBank(bankProvider.banks, p.bankId);
            return _PaymentEntry(payment: p, debt: debt, bank: bank);
          }).toList();

          var filtered = combined.where((entry) {
            if (typeFilter == 'debtPayment') return entry.payment.type == PaymentType.debtPayment;
            if (typeFilter == 'receivablePayment') return entry.payment.type == PaymentType.receivablePayment;
            return true;
          }).toList();

          if (startDate != null) {
            filtered = filtered.where((entry) => entry.payment.date.isAfter(startDate!.subtract(const Duration(days: 1)))).toList();
          }
          if (endDate != null) {
            filtered = filtered.where((entry) => entry.payment.date.isBefore(endDate!.add(const Duration(days: 1)))).toList();
          }

          final query = searchController.text.trim();
          if (query.isNotEmpty) {
            filtered = filtered.where((entry) {
              final fullName = entry.debt != null ? '${entry.debt!.personName} ${entry.debt!.personFamily}' : '';
              return fullName.contains(query);
            }).toList();
          }

          filtered.sort((a, b) => b.payment.date.compareTo(a.payment.date));

          final totalPaid = filtered.where((e) => e.payment.type == PaymentType.debtPayment).fold(0.0, (sum, e) => sum + e.payment.amount);
          final totalReceived = filtered.where((e) => e.payment.type == PaymentType.receivablePayment).fold(0.0, (sum, e) => sum + e.payment.amount);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: TextField(
                  controller: searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'جستجوی نام مخاطب...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    isDense: true,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('همه'),
                        selected: typeFilter == 'all',
                        onSelected: (_) => setState(() => typeFilter = 'all'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('پرداختی'),
                        selected: typeFilter == 'debtPayment',
                        selectedColor: Colors.red.shade100,
                        onSelected: (_) => setState(() => typeFilter = 'debtPayment'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('دریافتی'),
                        selected: typeFilter == 'receivablePayment',
                        selectedColor: Colors.green.shade100,
                        onSelected: (_) => setState(() => typeFilter = 'receivablePayment'),
                      ),
                    ),
                  ],
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('مجموع پرداختی', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 6),
                            Text(totalPaid.toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                          ],
                        ),
                        Container(width: 1, height: 30, color: Colors.white24),
                        Column(
                          children: [
                            const Text('مجموع دریافتی', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 6),
                            Text(totalReceived.toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                          ],
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
                          final entry = filtered[index];
                          final payment = entry.payment;
                          final isDebtPayment = payment.type == PaymentType.debtPayment;
                          final fullName = entry.debt != null ? '${entry.debt!.personName} ${entry.debt!.personFamily}' : 'نامشخص';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                onTap: () => _showDetails(context, payment, entry.debt, entry.bank),
                                leading: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: isDebtPayment ? Colors.red.withOpacity(0.15) : Colors.green.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      isDebtPayment ? Icons.arrow_upward : Icons.arrow_downward,
                                      color: isDebtPayment ? Colors.red : Colors.green,
                                    ),
                                  ),
                                ),
                                title: Text(fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                subtitle: Text(_formatJalali(payment.date), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                trailing: Text(
                                  payment.amount.toStringAsFixed(0),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: isDebtPayment ? Colors.red : Colors.green,
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

class _PaymentEntry {
  final Payment payment;
  final Debt? debt;
  final Bank? bank;
  _PaymentEntry({required this.payment, this.debt, this.bank});
}
