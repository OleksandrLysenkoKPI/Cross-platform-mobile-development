import 'package:flutter/material.dart';

void main() {
  runApp(const MultiCalculatorApp());
}

class MultiCalculatorApp extends StatelessWidget {
  const MultiCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Energy Calculators',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    FuelCalculatorPage(),
    OilCalculatorPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.local_gas_station), label: 'Паливо'),
          BottomNavigationBarItem(icon: Icon(Icons.oil_barrel), label: 'Мазут'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Завдання 1: Калькулятор палива
class FuelCalculatorPage extends StatefulWidget {
  const FuelCalculatorPage({super.key});

  @override
  State<FuelCalculatorPage> createState() => _FuelCalculatorPageState();
}

class _FuelCalculatorPageState extends State<FuelCalculatorPage> {
  final Map<String, TextEditingController> _controllers = {
    'H': TextEditingController(),
    'C': TextEditingController(),
    'S': TextEditingController(),
    'N': TextEditingController(),
    'O': TextEditingController(),
    'W': TextEditingController(),
    'A': TextEditingController(),
  };

  String _result = "Введіть дані";

  void _calculateExample() {
    setState(() {
      _controllers['H']?.text = "1.9";
      _controllers['C']?.text = "21.1";
      _controllers['S']?.text = "2.6";
      _controllers['N']?.text = "0.2";
      _controllers['O']?.text = "7.1";
      _controllers['W']?.text = "53";
      _controllers['A']?.text = "14.1";
    });
    _calculate();
  }

  void _calculate() {
    double h = double.tryParse(_controllers['H']!.text) ?? 0;
    double c = double.tryParse(_controllers['C']!.text) ?? 0;
    double s = double.tryParse(_controllers['S']!.text) ?? 0;
    double n = double.tryParse(_controllers['N']!.text) ?? 0;
    double o = double.tryParse(_controllers['O']!.text) ?? 0;
    double w = double.tryParse(_controllers['W']!.text) ?? 0;
    double a = double.tryParse(_controllers['A']!.text) ?? 0;

    double sum = h + c + s + n + o + w + a;
    if ((sum - 100).abs() > 0.01) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Склад палива ($sum%) не дорівнює 100%!")),
      );
      return;
    }

    double kPc = 100 / (100 - w);
    double kPg = 100 / (100 - w - a);
    double qPh = (339 * c + 1030 * h - 108.8 * (o - s) - 25 * w) / 1000;
    double qCh = (qPh + 0.025 * w) * (100 / (100 - w));
    double qGh = (qPh + 0.025 * w) * (100 / (100 - w - a));

    setState(() {
      _result = """
Коефіцієнти: Kpc = ${kPc.toStringAsFixed(2)}, Kpg = ${kPg.toStringAsFixed(2)}

Нижча теплота згоряння (МДж/кг):
Qp_н = ${qPh.toStringAsFixed(4)}
Qс_н = ${qCh.toStringAsFixed(4)}
Qг_н = ${qGh.toStringAsFixed(4)}
      """;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Калькулятор палива"), backgroundColor: Colors.blue[100]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ..._controllers.entries.map((e) => TextField(
              controller: e.value,
              decoration: InputDecoration(labelText: "${e.key} (%)"),
              keyboardType: TextInputType.number,
            )),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _calculateExample, child: const Text("Приклад")),
                ElevatedButton(onPressed: _calculate, child: const Text("Обчислити")),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.grey[200],
              child: Text(_result, style: const TextStyle(fontSize: 16, fontFamily: 'monospace')),
            ),
          ],
        ),
      ),
    );
  }
}

// Завдання 2: Калькулятор мазуту
class OilCalculatorPage extends StatefulWidget {
  const OilCalculatorPage({super.key});

  @override
  State<OilCalculatorPage> createState() => _OilCalculatorPageState();
}

class _OilCalculatorPageState extends State<OilCalculatorPage> {
  final Map<String, TextEditingController> _controllers = {
    'C': TextEditingController(),
    'H': TextEditingController(),
    'O': TextEditingController(),
    'S': TextEditingController(),
    'Q': TextEditingController(),
    'V': TextEditingController(),
    'A': TextEditingController(),
    'W': TextEditingController(),
  };

  String _result = "Результати з'являться тут";

  void _calculateExample() {
    setState(() {
      _controllers['C']?.text = "85.5";
      _controllers['H']?.text = "11.2";
      _controllers['O']?.text = "0.8";
      _controllers['S']?.text = "2.5";
      _controllers['Q']?.text = "40.4";
      _controllers['V']?.text = "2";
      _controllers['A']?.text = "0.15";
      _controllers['W']?.text = "333.3";
    });
    _calculate();
  }

  void _calculate() {
    double c = double.tryParse(_controllers['C']!.text) ?? 0;
    double h = double.tryParse(_controllers['H']!.text) ?? 0;
    double o = double.tryParse(_controllers['O']!.text) ?? 0;
    double s = double.tryParse(_controllers['S']!.text) ?? 0;
    double q = double.tryParse(_controllers['Q']!.text) ?? 0;
    double v = double.tryParse(_controllers['V']!.text) ?? 0;
    double a = double.tryParse(_controllers['A']!.text) ?? 0;
    double w = double.tryParse(_controllers['W']!.text) ?? 0;

    double eq1 = (100 - v - a) / 100;
    double eq2 = (100 - v) / 100;

    double cr = c * eq1;
    double hr = h * eq1;
    double or = o * eq1;
    double sr = s * eq1;
    double ar = a * eq2;
    double wr = w * eq2;

    double qr = q * ((100 - v - ar) / 100) - 0.025 * v;

    setState(() {
      _result = """
Склад робочої маси:
Hp: ${hr.toStringAsFixed(2)}%, Op: ${or.toStringAsFixed(2)}%, 
Vp: ${wr.toStringAsFixed(2)} мг/кг, Ap: ${ar.toStringAsFixed(2)}%, 
Sp: ${sr.toStringAsFixed(2)}%, Cp: ${cr.toStringAsFixed(2)}%

Нижча теплота згоряння (Qri):
${qr.toStringAsFixed(2)} МДж/кг
      """;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Калькулятор мазуту"), backgroundColor: Colors.orange[100]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ..._controllers.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: e.value,
                decoration: InputDecoration(labelText: _getLabel(e.key), border: const OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
            )),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _calculateExample, child: const Text("Приклад")),
                ElevatedButton(onPressed: _calculate, child: const Text("Обчислити")),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
              child: Text(_result, style: const TextStyle(fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }

  String _getLabel(String key) {
    Map<String, String> labels = {
      'C': 'C (%)', 'H': 'H (%)', 'O': 'O (%)', 'S': 'S (%)',
      'Q': 'Qг_н (МДж/кг)', 'V': 'W (%)', 'A': 'Ac (%)', 'W': 'V (мг/кг)'
    };
    return labels[key] ?? key;
  }
}