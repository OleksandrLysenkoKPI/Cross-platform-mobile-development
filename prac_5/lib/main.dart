import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const ReliabilityApp());
}

class ReliabilityApp extends StatelessWidget {
  const ReliabilityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reliability Calculator',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'monospace',
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _nController = TextEditingController();
  final _acPriceController = TextEditingController();
  final _plPriceController = TextEditingController();

  Map<String, String>? _results;

  void _calculate() {
    double n = double.tryParse(_nController.text) ?? 0;
    double acPrice = double.tryParse(_acPriceController.text) ?? 0;
    double plPrice = double.tryParse(_plPriceController.text) ?? 0;

    double wOc = 0.01 + 0.07 + 0.015 + 0.02 + 0.03 * n;
    double tvOc = (0.01 * 30 + 0.07 * 10 + 0.015 * 100 + 0.02 * 15 + (0.03 * n) * 2) / wOc;
    double kaOc = (wOc * tvOc) / 8760;
    double kpOc = 1.2 * (43.0 / 8760.0);
    double wDk = 2 * wOc * (kaOc + kpOc);
    double wDc = wDk + 0.02;

    double mathNedA = 0.01 * 45 * pow(10, -3) * 5.12 * pow(10, 3) * 6451;
    double mathNedP = 4 * pow(10, 3) * 5.12 * pow(10, 3) * 6451;
    double mathLosses = acPrice * mathNedA + plPrice * mathNedP;

    setState(() {
      _results = {
        'wOc': wOc.toStringAsFixed(4),
        'tvOc': tvOc.toStringAsFixed(1),
        'kaOc': kaOc.toStringAsFixed(5),
        'kpOc': kpOc.toStringAsFixed(5),
        'wDk': wDk.toStringAsFixed(5),
        'wDc': wDc.toStringAsFixed(4),
        'mathNedA': mathNedA.toStringAsFixed(2),
        'mathNedP': mathNedP.toStringAsFixed(2),
        'mathLosses': mathLosses.toStringAsFixed(2),
      };
    });
  }

  void _putExample() {
    setState(() {
      _nController.text = "6";
      _acPriceController.text = "23.6";
      _plPriceController.text = "17.6";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4B5F78), Color(0xFF169DA9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: SafeArea(
            child: Column(
              children: [
                const Text(
                  'Порівняння надійності та збитків',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.pink, blurRadius: 10)]),
                ),
                const SizedBox(height: 20),
                _buildGlassCard(
                  child: Column(
                    children: [
                      _buildInput("Кількість приєднань:", _nController),
                      _buildInput("Ціна кВт*год (аварійні):", _acPriceController),
                      _buildInput("Ціна кВт*год (планові):", _plPriceController),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _calculate,
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF112A46)),
                            child: const Text('Обрахувати'),
                          ),
                          ElevatedButton(
                            onPressed: _putExample,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                            child: const Text('Приклад'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                if (_results != null) ...[
                  const SizedBox(height: 20),
                  _buildResultsCard(),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black12,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: child,
    );
  }

  Widget _buildResultsCard() {
    return _buildGlassCard(
      child: ExpansionTile(
        initiallyExpanded: true,
        title: const Text("Результати", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        children: [
          _resultRow("Частота відмов одноколової:", "${_results!['wOc']} рік⁻¹"),
          _resultRow("Середній час відновлення:", "${_results!['tvOc']} год"),
          _resultRow("Коеф. ав. простою:", _results!['kaOc']!),
          _resultRow("Коеф. пл. простою:", _results!['kpOc']!),
          _resultRow("Частота подвійних відмов:", _results!['wDk']!),
          _resultRow("Відмови з секц. вимикачем:", _results!['wDc']!),
          const Divider(color: Colors.red),
          _resultRow("Мат. недовідп. (ав):", "${_results!['mathNedA']} кВт*год"),
          _resultRow("Мат. недовідп. (пл):", "${_results!['mathNedP']} кВт*год"),
          _resultRow("Збитки:", "${_results!['mathLosses']} грн", isBold: true),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: const TextStyle(fontSize: 12))),
          Text(value, style: TextStyle(color: Colors.yellow, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}