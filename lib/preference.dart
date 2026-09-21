import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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


