import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/debt_model.dart';
import '../models/contact_model.dart';
import '../models/bank_model.dart';
import '../models/transaction_model.dart';
import '../models/product_model.dart';
import '../models/ledger_model.dart';
import '../utils/formatters.dart';
import '../utils/app_colors.dart';

class AddDebtScreen extends StatefulWidget {
  final DebtType type;
  const AddDebtScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  final noteController = TextEditingController();
  final paidNowController = TextEditingController();
  final feeController = TextEditingController();
  final laborFeeController = TextEditingController();
  final trackingCodeController = TextEditingController();
  Contact? selectedContact;
  Product? selectedProduct;
  int? selectedBankId;
  int? selectedCashboxId;
  DateTime selectedDate = DateTime.now();
  String selectedUnit = 'count';
  String? selectedPaymentMethod;
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

  String _formatDateToJalali(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final picked = await showPersianDatePicker(context: context, initialDate: Jalali.fromDateTime(selectedDate), firstDate: Jalali(1390, 1), lastDate: Jalali(1420, 12, 29));
    if (picked != null) setState(() => selectedDate = picked.toDateTime());
  }

  Future<void> _pickContact() async {
    final contactProvider = context.read<ContactProvider>();
    final searchController = TextEditingController();

    final result = await showDialog<Contact>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final query = searchController.text.trim().toLowerCase();
            final filtered = contactProvider.contacts.where((c) => c.fullName.toLowerCase().contains(query)).toList();

            return AlertDialog(
              backgroundColor: AppColors.card(dialogContext),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('انتخاب مخاطب', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(dialogContext), fontFamily: _fontFamily)),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      onChanged: (_) => setDialogState(() {}),
                      style: TextStyle(color: AppColors.text(dialogContext), fontFamily: _fontFamily),
                      decoration: InputDecoration(hintText: 'جستجو...', hintStyle: const TextStyle(fontFamily: _fontFamily), prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(child: Text('مخاطبی یافت نشد', style: TextStyle(color: AppColors.textSecondary(dialogContext), fontWeight: FontWeight.w600, fontFamily: _fontFamily)))
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final contact = filtered[index];
                                return ListTile(
                                  title: Text(contact.fullName, style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily)),
                                  onTap: () => Navigator.pop(dialogContext, contact),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) setState(() => selectedContact = result);
  }

