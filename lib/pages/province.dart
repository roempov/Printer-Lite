import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../print_province.dart';
import '../ui_helper.dart';
import 'province_history.dart';
import '../preference.dart';

class Province extends StatefulWidget {
  const Province({super.key});

  @override
  State<StatefulWidget> createState() => _ProvinceState();
}

class _ProvinceState extends State<Province> with SingleTickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────────────────
  final _fieldSender = TextEditingController();
  final _fieldReceiver = TextEditingController();
  final _fieldDestination = TextEditingController();
  final _fieldNote = TextEditingController();
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

  // ── State ─────────────────────────────────────────────────────────────────
  bool _validateFieldReceiver = false;
  bool _validateFieldDestination = false;
  String _deliverValue = 'វីរៈ ប៊ុនថាំ';
  bool _isPrinting = false;

  static const String _keySelectedDelivery = 'pinnedDelivery'; // key kept as-is so existing saved prefs still load

  final List<String> _deliveryItems = ['វីរៈ ប៊ុនថាំ', 'J&T', 'កាពីតូល'];

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadSelectedDelivery();
    _loadSenderNumber();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadSenderNumber() async {
    final saved = await getSenderNumber();
    setState(() => _fieldSender.text = saved);
  }

  @override
  void dispose() {
    _fieldSender.dispose();
    _fieldReceiver.dispose();
    _fieldDestination.dispose();
    _fieldNote.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ── Methods ───────────────────────────────────────────────────────────────
  Future<void> _loadSelectedDelivery() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_keySelectedDelivery) ?? 'វីរៈ ប៊ុនថាំ';
    setState(() => _deliverValue = saved);
  }

  Future<void> _selectDelivery(String item) async {
    setState(() => _deliverValue = item);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedDelivery, item);
  }

  void _clearFields() {
    setState(() {
      _fieldReceiver.clear();
      _fieldDestination.clear();
      _fieldNote.clear();
      _validateFieldReceiver = false;
      _validateFieldDestination = false;
    });
  }

  Future<void> _onPrintPressed() async {
    if (_isPrinting) return;

    await _animController.forward();
    await _animController.reverse();

    if (!mounted) return;
    FocusScope.of(context).unfocus();

    final receiverEmpty = _fieldReceiver.text.isEmpty;
    final destinationEmpty = _fieldDestination.text.isEmpty;

    setState(() {
      _validateFieldReceiver = receiverEmpty;
      _validateFieldDestination = destinationEmpty;
    });

    if (receiverEmpty && destinationEmpty) {
      showToast('ដាក់លេខអ្នកទទួល និង ទីតាំង');
      return;
    }
    if (receiverEmpty) {
      showToast('ដាក់លេខអ្នកទទួល');
      return;
    }
    if (destinationEmpty) {
      showToast('ដាក់ទីតាំង');
      return;
    }

    setState(() => _isPrinting = true);
    try {
      await PrintProvince(
        senderNum: _fieldSender.text,
        receiverNum: _fieldReceiver.text,
        destination: _fieldDestination.text,
        delivery: _deliverValue,
        note: _fieldNote.text,
        onSuccess: _clearFields,
      ).preparePrint();
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xB3D8D8D8),
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: const SizedBox(
              width: 40,
              child: Text(
                '  -',
                style: TextStyle(color: Colors.orange),
              )),
          actions: [
            IconButton(
                onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProvinceHistory()),
                    ),
                color: Colors.orange,
                icon: const Icon(Icons.history)),
            const SizedBox(width: 15),
          ],
        ),
        floatingActionButton: ScaleTransition(
          scale: _scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SizedBox(
              width: 75,
              height: 75,
              child: FloatingActionButton(
                heroTag: null,
                backgroundColor: Colors.orange,
                onPressed: _isPrinting ? null : _onPrintPressed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _isPrinting
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.print_rounded, size: 35),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: Padding(
          padding: const EdgeInsets.only(top: 10, left: 25, right: 25),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const SizedBox(
                  height: 50,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),

                // Sender field

                SizedBox(
                  height: 70,
                  child: ValueListenableBuilder<String>(
                    valueListenable: senderNumberNotifier,
                    builder: (context, senderNumber, _) {
                      _fieldSender.text = senderNumber;
                      return TextField(
                        controller: _fieldSender,
                        readOnly: true,
                        style: const TextStyle(color: Colors.black54, fontSize: 22),
                        decoration: InputDecoration(
                          enabledBorder: buildOutLineBorder(),
                          focusedBorder: buildOutLineBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'លេខអ្នកផ្ញើ',
                          labelStyle: labelStyle(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Receiver field
                SizedBox(
                  height: 70,
                  child: TextField(
                    controller: _fieldReceiver,
                    inputFormatters: [buildMaskFormat()],
                    style: textFieldStyle(),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      enabledBorder: buildOutLineBorder(),
                      focusedBorder: buildOutLineBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'លេខអ្នកទទួល',
                      labelStyle: labelStyle(),
                      errorText: _validateFieldReceiver ? '' : null,
                      errorStyle: const TextStyle(color: Colors.white),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _fieldReceiver.clear(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Destination field
                SizedBox(
                  height: 120,
                  child: TextField(
                    controller: _fieldDestination,
                    maxLines: 2,
                    style: textFieldStyle(),
                    decoration: InputDecoration(
                      enabledBorder: buildOutLineBorder(),
                      focusedBorder: buildOutLineBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'ទីតាំង',
                      labelStyle: labelStyle(),
                      errorText: _validateFieldDestination ? '' : null,
                      errorStyle: const TextStyle(color: Colors.white),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _fieldDestination.clear(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Delivery selector
                Row(
                  children: _deliveryItems.map((item) {
                    final isSelected = item == _deliverValue;
                    final Color selectedTextColor = item == 'J&T'
                        ? Colors.red
                        : item == 'កាពីតូល'
                            ? Colors.blue.shade700
                            : Colors.orange.shade600;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: GestureDetector(
                          onDoubleTap: () => _selectDelivery(item),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected ? selectedTextColor : Colors.grey.withOpacity(0.1),
                                  blurRadius: 2,
                                  spreadRadius: 0.1,
                                ),
                              ],
                              border: Border.all(
                                color: isSelected ? selectedTextColor : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              item,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? selectedTextColor : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
