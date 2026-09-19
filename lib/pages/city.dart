import 'package:final_printer/pages/exchage_rate_setting.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../preference.dart';
import '../print_city.dart';
import 'city_history.dart';

class City extends StatefulWidget {
  const City({super.key});

  @override
  State<StatefulWidget> createState() => _CityState();
}

class _CityState extends State<City> with SingleTickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────────────────
  final _fieldPhone = TextEditingController();
  final _fieldAddress = TextEditingController();
  final _fieldAmount = TextEditingController();
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

  // ── State ─────────────────────────────────────────────────────────────────
  bool _validateFieldPhone = false;
  bool _validateFieldAddress = false;
  String _formattedResult = '';
  double _multiplier = 4000;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadMultiplier();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fieldPhone.dispose();
    _fieldAddress.dispose();
    _fieldAmount.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ── Methods ───────────────────────────────────────────────────────────────
  Future<void> _loadMultiplier() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _multiplier = prefs.getDouble('multiplier') ?? 4000;
    });
  }

  void _formatAmount(String value) {
    if (value.isEmpty) {
      setState(() => _formattedResult = '');
      return;
    }
    final clean = value.replaceAll(',', '');
    try {
      final number = double.parse(clean);
      final formatted = NumberFormat('#,###').format(number);
      _fieldAmount.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      setState(() {
        _formattedResult = (number / _multiplier).toStringAsFixed(2) + '\$';
      });
    } catch (_) {
      setState(() => _formattedResult = 'តម្លៃមិនត្រឹមត្រូវ');
    }
  }

  void _clearFields() {
    setState(() {
      _fieldPhone.clear();
      _fieldAddress.clear();
      _fieldAmount.clear();
      _formattedResult = '';
      _validateFieldPhone = false;
      _validateFieldAddress = false;
    });
  }

  Future<void> _navigateToSettings() async {
    final result = await Navigator.push<double>(
      context,
      MaterialPageRoute(builder: (_) => ExchangeRate()),
    );
    if (result != null) {
      setState(() => _multiplier = result);
      _formatAmount(_fieldAmount.text);
    }
  }

  Future<void> _onPrintPressed() async {
    // Run animation
    await _animController.forward();
    await _animController.reverse();

    FocusScope.of(context).unfocus();

    final phoneEmpty = _fieldPhone.text.isEmpty;
    final addressEmpty = _fieldAddress.text.isEmpty;

    setState(() {
      _validateFieldPhone = phoneEmpty;
      _validateFieldAddress = addressEmpty;
    });

    if (phoneEmpty && addressEmpty) {
      showToast('ដាក់លេខទូរស័ព្ទ និង អាស័យដ្ឋាន');
      return;
    }
    if (phoneEmpty) {
      showToast('ដាក់លេខទូរស័ព្ទ');
      return;
    }
    if (addressEmpty) {
      showToast('ដាក់អាសយដ្ឋាន');
      return;
    }

    PrintCity(
      phoneNumber: _fieldPhone.text,
      address: _fieldAddress.text,
      amount: _formattedResult,
      amountRiel: _fieldAmount.text,
      onSuccess: _clearFields,
    ).preparePrint();
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
          title: IconButton(
            icon: const Icon(Icons.currency_exchange),
            iconSize: 17,
            onPressed: _navigateToSettings,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CityHistory()),
              ),
              child: const Text(
                'ប្រវត្តិលក់',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),

        // FLOATING BUTTON HERE
        floatingActionButton: ScaleTransition(
          scale: _scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.only(right: 5), // move left
            child: SizedBox(
              width: 75,
              height: 75,
              child: FloatingActionButton(
                heroTag: null,
                backgroundColor: Colors.blue,
                onPressed: _onPrintPressed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.print_rounded, size: 35),
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
                      'COD',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),

                // Phone field
                SizedBox(
                  height: 70,
                  child: TextField(
                    controller: _fieldPhone,
                    inputFormatters: [buildMaskFormat()],
                    style: textFieldStyle(),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      enabledBorder: buildOutLineBorder(),
                      focusedBorder: buildOutLineBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'លេខទូរស័ព្ទ',
                      labelStyle: labelStyle(),
                      errorText: _validateFieldPhone ? '' : null,
                      errorStyle: const TextStyle(color: Colors.white),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _fieldPhone.clear(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Address field
                TextField(
                  controller: _fieldAddress,
                  maxLines: 2,
                  style: textFieldStyle(),
                  decoration: InputDecoration(
                    enabledBorder: buildOutLineBorder(),
                    focusedBorder: buildOutLineBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'អាសយដ្ឋាន',
                    labelStyle: labelStyle(),
                    errorText: _validateFieldAddress ? '' : null,
                    errorStyle: const TextStyle(color: Colors.white),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _fieldAddress.clear(),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Amount field (Riel input)
                SizedBox(
                  height: 70,
                  child: TextField(
                    controller: _fieldAmount,
                    onChanged: _formatAmount,
                    keyboardType: TextInputType.number,
                    style: textFieldStyle(),
                    decoration: InputDecoration(
                      enabledBorder: buildOutLineBorder(),
                      focusedBorder: buildOutLineBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'តម្លៃសរុប ៛',
                      labelStyle: labelStyle(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _fieldAmount.clear();
                          setState(() => _formattedResult = '');
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // USD result
                Text(
                  '  $_formattedResult',
                  style: const TextStyle(fontSize: 24),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
