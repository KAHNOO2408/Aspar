import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/contact_model.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/app_colors.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  static const _fontFamily = 'YekanBakh';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: buildCustomAppBar(title: 'مخاطبین', context: context),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [Color(0xFF4F6BF5), Color(0xFF2B3FBE)]),
          boxShadow: [BoxShadow(color: const Color(0xFF2B3FBE).withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 7))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showAddContactDialog(context),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add, color: Colors.white), SizedBox(width: 8), Text('مخاطب جدید', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontFamily: _fontFamily))]),
            ),
          ),
        ),
      ),
      body: Consumer<ContactProvider>(
        builder: (context, provider, _) {
          return provider.contacts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.contacts, size: 100, color: AppColors.textMuted(context)),
                      const SizedBox(height: 20),
                      Text('مخاطبی اضافه نکردی', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 18, fontWeight: FontWeight.w500, fontFamily: _fontFamily)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: provider.contacts.length,
                  itemBuilder: (context, index) {
                    final contact = provider.contacts[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: AppColors.divider(context).withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 2))]),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF4F6BF5), Color(0xFF2B3FBE)]),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(child: Icon(Icons.person, color: Colors.white, size: 24)),
                          ),
                          title: Text('${contact.firstName} ${contact.lastName}', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context), fontFamily: _fontFamily)),
                          subtitle: Text(contact.phoneNumber, style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context), fontFamily: _fontFamily)),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: const Row(children: [Icon(Icons.edit_outlined, size: 18, color: Colors.blue), SizedBox(width: 8), Text('ویرایش', style: TextStyle(fontFamily: _fontFamily))]),
                                onTap: () => _showEditContactDialog(context, provider, contact),
                              ),
                              PopupMenuItem(
                                child: const Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text('حذف', style: TextStyle(fontFamily: _fontFamily))]),
                                onTap: () => provider.deleteContact(contact.id!),
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
        title: Text('مخاطب جدید', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context), fontFamily: _fontFamily)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                decoration: InputDecoration(
                  labelText: 'نام',
                  labelStyle: TextStyle(color: AppColors.textSecondary(context), fontFamily: _fontFamily),
                  filled: true,
                  fillColor: AppColors.background(context),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lastNameController,
                style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                decoration: InputDecoration(
                  labelText: 'نام‌خانوادگی',
                  labelStyle: TextStyle(color: AppColors.textSecondary(context), fontFamily: _fontFamily),
                  filled: true,
                  fillColor: AppColors.background(context),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                decoration: InputDecoration(
                  labelText: 'تلفن',
                  labelStyle: TextStyle(color: AppColors.textSecondary(context), fontFamily: _fontFamily),
                  filled: true,
                  fillColor: AppColors.background(context),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                decoration: InputDecoration(
                  labelText: 'آدرس',
                  labelStyle: TextStyle(color: AppColors.textSecondary(context), fontFamily: _fontFamily),
                  filled: true,
                  fillColor: AppColors.background(context),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف', style: TextStyle(fontFamily: _fontFamily))),
          ElevatedButton(
            onPressed: () {
              if (firstNameController.text.isEmpty || lastNameController.text.isEmpty || phoneController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('نام، نام‌خانوادگی و تلفن الزامی هستند', style: TextStyle(fontFamily: _fontFamily))));
                return;
              }

              final newContact = Contact(
                id: DateTime.now().millisecondsSinceEpoch,
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                phoneNumber: phoneController.text,
                address: addressController.text.isEmpty ? null : addressController.text,
              );

              context.read<ContactProvider>().insertContact(newContact);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مخاطب اضافه شد ✅', style: TextStyle(fontFamily: _fontFamily))));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F6BF5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('اضافه', style: TextStyle(color: Colors.white, fontFamily: _fontFamily)),
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
        title: Text('ویرایش مخاطب', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(context), fontFamily: _fontFamily)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                decoration: InputDecoration(
                  labelText: 'نام',
                  labelStyle: TextStyle(color: AppColors.textSecondary(context), fontFamily: _fontFamily),
                  filled: true,
                  fillColor: AppColors.background(context),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lastNameController,
                style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                decoration: InputDecoration(
                  labelText: 'نام‌خانوادگی',
                  labelStyle: TextStyle(color: AppColors.textSecondary(context), fontFamily: _fontFamily),
                  filled: true,
                  fillColor: AppColors.background(context),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                decoration: InputDecoration(
                  labelText: 'تلفن',
                  labelStyle: TextStyle(color: AppColors.textSecondary(context), fontFamily: _fontFamily),
                  filled: true,
                  fillColor: AppColors.background(context),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                style: TextStyle(color: AppColors.text(context), fontFamily: _fontFamily),
                decoration: InputDecoration(
                  labelText: 'آدرس',
                  labelStyle: TextStyle(color: AppColors.textSecondary(context), fontFamily: _fontFamily),
                  filled: true,
                  fillColor: AppColors.background(context),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف', style: TextStyle(fontFamily: _fontFamily))),
          ElevatedButton(
            onPressed: () {
              if (firstNameController.text.isEmpty || lastNameController.text.isEmpty || phoneController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('نام، نام‌خانوادگی و تلفن الزامی هستند', style: TextStyle(fontFamily: _fontFamily))));
                return;
              }

              final updated = Contact(
                id: contact.id,
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                phoneNumber: phoneController.text,
                address: addressController.text.isEmpty ? null : addressController.text,
              );
              provider.updateContact(updated);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مخاطب اپدیت شد ✅', style: TextStyle(fontFamily: _fontFamily))));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F6BF5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('ذخیره', style: TextStyle(color: Colors.white, fontFamily: _fontFamily)),
          ),
        ],
      ),
    );
  }
}
