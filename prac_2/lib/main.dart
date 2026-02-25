import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const EmissionCalculatorApp());
}

class EmissionCalculatorApp extends StatelessWidget {
  const EmissionCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Emission Mobile Calc',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
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
  final _coalController = TextEditingController();
  final _mazutController = TextEditingController();
  final _gasController = TextEditingController();

  Map<String, List<String>> results = {};

  void _calculate() {
    setState(() {
      double coalInp = double.tryParse(_coalController.text) ?? 0;
      double mazutInp = double.tryParse(_mazutController.text) ?? 0;
      double gasInp = double.tryParse(_gasController.text) ?? 0;

      double coalEmission = (pow(10, 6) / 20.47) * 0.8 * 25.2 / (100 - 1.5) * (1 - 0.985);
      double coalTotal = pow(10, -6) * coalEmission * 20.47 * coalInp;

      double mazutEmission = (pow(10, 6) / 39.48) * 1 * 0.15 / (100 - 0) * (1 - 0.985);
      double mazutTotal = pow(10, -6) * mazutEmission * 39.48 * mazutInp;

      double gasEmission = 0;
      double gasTotal = 0 * gasInp; 

      results = {
        "Вугілля": [coalEmission.toStringAsFixed(2), coalTotal.toStringAsFixed(2)],
        "Мазут": [mazutEmission.toStringAsFixed(2), mazutTotal.toStringAsFixed(2)],
        "Газ": [gasEmission.toString(), gasTotal.toString()],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Калькулятор викидів"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildInputField("Вугілля (т)", _coalController, Icons.factory),
            _buildInputField("Мазут (т)", _mazutController, Icons.opacity),
            _buildInputField("Газ (тис. м³)", _gasController, Icons.air),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text("ОБРАХУВАТИ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 25),
            if (results.isNotEmpty) ...[
              const Text("Результати розрахунків:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildResultCard("Вугілля", results["Вугілля"]!),
              _buildResultCard("Мазут", results["Мазут"]!),
              _buildResultCard("Газ", results["Газ"]!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.teal),
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildResultCard(String title, List<String> values) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
            const Divider(),
            Text("Показник емісії: ${values[0]} г/ГДж"),
            Text("Валовий викид: ${values[1]} т."),
          ],
        ),
      ),
    );
  }
}