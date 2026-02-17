import 'package:flutter/material.dart';

void main() {
  runApp(const FuelCalculatorApp());
}

class FuelCalculatorApp extends StatelessWidget {
  const FuelCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fuel Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const FuelCalculatorScreen(),
    );
  }
}

class FuelCalculatorScreen extends StatefulWidget {
  const FuelCalculatorScreen({super.key});

  @override
  State<FuelCalculatorScreen> createState() => _FuelCalculatorScreenState();
}

class _FuelCalculatorScreenState extends State<FuelCalculatorScreen> {
  final TextEditingController hController = TextEditingController();
  final TextEditingController cController = TextEditingController();
  final TextEditingController sController = TextEditingController();
  final TextEditingController nController = TextEditingController();
  final TextEditingController oController = TextEditingController();
  final TextEditingController wController = TextEditingController();
  final TextEditingController aController = TextEditingController();

  String results = "";

  void calculateExample() {
    setState(() {
      hController.text = "1.9";
      cController.text = "21.1";
      sController.text = "2.6";
      nController.text = "0.2";
      oController.text = "7.1";
      wController.text = "53";
      aController.text = "14.1";
    });
    calculate();
  }

  void calculate() {
    double H = double.tryParse(hController.text) ?? 0;
    double C = double.tryParse(cController.text) ?? 0;
    double S = double.tryParse(sController.text) ?? 0;
    double N = double.tryParse(nController.text) ?? 0;
    double O = double.tryParse(oController.text) ?? 0;
    double W = double.tryParse(wController.text) ?? 0;
    double A = double.tryParse(aController.text) ?? 0;

    const double tolerance = 0.01;
    double kPc = 100 / (100 - W);
    double kPg = 100 / (100 - W - A);

    double hC = H * kPc;
    double oC = O * kPc;
    double nC = N * kPc;
    double aC = A * kPc;
    double sC = S * kPc;
    double cC = C * kPc;

    double cG = C * kPg;
    double oG = O * kPg;
    double nG = N * kPg;
    double sG = S * kPg;
    double hG = H * kPg;

    double qPh = (339 * C + 1030 * H - 108.8 * (O - S) - 25 * W) / 1000;
    double qCh = (qPh + 0.025 * W) * (100 / (100 - W));
    double qGh = (qPh + 0.025 * W) * (100 / (100 - W - A));

    if ((H + C + S + N + O + W + A - 100).abs() > tolerance) {
      _showAlert("Елементарний склад РОБОЧОГО палива не дорівнює 100%.");
      return;
    }

    setState(() {
      results = """
Коефіцієнт Kpc: ${kPc.toStringAsFixed(2)}
Коефіцієнт Kpg: ${kPg.toStringAsFixed(2)}

Склад сухої маси (%):
Hc = ${hC.toStringAsFixed(2)}, Oc = ${oC.toStringAsFixed(2)}, Nc = ${nC.toStringAsFixed(3)}, 
Ac = ${aC.toStringAsFixed(2)}, Sc = ${sC.toStringAsFixed(2)}, Cc = ${cC.toStringAsFixed(2)}

Склад горючої маси (%):
Hg = ${hG.toStringAsFixed(2)}, Og = ${oG.toStringAsFixed(2)}, Ng = ${nG.toStringAsFixed(3)}, 
Sg = ${sG.toStringAsFixed(2)}, Cg = ${cG.toStringAsFixed(2)}

Нижча теплота згоряння (МДж/кг):
Qp_h = ${qPh.toStringAsFixed(2)}
Qc_h = ${qCh.toStringAsFixed(2)}
Qg_h = ${qGh.toStringAsFixed(2)}
      """;
    });
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Помилка"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("ОК"))
        ],
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        "Калькулятор палива",
        style: TextStyle(color: Colors.blue),
      ),
      backgroundColor: Colors.grey[300],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInput("H %", hController),
              _buildInput("C %", cController),
              _buildInput("S %", sController),
              _buildInput("N %", nController),
              _buildInput("O %", oController),
              _buildInput("W %", wController),
              _buildInput("A %", aController),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(onPressed: calculateExample, child: const Text("Приклад")),
                  const SizedBox(width: 10),
                  ElevatedButton(onPressed: calculate, child: const Text("Обчислити")),
                ],
              ),
              const SizedBox(height: 20),
              if (results.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(results, style: const TextStyle(fontSize: 16)),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(width: 50, child: Text(label)),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
            ),
          ),
        ],
      ),
    );
  }
}