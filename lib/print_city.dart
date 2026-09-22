import 'package:blue_print_pos/receipt/receipt_alignment.dart';
import 'package:blue_print_pos/receipt/receipt_section_text.dart';
import 'package:blue_print_pos/receipt/receipt_text_size_type.dart';
import 'package:blue_print_pos/receipt/receipt_text_style_type.dart';
import 'package:final_printer/printer_job.dart';
import 'package:final_printer/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'firestore_service.dart';

class PrintCity extends PrinterJob {
  final String phoneNumber;
  final String address;
  final String amount; // USD result  e.g. "4.88$"
  final String amountRiel; // Riel input  e.g. "20,000"
  final VoidCallback? onSuccess;

  PrintCity({
    required this.phoneNumber,
    required this.address,
    required this.amount,
    required this.amountRiel,
    this.onSuccess,
  });

  final String _dateTime = DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());

  @override
  String get disconnectMessage => 'សូមបិទ បើកម៉ាស៊ីន ព្រីន';

  @override
  Future<void> printAndSave() async {
    final receipt = ReceiptSectionText();

    receipt.addLeftRightText(
      'COD',
      'Niza Shop',
      leftSize: ReceiptTextSizeType.medium,
      rightSize: ReceiptTextSizeType.small,
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
      '096 700 3269',
      alignment: ReceiptAlignment.center,
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
      phoneNumber,
      alignment: ReceiptAlignment.center,
      size: ReceiptTextSizeType.medium,
      style: ReceiptTextStyleType.bold,
    );

    receipt.addLeftRightText(
      'អាសយដ្ឋាន',
      '',
      leftSize: ReceiptTextSizeType.small,
      rightSize: ReceiptTextSizeType.small,
    );
    receipt.addSpacer();
    receipt.addText(
      address,
      alignment: ReceiptAlignment.center,
      size: ReceiptTextSizeType.medium,
      style: ReceiptTextStyleType.bold,
    );

    receipt.addLeftRightText(
      'តម្លៃសរុប',
      '',
      leftSize: ReceiptTextSizeType.small,
      rightSize: ReceiptTextSizeType.small,
    );
    receipt.addSpacer();
    receipt.addLeftRightText(
      amount,
      '($amountRiel៛)',
      leftStyle: ReceiptTextStyleType.bold,
      rightStyle: ReceiptTextStyleType.normal,
      leftSize: ReceiptTextSizeType.large,
      rightSize: ReceiptTextSizeType.medium,
    );

    receipt.addLeftRightText(
      '',
      _dateTime,
      leftSize: ReceiptTextSizeType.small,
      rightSize: ReceiptTextSizeType.small,
    );
    receipt.addSpacer(count: 2);

    showToast('Printing...', color: Colors.green);

    final printSucceeded = await printReceipt(receipt);

    if (printSucceeded) {
      await AddFireStore().city(
        address,
        '$amountRiel៛ ($amount)',
        phoneNumber,
        _dateTime,
      );
      onSuccess?.call();
    } else {
      showToast('ព្រីនមិនបានជោគជ័យ សូមព្យាយាមម្តងទៀត');
    }
  }
}
