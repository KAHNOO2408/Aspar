import 'package:flutter/material.dart';

class Contact {
  final int? id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? address;

  Contact({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.address,
  });

  String get fullName => '$firstName $lastName';
}

class ContactProvider extends ChangeNotifier {
  List<Contact> contacts = [];

  void addContact(Contact contact) {
    contacts.add(Contact(
      id: contacts.isEmpty ? 1 : contacts.last.id! + 1,
      firstName: contact.firstName,
      lastName: contact.lastName,
      phoneNumber: contact.phoneNumber,
      address: contact.address,
    ));
    notifyListeners();
  }

  void updateContact(Contact contact) {
    final index = contacts.indexWhere((c) => c.id == contact.id);
    if (index != -1) {
      contacts[index] = contact;
      notifyListeners();
    }
  }

  void deleteContact(int id) {
    contacts.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
