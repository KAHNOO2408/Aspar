import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/debt_model.dart';
import '../models/contact_model.dart';
import '../models/bank_model.dart';
import '../models/transaction_model.dart';
import '../models/payment_model.dart';
import '../models/product_model.dart';
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
            final query = searchController.text.trim();
            final filtered = productProvider.products
                .where((p) => p.name.contains(query))
                .toList();
            final exactMatch = productProvider.products.any((p) => p.name == query);

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
                          ? const Center(child: Text('محصولی یافت نشد', style: TextStyle(color: Colors.grey)))
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
                          final newProduct = await productProvider.getOrCreateProduct(query);
                          if (dialogContext.mounted) Navigator.pop(dialogContext, newProduct);
                        },
                        icon: const Icon(Icons.add),
                        label: Text('افزودن محصول جدید: «$query»'),
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
      appBar: AppBar(
        title: Text(isPurchase ? 'ثبت خرید (بدهی جدید)' : 'ثبت فروش (طلب جدید)'),
      ),
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
                  items: contactProvider.contacts.map((contact) {
                    return DropdownMenuItem(value: contact, child: Text(contact.fullName));
                  }).toList(),
                  onChanged: (contact) => setState(() => selectedContact = contact),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 20),

                const Text('محصول *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                InkWell(
                  onTap: _pickProduct,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, color: Colors.indigo),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            selectedProduct?.name ?? 'انتخاب محصول...',
                            style: TextStyle(color: selectedProduct != null ? Colors.black : Colors.grey),
                          ),
                        ),
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
                        decoration: InputDecoration(
                          labelText: 'تعداد *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'قیمت واحد *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'مبلغ کل: ${formatAmount((double.tryParse(quantityController.text) ?? 0) * (double.tryParse(priceController.text) ?? 0))} ریال',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.indigo),
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: 'یادداشت (اختیاری)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
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
                  Consumer<BankProvider>(
                    builder: (context, bankProvider, _) {
                      return DropdownButtonFormField<int>(
                        value: selectedBankId,
                        hint: const Text('انتخاب بانک *'),
                        items: bankProvider.banks.map((bank) {
                          return DropdownMenuItem<int>(
                            value: bank.id,
                            child: Text('${bank.bankName} - ${formatAmount(bank.balance)}'),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => selectedBankId = value),
                        decoration: InputDecoration(
                          labelText: 'بانک *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.all(12),
                        ),
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
    if (paidNow > totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مبلغ پرداختی نمی‌تواند بیشتر از مبلغ کل باشد')));
      return;
    }
    if (paidNow > 0 && selectedBankId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('برای مبلغ پرداختی، انتخاب بانک الزامی است')));
      return;
    }

    final sameType = widget.type;
    final isPurchase = sameType == DebtType.owed;
    final productProvider = context.read<ProductProvider>();

    // مدیریت انبار: خرید = اضافه شدن موجودی، فروش = کم شدن موجودی (با چک موجودی کافی)
    if (isPurchase) {
      await productProvider.recordPurchase(
        product: selectedProduct!,
        quantity: quantity,
        pricePerUnit: price,
        date: selectedDate,
      );
    } else {
      if (!productProvider.hasEnoughStock(selectedProduct!.id!, quantity)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('موجودی «${selectedProduct!.name}» کافی نیست (موجودی: ${productProvider.getStock(selectedProduct!.id!).toStringAsFixed(0)})')),
          );
        }
        return;
      }
      await productProvider.recordSale(
        product: selectedProduct!,
        quantity: quantity,
        pricePerUnit: price,
        date: selectedDate,
      );
    }

    final debtProvider = context.read<DebtProvider>();
    final oppositeType = sameType == DebtType.owed ? DebtType.receivable : DebtType.owed;
    final itemDescription = noteController.text.isNotEmpty
        ? '${selectedProduct!.name} (${quantity.toStringAsFixed(0)} عدد) - ${noteController.text}'
        : '${selectedProduct!.name} (${quantity.toStringAsFixed(0)} عدد)';

    final newId = DateTime.now().millisecondsSinceEpoch;
    final newDebt = Debt(
      id: newId,
      personName: selectedContact!.firstName,
      personFamily: selectedContact!.lastName,
      totalAmount: totalAmount,
      description: itemDescription,
      date: selectedDate,
      type: sameType,
      paidAmount: paidNow,
    );
    await debtProvider.addDebt(newDebt);

    final oppositeDebts = debtProvider.debts
        .where((d) =>
            d.personName == selectedContact!.firstName &&
            d.personFamily == selectedContact!.lastName &&
            d.type == oppositeType &&
            d.remainder > 0)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    double remainingNew = totalAmount - paidNow;
    for (final oppDebt in oppositeDebts) {
      if (remainingNew <= 0) break;
      final offset = remainingNew < oppDebt.remainder ? remainingNew : oppDebt.remainder;
      oppDebt.paidAmount += offset;
      await debtProvider.editDebt(oppDebt);
      remainingNew -= offset;
    }

    newDebt.paidAmount = totalAmount - remainingNew;
    await debtProvider.editDebt(newDebt);

    if (paidNow > 0) {
      final bankProvider = context.read<BankProvider>();
      final transProvider = context.read<TransactionProvider>();
      final paymentProvider = context.read<PaymentProvider>();
      final bank = bankProvider.banks.firstWhere((b) => b.id == selectedBankId);

      final updatedBank = Bank(
        id: bank.id,
        bankName: bank.bankName,
        accountNumber: bank.accountNumber,
        balance: sameType == DebtType.owed ? bank.balance - paidNow : bank.balance + paidNow,
      );
      await bankProvider.updateBank(updatedBank);

      final transaction = Transaction(
        title: sameType == DebtType.owed ? 'پرداخت به مخاطب' : 'دریافت از مخاطب',
        description: '${selectedContact!.fullName} - $itemDescription',
        amount: paidNow,
        type: sameType == DebtType.owed ? TransactionType.expense : TransactionType.income,
        category: 'معامله با مخاطب',
        date: selectedDate,
        bankId: bank.id,
      );
      transProvider.addTransaction(transaction);

      final payment = Payment(
        debtId: newId,
        amount: paidNow,
        date: selectedDate,
        description: itemDescription,
        type: sameType == DebtType.owed ? PaymentType.debtPayment : PaymentType.receivablePayment,
        bankId: bank.id,
      );
      await paymentProvider.addPayment(payment);
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
    super.dispose();
  }
}
