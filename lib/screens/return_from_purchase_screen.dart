import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/contact_model.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';
import '../models/bank_model.dart';
import '../models/ledger_model.dart';
import '../models/debt_model.dart';
import '../utils/formatters.dart';
import '../utils/app_colors.dart';

class ReturnFromPurchaseScreen extends StatefulWidget {
  const ReturnFromPurchaseScreen({Key? key}) : super(key: key);

  @override
  State<ReturnFromPurchaseScreen> createState() => _ReturnFromPurchaseScreenState();
}

class _ReturnFromPurchaseScreenState extends State<ReturnFromPurchaseScreen> {
  final quantityController = TextEditingController();
  final noteController = TextEditingController();
  Contact? selectedContact;
  Product? selectedProduct;
  ProductTransaction? selectedPurchase;
  int? selectedBankId;
  int? selectedCashboxId;
  String? selectedPaymentMethod;
  DateTime selectedDate = DateTime.now();
  bool _isSubmitting = false;

  static const _fontFamily = 'YekanBakh';
  static const List<Color> _gradient = [Color(0xFFE74C3C), Color(0xFFC0392B)];

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

    if (result != null) {
      setState(() {
        selectedContact = result;
        selectedProduct = null;
        selectedPurchase = null;
        quantityController.clear();
      });
    }
  }

  Future<void> _pickProduct() async {
    if (selectedContact == null) return;
    final productProvider = context.read<ProductProvider>();
    final contactFullName = selectedContact!.fullName;

    final purchasedProductIds = productProvider.productTransactions
        .where((t) => t.type == ProductTxType.purchase && t.contactName == contactFullName)
        .map((t) => t.productId)
        .toSet();
    final availableProducts = productProvider.products.where((p) => purchasedProductIds.contains(p.id)).toList();

    final searchController = TextEditingController();

    final result = await showDialog<Product>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final query = searchController.text.trim().toLowerCase();
            final filtered = availableProducts.where((p) => p.name.toLowerCase().contains(query)).toList();

            return AlertDialog(
              backgroundColor: AppColors.card(dialogContext),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('انتخاب محصول', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(dialogContext), fontFamily: _fontFamily)),
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
                          ? Center(child: Text('محصولی از این مخاطب خریداری نشده', style: TextStyle(color: AppColors.textSecondary(dialogContext), fontWeight: FontWeight.w600, fontFamily: _fontFamily), textAlign: TextAlign.center))
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final product = filtered[index];
                                return ListTile(
                                  title: Text(product.name, style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily)),
                                  onTap: () => Navigator.pop(dialogContext, product),
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

    if (result != null) {
      setState(() {
        selectedProduct = result;
        selectedPurchase = null;
        quantityController.clear();
      });
      _pickPurchaseTransaction();
    }
  }

  Future<void> _pickPurchaseTransaction() async {
    if (selectedContact == null || selectedProduct == null) return;
    final productProvider = context.read<ProductProvider>();
    final matches = productProvider.productTransactions
        .where((t) => t.type == ProductTxType.purchase && t.contactName == selectedContact!.fullName && t.productId == selectedProduct!.id && t.quantity > 0)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final result = await showDialog<ProductTransaction>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card(dialogContext),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('انتخاب خرید', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(dialogContext), fontFamily: _fontFamily)),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: matches.isEmpty
              ? Center(child: Text('خریدی یافت نشد', style: TextStyle(color: AppColors.textSecondary(dialogContext), fontFamily: _fontFamily)))
              : ListView.builder(
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final t = matches[index];
                    return ListTile(
                      title: Text(_formatDateToJalali(t.date), style: TextStyle(color: AppColors.text(context), fontWeight: FontWeight.w700, fontFamily: _fontFamily)),
                      subtitle: Text('تعداد: ${t.quantity.toStringAsFixed(0)}  •  قیمت واحد: ${formatAmount(t.pricePerUnit)} تومان', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12, fontFamily: _fontFamily)),
                      trailing: Text('${formatAmount(t.totalAmount)} تومان', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFC0392B), fontFamily: _fontFamily)),
                      onTap: () => Navigator.pop(dialogContext, t),
                    );
                  },
                ),
        ),
      ),
    );

    if (result != null) setState(() => selectedPurchase = result);
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
    final quantity = double.tryParse(quantityController.text) ?? 0;
    final unitPrice = selectedPurchase?.pricePerUnit ?? 0;
    final totalReturn = quantity * unitPrice;

    final stock = selectedProduct != null ? context.watch<ProductProvider>().getStock(selectedProduct!.id!) : 0.0;
    final maxReturnable = selectedPurchase != null ? (selectedPurchase!.quantity < stock ? selectedPurchase!.quantity : stock) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('برگشت از خرید', style: TextStyle(fontFamily: _fontFamily))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: _gradient), borderRadius: BorderRadius.circular(16)),
              child: const Row(children: [Icon(Icons.info_outline, color: Colors.white, size: 20), SizedBox(width: 10), Expanded(child: Text('برگشت محصول خریده شده', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600, fontFamily: _fontFamily)))]),
            ),
            const SizedBox(height: 20),

            InkWell(
              onTap: _pickContact,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: selectedContact == null ? AppColors.divider(context) : const Color(0xFFC0392B), width: 2)),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(gradient: LinearGradient(colors: _gradient), shape: BoxShape.circle), child: const Icon(Icons.person, color: Colors.white, size: 18)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(selectedContact?.fullName ?? 'انتخاب مخاطب *', style: TextStyle(color: selectedContact != null ? AppColors.text(context) : AppColors.textMuted(context), fontWeight: FontWeight.w600, fontFamily: _fontFamily))),
                    Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary(context)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            IgnorePointer(
              ignoring: selectedContact == null,
              child: Opacity(
                opacity: selectedContact == null ? 0.5 : 1,
                child: InkWell(
                  onTap: _pickProduct,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: selectedProduct == null ? AppColors.divider(context) : const Color(0xFFC0392B), width: 2)),
                    child: Row(
                      children: [
                        Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(gradient: LinearGradient(colors: _gradient), shape: BoxShape.circle), child: const Icon(Icons.shopping_cart, color: Colors.white, size: 18)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(selectedProduct?.name ?? 'انتخاب محصول *', style: TextStyle(color: selectedProduct != null ? AppColors.text(context) : AppColors.textMuted(context), fontWeight: FontWeight.w600, fontFamily: _fontFamily))),
                        Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary(context)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (selectedProduct != null)
              InkWell(
                onTap: _pickPurchaseTransaction,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: selectedPurchase == null ? AppColors.divider(context) : const Color(0xFFC0392B), width: 2)),
                  child: Row(
                    children: [
                      Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(gradient: LinearGradient(colors: _gradient), shape: BoxShape.circle), child: const Icon(Icons.receipt_long, color: Colors.white, size: 18)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedPurchase == null ? 'انتخاب خرید (تاریخ) *' : '${_formatDateToJalali(selectedPurchase!.date)}  •  ${formatAmount(selectedPurchase!.pricePerUnit)} تومان',
                          style: TextStyle(color: selectedPurchase != null ? AppColors.text(context) : AppColors.textMuted(context), fontWeight: FontWeight.w600, fontFamily: _fontFamily),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary(context)),
                    ],
                  ),
                ),
              ),
            if (selectedProduct != null) const SizedBox(height: 16),

            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
              decoration: _decoration(context, 'تعداد برگشتی *'),
            ),
            if (selectedPurchase != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('حداکثر: ${maxReturnable.toStringAsFixed(0)} عدد (بر اساس موجودی فعلی انبار)', style: TextStyle(fontSize: 11, color: AppColors.textMuted(context), fontFamily: _fontFamily)),
              ),
            const SizedBox(height: 16),

            if (totalReturn > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider(context))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('مبلغ دریافتی', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: _fontFamily)),
                      const SizedBox(height: 8),
                      Text(formatAmount(totalReturn), style: TextStyle(color: AppColors.text(context), fontSize: 18, fontWeight: FontWeight.w800, fontFamily: _fontFamily)),
                      const SizedBox(height: 4),
                      Text('تومان', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 11, fontFamily: _fontFamily)),
                    ],
                  ),
                ),
              ),

            TextField(
              controller: noteController,
              style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
              decoration: _decoration(context, 'یادداشت (اختیاری)'),
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
                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFFC0392B)),
                        const SizedBox(width: 8),
                        Text(_formatDateToJalali(selectedDate), style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text(context), fontFamily: _fontFamily)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text('واریز مبلغ به (اختیاری)', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: _fontFamily)),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: selectedPaymentMethod == 'cash' ? const LinearGradient(colors: _gradient) : null,
                      color: selectedPaymentMethod != 'cash' ? AppColors.card(context) : null,
                      border: selectedPaymentMethod != 'cash' ? Border.all(color: AppColors.divider(context), width: 2) : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() => selectedPaymentMethod = selectedPaymentMethod == 'cash' ? null : 'cash'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: Text('نقدی', style: TextStyle(color: selectedPaymentMethod == 'cash' ? Colors.white : AppColors.textSecondary(context), fontWeight: FontWeight.w700, fontFamily: _fontFamily))),
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
                      gradient: selectedPaymentMethod == 'card' ? const LinearGradient(colors: _gradient) : null,
                      color: selectedPaymentMethod != 'card' ? AppColors.card(context) : null,
                      border: selectedPaymentMethod != 'card' ? Border.all(color: AppColors.divider(context), width: 2) : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() => selectedPaymentMethod = selectedPaymentMethod == 'card' ? null : 'card'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: Text('کارت', style: TextStyle(color: selectedPaymentMethod == 'card' ? Colors.white : AppColors.textSecondary(context), fontWeight: FontWeight.w700, fontFamily: _fontFamily))),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (selectedPaymentMethod == 'cash')
              InkWell(
                onTap: _pickCashbox,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: selectedCashboxId == null ? AppColors.divider(context) : const Color(0xFFC0392B), width: 2)),
                  child: Row(
                    children: [
                      Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(gradient: LinearGradient(colors: _gradient), shape: BoxShape.circle), child: const Icon(Icons.savings_rounded, color: Colors.white, size: 18)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedCashboxId == null ? 'انتخاب صندوق' : context.read<BankProvider>().banks.firstWhere((b) => b.id == selectedCashboxId, orElse: () => Bank(id: -1, bankName: 'نامشخص', accountNumber: '', balance: 0, cashBox: 0)).bankName,
                          style: TextStyle(color: selectedCashboxId != null ? AppColors.text(context) : AppColors.textMuted(context), fontWeight: FontWeight.w600, fontFamily: _fontFamily),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary(context)),
                    ],
                  ),
                ),
              ),

            if (selectedPaymentMethod == 'card')
              InkWell(
                onTap: _pickBank,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: selectedBankId == null ? AppColors.divider(context) : const Color(0xFFC0392B), width: 2)),
                  child: Row(
                    children: [
                      Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(gradient: LinearGradient(colors: _gradient), shape: BoxShape.circle), child: const Icon(Icons.account_balance, color: Colors.white, size: 18)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedBankId == null ? 'انتخاب بانک' : context.read<BankProvider>().banks.firstWhere((b) => b.id == selectedBankId, orElse: () => Bank(id: -1, bankName: 'نامشخص', accountNumber: '', balance: 0, cashBox: 0)).bankName,
                          style: TextStyle(color: selectedBankId != null ? AppColors.text(context) : AppColors.textMuted(context), fontWeight: FontWeight.w600, fontFamily: _fontFamily),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary(context)),
                    ],
                  ),
                ),
              ),
            if (selectedPaymentMethod != null) const SizedBox(height: 16),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(colors: _gradient),
                boxShadow: [BoxShadow(color: const Color(0xFFC0392B).withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 7))],
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
                          : const Text('ثبت برگشت', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, fontFamily: _fontFamily)),
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
    if (selectedContact == null || selectedProduct == null || selectedPurchase == null || quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مخاطب، محصول، خرید و تعداد الزامی هستند', style: TextStyle(fontFamily: _fontFamily))));
      return;
    }

    final quantity = double.tryParse(quantityController.text) ?? 0;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعداد باید بزرگتر از صفر باشد', style: TextStyle(fontFamily: _fontFamily))));
      return;
    }

    final productProvider = context.read<ProductProvider>();
    final stock = productProvider.getStock(selectedProduct!.id!);
    final maxReturnable = selectedPurchase!.quantity < stock ? selectedPurchase!.quantity : stock;

    if (quantity > maxReturnable) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حداکثر ${maxReturnable.toStringAsFixed(0)} عدد قابل برگشت است (موجودی فعلی انبار)', style: const TextStyle(fontFamily: _fontFamily))));
      return;
    }
    if (selectedPaymentMethod == 'card' && selectedBankId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('بانک را انتخاب کنید یا گزینه کارت را غیرفعال کنید', style: TextStyle(fontFamily: _fontFamily))));
      return;
    }
    if (selectedPaymentMethod == 'cash' && selectedCashboxId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('صندوق را انتخاب کنید یا گزینه نقدی را غیرفعال کنید', style: TextStyle(fontFamily: _fontFamily))));
      return;
    }

    setState(() => _isSubmitting = true);

    final totalReturn = quantity * selectedPurchase!.pricePerUnit;
    final returnDescription = 'برگشت ${selectedProduct!.name} (${quantity.toStringAsFixed(0)} عدد)${noteController.text.isNotEmpty ? ' - ${noteController.text}' : ''}';

    // کم کردن موجودی انبار
    await productProvider.reduceStockFifo(selectedProduct!.id!, quantity);

    // اصلاح رکورد خرید اصلی (کم کردن مقدار برگشت‌داده‌شده)
    final newQuantity = selectedPurchase!.quantity - quantity;
    final updatedPurchase = ProductTransaction(
      id: selectedPurchase!.id,
      productId: selectedPurchase!.productId,
      productName: selectedPurchase!.productName,
      quantity: newQuantity,
      pricePerUnit: selectedPurchase!.pricePerUnit,
      totalAmount: newQuantity * selectedPurchase!.pricePerUnit,
      type: ProductTxType.purchase,
      date: selectedPurchase!.date,
      contactName: selectedPurchase!.contactName,
    );
    await productProvider.updateProductTransaction(updatedPurchase);

    // ثبت یه رکورد مستقل برای خودِ برگشت، تا تو تاریخچه‌ی محصول دیده بشه
    await productProvider.recordReturnLog(
      product: selectedProduct!,
      quantity: quantity,
      pricePerUnit: selectedPurchase!.pricePerUnit,
      date: selectedDate,
      type: ProductTxType.returnFromPurchase,
      contactName: selectedContact!.fullName,
    );

    // اگه همون لحظه پول گرفته شده، مبلغ باقی‌مونده صفره؛ اگه نه، کل مبلغ میره تو حساب طرف
    final remainingAmount = selectedPaymentMethod != null ? 0.0 : totalReturn;

    final ledgerProvider = context.read<LedgerProvider>();
    await ledgerProvider.addEntry(LedgerEntry(
      personName: selectedContact!.firstName,
      personFamily: selectedContact!.lastName,
      date: selectedDate,
      description: returnDescription,
      debitAmount: remainingAmount,
      creditAmount: 0,
    ));

    if (remainingAmount > 0) {
      final debtProvider = context.read<DebtProvider>();
      await debtProvider.addDebt(Debt(
        personName: selectedContact!.firstName,
        personFamily: selectedContact!.lastName,
        totalAmount: remainingAmount,
        description: returnDescription,
        date: selectedDate,
        type: DebtType.receivable,
      ));
    }

    if (selectedPaymentMethod != null) {
      final bankProvider = context.read<BankProvider>();
      final transProvider = context.read<TransactionProvider>();

      if (selectedPaymentMethod == 'cash') {
        final cashbox = bankProvider.banks.firstWhere((b) => b.id == selectedCashboxId);
        await bankProvider.updateBank(Bank(id: cashbox.id, bankName: cashbox.bankName, accountNumber: cashbox.accountNumber, balance: cashbox.balance, cashBox: cashbox.cashBox + totalReturn));
      } else {
        final bank = bankProvider.banks.firstWhere((b) => b.id == selectedBankId);
        await bankProvider.updateBank(Bank(id: bank.id, bankName: bank.bankName, accountNumber: bank.accountNumber, balance: bank.balance + totalReturn, cashBox: bank.cashBox));
      }

      await transProvider.addTransaction(Transaction(
        id: DateTime.now().millisecondsSinceEpoch,
        title: 'برگشت از خرید',
        description: returnDescription,
        amount: totalReturn,
        type: TransactionType.income,
        category: 'برگشت از خرید',
        date: selectedDate,
        contactName: selectedContact!.fullName,
      ));
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('برگشت ثبت شد ✅', style: TextStyle(fontFamily: _fontFamily))));
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    noteController.dispose();
    super.dispose();
  }
}
