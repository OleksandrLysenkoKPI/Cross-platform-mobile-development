import 'package:flutter/material.dart';

void main() {
  runApp(const OilCalculatorApp());
}

class OilCalculatorApp extends StatelessWidget {
  const OilCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oil Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const OilCalculatorScreen(),
    );
  }
}

class OilCalculatorScreen extends StatefulWidget {
  const OilCalculatorScreen({super.key});

  @override
  State<OilCalculatorScreen> createState() => _OilCalculatorScreenState();
}

class _OilCalculatorScreenState extends State<OilCalculatorScreen> {
  final TextEditingController cController = TextEditingController();
  final TextEditingController hController = TextEditingController();
  final TextEditingController oController = TextEditingController();
  final TextEditingController sController = TextEditingController();
  final TextEditingController qController = TextEditingController();
  final TextEditingController vController = TextEditingController();
  final TextEditingController aController = TextEditingController();
  final TextEditingController wController = TextEditingController();

  String results = "";

  void calculateExample() {
    setState(() {
      cController.text = "85.5";
      hController.text = "11.2";
      oController.text = "0.8";
      sController.text = "2.5";
      qController.text = "40.4";
      vController.text = "2";
      aController.text = "0.15";
      wController.text = "333.3";
    });
    calculate();
  }

  void calculate() {
    double C = double.tryParse(cController.text) ?? 0;
    double H = double.tryParse(hController.text) ?? 0;
    double O = double.tryParse(oController.text) ?? 0;
    double S = double.tryParse(sController.text) ?? 0;
    double Q = double.tryParse(qController.text) ?? 0;
    double V = double.tryParse(vController.text) ?? 0;
    double A = double.tryParse(aController.text) ?? 0;
    double W = double.tryParse(wController.text) ?? 0;

    double eq1 = (100 - V - A) / 100;
    double eq2 = (100 - V) / 100;

    double cr = C * eq1;
    double hr = H * eq1;
    double or = O * eq1;
    double sr = S * eq1;
    double ar = A * eq2;
    double wr = W * eq2;

    double qr = Q * ((100 - V - ar) / 100) - 0.025 * V;

    setState(() {
      results = """
Склад робочої маси мазуту (%):
Hp = ${hr.toStringAsFixed(2)}, Op = ${or.toStringAsFixed(2)}, 
Ap = ${ar.toStringAsFixed(2)}, Sp = ${sr.toStringAsFixed(2)}, 
Cp = ${cr.toStringAsFixed(2)}

Ванадій (Vp): ${wr.toStringAsFixed(2)} мг/кг

Нижча теплота згоряння (МДж/кг):
Qr_i = ${qr.toStringAsFixed(2)}
      """;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Калькулятор мазуту", style: TextStyle(color: Colors.blue)),
        backgroundColor: Colors.grey[300],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInput("C %", cController),
                _buildInput("H %", hController),
                _buildInput("O %", oController),
                _buildInput("S %", sController),
                _buildInput("Q (МДж/кг)", qController),
                _buildInput("Вологість %", vController),
                _buildInput("Зольність %", aController),
                _buildInput("Ванадій (мг/кг)", wController),
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
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          SizedBox(width: 150, child: Text(label)),
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