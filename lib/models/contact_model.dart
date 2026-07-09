import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../database/db_helper.dart';

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

  Map<String, dynamic> toMap() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'address': address,
      };

  factory Contact.fromMap(Map<String, dynamic> map) => Contact(
        id: map['id'],
        firstName: map['firstName'],
        lastName: map['lastName'],
        phoneNumber: map['phoneNumber'],
        address: map['address'],
      );
}

class ContactAdapter extends TypeAdapter<Contact> {
  @override
  final int typeId = 2;

  @override
  Contact read(BinaryReader reader) {
    return Contact(
      id: reader.read() as int?,
      firstName: reader.read() as String,
      lastName: reader.read() as String,
      phoneNumber: reader.read() as String,
      address: reader.read() as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Contact obj) {
    writer.write(obj.id);
    writer.write(obj.firstName);
    writer.write(obj.lastName);
    writer.write(obj.phoneNumber);
    writer.write(obj.address);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ContactAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class ContactProvider extends ChangeNotifier {
  List<Contact> contacts = [];

  ContactProvider() {
    loadContacts();
  }

  Future<void> loadContacts() async {
    contacts = await DatabaseHelper.getContacts();
    notifyListeners();
  }

  Future<void> addContact(Contact contact) async {
    final toSave = contact.id == null
        ? Contact(
            id: DateTime.now().millisecondsSinceEpoch,
            firstName: contact.firstName,
            lastName: contact.lastName,
            phoneNumber: contact.phoneNumber,
            address: contact.address,
          )
        : contact;
    await DatabaseHelper.insertContact(toSave);
    await loadContacts();
  }

  Future<void> updateContact(Contact contact) async {
    await DatabaseHelper.updateContact(contact);
    await loadContacts();
  }

  Future<void> deleteContact(int id) async {
    await DatabaseHelper.deleteContact(id);
    await loadContacts();
  }
}
