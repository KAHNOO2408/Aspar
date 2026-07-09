import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bank_model.dart';
import '../models/savings_model.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/formatters.dart';
import '../utils/app_colors.dart';
import 'add_bank_screen.dart';

class BanksScreen extends StatelessWidget {
  const BanksScreen({Key? key}) : super(key: key);

  final List<List<Color>> _cardGradients = const [
    [Color(0xFF4F6BF5), Color(0xFF2B3FBE)],
    [Color(0xFF00C6A9), Color(0xFF00897B)],
    [Color(0xFFFF7A59), Color(0xFFE64A19)],
    [Color(0xFF9B6DFF), Color(0xFF6A3DE8)],
    [Color(0xFFFF5C8A), Color(0xFFD81B60)],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: buildCustomAppBar(title: 'بانک', context: context),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [Color(0xFF4F6BF5), Color(0xFF2B3FBE)]),
          boxShadow: [BoxShadow(color: const Color(0xFF2B3FBE).withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBankScreen())),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add, color: Colors.white), SizedBox(width: 8), Text('بانک جدید', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))]),
            ),
          ),
        ),
      ),
      body: Consumer2<BankProvider, SavingsProvider>(
        builder: (context, bankProvider, savingsProvider, _) {
          final totalBalance = bankProvider.getTotalBalance();
          final totalCashBox = bankProvider.getTotalCashBox();
          final totalWithCashBox = bankProvider.getTotalBalanceWithCashBox();
          final totalSavings = savingsProvider.getTotalSavings();

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Column(
                    children: [
                      // کل موجودی
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: const LinearGradient(colors: [Color(0xFF4F6BF5), Color(0xFF2B3FBE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          boxShadow: [BoxShadow(color: const Color(0xFF2B3FBE).withOpacity(0.4), blurRadius: 18, offset: const Offset(0, 10))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20)),
                                const SizedBox(width: 10),
                                const Text('کل موجودی', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'YekanBakh')),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(formatAmount(totalWithCashBox), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'YekanBakh')),
                            const SizedBox(height: 2),
                            const Text('تومان', style: TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'YekanBakh')),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // دو کارت موجودی بانک و صندوق
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: const LinearGradient(colors: [Color(0xFF11998E), Color(0xFF38EF7D)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                boxShadow: [BoxShadow(color: const Color(0xFF11998E).withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 7))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 16)),
                                      const SizedBox(width: 8),
                                      const Text('موجودی بانک', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'YekanBakh')),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(formatAmount(totalBalance), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'YekanBakh')),
                                  const SizedBox(height: 1),
                                  const Text('تومان', style: TextStyle(color: Colors.white70, fontSize: 9, fontFamily: 'YekanBakh')),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: const LinearGradient(colors: [Color(0xFFE67E22), Color(0xFFD35400)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                boxShadow: [BoxShadow(color: const Color(0xFFD35400).withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 7))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.savings_rounded, color: Colors.white, size: 16)),
                                      const SizedBox(width: 8),
                                      const Text('صندوق', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'YekanBakh')),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(formatAmount(totalCashBox), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'YekanBakh')),
                                  const SizedBox(height: 1),
                                  const Text('تومان', style: TextStyle(color: Colors.white70, fontSize: 9, fontFamily: 'YekanBakh')),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // پس انداز
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(colors: [Color(0xFF9B6DFF), Color(0xFF6A3DE8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          boxShadow: [BoxShadow(color: const Color(0xFF6A3DE8).withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 7))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.savings_rounded, color: Colors.white, size: 16)),
                                    const SizedBox(width: 8),
                                    const Text('کل پس انداز', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'YekanBakh')),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(formatAmount(totalSavings), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'YekanBakh')),
                                const SizedBox(height: 1),
                                const Text('تومان', style: TextStyle(color: Colors.white70, fontSize: 9, fontFamily: 'YekanBakh')),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.savings_rounded, color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (bankProvider.banks.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Align(alignment: Alignment.centerRight, child: Text('حساب‌های بانکی', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textSecondary(context)))),
                  ),

                if (bankProvider.banks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(60),
                    child: Column(
                      children: [
                        Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.card(context), shape: BoxShape.circle), child: Icon(Icons.account_balance_rounded, size: 60, color: AppColors.textMuted(context))),
                        const SizedBox(height: 20),
                        Text('هنوز بانکی اضافه نکردی', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('با دکمه‌ی پایین صفحه شروع کن', style: TextStyle(color: AppColors.textMuted(context), fontSize: 12)),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    itemCount: bankProvider.banks.length,
                    itemBuilder: (context, index) {
                      final bank = bankProvider.banks[index];
                      final gradient = _cardGradients[index % _cardGradients.length];
                      final isCashbox = bank.accountNumber == 'صندوق';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                            boxShadow: [BoxShadow(color: gradient[1].withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8))],
                          ),
                          child: Stack(
                            children: [
                              Positioned(left: -20, top: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)))),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(14)), child: Icon(isCashbox ? Icons.savings_rounded : Icons.account_balance_rounded, color: Colors.white, size: 22)),
                                            const SizedBox(width: 12),
                                            Text(bank.bankName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Colors.white, fontFamily: 'YekanBakh')),
                                          ],
                                        ),
                                        PopupMenuButton<String>(
                                          icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.9)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          onSelected: (value) {
                                            if (value == 'edit') _showEditDialog(context, bankProvider, bank, isCashbox);
                                            if (value == 'delete') _showDeleteDialog(context, bankProvider, bank);
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18, color: Colors.blue), SizedBox(width: 8), Text('ویرایش', style: TextStyle(fontFamily: 'YekanBakh'))])),
                                            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text('حذف', style: TextStyle(fontFamily: 'YekanBakh'))])),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 22),
                                    if (!isCashbox)
                                      Text(bank.accountNumber, style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.85), letterSpacing: 1.2, fontWeight: FontWeight.w500, fontFamily: 'YekanBakh')),
                                    if (!isCashbox) const SizedBox(height: 18),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(formatAmount(bank.totalBalance), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: Colors.white, fontFamily: 'YekanBakh')),
                                        const SizedBox(width: 6),
                                        Padding(padding: const EdgeInsets.only(bottom: 3), child: Text('تومان', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75), fontFamily: 'YekanBakh'))),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 90),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, BankProvider provider, Bank bank, bool isCashbox) {
    final nameController = TextEditingController(text: bank.bankName);
    final accountController = TextEditingController(text: bank.accountNumber);
    final balanceController = TextEditingController(text: bank.balance.toString());
    final cashBoxController = TextEditingController(text: bank.cashBox.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isCashbox ? 'ویرایش صندوق' : 'ویرایش بانک', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context), fontFamily: 'YekanBakh')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, style: TextStyle(color: AppColors.text(context), fontFamily: 'YekanBakh'), decoration: InputDecoration(labelText: isCashbox ? 'نام صندوق' : 'نام بانک', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.all(14))),
            if (!isCashbox) const SizedBox(height: 16),
            if (!isCashbox)
              TextField(controller: accountController, style: TextStyle(color: AppColors.text(context), fontFamily: 'YekanBakh'), decoration: InputDecoration(labelText: 'شماره حساب', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.all(14))),
            const SizedBox(height: 16),
            if (isCashbox)
              TextField(controller: cashBoxController, keyboardType: TextInputType.number, style: TextStyle(color: AppColors.text(context), fontFamily: 'YekanBakh'), decoration: InputDecoration(labelText: 'موجودی صندوق (تومان)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.all(14)))
            else
              TextField(controller: balanceController, keyboardType: TextInputType.number, style: TextStyle(color: AppColors.text(context), fontFamily: 'YekanBakh'), decoration: InputDecoration(labelText: 'موجودی (تومان)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.all(14))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف', style: TextStyle(fontFamily: 'YekanBakh'))),
          ElevatedButton(
            onPressed: () {
              final updatedBank = Bank(
                id: bank.id,
                bankName: nameController.text,
                accountNumber: isCashbox ? 'صندوق' : accountController.text,
                balance: isCashbox ? 0 : (double.tryParse(balanceController.text) ?? 0),
                cashBox: isCashbox ? (double.tryParse(cashBoxController.text) ?? 0) : 0,
              );
              provider.updateBank(updatedBank);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B3FBE), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('ذخیره', style: TextStyle(color: Colors.white, fontFamily: 'YekanBakh')),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, BankProvider provider, Bank bank) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف بانک', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red, fontFamily: 'YekanBakh')),
        content: Text('آیا مطمئن‌اید؟', style: TextStyle(color: AppColors.text(context), fontFamily: 'YekanBakh')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف', style: TextStyle(fontFamily: 'YekanBakh'))),
          ElevatedButton(
            onPressed: () {
              provider.deleteBank(bank.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('حذف', style: TextStyle(color: Colors.white, fontFamily: 'YekanBakh')),
          ),
        ],
      ),
    );
  }
}
