import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

void showToast(String text, {Color color = Colors.red}) {
  Fluttertoast.showToast(msg: text, backgroundColor: color);
}

OutlineInputBorder buildOutLineBorder() {
  OutlineInputBorder outlineInputBorder =
      OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white));
  return outlineInputBorder;
}

TextStyle labelStyle() {
  const TextStyle labelStyle = TextStyle(fontWeight: FontWeight.normal, fontSize: 20);
  return labelStyle;
}

TextStyle textFieldStyle() {
  const TextStyle myStyle = TextStyle(fontSize: 26, fontWeight: FontWeight.bold);
  return myStyle;
}

MaskTextInputFormatter buildMaskFormat() {
  final maskFormatter = MaskTextInputFormatter(mask: '### ### ####', filter: {"#": RegExp(r'\d')}, type: MaskAutoCompletionType.lazy);
  return maskFormatter;
}
