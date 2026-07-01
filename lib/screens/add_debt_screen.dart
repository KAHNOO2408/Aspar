import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/debt_model.dart';
import '../models/contact_model.dart';

class AddDebtScreen extends StatefulWidget {
  final DebtType type;
  const AddDebtScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  Contact? selectedContact;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type == DebtType.owed ? 'افزودن بدهی' : 'افزودن طلب'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Consumer<ContactProvider>(
          builder: (context, contactProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('انتخاب مخاطب',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                DropdownButton<Contact>(
                  isExpanded: true,
                  hint: const Text('مخاطب را انتخاب کنید'),
                  value: selectedContact,
                  items: contactProvider.contacts.map((contact) {
                    return DropdownMenuItem(
                      value: contact,
                      child: Text(contact.fullName),
                    );
                  }).toList(),
                  onChanged: (contact) {
                    setState(() {
                      selectedContact = contact;
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'مبلغ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'توضیح',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _addDebt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.type == DebtType.owed ? Colors.red : Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'اضافه کن',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _addDebt() {
    if (selectedContact == null || amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('مخاطب و مبلغ را انتخاب کنید')),
      );
      return;
    }

    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('مبلغ باید بزرگتر از صفر باشد')),
      );
      return;
    }

    final debt = Debt(
      personName: selectedContact!.firstName,
      personFamily: selectedContact!.lastName,
      totalAmount: amount,
      description: descriptionController.text,
      date: DateTime.now(),
      type: widget.type,
    );

    try {
      context.read<DebtProvider>().addDebt(debt);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('افزودن شد ✅')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا: $e')),
      );
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
