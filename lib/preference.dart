import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _keyAddress = 'macAddress';
const String _keySenderNumber = 'senderNumber';

Future setDeviceAddress(String address) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString(_keyAddress, address);
}

Future<String?> getDeviceAddress() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getString(_keyAddress) ?? '';
}

/// Holds the current sender number in memory so any page can listen for
/// changes without needing to reload from SharedPreferences manually.
final ValueNotifier<String> senderNumberNotifier =
ValueNotifier<String>('096 700 3269');

Future<void> loadSenderNumberIntoNotifier() async {
  final prefs = await SharedPreferences.getInstance();
  senderNumberNotifier.value =
      prefs.getString(_keySenderNumber) ?? '096 700 3269';
}

Future setSenderNumber(String number) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString(_keySenderNumber, number);
  senderNumberNotifier.value = number; // <-- pushes the update to any listener immediately
}

Future<String> getSenderNumber() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getString(_keySenderNumber) ?? '096 700 3269';
}