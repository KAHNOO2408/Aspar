import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/loan_model.dart';
import '../utils/formatters.dart';
import '../utils/app_colors.dart';

class AddLoanScreen extends StatefulWidget {
  const AddLoanScreen({Key? key}) : super(key: key);

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  final bankNameController = TextEditingController();
  final principalController = TextEditingController();
  final monthsController = TextEditingController();
  final interestPercentController = TextEditingController();
  final paidInstallmentsController = TextEditingController();
  final descriptionController = TextEditingController();

  DateTime? selectedStartDate;
  bool _isSubmitting = false;

  static const _fontFamily = 'YekanBakh';

  InputDecoration _decoration(BuildContext context, String label, IconData icon) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary(context), fontFamily: _fontFamily),
        hintStyle: TextStyle(color: AppColors.textMuted(context), fontFamily: _fontFamily),
        prefixIcon: Icon(icon, color: const Color(0xFF9B6DFF)),
        filled: true,
        fillColor: AppColors.card(context),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(14),
      );

  String _formatDateToJalali(DateTime? date) {
    if (date == null) return '';
    final jalali = Jalali.fromDateTime(date);
    return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickStartDate() async {
    final picked = await showPersianDatePicker(context: context, initialDate: Jalali.now(), firstDate: Jalali(1390, 1), lastDate: Jalali(1420, 12, 29));
    if (picked != null) setState(() => selectedStartDate = picked.toDateTime());
  }

  double get _principal => double.tryParse(principalController.text) ?? 0;
  int get _months => int.tryParse(monthsController.text) ?? 0;
  double get _percent => double.tryParse(interestPercentController.text) ?? 0;
  double get _totalPayable => _principal + (_principal * _percent / 100);
  double get _computedMonthlyPayment => _months > 0 ? _totalPayable / _months : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('اضافه کردن وام')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: bankNameController, style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily), decoration: _decoration(context, 'نام وام/بانک *', Icons.account_balance)),
            const SizedBox(height: 16),
            TextField(controller: principalController, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily), decoration: _decoration(context, 'اصل مبلغ وام (تومان) *', Icons.payments_outlined)),
            const SizedBox(height: 16),
            TextField(controller: monthsController, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily), decoration: _decoration(context, 'تعداد ماه وام *', Icons.calendar_view_month)),
            const SizedBox(height: 16),
            TextField(controller: interestPercentController, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily), decoration: _decoration(context, 'درصد سود (اختیاری - اگه سود نداره خالی بذار)', Icons.percent)),
            const SizedBox(height: 12),

            if (_principal > 0 && _months > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF9B6DFF).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('مبلغ کل قابل بازپرداخت: ${formatAmount(_totalPayable)} تومان', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6A3DE8))),
                    const SizedBox(height: 6),
                    Text('قسط ماهیانه (محاسبه‌شده): ${formatAmount(_computedMonthlyPayment)} تومان', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF6A3DE8), fontSize: 15)),
                  ],
                ),
              ),

            const SizedBox(height: 16),
            _DateButton(icon: Icons.calendar_today, label: selectedStartDate == null ? 'انتخاب تاریخ شروع *' : _formatDateToJalali(selectedStartDate), onTap: _pickStartDate),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF9B6DFF).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(
                'اگه از قبل چند قسط این وام رو پرداخت کردی (مثلاً وامی که چند ماهه دستته)، تعدادشون رو اینجا بنویس تا مانده و ماه‌های باقی درست محاسبه بشه.',
                style: TextStyle(fontSize: 12, color: AppColors.text(context), fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            TextField(controller: paidInstallmentsController, keyboardType: TextInputType.number, style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily), decoration: _decoration(context, 'تعداد قسط‌های پرداخت‌شده تاکنون (اختیاری)', Icons.check_circle_outline)),

            const SizedBox(height: 16),
            TextField(controller: descriptionController, maxLines: 2, style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily), decoration: _decoration(context, 'توضیح', Icons.description_outlined)),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(colors: [Color(0xFF9B6DFF), Color(0xFF6A3DE8)]),
                boxShadow: [BoxShadow(color: const Color(0xFF6A3DE8).withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 7))],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _isSubmitting ? null : _addLoan,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: _isSubmitting
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Text('اضافه کن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addLoan() async {
    if (_isSubmitting) return;
    if (bankNameController.text.isEmpty || principalController.text.isEmpty || monthsController.text.isEmpty || selectedStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('نام وام، اصل مبلغ، تعداد ماه و تاریخ شروع الزامی هستند!')));
      return;
    }

    final principal = _principal;
    final months = _months;
    if (principal <= 0 || months <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اصل مبلغ و تعداد ماه باید بزرگتر از صفر باشند')));
      return;
    }

    final totalPayable = _totalPayable;
    final monthlyPayment = _computedMonthlyPayment;
    final paidInstallmentsCount = int.tryParse(paidInstallmentsController.text) ?? 0;

    if (paidInstallmentsCount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعداد قسط‌های پرداخت‌شده نمی‌تواند منفی باشد')));
      return;
    }

    final initialPaidAmount = paidInstallmentsCount * monthlyPayment;
    if (initialPaidAmount > totalPayable) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مبلغ اقساط پرداخت‌شده نمی‌تواند بیشتر از مبلغ کل وام باشد')));
      return;
    }

    setState(() => _isSubmitting = true);

    final endDate = DateTime(selectedStartDate!.year, selectedStartDate!.month + months, selectedStartDate!.day);

    final loan = Loan(
      bankName: bankNameController.text,
      totalAmount: totalPayable,
      principalAmount: principal,
      interestPercent: _percent,
      monthlyPayment: monthlyPayment,
      months: months,
      startDate: selectedStartDate!,
      endDate: endDate,
      bankId: 0,
      description: descriptionController.text,
      paidAmount: initialPaidAmount,
    );

    await context.read<LoanProvider>().addLoan(loan);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('وام اضافه شد ✅')));
    }
  }

  @override
  void dispose() {
    bankNameController.dispose();
    principalController.dispose();
    monthsController.dispose();
    interestPercentController.dispose();
    paidInstallmentsController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}

class _DateButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DateButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: const Color(0xFF6A3DE8)),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text(context))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
