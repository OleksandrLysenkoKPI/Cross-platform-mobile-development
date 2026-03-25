import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const LoadCalcApp());
}

class LoadCalcApp extends StatelessWidget {
  const LoadCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Electric Load Calculator',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'monospace',
      ),
      home: const LoadCalculatorScreen(),
    );
  }
}

class LoadCalculatorScreen extends StatefulWidget {
  const LoadCalculatorScreen({super.key});

  @override
  State<LoadCalculatorScreen> createState() => _LoadCalculatorScreenState();
}

class _LoadCalculatorScreenState extends State<LoadCalculatorScreen> {
  final _powerController = TextEditingController();
  final _coefController = TextEditingController();
  final _tgController = TextEditingController();

  Map<String, String>? _res;

  void _calculate() {
    double pn = double.tryParse(_powerController.text) ?? 0;
    double kv = double.tryParse(_coefController.text) ?? 0;
    double tg = double.tryParse(_tgController.text) ?? 0;

    double productNominalSand = 4 * pn;

    double sumProductNominalMultKv = (productNominalSand * 0.15) + 3.36 + 25.2 + 10.8 + 10 + (40 * kv) + 12.8 + 13;
    double sumProductNominal = productNominalSand + 28 + 168 + 36 + 20 + 40 + 64 + 20;
    double squarePSumProductNominal = (4 * pow(pn, 2)) + 392 + 7056 + 1296 + 400 + 1600 + 2048 + 400;
    double sumProductNominalMultKvWithTg = (productNominalSand * 0.15 * 1.33) + 3.36 + 33.5 + (36 * 0.3 * tg) + 7.5 + (40 * kv * 1) + 12.8 + 9.5;

    double groupKv = sumProductNominalMultKv / sumProductNominal;
    double effectiveEPnum = (pow(sumProductNominal, 2) / squarePSumProductNominal) + 1;
    double estimatedActLoad = 1.25 * sumProductNominalMultKv;
    double estimatedREactLoad = 1 * sumProductNominalMultKvWithTg;
    double fullPower = sqrt(pow(estimatedActLoad, 2) + pow(estimatedREactLoad, 2));
    double groupElectricity = estimatedActLoad / 0.38;

    double totalKv = 752 / 2330;
    double totalEffectiveEPnum = pow(2330, 2) / 96399;
    double estimatedTireActLoad = 0.7 * 752;
    double estimatedTireREactLoad = 0.7 * 657;
    double fullTirePower = sqrt(pow(estimatedTireActLoad, 2) + pow(estimatedTireREactLoad, 2));
    double tireGroupElectricity = estimatedTireActLoad / 0.38;

    setState(() {
      _res = {
        'groupKv': groupKv.toStringAsFixed(4),
        'effEP': effectiveEPnum.toStringAsFixed(0),
        'actLoad': estimatedActLoad.toStringAsFixed(2),
        'reactLoad': estimatedREactLoad.toStringAsFixed(2),
        'fullP': fullPower.toStringAsFixed(3),
        'groupI': groupElectricity.toStringAsFixed(2),
        'totKv': totalKv.toStringAsFixed(2),
        'totEffEP': totalEffectiveEPnum.toStringAsFixed(0),
        'tireAct': estimatedTireActLoad.toStringAsFixed(1),
        'tireReact': estimatedTireREactLoad.toStringAsFixed(1),
        'tireFull': fullTirePower.toStringAsFixed(0),
        'tireI': tireGroupElectricity.toStringAsFixed(2),
      };
    });
  }

  void _fillExample() {
    setState(() {
      _powerController.text = "20";
      _coefController.text = "0.2";
      _tgController.text = "1.52";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4B5F78), Color(0xFF169DA9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Розрахунок електричних навантажень',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                _buildGlassCard(
                  child: Column(
                    children: [
                      _buildInput("Номінальна потужність (Pn):", _powerController),
                      _buildInput("Коефіцієнт використання (Kv):", _coefController),
                      _buildInput("Коефіцієнт реактивної потужності (tg φ):", _tgController),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _calculate,
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF112A46)),
                            child: const Text('Обрахувати'),
                          ),
                          ElevatedButton(
                            onPressed: _fillExample,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                            child: const Text('Приклад'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                if (_res != null) ...[
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.yellow, fontSize: 13)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
      ),
      child: child,
    );
  }

  Widget _buildResultsCard() {
    return _buildGlassCard(
      child: ExpansionTile(
        initiallyExpanded: true,
        title: const Text("Результати (ШР та Цех)", style: TextStyle(color: Colors.white)),
        children: [
          _resRow("Груп. коеф. використання:", _res!['groupKv']!),
          _resRow("Ефективна кількість ЕП:", _res!['effEP']!),
          _resRow("Активне навантаження:", "${_res!['actLoad']} кВт"),
          _resRow("Реактивне навантаження:", "${_res!['reactLoad']} квар"),
          _resRow("Повна потужність:", "${_res!['fullP']} кВА"),
          _resRow("Груповий струм:", "${_res!['groupI']} А"),
          const Divider(color: Colors.white30),
          _resRow("Загальний коеф. вик.:", _res!['totKv']!),
          _resRow("Еф. кількість ЕП (цех):", _res!['totEffEP']!),
          _resRow("Навантаження на шинах:", "${_res!['tireAct']} кВт"),
          _resRow("Повна потужність шин:", "${_res!['tireFull']} кВА"),
          _resRow("Струм на шинах 0,38 кВ:", "${_res!['tireI']} А"),
        ],
      ),
    );
  }

  Widget _resRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: const TextStyle(fontSize: 12))),
          Text(value, style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}