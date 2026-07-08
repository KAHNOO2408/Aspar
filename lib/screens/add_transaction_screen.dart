import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/transaction_model.dart';
import '../utils/formatters.dart';
import '../utils/app_colors.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  String transactionType = 'درآمد';
  String? selectedCategory;
  List<String> categories = [];
  DateTime selectedDate = DateTime.now();
  bool _isSubmitting = false;

  static const _fontFamily = 'YekanBakh';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final prefs = await _getSharedPreferences();
    setState(() {
      categories = prefs.getStringList('categories_$transactionType') ?? [];
    });
  }

  Future<dynamic> _getSharedPreferences() async {
    // این میتونه SharedPreferences یا Hive باشه
    // برای حالا فقط list رو return می‌کنم
    return {'getStringList': (key) => [] as List<String>?};
  }

  InputDecoration _decoration(BuildContext context, String label) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary(context), fontFamily: _fontFamily),
        filled: true,
        fillColor: AppColors.card(context),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(14),
      );

  String _formatDateToJalali(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final picked = await showPersianDatePicker(context: context, initialDate: Jalali.fromDateTime(selectedDate), firstDate: Jalali(1390, 1), lastDate: Jalali(1420, 12, 29));
    if (picked != null) setState(() => selectedDate = picked.toDateTime());
  }

  void _showAddCategoryDialog() {
    final newCategoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('دسته‌بندی جدید', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context), fontFamily: _fontFamily)),
        content: TextField(
          controller: newCategoryController,
          style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
          decoration: InputDecoration(labelText: 'نام دسته‌بندی', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.all(14)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف', style: TextStyle(fontFamily: _fontFamily))),
          ElevatedButton(
            onPressed: () {
              if (newCategoryController.text.isNotEmpty) {
                setState(() {
                  categories.add(newCategoryController.text);
                  selectedCategory = newCategoryController.text;
                  categories = categories.toSet().toList(); // Remove duplicates
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F6BF5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('اضافه کن', style: TextStyle(color: Colors.white, fontFamily: _fontFamily)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(amountController.text) ?? 0;
    final isIncome = transactionType == 'درآمد';
    final gradient = isIncome ? const [Color(0xFF11998E), Color(0xFF38EF7D)] : const [Color(0xFFFF7A59), Color(0xFFE64A19)];

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('تراکنش جدید', style: TextStyle(fontFamily: _fontFamily))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(gradient: LinearGradient(colors: gradient), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Icon(isIncome ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(isIncome ? 'درآمد' : 'خرج', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600, fontFamily: _fontFamily))),
                  Segmented(
                    options: const ['درآمد', 'خرج'],
                    selected: transactionType,
                    onOptionSelected: (value) => setState(() => transactionType = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Category dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider(context))),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedCategory,
                      hint: Text('دسته‌بندی *', style: TextStyle(color: AppColors.textMuted(context), fontFamily: _fontFamily)),
                      underline: const SizedBox(),
                      items: [
                        ...categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily)))),
                      ],
                      onChanged: (value) => setState(() => selectedCategory = value),
                      style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                      dropdownColor: AppColors.card(context),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFF4F6BF5)),
                    onPressed: _showAddCategoryDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
              decoration: _decoration(context, 'مبلغ (تومان) *'),
            ),
            if (amount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: gradient[0].withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('${formatAmount(amount)} تومان', style: TextStyle(fontWeight: FontWeight.w700, color: gradient[1], fontFamily: _fontFamily)),
                ),
              ),
            const SizedBox(height: 16),

            TextField(
              controller: descriptionController,
              style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
              decoration: _decoration(context, 'توضیح (اختیاری)'),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14)),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _pickDate,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFF4F6BF5)),
                        const SizedBox(width: 8),
                        Text(_formatDateToJalali(selectedDate), style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text(context), fontFamily: _fontFamily)),
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
                gradient: LinearGradient(colors: gradient),
                boxShadow: [BoxShadow(color: gradient[1].withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 7))],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _isSubmitting ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: _isSubmitting
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Text('ثبت ${transactionType == 'درآمد' ? 'درآمد' : 'خرج'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, fontFamily: _fontFamily)),
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

  void _submit() async {
    if (selectedCategory == null || amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('دسته‌بندی و مبلغ الزامی هستند', style: TextStyle(fontFamily: _fontFamily))));
      return;
    }

    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مبلغ باید بزرگتر از صفر باشد', style: TextStyle(fontFamily: _fontFamily))));
      return;
    }

    setState(() => _isSubmitting = true);

    final transProvider = context.read<TransactionProvider>();

    await transProvider.addTransaction(Transaction(
      id: DateTime.now().millisecondsSinceEpoch,
      title: selectedCategory ?? 'تراکنش',
      description: descriptionController.text,
      amount: amount,
      type: transactionType == 'درآمد' ? TransactionType.income : TransactionType.expense,
      category: selectedCategory ?? 'عمومی',
      date: selectedDate,
      contactName: '',
    ));

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تراکنش ثبت شد ✅', style: TextStyle(fontFamily: _fontFamily'))));
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}

class Segmented extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onOptionSelected;

  const Segmented({required this.options, required this.selected, required this.onOptionSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: options.map((option) {
        final isSelected = option == selected;
        return GestureDetector(
          onTap: () => onOptionSelected(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(option, style: TextStyle(color: Colors.white, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, fontSize: 11, fontFamily: 'YekanBakh')),
          ),
        );
      }).toList(),
    );
  }
}
