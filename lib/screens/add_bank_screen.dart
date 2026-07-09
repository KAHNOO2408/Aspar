import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bank_model.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';

class AddBankScreen extends StatefulWidget {
  const AddBankScreen({Key? key}) : super(key: key);

  @override
  State<AddBankScreen> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends State<AddBankScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Bank fields
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final balanceController = TextEditingController();
  
  // Cashbox fields
  final cashboxNameController = TextEditingController();
  final cashboxAmountController = TextEditingController();

  static const _fontFamily = 'YekanBakh';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    balanceController.dispose();
    cashboxNameController.dispose();
    cashboxAmountController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(BuildContext context, String label) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary(context), fontFamily: _fontFamily),
        filled: true,
        fillColor: AppColors.card(context),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(14),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('بانک/صندوق جدید', style: TextStyle(fontFamily: _fontFamily)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'بانک', icon: Icon(Icons.account_balance)),
            Tab(text: 'صندوق', icon: Icon(Icons.savings_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBankTab(context),
          _buildCashboxTab(context),
        ],
      ),
    );
  }

  Widget _buildBankTab(BuildContext context) {
    final balance = double.tryParse(balanceController.text) ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: bankNameController,
            style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
            decoration: _decoration(context, 'نام بانک *'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: accountNumberController,
            style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
            decoration: _decoration(context, 'شماره حساب/کارت *'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: balanceController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
            decoration: _decoration(context, 'موجودی (تومان)'),
          ),
          if (balance > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFF4F6BF5).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text('${formatAmount(balance)} تومان', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2B3FBE), fontFamily: _fontFamily)),
              ),
            ),
          const SizedBox(height: 30),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(colors: [Color(0xFF4F6BF5), Color(0xFF2B3FBE)]),
              boxShadow: [BoxShadow(color: const Color(0xFF2B3FBE).withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 7))],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _submitBank,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text('ایجاد بانک', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, fontFamily: _fontFamily)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashboxTab(BuildContext context) {
    final amount = double.tryParse(cashboxAmountController.text) ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: cashboxNameController,
            style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
            decoration: _decoration(context, 'نام صندوق *'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: cashboxAmountController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
            decoration: _decoration(context, 'مبلغ (تومان)'),
          ),
          if (amount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFFE67E22).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text('${formatAmount(amount)} تومان', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFD35400), fontFamily: _fontFamily)),
              ),
            ),
          const SizedBox(height: 30),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(colors: [Color(0xFFE67E22), Color(0xFFD35400)]),
              boxShadow: [BoxShadow(color: const Color(0xFFD35400).withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 7))],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _submitCashbox,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text('ایجاد صندوق', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, fontFamily: _fontFamily)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitBank() async {
    if (bankNameController.text.isEmpty || accountNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('نام و شماره حساب الزامی هستند', style: TextStyle(fontFamily: _fontFamily))));
      return;
    }

    final bank = Bank(
      id: DateTime.now().millisecondsSinceEpoch,
      bankName: bankNameController.text,
      accountNumber: accountNumberController.text,
      balance: double.tryParse(balanceController.text) ?? 0,
      cashBox: 0,
    );

    await Provider.of<BankProvider>(context, listen: false).insertBank(bank);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('بانک ایجاد شد ✅', style: TextStyle(fontFamily: _fontFamily))));
    }
  }

  void _submitCashbox() async {
    if (cashboxNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('نام صندوق الزامی است', style: TextStyle(fontFamily: _fontFamily))));
      return;
    }

    final cashbox = Bank(
      id: DateTime.now().millisecondsSinceEpoch,
      bankName: cashboxNameController.text,
      accountNumber: 'صندوق',
      balance: 0,
      cashBox: double.tryParse(cashboxAmountController.text) ?? 0,
    );

    await Provider.of<BankProvider>(context, listen: false).insertBank(cashbox);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('صندوق ایجاد شد ✅', style: TextStyle(fontFamily: _fontFamily))));
    }
  }
}
