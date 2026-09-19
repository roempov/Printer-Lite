import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _keyAddress = 'macAddress';

Future setDeviceAddress(String address) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString(_keyAddress, address);
}

Future<String?> getDeviceAddress() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getString(_keyAddress) ?? '';
}

void showToast(String text, {Color color = Colors.red}) {
  Fluttertoast.showToast(msg: text, backgroundColor: color);
}

OutlineInputBorder buildOutLineBorder() {
  OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.white));
  return outlineInputBorder;
}

TextStyle labelStyle() {
  const TextStyle labelStyle =
      TextStyle(fontWeight: FontWeight.normal, fontSize: 20);
  return labelStyle;
}

TextStyle textFieldStyle() {
  const TextStyle myStyle =
      TextStyle(fontSize: 26, fontWeight: FontWeight.bold);
  return myStyle;
}

MaskTextInputFormatter buildMaskFormat() {
  final maskFormatter = MaskTextInputFormatter(
      mask: '### ### ####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);
  return maskFormatter;
}

class AddFireStore {
  final String _sortDate =
      DateFormat('yy-MM-dd HHmmss').format(DateTime.now());

  Future city(String address, String amount, String phoneNumber,
      String dateTime) async {
    final CollectionReference collCod =
        FirebaseFirestore.instance.collection('cod');

    await collCod.add({
      "address": address,
      "price": amount,
      "phone": phoneNumber,
      "date": dateTime,
      "sort": _sortDate
    });
  }

  Future province(
    String receiverNum,
    String destination,
    String delivery,
    String dateTime,
  ) async {
    final CollectionReference collPro =
        FirebaseFirestore.instance.collection('province');

    await collPro.add({
      "phone": receiverNum,
      "destination": destination,
      "deliver": delivery,
      "date": dateTime,
      "sort": _sortDate
    });
  }
}
