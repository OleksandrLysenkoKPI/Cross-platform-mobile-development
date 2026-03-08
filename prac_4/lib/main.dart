import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const EnergyCalculatorApp());
}

class EnergyCalculatorApp extends StatelessWidget {
  const EnergyCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Енерго Калькулятор',
      theme: ThemeData(
        primaryColor: const Color(0xFF2C3E50),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Електротехнічні розрахунки'),
          backgroundColor: Colors.blueGrey[50],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: '1. Вибір кабелю'),
              Tab(text: '2. Струми ГПП'),
              Tab(text: '3. Режими ХПнЕМ'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Task1Screen(),
            Task2Screen(),
            Task3Screen(),
          ],
        ),
      ),
    );
  }
}


class Task1Screen extends StatefulWidget {
  const Task1Screen({super.key});

  @override
  State<Task1Screen> createState() => _Task1ScreenState();
}

class _Task1ScreenState extends State<Task1Screen> {
  final TextEditingController _smController = TextEditingController(text: "1300");
  final TextEditingController _ikController = TextEditingController(text: "2500");
  final TextEditingController _tfController = TextEditingController(text: "2.5");
  String _result = "";

  void _calculate() {
    double sm = double.tryParse(_smController.text) ?? 0;
    double ik = double.tryParse(_ikController.text) ?? 0;
    double tf = double.tryParse(_tfController.text) ?? 0;

    double im = (sm / 2) / (sqrt(3) * 10);
    double impa = 2 * im;
    double sek = im / 1.4;
    double smin = (ik * sqrt(tf)) / 92;

    setState(() {
      _result = "Розрахунковий струм (норм): ${im.toStringAsFixed(1)} А\n"
          "Післяаварійний струм: ${impa.toStringAsFixed(0)} А\n"
          "Економічний переріз: ${sek.toStringAsFixed(1)} мм²\n"
          "Мінімальний переріз (s ≥ s_min): ${smin.toStringAsFixed(0)} мм²";
    });
  }

  @override
  Widget build(BuildContext context) => _buildLayout([
    _buildField(_smController, "S_m (Повна потужність)"),
    _buildField(_ikController, "I_к (Струм КЗ)"),
    _buildField(_tfController, "t_ф (Фіктивний час)"),
    _buildButton(_calculate),
    _buildResult(_result),
  ]);
}

class Task2Screen extends StatefulWidget {
  const Task2Screen({super.key});

  @override
  State<Task2Screen> createState() => _Task2ScreenState();
}


class _Task2ScreenState extends State<Task2Screen> {
  final TextEditingController _skController = TextEditingController(text: "200");
  String _result = "";

  void _calculate() {
    double sk = double.tryParse(_skController.text) ?? 0;
    double xc = pow(10.5, 2) / sk;
    double xt = (10.5 / 100) * (pow(10.5, 2) / 6.3);
    double xsum = xc + xt;
    double ip0 = 10.5 / (sqrt(3) * xsum);

    setState(() {
      _result = "Опір системи (Xc): ${xc.toStringAsFixed(2)} Ом\n"
          "Опір трансформатора (Xt): ${xt.toStringAsFixed(2)} Ом\n"
          "Сумарний опір: ${xsum.toStringAsFixed(2)} Ом\n"
          "Струм трифазного КЗ: ${ip0.toStringAsFixed(1)} кА";
    });
  }

  @override
  Widget build(BuildContext context) => _buildLayout([
    _buildField(_skController, "S_k (Потужність КЗ системи)"),
    _buildButton(_calculate),
    _buildResult(_result),
  ]);
}


class Task3Screen extends StatefulWidget {
  const Task3Screen({super.key});

  @override
  State<Task3Screen> createState() => _Task3ScreenState();
}

class _Task3ScreenState extends State<Task3Screen> {
  final TextEditingController _rsn = TextEditingController(text: "10.65");
  final TextEditingController _xsn = TextEditingController(text: "24.02");
  final TextEditingController _rsnMin = TextEditingController(text: "34.88");
  final TextEditingController _xsnMin = TextEditingController(text: "65.68");
  String _result = "";

  void _calculate() {
    double rsn = double.tryParse(_rsn.text) ?? 0;
    double xsn = double.tryParse(_xsn.text) ?? 0;
    double rsnMin = double.tryParse(_rsnMin.text) ?? 0;
    double xsnMin = double.tryParse(_xsnMin.text) ?? 0;

    double xt = (11.1 * pow(115, 2)) / (100 * 6.3);
    double kpr = pow(11, 2) / pow(115, 2);

    // Нормальний режим (110 кВ та 10 кВ)
    double zsh = sqrt(pow(rsn, 2) + pow(xsn + xt, 2));
    double ish3 = (115 * 1000) / (sqrt(3) * zsh);
    double zshn = sqrt(pow(rsn * kpr, 2) + pow((xsn + xt) * kpr, 2));
    double ishn3 = (11 * 1000) / (sqrt(3) * zshn);

    // Мінімальний режим
    double zshMin = sqrt(pow(rsnMin, 2) + pow(xsnMin + xt, 2));
    double ish3Min = (115 * 1000) / (sqrt(3) * zshMin);
    double zshnMin = sqrt(pow(rsnMin * kpr, 2) + pow((xsnMin + xt) * kpr, 2));
    double ishn3Min = (11 * 1000) / (sqrt(3) * zshnMin);

    setState(() {
      _result = "--- НОРМАЛЬНИЙ РЕЖИМ ---\n"
          "Шини 110кВ: I(3)=${ish3.toStringAsFixed(0)}А, I(2)=${(ish3 * 0.866).toStringAsFixed(0)}А\n"
          "Шини 10кВ: I(3)=${ishn3.toStringAsFixed(0)}А, I(2)=${(ishn3 * 0.866).toStringAsFixed(0)}А\n\n"
          "--- МІНІМАЛЬНИЙ РЕЖИМ ---\n"
          "Шини 110кВ: I(3)=${ish3Min.toStringAsFixed(0)}А, I(2)=${(ish3Min * 0.866).toStringAsFixed(0)}А\n"
          "Шини 10кВ: I(3)=${ishn3Min.toStringAsFixed(0)}А, I(2)=${(ishn3Min * 0.866).toStringAsFixed(0)}А";
    });
  }

  @override
  Widget build(BuildContext context) => _buildLayout([
    _buildField(_rsn, "R_sn (Норм)"),
    _buildField(_xsn, "X_sn (Норм)"),
    _buildField(_rsnMin, "R_sn (Min)"),
    _buildField(_xsnMin, "X_sn (Min)"),
    _buildButton(_calculate),
    _buildResult(_result),
  ]);
}

// ВІДЖЕТИ

Widget _buildLayout(List<Widget> children) => SingleChildScrollView(
  padding: const EdgeInsets.all(16.0),
  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
);

Widget _buildField(TextEditingController controller, String label) => Padding(
  padding: const EdgeInsets.only(bottom: 12.0),
  child: TextField(
    controller: controller,
    decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    keyboardType: TextInputType.number,
  ),
);

Widget _buildButton(VoidCallback onPressed) => ElevatedButton(
  onPressed: onPressed,
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF2C3E50),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16),
  ),
  child: const Text('ОБРАХУВАТИ'),
);

Widget _buildResult(String result) {
  if (result.isEmpty) return const SizedBox.shrink();
  return Container(
    margin: const EdgeInsets.only(top: 20),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.blueGrey[50],
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.blueGrey[200]!),
    ),
    child: Text(result, style: const TextStyle(fontSize: 14, height: 1.5)),
  );
}