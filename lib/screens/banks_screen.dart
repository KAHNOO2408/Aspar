import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/bank_model.dart';
import '../widgets/custom_app_bar.dart';
import 'add_bank_screen.dart';

class BanksScreen extends StatelessWidget {
  const BanksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(title: 'بانک', context: context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBankScreen())),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      body: Consumer<BankProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // کل موجودی
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green.withOpacity(0.9), Colors.green.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('کل موجودی', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${provider.getTotalBalance().toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                              const Text('🏦', style: TextStyle(fontSize: 48)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (provider.banks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(50),
                    child: Column(
                      children: [
                        Icon(Icons.account_balance, size: 100, color: Colors.grey[200]),
                        const SizedBox(height: 20),
                        const Text('بانکی اضافه نکردی', style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.banks.length,
                    itemBuilder: (context, index) {
                      final bank = provider.banks[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue.withOpacity(0.85), Colors.blue.shade600],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(bank.bankName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
                                const SizedBox(height: 8),
                                Text(bank.accountNumber, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                                const SizedBox(height: 15),
                                Text('${bank.balance.toStringAsFixed(0)} ریال', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => _showEditDialog(context, provider, bank),
                                      icon: const Icon(Icons.edit, size: 18),
                                      label: const Text('ویرایش'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => _showDeleteDialog(context, provider, bank),
                                      icon: const Icon(Icons.delete, size: 18),
                                      label: const Text('حذف'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, BankProvider provider, Bank bank) {
    final nameController = TextEditingController(text: bank.bankName);
    final accountController = TextEditingController(text: bank.accountNumber);
    final balanceController = TextEditingController(text: bank.balance.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ویرایش بانک', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'نام بانک', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12))),
            const SizedBox(height: 15),
            TextField(controller: accountController, decoration: InputDecoration(labelText: 'شماره حساب', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12))),
            const SizedBox(height: 15),
            TextField(controller: balanceController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'موجودی', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () {
              final updatedBank = Bank(
                id: bank.id,
                bankName: nameController.text,
                accountNumber: accountController.text,
                balance: double.tryParse(balanceController.text) ?? 0,
              );
              provider.updateBank(updatedBank);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('ذخیره', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, BankProvider provider, Bank bank) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف بانک', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red)),
        content: const Text('آیا مطمئن‌اید؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () {
              provider.deleteBank(bank.id!);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