  Future<void> _pickProduct() async {
    final productProvider = context.read<ProductProvider>();
    final searchController = TextEditingController();

    final result = await showDialog<Product>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final query = searchController.text.trim().toLowerCase();
            final filtered = productProvider.products.where((p) => p.name.toLowerCase().contains(query)).toList();
            final exactMatch = productProvider.products.any((p) => p.name.toLowerCase() == query);

            return AlertDialog(
              backgroundColor: AppColors.card(dialogContext),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('انتخاب محصول', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(dialogContext), fontFamily: _fontFamily)),
              content: SizedBox(
                width: double.maxFinite,
                height: 350,
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      onChanged: (_) => setDialogState(() {}),
                      style: TextStyle(color: AppColors.text(dialogContext), fontFamily: _fontFamily),
                      decoration: InputDecoration(hintText: 'جستجو یا نام محصول جدید...', hintStyle: const TextStyle(fontFamily: _fontFamily), prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(child: Text('محصولی یافت نشد', style: TextStyle(color: AppColors.textSecondary(dialogContext), fontWeight: FontWeight.w600, fontFamily: _fontFamily)))
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final product = filtered[index];
                                final stock = productProvider.getStock(product.id!);
                                return ListTile(
                                  title: Text(product.name, style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily)),
                                  trailing: Text(stock > 0 ? '${stock.toStringAsFixed(0)}' : 'موجود نیست', style: TextStyle(color: stock > 0 ? Colors.green : Colors.red, fontWeight: FontWeight.w600, fontFamily: _fontFamily)),
                                  onTap: () => Navigator.pop(dialogContext, product),
                                );
                              },
                            ),
                    ),
                    if (query.isNotEmpty && !exactMatch) ...[
                      const Divider(),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(colors: [Color(0xFF4F6BF5), Color(0xFF2B3FBE)])),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final newProduct = await productProvider.getOrCreateProduct(searchController.text.trim());
                              if (dialogContext.mounted) Navigator.pop(dialogContext, newProduct);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Text('+ ایجاد محصول «${searchController.text.trim()}»', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13, fontFamily: _fontFamily)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) setState(() => selectedProduct = result);
  }

  Future<void> _pickBank() async {
    final bankProvider = context.read<BankProvider>();
    final banks = bankProvider.banks.where((b) => b.accountNumber != 'صندوق').toList();
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card(dialogContext),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('انتخاب بانک', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(dialogContext), fontFamily: _fontFamily)),
        content: SizedBox(
          width: double.maxFinite,
          height: 250,
          child: banks.isEmpty
              ? Center(child: Text('بانکی موجود نیست', style: TextStyle(color: AppColors.textSecondary(dialogContext), fontFamily: _fontFamily)))
              : ListView.builder(
                  itemCount: banks.length,
                  itemBuilder: (context, index) {
                    final bank = banks[index];
                    return ListTile(
                      title: Text(bank.bankName, style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily)),
                      subtitle: Text('${formatAmount(bank.balance)} تومان', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12, fontFamily: _fontFamily)),
                      onTap: () => Navigator.pop(dialogContext, bank.id),
                    );
                  },
                ),
        ),
      ),
    );

    if (result != null) setState(() => selectedBankId = result);
  }

  Future<void> _pickCashbox() async {
    final bankProvider = context.read<BankProvider>();
    final cashboxes = bankProvider.banks.where((b) => b.accountNumber == 'صندوق').toList();
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card(dialogContext),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('انتخاب صندوق', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(dialogContext), fontFamily: _fontFamily)),
        content: SizedBox(
          width: double.maxFinite,
          height: 250,
          child: cashboxes.isEmpty
              ? Center(child: Text('صندوقی موجود نیست', style: TextStyle(color: AppColors.textSecondary(dialogContext), fontFamily: _fontFamily)))
              : ListView.builder(
                  itemCount: cashboxes.length,
                  itemBuilder: (context, index) {
                    final cashbox = cashboxes[index];
                    return ListTile(
                      title: Text(cashbox.bankName, style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily)),
                      subtitle: Text('${formatAmount(cashbox.cashBox)} تومان', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12, fontFamily: _fontFamily)),
                      onTap: () => Navigator.pop(dialogContext, cashbox.id),
                    );
                  },
                ),
        ),
      ),
    );

    if (result != null) setState(() => selectedCashboxId = result);
  }

  @override
  Widget build(BuildContext context) {
    final isPurchase = widget.type == DebtType.owed;
    final gradient = isPurchase ? const [Color(0xFFFF7A59), Color(0xFFE64A19)] : const [Color(0xFF11998E), Color(0xFF38EF7D)];
    final price = double.tryParse(priceController.text) ?? 0;
    final quantity = double.tryParse(quantityController.text) ?? 0;
    final showLaborFee = selectedUnit == 'ml' && !isPurchase;
    final laborFee = showLaborFee ? (double.tryParse(laborFeeController.text) ?? 0.0) : 0.0;
    final baseAmount = quantity * price;
    final totalAmount = baseAmount + laborFee;
    final paidLabel = isPurchase ? 'مبلغ پرداختی (تومان)' : 'مبلغ دریافتی (تومان)';
    final paidNow = double.tryParse(paidNowController.text) ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: Text(isPurchase ? 'ثبت خرید' : 'ثبت فروش', style: const TextStyle(fontFamily: _fontFamily))),
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
                  Icon(isPurchase ? Icons.shopping_cart : Icons.sell, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(isPurchase ? 'خرید محصول' : 'فروش محصول', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600, fontFamily: _fontFamily))),
                ],
              ),
            ),
            const SizedBox(height: 20),

            InkWell(
              onTap: _pickContact,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: selectedContact == null ? AppColors.divider(context) : gradient[1], width: 2)),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: LinearGradient(colors: gradient), shape: BoxShape.circle), child: const Icon(Icons.person, color: Colors.white, size: 18)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(selectedContact?.fullName ?? 'انتخاب مخاطب *', style: TextStyle(color: selectedContact != null ? AppColors.text(context) : AppColors.textMuted(context), fontWeight: FontWeight.w600, fontFamily: _fontFamily))),
                    Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary(context)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            InkWell(
              onTap: _pickProduct,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: selectedProduct == null ? AppColors.divider(context) : gradient[1], width: 2)),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: LinearGradient(colors: gradient), shape: BoxShape.circle), child: const Icon(Icons.shopping_bag, color: Colors.white, size: 18)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(selectedProduct?.name ?? 'انتخاب محصول *', style: TextStyle(color: selectedProduct != null ? AppColors.text(context) : AppColors.textMuted(context), fontWeight: FontWeight.w600, fontFamily: _fontFamily))),
                    Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary(context)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _UnitButton(label: 'عدد', selected: selectedUnit == 'count', gradient: gradient, onTap: () => setState(() => selectedUnit = 'count')),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _UnitButton(label: 'میل', selected: selectedUnit == 'ml', gradient: gradient, onTap: () => setState(() => selectedUnit = 'ml')),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${selectedUnit == 'ml' ? 'میل' : 'تعداد'} *', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: _fontFamily)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.card(context),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.all(12),
                          hintText: '0',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('قیمت واحد (تومان) *', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: _fontFamily)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.card(context),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.all(12),
                          hintText: '0',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(12)),
                    child: Center(
                      child: Text('مبلغ کل: ${formatAmount(totalAmount)} تومان', style: TextStyle(color: gradient[1], fontSize: 12, fontWeight: FontWeight.w700, fontFamily: _fontFamily)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(12)),
                    child: Center(
                      child: Text('مبلغ: ${formatAmount(price)} تومان', style: TextStyle(color: gradient[1], fontSize: 12, fontWeight: FontWeight.w700, fontFamily: _fontFamily)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (showLaborFee) ...[
              TextField(
                controller: laborFeeController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                decoration: _decoration(context, 'کارمزد'),
              ),
              const SizedBox(height: 16),
              if (laborFee > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Text('${formatAmount(laborFee)} تومان', style: TextStyle(color: gradient[1], fontSize: 12, fontWeight: FontWeight.w700, fontFamily: _fontFamily)),
                  ),
                ),
              const SizedBox(height: 16),
            ],

            TextField(
              controller: noteController,
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
                        Icon(Icons.calendar_today, size: 16, color: gradient[1]),
                        const SizedBox(width: 8),
                        Text(_formatDateToJalali(selectedDate), style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text(context), fontFamily: _fontFamily)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: selectedPaymentMethod == 'cash' ? LinearGradient(colors: gradient) : null,
                      color: selectedPaymentMethod != 'cash' ? AppColors.card(context) : null,
                      border: selectedPaymentMethod != 'cash' ? Border.all(color: AppColors.divider(context), width: 2) : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() => selectedPaymentMethod = 'cash'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text('نقدی', style: TextStyle(color: selectedPaymentMethod == 'cash' ? Colors.white : AppColors.textSecondary(context), fontWeight: FontWeight.w700, fontFamily: _fontFamily)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: selectedPaymentMethod == 'card' ? LinearGradient(colors: gradient) : null,
                      color: selectedPaymentMethod != 'card' ? AppColors.card(context) : null,
                      border: selectedPaymentMethod != 'card' ? Border.all(color: AppColors.divider(context), width: 2) : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() => selectedPaymentMethod = 'card'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text('کارت', style: TextStyle(color: selectedPaymentMethod == 'card' ? Colors.white : AppColors.textSecondary(context), fontWeight: FontWeight.w700, fontFamily: _fontFamily)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (selectedPaymentMethod == 'cash')
              Column(
                children: [
                  InkWell(
                    onTap: _pickCashbox,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: selectedCashboxId == null ? AppColors.divider(context) : gradient[1], width: 2),
                      ),
                      child: Row(
                        children: [
                          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: LinearGradient(colors: gradient), shape: BoxShape.circle), child: const Icon(Icons.savings_rounded, color: Colors.white, size: 18)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedCashboxId == null ? 'انتخاب صندوق *' : context.read<BankProvider>().banks.firstWhere((b) => b.id == selectedCashboxId, orElse: () => Bank(id: -1, bankName: 'نامشخص', accountNumber: '', balance: 0, cashBox: 0)).bankName,
                              style: TextStyle(color: selectedCashboxId != null ? AppColors.text(context) : AppColors.textMuted(context), fontWeight: FontWeight.w600, fontFamily: _fontFamily),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary(context)),
                        ],
                      ),
                    ),
                  ),
                  if (selectedCashboxId != null) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: paidNowController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                      decoration: _decoration(context, paidLabel),
                    ),
                    if (paidNow > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(color: gradient[0].withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Text('${formatAmount(paidNow)} تومان', style: TextStyle(fontWeight: FontWeight.w700, color: gradient[1], fontFamily: _fontFamily)),
                        ),
                      ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),

            if (selectedPaymentMethod == 'card')
              Column(
                children: [
                  InkWell(
                    onTap: _pickBank,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: selectedBankId == null ? AppColors.divider(context) : gradient[1], width: 2),
                      ),
                      child: Row(
                        children: [
                          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: LinearGradient(colors: gradient), shape: BoxShape.circle), child: const Icon(Icons.account_balance, color: Colors.white, size: 18)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedBankId == null ? 'انتخاب بانک *' : context.read<BankProvider>().banks.firstWhere((b) => b.id == selectedBankId, orElse: () => Bank(id: -1, bankName: 'نامشخص', accountNumber: '', balance: 0, cashBox: 0)).bankName,
                              style: TextStyle(
                                color: selectedBankId != null ? AppColors.text(context) : AppColors.textMuted(context),
                                fontWeight: FontWeight.w600,
                                fontFamily: _fontFamily,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary(context)),
                        ],
                      ),
                    ),
                  ),
                  if (selectedBankId != null) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: paidNowController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                      decoration: _decoration(context, paidLabel),
                    ),
                    if (paidNow > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(color: gradient[0].withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Text('${formatAmount(paidNow)} تومان', style: TextStyle(fontWeight: FontWeight.w700, color: gradient[1], fontFamily: _fontFamily)),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: trackingCodeController,
                      style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                      decoration: _decoration(context, 'کد پیگیری (اختیاری)'),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),

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
                          : Text(widget.type == DebtType.owed ? 'ثبت خرید' : 'ثبت فروش', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, fontFamily: _fontFamily)),
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
    if (selectedContact == null || selectedProduct == null || priceController.text.isEmpty || quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمام فیلدهای الزامی رو پر کن', style: TextStyle(fontFamily: _fontFamily))));
      return;
    }

    final isPurchase = widget.type == DebtType.owed;
    final showLaborFee = selectedUnit == 'ml' && !isPurchase;
    final laborFee = showLaborFee ? (double.tryParse(laborFeeController.text) ?? 0.0) : 0.0;

    final baseAmount = double.tryParse(quantityController.text)! * (double.tryParse(priceController.text) ?? 0);
    final totalAmount = baseAmount + laborFee;
    final paidNow = double.tryParse(paidNowController.text) ?? 0;
    final fee = double.tryParse(feeController.text) ?? 0;

    if (paidNow > totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مبلغ پرداختی نمی‌تواند بیشتر از مبلغ کل باشد', style: TextStyle(fontFamily: _fontFamily))));
      return;
    }
    if (selectedPaymentMethod == 'card' && selectedBankId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('برای پرداخت کارت، انتخاب بانک الزامی است', style: TextStyle(fontFamily: _fontFamily))));
      return;
    }
    if (selectedPaymentMethod == 'cash' && selectedCashboxId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('برای پرداخت نقدی، انتخاب صندوق الزامی است', style: TextStyle(fontFamily: _fontFamily))));
      return;
    }

    setState(() => _isSubmitting = true);

    final productProvider = context.read<ProductProvider>();
    final quantity = double.tryParse(quantityController.text) ?? 0;
    final price = double.tryParse(priceController.text) ?? 0;

    if (isPurchase) {
      await productProvider.recordPurchase(product: selectedProduct!, quantity: quantity, pricePerUnit: price, date: selectedDate, contactName: selectedContact!.fullName);
    } else {
      if (!productProvider.hasEnoughStock(selectedProduct!.id!, quantity)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('موجودی «${selectedProduct!.name}» کافی نیست (موجودی: ${productProvider.getStock(selectedProduct!.id!).toStringAsFixed(0)})', style: const TextStyle(fontFamily: _fontFamily))));
          setState(() => _isSubmitting = false);
        }
        return;
      }
      await productProvider.recordSale(product: selectedProduct!, quantity: quantity, pricePerUnit: price, date: selectedDate, laborFee: laborFee, contactName: selectedContact!.fullName);
    }

    final unitLabel = selectedUnit == 'ml' ? 'میل' : 'عدد';
    final productInfo = noteController.text.isNotEmpty ? '${selectedProduct!.name} (${quantity.toStringAsFixed(0)} $unitLabel) - ${noteController.text}' : '${selectedProduct!.name} (${quantity.toStringAsFixed(0)} $unitLabel)';

    final remainingAmount = totalAmount - paidNow < 0 ? 0.0 : totalAmount - paidNow;

    final ledgerProvider = context.read<LedgerProvider>();
    final ledgerId = await ledgerProvider.addEntry(LedgerEntry(
      id: DateTime.now().millisecondsSinceEpoch,
      personName: selectedContact!.firstName,
      personFamily: selectedContact!.lastName,
      date: selectedDate,
      description: productInfo,
      creditAmount: isPurchase ? remainingAmount : 0,
      debitAmount: isPurchase ? 0 : remainingAmount,
      laborFee: laborFee,
      trackingCode: selectedPaymentMethod == 'card' && trackingCodeController.text.trim().isNotEmpty ? trackingCodeController.text.trim() : null,
    ));

    if (remainingAmount > 0) {
      final debtProvider = context.read<DebtProvider>();
      await debtProvider.addDebt(Debt(
        personName: selectedContact!.firstName,
        personFamily: selectedContact!.lastName,
        totalAmount: remainingAmount,
        description: productInfo,
        date: selectedDate,
        type: isPurchase ? DebtType.owed : DebtType.receivable,
        linkedLedgerId: ledgerId,
      ));
    }

    if (paidNow > 0 && selectedPaymentMethod == 'cash') {
      final bankProvider = context.read<BankProvider>();
      final transProvider = context.read<TransactionProvider>();
      final cashbox = bankProvider.banks.firstWhere((b) => b.id == selectedCashboxId);

      final updatedCashbox = Bank(
        id: cashbox.id,
        bankName: cashbox.bankName,
        accountNumber: cashbox.accountNumber,
        balance: cashbox.balance,
        cashBox: isPurchase ? cashbox.cashBox - paidNow : cashbox.cashBox + paidNow,
      );
      await bankProvider.updateBank(updatedCashbox);

      await transProvider.addTransaction(Transaction(
        id: DateTime.now().millisecondsSinceEpoch,
        title: isPurchase ? 'پرداخت نقدی' : 'دریافت نقدی',
        description: isPurchase ? 'پرداخت نقدی' : 'دریافت نقدی',
        amount: paidNow,
        type: isPurchase ? TransactionType.expense : TransactionType.income,
        category: 'معامله نقدی',
        date: selectedDate,
        contactName: selectedContact!.fullName,
      ));
    }

    if (paidNow > 0 && selectedPaymentMethod == 'card') {
      final bankProvider = context.read<BankProvider>();
      final transProvider = context.read<TransactionProvider>();
      final bank = bankProvider.banks.firstWhere((b) => b.id == selectedBankId);

      final updatedBank = Bank(
        id: bank.id,
        bankName: bank.bankName,
        accountNumber: bank.accountNumber,
        balance: isPurchase ? bank.balance - paidNow - fee : bank.balance + paidNow - fee,
        cashBox: bank.cashBox,
      );
      await bankProvider.updateBank(updatedBank);

      await transProvider.addTransaction(Transaction(
        id: DateTime.now().millisecondsSinceEpoch,
        title: isPurchase ? 'پرداخت به مخاطب' : 'دریافت از مخاطب',
        description: isPurchase ? 'پرداخت کارتی' : 'دریافت کارتی',
        amount: paidNow,
        type: isPurchase ? TransactionType.expense : TransactionType.income,
        category: 'معامله کارتی',
        date: selectedDate,
        contactName: selectedContact!.fullName,
      ));

      if (fee > 0) {
        await transProvider.addTransaction(Transaction(
          id: DateTime.now().millisecondsSinceEpoch + 2,
          title: 'کارمزد تراکنش',
          description: 'کارمزد ${isPurchase ? 'پرداخت به' : 'دریافت از'} ${selectedContact!.fullName}',
          amount: fee,
          type: TransactionType.expense,
          category: 'کارمزد',
          date: selectedDate,
          contactName: selectedContact!.fullName,
        ));
      }
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ثبت شد ✅', style: TextStyle(fontFamily: _fontFamily))));
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    priceController.dispose();
    noteController.dispose();
    paidNowController.dispose();
    feeController.dispose();
    laborFeeController.dispose();
    trackingCodeController.dispose();
    super.dispose();
  }
}

class _UnitButton extends StatelessWidget {
  final String label;
  final bool selected;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _UnitButton({required this.label, required this.selected, required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: selected ? LinearGradient(colors: gradient) : null,
        color: selected ? null : AppColors.card(context),
        boxShadow: selected ? [BoxShadow(color: gradient[1].withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Center(child: Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary(context), fontWeight: FontWeight.w700, fontFamily: 'YekanBakh')))),
        ),
      ),
    );
  }
}
