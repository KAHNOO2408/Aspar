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
  Contact? selectedContact;
  Product? selectedProduct;
  int? selectedBankId;
  DateTime selectedDate = DateTime.now();

  String _formatDateToJalali(DateTime date) {
    final jalali = Jalali.fromDateTime(date);
    return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: Jalali.fromDateTime(selectedDate),
      firstDate: Jalali(1390, 1),
      lastDate: Jalali(1420, 12, 29),
    );
    if (picked != null) {
      setState(() => selectedDate = picked.toDateTime());
    }
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
              title: const Text('انتخاب محصول', style: TextStyle(fontWeight: FontWeight.w700)),
              content: SizedBox(
                width: double.maxFinite,
                height: 350,
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        hintText: 'جستجو یا نام محصول جدید...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text('محصولی یافت نشد', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)))
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final product = filtered[index];
                                final stock = productProvider.getStock(product.id!);
                                return ListTile(
                                  title: Text(product.name),
                                  trailing: Text(
                                    stock > 0 ? '${stock.toStringAsFixed(0)} عدد' : 'موجود نیست',
                                    style: TextStyle(color: stock > 0 ? Colors.green : Colors.red, fontWeight: FontWeight.w600),
                                  ),
                                  onTap: () => Navigator.pop(dialogContext, product),
                                );
                              },
                            ),
                    ),
                    if (query.isNotEmpty && !exactMatch) ...[
                      const Divider(),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final newProduct = await productProvider.getOrCreateProduct(searchController.text.trim());
                          if (dialogContext.mounted) Navigator.pop(dialogContext, newProduct);
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: Text(
                          'افزودن محصول جدید: «${searchController.text.trim()}»',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, minimumSize: const Size(double.infinity, 45)),
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

    if (result != null) {
      setState(() => selectedProduct = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPurchase = widget.type == DebtType.owed;
    final productProvider = context.watch<ProductProvider>();
    final stock = selectedProduct != null ? productProvider.getStock(selectedProduct!.id!) : null;

    return Scaffold(
      appBar: AppBar(title: Text(isPurchase ? 'ثبت خرید' : 'ثبت فروش')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Consumer<ContactProvider>(
          builder: (context, contactProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('انتخاب مخاطب *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                DropdownButtonFormField<Contact>(
                  isExpanded: true,
                  hint: const Text('مخاطب را انتخاب کنید'),
                  value: selectedContact,
                  items: contactProvider.contacts.map((contact) => DropdownMenuItem(value: contact, child: Text(contact.fullName))).toList(),
                  onChanged: (contact) => setState(() => selectedContact = contact),
                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12)),
                ),
                const SizedBox(height: 20),

                const Text('محصول *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                InkWell(
                  onTap: _pickProduct,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, color: Colors.indigo),
                        const SizedBox(width: 10),
                        Expanded(child: Text(selectedProduct?.name ?? 'انتخاب محصول...', style: TextStyle(color: selectedProduct != null ? Colors.black : Colors.grey))),
                        if (selectedProduct != null && !isPurchase)
                          Text(
                            stock! > 0 ? 'موجودی: ${stock.toStringAsFixed(0)}' : 'موجود نیست',
                            style: TextStyle(fontSize: 12, color: stock > 0 ? Colors.green : Colors.red, fontWeight: FontWeight.w700),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(labelText: 'تعداد *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(labelText: 'قیمت واحد *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'مبلغ کل: ${formatAmount((double.tryParse(quantityController.text) ?? 0) * (double.tryParse(priceController.text) ?? 0))} تومان',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.indigo),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: noteController,
                  decoration: InputDecoration(labelText: 'یادداشت (اختیاری)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12)),
                ),
                const SizedBox(height: 15),

                ElevatedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(_formatDateToJalali(selectedDate)),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
                ),

                const SizedBox(height: 25),
                const Divider(),
                const SizedBox(height: 10),
                Text(
                  isPurchase ? '💰 پرداخت فوری (اختیاری)' : '💰 دریافت فوری (اختیاری)',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: paidNowController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: isPurchase ? 'مبلغ پرداخت شده الان' : 'مبلغ دریافت شده الان',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),

                if ((double.tryParse(paidNowController.text) ?? 0) > 0) ...[
                  const SizedBox(height: 15),
                  TextField(
                    controller: feeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'کارمزد (تومان) - اختیاری',
                      hintText: 'اگه کارمزدی نداشت خالی بذار',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Consumer<BankProvider>(
                    builder: (context, bankProvider, _) {
                      return DropdownButtonFormField<int>(
                        value: selectedBankId,
                        hint: const Text('انتخاب بانک *'),
                        items: bankProvider.banks.map((bank) {
                          return DropdownMenuItem<int>(value: bank.id, child: Text('${bank.bankName} - ${formatAmount(bank.balance)} تومان'));
                        }).toList(),
                        onChanged: (value) => setState(() => selectedBankId = value),
                        decoration: InputDecoration(labelText: 'بانک *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12)),
                      );
                    },
                  ),
                ],

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPurchase ? Colors.red : Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('ثبت کن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
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

    final totalAmount = quantity * price;
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

    final isPurchase = widget.type == DebtType.owed;
    final productProvider = context.read<ProductProvider>();

    if (isPurchase) {
      await productProvider.recordPurchase(product: selectedProduct!, quantity: quantity, pricePerUnit: price, date: selectedDate);
    } else {
      if (!productProvider.hasEnoughStock(selectedProduct!.id!, quantity)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('موجودی «${selectedProduct!.name}» کافی نیست (موجودی: ${productProvider.getStock(selectedProduct!.id!).toStringAsFixed(0)})')),
          );
        }
        return;
      }
      await productProvider.recordSale(product: selectedProduct!, quantity: quantity, pricePerUnit: price, date: selectedDate);
    }

    final itemDescription = noteController.text.isNotEmpty
        ? '${selectedProduct!.name} (${quantity.toStringAsFixed(0)} عدد) - ${noteController.text}'
        : '${selectedProduct!.name} (${quantity.toStringAsFixed(0)} عدد)';

    final ledgerProvider = context.read<LedgerProvider>();

    await ledgerProvider.addEntry(LedgerEntry(
      personName: selectedContact!.firstName,
      personFamily: selectedContact!.lastName,
      date: selectedDate,
      description: itemDescription,
      creditAmount: isPurchase ? totalAmount : 0,
      debitAmount: isPurchase ? 0 : totalAmount,
    ));

    if (paidNow > 0) {
      final bankProvider = context.read<BankProvider>();
      final transProvider = context.read<TransactionProvider>();
      final bank = bankProvider.banks.firstWhere((b) => b.id == selectedBankId);

      final updatedBank = Bank(
        id: bank.id,
        bankName: bank.bankName,
        accountNumber: bank.accountNumber,
        balance: isPurchase ? bank.balance - paidNow - fee : bank.balance + paidNow - fee,
      );
      await bankProvider.updateBank(updatedBank);

      final transaction = Transaction(
        title: isPurchase ? 'پرداخت به مخاطب' : 'دریافت از مخاطب',
        description: '${selectedContact!.fullName} - $itemDescription',
        amount: paidNow,
        type: isPurchase ? TransactionType.expense : TransactionType.income,
        category: 'معامله با مخاطب',
        date: selectedDate,
        bankId: bank.id,
      );
      transProvider.addTransaction(transaction);

      if (fee > 0) {
        final feeTransaction = Transaction(
          title: 'کارمزد تراکنش',
          description: 'کارمزد ${isPurchase ? 'پرداخت به' : 'دریافت از'} ${selectedContact!.fullName}',
          amount: fee,
          type: TransactionType.expense,
          category: 'کارمزد',
          date: selectedDate,
          bankId: bank.id,
        );
        transProvider.addTransaction(feeTransaction);
      }

      await ledgerProvider.addEntry(LedgerEntry(
        personName: selectedContact!.firstName,
        personFamily: selectedContact!.lastName,
        date: selectedDate,
        description: isPurchase ? 'پرداخت نقدی بابت: ${selectedProduct!.name}' : 'دریافت نقدی بابت: ${selectedProduct!.name}',
        debitAmount: isPurchase ? paidNow : 0,
        creditAmount: isPurchase ? 0 : paidNow,
        bankId: bank.id,
      ));
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ثبت شد ✅')));
    }
  }

  @override
  void dispose() {
    quantityController.dispose();
    priceController.dispose();
    noteController.dispose();
    paidNowController.dispose();
    feeController.dispose();
    super.dispose();
  }
}
