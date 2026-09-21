import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ui_helper.dart';

class ExchangeRate extends StatefulWidget {
  const ExchangeRate({super.key});

  @override
  _ExchangeRateState createState() => _ExchangeRateState();
}

class _ExchangeRateState extends State<ExchangeRate> {
  final _controller = TextEditingController();
  double _multiplier = 4000;

  // Common presets
  final List<double> _presets = [4000, 4050, 4100, 4150, 4200];

  @override
  void initState() {
    super.initState();
    _loadMultiplier();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadMultiplier() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getDouble('multiplier') ?? 4000;
    setState(() {
      _multiplier = value;
      _controller.text = value.toStringAsFixed(0);
    });
  }

  void _updateMultiplier(String value) {
    if (value.isEmpty) return;
    final parsed = double.tryParse(value);
    if (parsed != null) {
      setState(() {
        _multiplier = parsed;
      });
    }
  }

  void _selectPreset(double value) {
    setState(() {
      _multiplier = value;
      _controller.text = value.toStringAsFixed(0);
      _controller.selection = TextSelection.collapsed(
          offset: _controller.text.length);
    });
  }

  Future<void> _save() async {
    if (_multiplier <= 0) {
      showToast('អត្រាប្ដូរប្រាក់មិនត្រឹមត្រូវ');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('multiplier', _multiplier);
    Navigator.pop(context, _multiplier);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F7),
        appBar: AppBar(
          backgroundColor: Colors.black87,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'អត្រាប្ដូរប្រាក់',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Current rate card ───────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Text(
                      '1 USD =',
                      style: TextStyle(
                          color: Colors.white60, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _multiplier.toStringAsFixed(0),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6, left: 6),
                          child: Text(
                            '៛',
                            style: TextStyle(
                                color: Colors.orange,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Quick presets ────────────────────────────────────────────
              const Text(
                'ជ្រើសរើសរហ័ស',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Row(
                children: _presets.map((preset) {
                  final isSelected = _multiplier == preset;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () => _selectPreset(preset),
                        child: Container(
                          padding:
                          const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.black87
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black87
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            preset.toStringAsFixed(0),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // ── Manual input ─────────────────────────────────────────────
              const Text(
                'បញ្ចូលដោយខ្លួនឯង',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _controller,
                  onChanged: _updateMultiplier,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    hintText: '4000',
                    hintStyle: TextStyle(
                        color: Colors.grey.shade300, fontSize: 22),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear,
                          color: Colors.grey.shade400, size: 18),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _multiplier = 0;
                        });
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── USD preview ──────────────────────────────────────────────
              Center(
                child: Text(
                  _multiplier > 0
                      ? '10,000៛  =  ${(10000 / _multiplier).toStringAsFixed(2)}\$'
                      : '',
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black45),
                ),
              ),

              const Spacer(),

              // ── Save button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 25,)
            ],
          ),
        ),
      ),
    );
  }
}