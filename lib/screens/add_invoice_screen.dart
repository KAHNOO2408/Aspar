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

class _InvoiceItem {
  final Product product;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final double laborFee;
  _InvoiceItem({required this.product, required this.quantity, required this.unit, required this.pricePerUnit, this.laborFee = 0});
  double get baseAmount => quantity * pricePerUnit;
  double get totalAmount => baseAmount + laborFee;
}

class AddInvoiceScreen extends StatefulWidget {
  final DebtType type;
  const AddInvoiceScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  final noteController = TextEditingController();
  final paidNowController = TextEditingController();
  final feeController = TextEditingController();
  final trackingCodeController = TextEditingController();
  Contact? selectedContact;
  int? selectedBankId;
  int? selectedCashboxId;
  DateTime selectedDate = DateTime.now();
  String? selectedPaymentMethod;
  bool _isSubmitting = false;
  final List<_InvoiceItem> items = [];

  static const _fontFamily = 'YekanBakh';

  bool get isPurchase => widget.type == DebtType.owed;
  List<Color> get gradient => isPurchase ? const [Color(0xFFFF7A59), Color(0xFFE64A19)] : const [Color(0xFF11998E), Color(0xFF38EF7D)];

  double get invoiceTotal => items.fold(0.0, (sum, i) => sum + i.totalAmount);

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

