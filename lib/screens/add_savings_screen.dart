import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/savings_model.dart';
import '../utils/formatters.dart';
import '../utils/app_colors.dart';

class AddSavingsScreen extends StatefulWidget {
  const AddSavingsScreen({Key? key}) : super(key: key);

  @override
  State<AddSavingsScreen> createState() => _AddSavingsScreenState();
}

class _AddSavingsScreenState extends State<AddSavingsScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final targetAmountController = TextEditingController();
  final currentAmountController = TextEditingController();
  DateTime? selectedTargetDate;
  bool _isSubmitting = false;

  static const _fontFamily = 'YekanBakh';

  InputDecoration _decoration(BuildContext context, String label) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary(context), fontFamily: _fontFamily),
        hintStyle: TextStyle(color: AppColors.textMuted(context), fontFamily: _fontFamily),
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

  Future<void> _pickTargetDate() async {
    final picked = await showPersianDatePicker(context: context, initialDate: Jalali.now(), firstDate: Jalali(1390, 1), lastDate: Jalali(1420, 12, 29));
    if (picked != null) setState(() => selectedTargetDate = picked.toDateTime());
  }

  @override
  Widget build(BuildContext context) {
    final targetAmount = double.tryParse(targetAmountController.text) ?? 0;
    final currentAmount = double.tryParse(currentAmountController.text) ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('اضافه کردن هدف پس انداز')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
              decoration: _decoration(context, 'عنوان پس انداز *'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 2,
              style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
              decoration: _decoration(context, 'توضیح (اختیاری)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: targetAmountController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
              decoration: _decoration(context, 'هدف پس انداز (تومان) *'),
            ),
            if (targetAmount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFF9B6DFF).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('${formatAmount(targetAmount)} تومان', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6A3DE8))),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: currentAmountController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
              decoration: _decoration(context, 'مبلغ شروع (اختیاری)'),
            ),
            if (currentAmount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFF9B6DFF).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('${formatAmount(currentAmount)} تومان', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6A3DE8))),
                ),
              ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14)),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _pickTargetDate,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFF6A3DE8)),
                        const SizedBox(width: 8),
                        Text(
                          selectedTargetDate == null ? 'انتخاب تاریخ هدف (اختیاری)' : _formatDateToJalali(selectedTargetDate),
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text(context)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
                  onTap: _isSubmitting ? null : _addGoal,
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

  void _addGoal() async {
    if (_isSubmitting) return;
    if (titleController.text.isEmpty || targetAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('عنوان و هدف پس انداز الزامی هستند')));
      return;
    }

    final targetAmount = double.tryParse(targetAmountController.text) ?? 0;
    final currentAmount = double.tryParse(currentAmountController.text) ?? 0;

    if (targetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('هدف باید بزرگتر از صفر باشد')));
      return;
    }

    if (currentAmount > targetAmount) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مبلغ شروع نمی‌تواند بیشتر از هدف باشد')));
      return;
    }

    setState(() => _isSubmitting = true);

    final goal = SavingsGoal(
      title: titleController.text,
      description: descriptionController.text,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      createdDate: DateTime.now(),
      targetDate: selectedTargetDate,
    );

    await context.read<SavingsProvider>().addSavingsGoal(goal);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('هدف اضافه شد ✅')));
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    targetAmountController.dispose();
    currentAmountController.dispose();
    super.dispose();
  }
}
