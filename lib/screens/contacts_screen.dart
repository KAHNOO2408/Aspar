import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/contact_model.dart';
import '../widgets/custom_app_bar.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(title: 'مخاطبین', context: context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactDialog(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: Consumer<ContactProvider>(
        builder: (context, provider, _) {
          return provider.contacts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.contacts, size: 100, color: Colors.grey[200]),
                      const SizedBox(height: 20),
                      const Text('مخاطبی اضافه نکردی', style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.w500)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: provider.contacts.length,
                  itemBuilder: (context, index) {
                    final contact = provider.contacts[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                            child: const Center(child: Icon(Icons.person, color: Colors.blue, size: 24)),
                          ),
                          title: Text('${contact.firstName} ${contact.lastName}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(contact.phoneNumber, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(child: const Text('ویرایش'), onTap: () => _showEditContactDialog(context, provider, contact)),
                              PopupMenuItem(child: const Text('حذف'), onTap: () => provider.deleteContact(contact.id!)),
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
        title: const Text('مخاطب جدید', style: TextStyle(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: firstNameController, decoration: InputDecoration(labelText: 'نام', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12))),
              const SizedBox(height: 12),
              TextField(controller: lastNameController, decoration: InputDecoration(labelText: 'نام‌خانوادگی', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12))),
              const SizedBox(height: 12),
              TextField(controller: phoneController, decoration: InputDecoration(labelText: 'تلفن', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12))),
              const SizedBox(height: 12),
              TextField(controller: addressController, decoration: InputDecoration(labelText: 'آدرس', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12))),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
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
        title: const Text('ویرایش مخاطب', style: TextStyle(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: firstNameController, decoration: InputDecoration(labelText: 'نام', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12))),
              const SizedBox(height: 12),
              TextField(controller: lastNameController, decoration: InputDecoration(labelText: 'نام‌خانوادگی', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12))),
              const SizedBox(height: 12),
              TextField(controller: phoneController, decoration: InputDecoration(labelText: 'تلفن', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12))),
              const SizedBox(height: 12),
              TextField(controller: addressController, decoration: InputDecoration(labelText: 'آدرس', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.all(12))),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('ذخیره', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
