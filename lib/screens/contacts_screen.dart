import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/contact_model.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/app_colors.dart';
import 'contact_ledger_screen.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  final List<List<Color>> _gradients = const [
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
      appBar: buildCustomAppBar(title: 'مخاطبین', context: context),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [Color(0xFF4F6BF5), Color(0xFF2B3FBE)]),
          boxShadow: [BoxShadow(color: const Color(0xFF2B3FBE).withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(16), onTap: () => _showAddContactDialog(context), child: const Padding(padding: EdgeInsets.all(16), child: Icon(Icons.add, color: Colors.white)))),
      ),
      body: Consumer<ContactProvider>(
        builder: (context, provider, _) {
          return provider.contacts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.card(context), shape: BoxShape.circle), child: Icon(Icons.contacts_outlined, size: 55, color: AppColors.textMuted(context))),
                      const SizedBox(height: 20),
                      Text('مخاطبی اضافه نکردی', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: provider.contacts.length,
                  itemBuilder: (context, index) {
                    final contact = provider.contacts[index];
                    final gradient = _gradients[index % _gradients.length];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: AppColors.card(context),
                        borderRadius: BorderRadius.circular(18),
                        elevation: 2,
                        shadowColor: Colors.black12,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(width: 48, height: 48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight)), child: const Icon(Icons.person_rounded, color: Colors.white, size: 24)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${contact.firstName} ${contact.lastName}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.text(context))),
                                    const SizedBox(height: 2),
                                    Text(contact.phoneNumber, style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context))),
                                  ],
                                ),
                              ),
                              PopupMenuButton(
                                icon: Icon(Icons.more_vert, color: AppColors.textSecondary(context)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Row(children: [Icon(Icons.receipt_long, size: 18, color: Colors.indigo), SizedBox(width: 8), Text('مشاهده حساب')]),
                                    onTap: () {
                                      Future.delayed(Duration.zero, () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => ContactLedgerScreen(personName: contact.firstName, personFamily: contact.lastName)));
                                      });
                                    },
                                  ),
                                  PopupMenuItem(child: const Row(children: [Icon(Icons.edit, size: 18, color: Colors.blue), SizedBox(width: 8), Text('ویرایش')]), onTap: () => _showEditContactDialog(context, provider, contact)),
                                  PopupMenuItem(child: const Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('حذف')]), onTap: () => provider.deleteContact(contact.id!)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }

  InputDecoration _decoration(BuildContext context, String label) => InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.all(12));

  void _showAddContactDialog(BuildContext context) {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('مخاطب جدید', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: firstNameController, style: TextStyle(color: AppColors.text(context)), decoration: _decoration(context, 'نام')),
              const SizedBox(height: 12),
              TextField(controller: lastNameController, style: TextStyle(color: AppColors.text(context)), decoration: _decoration(context, 'نام‌خانوادگی')),
              const SizedBox(height: 12),
              TextField(controller: phoneController, style: TextStyle(color: AppColors.text(context)), decoration: _decoration(context, 'تلفن')),
              const SizedBox(height: 12),
              TextField(controller: addressController, style: TextStyle(color: AppColors.text(context)), decoration: _decoration(context, 'آدرس')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () {
              context.read<ContactProvider>().addContact(Contact(firstName: firstNameController.text, lastName: lastNameController.text, phoneNumber: phoneController.text, address: addressController.text));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B3FBE), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('اضافه', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditContactDialog(BuildContext context, ContactProvider provider, Contact contact) {
    final firstNameController = TextEditingController(text: contact.firstName);
    final lastNameController = TextEditingController(text: contact.lastName);
    final phoneController = TextEditingController(text: contact.phoneNumber);
    final addressController = TextEditingController(text: contact.address ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('ویرایش مخاطب', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: firstNameController, style: TextStyle(color: AppColors.text(context)), decoration: _decoration(context, 'نام')),
              const SizedBox(height: 12),
              TextField(controller: lastNameController, style: TextStyle(color: AppColors.text(context)), decoration: _decoration(context, 'نام‌خانوادگی')),
              const SizedBox(height: 12),
              TextField(controller: phoneController, style: TextStyle(color: AppColors.text(context)), decoration: _decoration(context, 'تلفن')),
              const SizedBox(height: 12),
              TextField(controller: addressController, style: TextStyle(color: AppColors.text(context)), decoration: _decoration(context, 'آدرس')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () {
              final updated = Contact(id: contact.id, firstName: firstNameController.text, lastName: lastNameController.text, phoneNumber: phoneController.text, address: addressController.text);
              provider.updateContact(updated);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B3FBE), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('ذخیره', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
