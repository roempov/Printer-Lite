import 'package:blue_print_pos/receipt/receipt_alignment.dart';
import 'package:blue_print_pos/receipt/receipt_section_text.dart';
import 'package:blue_print_pos/receipt/receipt_text_size_type.dart';
import 'package:blue_print_pos/receipt/receipt_text_style_type.dart';
import 'package:final_printer/printer_job.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'preference.dart';

class PrintProvince extends PrinterJob {
  final String senderNum;
  final String receiverNum;
  final String destination;
  final String delivery;
  final String note;
  final VoidCallback? onSuccess;

  PrintProvince({
    required this.senderNum,
    required this.receiverNum,
    required this.destination,
    required this.delivery,
    required this.note,
    this.onSuccess,
  });

  final String _dateTime =
      DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());

  @override
  String get disconnectMessage => 'Restart ម៉ាស៊ីន ព្រីន';

  @override
  Future<void> printAndSave() async {
    final receipt = ReceiptSectionText();

    receipt.addText(
      'Niza Shop',
      alignment: ReceiptAlignment.center,
      size: ReceiptTextSizeType.extraLarge,
      style: ReceiptTextStyleType.bold,
    );
    receipt.addSpacer(useDashed: true);

    receipt.addLeftRightText(
      'លេខអ្នកផ្ញើ',
      '',
      leftSize: ReceiptTextSizeType.small,
      rightSize: ReceiptTextSizeType.small,
    );
    receipt.addSpacer();
    receipt.addText(
      senderNum,
      alignment: ReceiptAlignment.left,
      size: ReceiptTextSizeType.medium,
      style: ReceiptTextStyleType.normal,
    );

    receipt.addLeftRightText(
      'អ្នកទទួល',
      '',
      leftSize: ReceiptTextSizeType.small,
      rightSize: ReceiptTextSizeType.small,
    );
    receipt.addSpacer();
    receipt.addText(
      receiverNum,
      alignment: ReceiptAlignment.left,
      size: ReceiptTextSizeType.medium,
      style: ReceiptTextStyleType.bold,
    );

    receipt.addLeftRightText(
      'ទីតាំង',
      '',
      leftSize: ReceiptTextSizeType.small,
      rightSize: ReceiptTextSizeType.small,
    );
    receipt.addText(
      destination,
      alignment: ReceiptAlignment.left,
      size: ReceiptTextSizeType.medium,
      style: ReceiptTextStyleType.bold,
    );
    receipt.addSpacer();

    receipt.addLeftRightText(
      _dateTime,
      delivery,
      leftSize: ReceiptTextSizeType.small,
      rightSize: ReceiptTextSizeType.small,
    );
    receipt.addSpacer(count: 2);

    showToast('Printing...', color: Colors.green);

    final printSucceeded = await printReceipt(receipt);

    if (printSucceeded) {
      await AddFireStore().province(
        receiverNum,
        destination,
        delivery,
        _dateTime,
      );
      onSuccess?.call();
    } else {
      showToast('ព្រីនមិនបានជោគជ័យ សូមព្យាយាមម្តងទៀត');
    }
  }
}
