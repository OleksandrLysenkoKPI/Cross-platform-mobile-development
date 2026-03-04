import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const PowerPlantApp());
}

class PowerPlantApp extends StatelessWidget {
  const PowerPlantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Power Plant Calculator',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
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
  final TextEditingController _powerController = TextEditingController();
  final TextEditingController _sigmaController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  Map<String, String> results = {};
  bool _showResults = false;

  void _putExampleValues() {
    setState(() {
      _powerController.text = "5";
      _sigmaController.text = "1";
      _priceController.text = "7";
    });
  }

  double calculatePd(double p, double pc, double sigma) {
    return (1 / (sigma * math.sqrt(2 * math.pi))) *
        math.exp(-math.pow(p - pc, 2) / (2 * math.pow(sigma, 2)));
  }

  double integrate(double Function(double) func, double start, double end, int steps) {
    double step = (end - start) / steps;
    double sum = 0.5 * (func(start) + func(end));

    for (int i = 0; i < steps; i++) {
      double x = start + i * step;
      sum += func(x);
    }
    return sum * step;
  }

  void _calculate() {
    double pc = double.tryParse(_powerController.text) ?? 0;
    double sigma1 = double.tryParse(_sigmaController.text) ?? 0;
    double price = double.tryParse(_priceController.text) ?? 0;
    double p = 5.0;

    double deltaW1 = integrate((x) => calculatePd(x, pc, sigma1), 4.75, 5.25, 1000);
    double w1 = pc * 24 * double.parse(deltaW1.toStringAsFixed(2));
    double income1 = w1 * price;
    double w2 = pc * 24 * (1 - double.parse(deltaW1.toStringAsFixed(2)));
    double fine1 = w2 * price;

    double sigma2 = 0.25;
    double deltaW2 = integrate((x) => calculatePd(x, pc, sigma2), 4.75, 5.25, 1000);
    double w3 = pc * 24 * double.parse(deltaW2.toStringAsFixed(2));
    double income2 = w3 * price;
    double w4 = pc * 24 * (1 - double.parse(deltaW2.toStringAsFixed(2)));
    double fine2 = w4 * price;
    double incomeFinale = income2 - fine2;

    setState(() {
      results = {
        'norm_law': calculatePd(p, pc, sigma1).toStringAsFixed(2),
        'energy_piece_1': (deltaW1 * 100).toStringAsFixed(2),
        'W_1': w1.toStringAsFixed(0),
        'income_1': income1.toStringAsFixed(0),
        'W_2': w2.toStringAsFixed(0),
        'fine_1': fine1.toStringAsFixed(0),
        'energy_piece_2': (deltaW2 * 100).toStringAsFixed(2),
        'W_3': w3.toStringAsFixed(1),
        'income_2': income2.toStringAsFixed(1),
        'W_4': w4.toStringAsFixed(1),
        'fine_2': fine2.toStringAsFixed(1),
        'income_finale': incomeFinale.toStringAsFixed(1),
      };
      _showResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Обрахунок прибутку станції'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade200,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueGrey.shade700, Colors.teal.shade800],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputField(_powerController, 'Середньодобова потужність (Pc)'),
              _buildInputField(_sigmaController, 'Середньоквадратичне відхилення (σ1)'),
              _buildInputField(_priceController, 'Вартість електроенергії'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _calculate,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade900, foregroundColor: Colors.white),
                      child: const Text('Обрахувати'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _putExampleValues,
                      child: const Text('Контрольний приклад'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_showResults) _buildResultsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.yellowAccent),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.yellowAccent)),
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    return Card(
      color: Colors.white.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Результати розрахунків:', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.white24),
            _resultText('Нормальний закон розподілу (pd):', results['norm_law']!),
            _resultText('Частка без небалансів (δW1):', '${results['energy_piece_1']}%'),
            _resultText('Прибуток (П1):', '${results['income_1']} тис. грн'),
            _resultText('Штраф (Ш1):', '${results['fine_1']} тис. грн'),
            const Divider(color: Colors.white24),
            _resultText('Частка без небалансів (δW2):', '${results['energy_piece_2']}%'),
            _resultText('Прибуток (П2):', '${results['income_2']} тис. грн'),
            _resultText('Штраф (Ш2):', '${results['fine_2']} тис. грн'),
            const SizedBox(height: 10),
            Text(
              'Відповідь: Прибуток П = ${results['income_finale']} тис. грн',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 2, color: Colors.black)])),
        ],
      ),
    );
  }
}