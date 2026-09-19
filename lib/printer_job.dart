import 'package:blue_print_pos/blue_print_pos.dart';
import 'package:blue_print_pos/models/blue_device.dart';
import 'package:blue_print_pos/models/connection_status.dart';
import 'package:blue_print_pos/receipt/receipt_section_text.dart';
import 'bluetooth_permission.dart';
import 'preference.dart';

/// Shared scan → find saved device → connect → print → disconnect flow,
/// used by both PrintCity and PrintProvince. Subclasses only implement
/// printAndSave() (build the receipt content + write the Firestore record)
/// and disconnectMessage (the toast shown after a timeout disconnect).
abstract class PrinterJob {
  final BluePrintPos bluePrintPos = BluePrintPos.instance;
  final List<BlueDevice> blueDevices = [];
  BlueDevice? selectedDevice;

  String get disconnectMessage;

  Future<void> printAndSave();

  Future<void> preparePrint() async {
    final granted = await requestBluetoothPermissions();
    if (!granted) {
      showToast('សូមអនុញ្ញាត Bluetooth និង Location');
      return;
    }

    List<BlueDevice> devices;
    try {
      devices = await bluePrintPos.scan().timeout(
        const Duration(seconds: 6),
        onTimeout: () => <BlueDevice>[],
      );
    } catch (e) {
      showToast('ស្កេនបរាជ័យ: $e');
      return;
    }

    if (devices.isEmpty) {
      showToast('បើក Bluetooth ទូរស័ព្ទ');
      return;
    }

    final deviceAddress = await getDeviceAddress();
    blueDevices.addAll(devices);

    bool matched = false;
    for (final device in blueDevices) {
      if (device.address == deviceAddress) {
        matched = true;
        await bluePrintPos.disconnect();
        selectedDevice = device;

        try {
          final status = await bluePrintPos.connect(selectedDevice!);
          if (status == ConnectionStatus.connected) {
            await printAndSave();
          } else if (status == ConnectionStatus.timeout) {
            _onDisconnectDevice();
          } else {
            showToast('Error connection');
          }
        } catch (e) {
          showToast('មានបញ្ហាក្នុងការភ្ជាប់ម៉ាស៊ីនព្រីន');
        }
        break;
      }
    }

    if (!matched) {
      showToast('រកមិនឃើញម៉ាស៊ីនព្រីនដែលបានរក្សាទុក សូមភ្ជាប់នៅទំព័រ Connect');
    }
  }

  void _onDisconnectDevice() {
    bluePrintPos.disconnect().then((status) {
      if (status == ConnectionStatus.disconnect) {
        showToast(disconnectMessage);
      }
    });
  }

  /// Prints the receipt, catching any thrown exception as failure (the
  /// plugin's printReceiptText returns void, so an exception is the only
  /// failure signal available), then schedules the disconnect. Returns
  /// whether the print call completed without throwing.
  Future<bool> printReceipt(ReceiptSectionText receipt) async {
    bool printSucceeded = true;
    try {
      await bluePrintPos.printReceiptText(receipt, duration: 2000);
    } catch (e) {
      printSucceeded = false;
    }

    Future.delayed(const Duration(seconds: 8), () async {
      await bluePrintPos.disconnect();
    });

    return printSucceeded;
  }
}
