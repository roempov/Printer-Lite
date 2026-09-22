import 'package:blue_print_pos/blue_print_pos.dart';
import 'package:blue_print_pos/models/blue_device.dart';
import 'package:blue_print_pos/models/connection_status.dart';
import 'package:blue_print_pos/receipt/receipt_section_text.dart';
import 'package:blue_print_pos/receipt/receipt_text_size_type.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../bluetooth_permission.dart';
import '../preference.dart';
import '../ui_helper.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final BluePrintPos _bluePrintPos = BluePrintPos.instance;
  List<BlueDevice> _blueDevices = <BlueDevice>[];
  BlueDevice? _selectedDevice;
  bool _isLoading = false;
  int _loadingAtIndex = -1;

  final _fieldSender = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadSenderNumber();
  }

  @override
  void dispose() {
    _fieldSender.dispose();
    super.dispose();
  }

  Future<void> _loadSenderNumber() async {
    final saved = await getSenderNumber();
    setState(() => _fieldSender.text = saved);
  }

  Future<void> _saveSenderNumber() async {
    final value = _fieldSender.text.trim();
    if (value.isEmpty) {
      showToast('ដាក់លេខអ្នកផ្ញើ');
      return;
    }
    await setSenderNumber(value);
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    showToast('រក្សាទុករួចរាល់', color: Colors.green);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xB3D8D8D8),
      appBar: AppBar(
        backgroundColor: Colors.black87,
      ),
      body: Center(
        child: Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.only(top: 30, left: 25, right: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
                child: TextField(
                  controller: _fieldSender,
                  inputFormatters: [buildMaskFormat()],
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 20),
                  onEditingComplete: _saveSenderNumber,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'កំណត់លេខអ្នកផ្ញើ',
                    labelStyle: labelStyle(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: _saveSenderNumber,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
              SafeArea(
                child: _isLoading && _blueDevices.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      )
                    : _blueDevices.isNotEmpty
                        ? SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                  children: List<Widget>.generate(_blueDevices.length, (int index) {
                                    return Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: _blueDevices[index].address == (_selectedDevice?.address ?? '')
                                                ? _onDisconnectDevice
                                                : () => _onSelectDevice(index),
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 25, right: 25),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    _blueDevices[index].name,
                                                    style: TextStyle(
                                                      color: _selectedDevice?.address == _blueDevices[index].address ? Colors.blue : Colors.black,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    _blueDevices[index].address,
                                                    style: TextStyle(
                                                      color: _selectedDevice?.address == _blueDevices[index].address ? Colors.blueGrey : Colors.grey,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (_loadingAtIndex == index && _isLoading)
                                          Container(
                                            height: 24.0,
                                            width: 24.0,
                                            margin: const EdgeInsets.only(right: 8.0),
                                            child: const CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Colors.blue,
                                              ),
                                            ),
                                          ),
                                        if (!_isLoading && _blueDevices[index].address == (_selectedDevice?.address ?? ''))
                                          Padding(
                                            padding: const EdgeInsets.only(right: 20),
                                            child: TextButton(
                                              onPressed: _startPrint,
                                              style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                                    (Set<MaterialState> states) {
                                                      if (states.contains(MaterialState.pressed)) {
                                                        return Colors.teal.withOpacity(0.5);
                                                      }
                                                      return Colors.teal;
                                                    },
                                                  ),
                                                  shape: MaterialStateProperty.all(
                                                    RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(18),
                                                    ),
                                                  )),
                                              child: const Text(
                                                'Test Print',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  }),
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const <Widget>[
                                Text(
                                  'ប៊ូតុងខាងក្រោម សម្រាប់ភ្ជាប់ម៉ាស៊ីនព្រីន',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
              ),
              const SizedBox(height: 100),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: _isLoading ? null : _onScanPressed,
                  child: const Text('Show Bluetooth Printer')),
            ],
          ),
        ),
      ),
    );
  }

  void _onDisconnectDevice() {
    _bluePrintPos.disconnect().then((ConnectionStatus status) {
      if (status == ConnectionStatus.disconnect) {
        setState(() {
          showToast('Printer may turned off');
          _selectedDevice = null;
        });
      }
    });
  }

  Future<void> _onScanPressed() async {
    setState(() => _isLoading = true);

    final granted = await requestBluetoothPermissions();
    if (!granted) {
      setState(() => _isLoading = false);
      showToast('សូមអនុញ្ញាត Bluetooth និង Location');
      return;
    }

    try {
      final devices = await _bluePrintPos.scan().timeout(
            const Duration(seconds: 6),
            onTimeout: () => <BlueDevice>[],
          );
      if (devices.isNotEmpty) {
        setState(() {
          _blueDevices = devices;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        showToast('សូមបើក Bluetooth ទូរស័ព្ទ');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      showToast('ស្កេនបរាជ័យ: $e'); // TEMPORARY — shows the real error, remove the ": $e" once confirmed working
    }
  }

  void _onSelectDevice(int index) {
    setState(() {
      _isLoading = true;
      _loadingAtIndex = index;
    });
    final BlueDevice blueDevice = _blueDevices[index];
    _bluePrintPos.connect(blueDevice).then((ConnectionStatus status) {
      if (status == ConnectionStatus.connected) {
        setState(() => _selectedDevice = blueDevice);

        final address = _blueDevices[index].address;
        setDeviceAddress(address);
      } else if (status == ConnectionStatus.timeout) {
        _onDisconnectDevice();
      } else {
        showToast('Something went wrong');
      }
      setState(() => _isLoading = false);
    });
  }

  Future<void> _startPrint() async {
    final String formatDate = DateFormat.yMd().add_jm().format(DateTime.now());
    final ReceiptSectionText receiptText = ReceiptSectionText();
    receiptText.addLeftRightText(formatDate, 'OK', leftSize: ReceiptTextSizeType.small, rightSize: ReceiptTextSizeType.small);
    receiptText.addSpacer(count: 4);

    showToast('Printing...', color: Colors.green);
    await _bluePrintPos.printReceiptText(receiptText);
    await _bluePrintPos.disconnect();
  }
}