  Future<Product?> _pickProductOnly() async {
    final productProvider = context.read<ProductProvider>();
    final searchController = TextEditingController();

    return showDialog<Product>(
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
  }

  Future<void> _addItemFlow() async {
    final product = await _pickProductOnly();
    if (product == null) return;
    if (!mounted) return;

    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final itemLaborFeeController = TextEditingController();
    String unit = 'count';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final quantity = double.tryParse(quantityController.text) ?? 0;
            final price = double.tryParse(priceController.text) ?? 0;
            final showLabor = unit == 'ml' && !isPurchase;
            final labor = showLabor ? (double.tryParse(itemLaborFeeController.text) ?? 0) : 0.0;
            final total = quantity * price + labor;

            return AlertDialog(
              backgroundColor: AppColors.card(dialogContext),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(product.name, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(dialogContext), fontFamily: _fontFamily)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDialogState(() => unit = 'count'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(color: unit == 'count' ? const Color(0xFF4F6BF5) : Colors.grey.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                              child: Center(child: Text('عدد', style: TextStyle(color: unit == 'count' ? Colors.white : AppColors.text(dialogContext), fontFamily: _fontFamily))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDialogState(() => unit = 'ml'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(color: unit == 'ml' ? const Color(0xFF4F6BF5) : Colors.grey.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                              child: Center(child: Text('میل', style: TextStyle(color: unit == 'ml' ? Colors.white : AppColors.text(dialogContext), fontFamily: _fontFamily))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setDialogState(() {}),
                      style: TextStyle(color: AppColors.text(dialogContext), fontFamily: _fontFamily),
                      decoration: InputDecoration(labelText: unit == 'ml' ? 'میل *' : 'تعداد *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setDialogState(() {}),
                      style: TextStyle(color: AppColors.text(dialogContext), fontFamily: _fontFamily),
                      decoration: InputDecoration(labelText: 'قیمت واحد (تومان) *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                    if (showLabor) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: itemLaborFeeController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setDialogState(() {}),
                        style: TextStyle(color: AppColors.text(dialogContext), fontFamily: _fontFamily),
                        decoration: InputDecoration(labelText: 'کارمزد (اختیاری)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ],
                    if (total > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text('مبلغ این قلم: ${formatAmount(total)} تومان', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2B3FBE))),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('انصراف', style: TextStyle(fontFamily: _fontFamily))),
                ElevatedButton(
                  onPressed: () {
                    if (quantity <= 0 || price <= 0) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('تعداد و قیمت الزامی هستند', style: TextStyle(fontFamily: _fontFamily))));
                      return;
                    }
                    setState(() {
                      items.add(_InvoiceItem(product: product, quantity: quantity, unit: unit, pricePerUnit: price, laborFee: labor));
                    });
                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B3FBE), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('افزودن به فاکتور', style: TextStyle(color: Colors.white, fontFamily: _fontFamily)),
                ),
              ],
            );
          },
        );
      },
    );
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
    final paidNow = double.tryParse(paidNowController.text) ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: Text(isPurchase ? 'ثبت فاکتور خرید' : 'ثبت فاکتور فروش', style: const TextStyle(fontFamily: _fontFamily))),
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
                  Expanded(child: Text('چند قلم کالا رو به فاکتور اضافه کن، بعد یه‌جا ثبتشون کن', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600, fontFamily: _fontFamily))),
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
            const SizedBox(height: 20),

            Text('قلم‌های فاکتور', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13, fontWeight: FontWeight.w700, fontFamily: _fontFamily)),
            const SizedBox(height: 10),

            if (items.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider(context))),
                child: Center(child: Text('هنوز کالایی اضافه نکردی', style: TextStyle(color: AppColors.textMuted(context), fontFamily: _fontFamily))),
              )
            else
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider(context))),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.product.name, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context), fontFamily: _fontFamily)),
                              const SizedBox(height: 4),
                              Text('${item.quantity.toStringAsFixed(0)} ${item.unit == 'ml' ? 'میل' : 'عدد'} × ${formatAmount(item.pricePerUnit)}${item.laborFee > 0 ? ' + کارمزد ${formatAmount(item.laborFee)}' : ''}', style: TextStyle(fontSize: 11, color: AppColors.textSecondary(context), fontFamily: _fontFamily)),
                            ],
                          ),
                        ),
                        Text(formatAmount(item.totalAmount), style: TextStyle(fontWeight: FontWeight.w800, color: gradient[1], fontFamily: _fontFamily)),
                        IconButton(icon: const Icon(Icons.close, color: Colors.red, size: 20), onPressed: () => setState(() => items.removeAt(index))),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14)),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: selectedContact == null ? null : _addItemFlow,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, color: selectedContact == null ? AppColors.textMuted(context) : gradient[1]),
                        const SizedBox(width: 8),
                        Text('افزودن قلم کالا', style: TextStyle(fontWeight: FontWeight.w700, color: selectedContact == null ? AppColors.textMuted(context) : gradient[1], fontFamily: _fontFamily)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (items.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: gradient[0].withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('جمع کل فاکتور (${items.length} قلم)', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text(context), fontFamily: _fontFamily)),
                    Text('${formatAmount(invoiceTotal)} تومان', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: gradient[1], fontFamily: _fontFamily)),
                  ],
                ),
              ),
            const SizedBox(height: 16),

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

            Text('${isPurchase ? 'مبلغ پرداختی الان' : 'مبلغ دریافتی الان'} (اختیاری، جدا از قلم‌ها)', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12, fontWeight: FontWeight.w600, fontFamily: _fontFamily)),
            const SizedBox(height: 8),

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
                      gradient: selectedPaymentMethod == 'card' ? LinearGradient(colors: gradient) : null,
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
              Column(
                children: [
                  InkWell(
                    onTap: _pickCashbox,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: selectedCashboxId == null ? AppColors.divider(context) : gradient[1], width: 2)),
                      child: Row(
                        children: [
                          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: LinearGradient(colors: gradient), shape: BoxShape.circle), child: const Icon(Icons.savings_rounded, color: Colors.white, size: 18)),
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: paidNowController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                    decoration: _decoration(context, 'مبلغ'),
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
                      decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: selectedBankId == null ? AppColors.divider(context) : gradient[1], width: 2)),
                      child: Row(
                        children: [
                          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: LinearGradient(colors: gradient), shape: BoxShape.circle), child: const Icon(Icons.account_balance, color: Colors.white, size: 18)),
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: paidNowController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                    decoration: _decoration(context, 'مبلغ'),
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
                          : Text('ثبت فاکتور (${items.length} قلم)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, fontFamily: _fontFamily)),
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
    if (selectedContact == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('انتخاب مخاطب الزامی است', style: TextStyle(fontFamily: _fontFamily))));
      return;
    }
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حداقل یه قلم کالا اضافه کن', style: TextStyle(fontFamily: _fontFamily))));
      return;
    }
    final paidNow = double.tryParse(paidNowController.text) ?? 0;
    final fee = double.tryParse(feeController.text) ?? 0;
    if (selectedPaymentMethod == 'card' && selectedBankId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('برای پرداخت کارت، انتخاب بانک الزامی است', style: TextStyle(fontFamily: _fontFamily))));
      return;
    }
    if (selectedPaymentMethod == 'cash' && selectedCashboxId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('برای پرداخت نقدی، انتخاب صندوق الزامی است', style: TextStyle(fontFamily: _fontFamily))));
      return;
    }
    if (paidNow > invoiceTotal) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مبلغ پرداختی نمی‌تواند از جمع کل فاکتور بیشتر باشد', style: TextStyle(fontFamily: _fontFamily))));
      return;
    }

    setState(() => _isSubmitting = true);

    final productProvider = context.read<ProductProvider>();
    final ledgerProvider = context.read<LedgerProvider>();
    final invoiceId = DateTime.now().millisecondsSinceEpoch;

    // ثبت تک‌تک قلم‌ها، هرکدوم یه رکورد جدای دفتر معاملات با همون invoiceId مشترک
    for (final item in items) {
      Map<String, dynamic> productResult;
      if (isPurchase) {
        productResult = await productProvider.recordPurchase(product: item.product, quantity: item.quantity, pricePerUnit: item.pricePerUnit, date: selectedDate, contactName: selectedContact!.fullName);
      } else {
        if (!productProvider.hasEnoughStock(item.product.id!, item.quantity)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('موجودی «${item.product.name}» کافی نیست', style: const TextStyle(fontFamily: _fontFamily))));
            setState(() => _isSubmitting = false);
          }
          return;
        }
        productResult = await productProvider.recordSale(product: item.product, quantity: item.quantity, pricePerUnit: item.pricePerUnit, date: selectedDate, laborFee: item.laborFee, contactName: selectedContact!.fullName);
      }

      final unitLabel = item.unit == 'ml' ? 'میل' : 'عدد';
      final itemDescription = '${item.product.name} (${item.quantity.toStringAsFixed(0)} $unitLabel)';

      await ledgerProvider.addEntry(LedgerEntry(
        personName: selectedContact!.firstName,
        personFamily: selectedContact!.lastName,
        date: selectedDate,
        description: itemDescription,
        creditAmount: isPurchase ? item.totalAmount : 0,
        debitAmount: isPurchase ? 0 : item.totalAmount,
        laborFee: item.laborFee,
        sourceType: isPurchase ? 'purchase' : 'sale',
        productId: item.product.id,
        quantity: item.quantity,
        unitPrice: item.pricePerUnit,
        unitCost: isPurchase ? null : (productResult['unitCost'] as double?),
        relatedProductTxId: productResult['productTransactionId'] as int?,
        linkedBatchId: isPurchase ? productResult['batchId'] as int? : null,
        invoiceId: invoiceId,
      ));
    }

    // اگه پولی همون لحظه رد و بدل شده، یه ردیف جدا (بدون ربط به هیچ‌کدوم از قلم‌ها) برای فاکتور ثبت میشه
    if (paidNow > 0 && selectedPaymentMethod != null) {
      final bankProvider = context.read<BankProvider>();
      final transProvider = context.read<TransactionProvider>();
      final int bankTxId = DateTime.now().millisecondsSinceEpoch;
      final int? feeTxId = (selectedPaymentMethod == 'card' && fee > 0) ? DateTime.now().millisecondsSinceEpoch + 1 : null;
      final noteText = noteController.text.isNotEmpty ? ' - ${noteController.text}' : '';
      final paymentDescription = '${isPurchase ? 'پرداخت' : 'دریافت'} بابت فاکتور (${items.length} قلم)$noteText';

      int accountId;
      if (selectedPaymentMethod == 'cash') {
        final cashbox = bankProvider.banks.firstWhere((b) => b.id == selectedCashboxId);
        accountId = cashbox.id;
        await bankProvider.updateBank(Bank(id: cashbox.id, bankName: cashbox.bankName, accountNumber: cashbox.accountNumber, balance: cashbox.balance, cashBox: isPurchase ? cashbox.cashBox - paidNow : cashbox.cashBox + paidNow));
      } else {
        final bank = bankProvider.banks.firstWhere((b) => b.id == selectedBankId);
        accountId = bank.id;
        await bankProvider.updateBank(Bank(id: bank.id, bankName: bank.bankName, accountNumber: bank.accountNumber, balance: isPurchase ? bank.balance - paidNow - fee : bank.balance + paidNow - fee, cashBox: bank.cashBox));
      }

      await ledgerProvider.addEntry(LedgerEntry(
        personName: selectedContact!.firstName,
        personFamily: selectedContact!.lastName,
        date: selectedDate,
        description: paymentDescription,
        debitAmount: isPurchase ? paidNow : 0,
        creditAmount: isPurchase ? 0 : paidNow,
        trackingCode: selectedPaymentMethod == 'card' && trackingCodeController.text.trim().isNotEmpty ? trackingCodeController.text.trim() : null,
        affectedBankId: accountId,
        bankAmount: paidNow,
        bankIsIncome: !isPurchase,
        feeAmount: feeTxId != null ? fee : null,
        linkedTransactionId: bankTxId,
        linkedFeeTransactionId: feeTxId,
        invoiceId: invoiceId,
      ));

      await transProvider.addTransaction(Transaction(
        id: bankTxId,
        title: isPurchase ? 'پرداخت بابت فاکتور' : 'دریافت بابت فاکتور',
        description: paymentDescription,
        amount: paidNow,
        type: isPurchase ? TransactionType.expense : TransactionType.income,
        category: isPurchase ? 'معامله فاکتوری' : 'معامله فاکتوری',
        date: selectedDate,
        bankId: accountId,
        contactName: selectedContact!.fullName,
      ));

      if (fee > 0 && feeTxId != null) {
        await transProvider.addTransaction(Transaction(
          id: feeTxId,
          title: 'کارمزد تراکنش',
          description: 'کارمزد فاکتور ${selectedContact!.fullName}',
          amount: fee,
          type: TransactionType.expense,
          category: 'کارمزد',
          date: selectedDate,
          bankId: accountId,
          contactName: selectedContact!.fullName,
        ));
      }
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فاکتور ثبت شد ✅', style: TextStyle(fontFamily: _fontFamily))));
    }
  }

  @override
  void dispose() {
    noteController.dispose();
    paidNowController.dispose();
    feeController.dispose();
    trackingCodeController.dispose();
    super.dispose();
  }
}
