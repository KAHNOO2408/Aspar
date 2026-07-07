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
  Contact? selectedContact;
  Product? selectedProduct;
  int? selectedBankId;
  DateTime selectedDate = DateTime.now();
  String selectedUnit = 'count';
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
              title: Text('انتخاب محصول', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(dialogContext))),
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
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              child: Center(child: Text('افزودن محصول جدید: «${searchController.text.trim()}»', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontFamily: _fontFamily), textAlign: TextAlign.center)),
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

  @override
  Widget build(BuildContext context) {
    final isPurchase = widget.type == DebtType.owed;
    final gradient = isPurchase ? const [Color(0xFFFF7A59), Color(0xFFE64A19)] : const [Color(0xFF11998E), Color(0xFF38EF7D)];
    final productProvider = context.watch<ProductProvider>();
    final stock = selectedProduct != null ? productProvider.getStock(selectedProduct!.id!) : null;
    final showLaborFee = selectedUnit == 'ml' && !isPurchase;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: Text(isPurchase ? 'ثبت خرید' : 'ثبت فروش')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Consumer<ContactProvider>(
          builder: (context, contactProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<Contact>(
                  isExpanded: true,
                  hint: Text('مخاطب را انتخاب کنید', style: TextStyle(fontFamily: _fontFamily, color: AppColors.textMuted(context))),
                  value: selectedContact,
                  items: contactProvider.contacts.map((contact) => DropdownMenuItem(value: contact, child: Text(contact.fullName, style: TextStyle(fontFamily: _fontFamily, color: AppColors.text(context))))).toList(),
                  onChanged: (contact) => setState(() => selectedContact = contact),
                  decoration: _decoration(context, 'مخاطب *'),
                  style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                ),
                const SizedBox(height: 16),

                InkWell(
                  onTap: _pickProduct,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: LinearGradient(colors: gradient), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 18)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(selectedProduct?.name ?? 'انتخاب محصول...', style: TextStyle(color: selectedProduct != null ? AppColors.text(context) : AppColors.textMuted(context), fontWeight: FontWeight.w600, fontFamily: _fontFamily))),
                        if (selectedProduct != null && !isPurchase)
                          Text(stock! > 0 ? 'موجودی: ${stock.toStringAsFixed(0)}' : 'موجود نیست', style: TextStyle(fontSize: 12, color: stock > 0 ? const Color(0xFF11998E) : const Color(0xFFE64A19), fontWeight: FontWeight.w700, fontFamily: _fontFamily)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text('واحد اندازه‌گیری', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textSecondary(context))),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _UnitButton(label: 'تعداد', selected: selectedUnit == 'count', gradient: gradient, onTap: () => setState(() => selectedUnit = 'count'))),
                    const SizedBox(width: 10),
                    Expanded(child: _UnitButton(label: 'میل', selected: selectedUnit == 'ml', gradient: gradient, onTap: () => setState(() => selectedUnit = 'ml'))),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(child: TextField(controller: quantityController, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily), decoration: _decoration(context, selectedUnit == 'ml' ? 'مقدار (میل) *' : 'تعداد *'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: priceController, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily), decoration: _decoration(context, selectedUnit == 'ml' ? 'قیمت هر میل *' : 'قیمت واحد *'))),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: gradient[0].withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('مبلغ کل: ${formatAmount((double.tryParse(quantityController.text) ?? 0) * (double.tryParse(priceController.text) ?? 0))} تومان', style: TextStyle(fontWeight: FontWeight.w700, color: gradient[1])),
                ),

                if (showLaborFee) ...[
                  const SizedBox(height: 16),
                  TextField(controller: laborFeeController, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily), decoration: _decoration(context, 'دستمزد (تومان) - اختیاری')),
                ],

                const SizedBox(height: 16),
                TextField(controller: noteController, style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily), decoration: _decoration(context, 'یادداشت (اختیاری)')),
                const SizedBox(height: 16),

                _DateButton(label: _formatDateToJalali(selectedDate), onTap: _pickDate),

                const SizedBox(height: 25),
                Row(
                  children: [
                    Container(width: 4, height: 18, decoration: BoxDecoration(gradient: LinearGradient(colors: gradient), borderRadius: BorderRadius.circular(4))),
                    const SizedBox(width: 8),
                    Text(isPurchase ? 'پرداخت فوری (اختیاری)' : 'دریافت فوری (اختیاری)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textSecondary(context))),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(controller: paidNowController, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily), decoration: _decoration(context, isPurchase ? 'مبلغ پرداخت شده الان' : 'مبلغ دریافت شده الان')),

                if ((double.tryParse(paidNowController.text) ?? 0) > 0) ...[
                  const SizedBox(height: 15),
                  TextField(controller: feeController, keyboardType: TextInputType.number, style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily), decoration: _decoration(context, 'کارمزد بانکی (تومان) - اختیاری')),
                  const SizedBox(height: 15),
                  Consumer<BankProvider>(
                    builder: (context, bankProvider, _) {
                      return DropdownButtonFormField<int>(
                        value: selectedBankId,
                        hint: Text('انتخاب بانک *', style: TextStyle(fontFamily: _fontFamily, color: AppColors.textMuted(context))),
                        items: bankProvider.banks.map((bank) => DropdownMenuItem<int>(value: bank.id, child: Text('${bank.bankName} - ${formatAmount(bank.balance)} تومان', style: TextStyle(fontFamily: _fontFamily, color: AppColors.text(context))))).toList(),
                        onChanged: (value) => setState(() => selectedBankId = value),
                        decoration: _decoration(context, 'بانک *'),
                        style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                      );
                    },
                  ),
                ],

                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(colors: gradient), boxShadow: [BoxShadow(color: gradient[1].withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 7))]),
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
                              : const Text('ثبت کن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

void _submit() async {
    if (_isSubmitting) return;
    if (selectedContact == null || selectedProduct == null || quantityController.text.isEmpty || priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مخاطب، محصول، تعداد و قیمت الزامی هستند')));
      return;
    }

    final quantity = double.tryParse(quantityController.text) ?? 0;
    final price = double.tryParse(priceController.text) ?? 0;
    if (quantity <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعداد و قیمت باید بزرگتر از صفر باشند')));
      return;
    }

    final isPurchase = widget.type == DebtType.owed;
    final showLaborFee = selectedUnit == 'ml' && !isPurchase;
    final laborFee = showLaborFee ? (double.tryParse(laborFeeController.text) ?? 0.0) : 0.0;

    final baseAmount = quantity * price;
    final totalAmount = baseAmount + laborFee;
    final paidNow = double.tryParse(paidNowController.text) ?? 0;
    final fee = double.tryParse(feeController.text) ?? 0;
    if (paidNow > totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مبلغ پرداختی نمی‌تواند بیشتر از مبلغ کل باشد')));
      return;
    }
    if (paidNow > 0 && selectedBankId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('برای مبلغ پرداختی، انتخاب بانک الزامی است')));
      return;
    }

    setState(() => _isSubmitting = true);

    final productProvider = context.read<ProductProvider>();

    if (isPurchase) {
      await productProvider.recordPurchase(product: selectedProduct!, quantity: quantity, pricePerUnit: price, date: selectedDate, contactName: selectedContact!.fullName);
    } else {
      if (!productProvider.hasEnoughStock(selectedProduct!.id!, quantity)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('موجودی «${selectedProduct!.name}» کافی نیست (موجودی: ${productProvider.getStock(selectedProduct!.id!).toStringAsFixed(0)})')));
          setState(() => _isSubmitting = false);
        }
        return;
      }
      await productProvider.recordSale(product: selectedProduct!, quantity: quantity, pricePerUnit: price, date: selectedDate, laborFee: laborFee, contactName: selectedContact!.fullName);
    }

    final unitLabel = selectedUnit == 'ml' ? 'میل' : 'عدد';
    final productInfo = noteController.text.isNotEmpty
        ? '${selectedProduct!.name} (${quantity.toStringAsFixed(0)} $unitLabel) - ${noteController.text}'
        : '${selectedProduct!.name} (${quantity.toStringAsFixed(0)} $unitLabel)';

    final ledgerProvider = context.read<LedgerProvider>();
    await ledgerProvider.addEntry(LedgerEntry(
      personName: selectedContact!.firstName,
      personFamily: selectedContact!.lastName,
      date: selectedDate,
      description: productInfo,
      creditAmount: isPurchase ? totalAmount : 0,
      debitAmount: isPurchase ? 0 : totalAmount,
      laborFee: laborFee,
    ));

    if (paidNow > 0) {
      final bankProvider = context.read<BankProvider>();
      final transProvider = context.read<TransactionProvider>();
      final bank = bankProvider.banks.firstWhere((b) => b.id == selectedBankId);

      final updatedBank = Bank(id: bank.id, bankName: bank.bankName, accountNumber: bank.accountNumber, balance: isPurchase ? bank.balance - paidNow - fee : bank.balance + paidNow - fee);
      await bankProvider.updateBank(updatedBank);

      final cashLedgerId = await ledgerProvider.addEntry(LedgerEntry(
        personName: selectedContact!.firstName,
        personFamily: selectedContact!.lastName,
        date: selectedDate,
        description: isPurchase ? 'پرداخت نقدی بابت: ${selectedProduct!.name}' : 'دریافت نقدی بابت: ${selectedProduct!.name}',
        debitAmount: isPurchase ? paidNow : 0,
        creditAmount: isPurchase ? 0 : paidNow,
        bankId: bank.id,
      ));

      await transProvider.addTransaction(Transaction(
        title: isPurchase ? 'پرداخت به مخاطب' : 'دریافت از مخاطب',
        description: isPurchase ? 'پرداخت نقدی' : 'دریافت نقدی',
        amount: paidNow,
        type: isPurchase ? TransactionType.expense : TransactionType.income,
        category: 'معامله با مخاطب',
        date: selectedDate,
        bankId: bank.id,
        contactName: selectedContact!.fullName,
        productInfo: productInfo,
        laborFee: laborFee,
        ledgerEntryId: cashLedgerId,
      ));

      if (fee > 0) {
        await transProvider.addTransaction(Transaction(
          title: 'کارمزد تراکنش',
          description: 'کارمزد ${isPurchase ? 'پرداخت به' : 'دریافت از'} ${selectedContact!.fullName}',
          amount: fee,
          type: TransactionType.expense,
          category: 'کارمزد',
          date: selectedDate,
          bankId: bank.id,
        ));
      }
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ثبت شد ✅')));
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
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Center(child: Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary(context), fontWeight: FontWeight.w700)))),
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DateButton({required this.label, required this.onTap});

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
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.calendar_today, size: 16, color: Color(0xFF4F6BF5)), const SizedBox(width: 8), Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text(context)))]),
          ),
        ),
      ),
    );
  }
}
