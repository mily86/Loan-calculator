import 'package:flutter/material.dart';
import 'dart:math';

class LoanCalculatorScreen extends StatefulWidget {
  const LoanCalculatorScreen({super.key});

  @override
  State<LoanCalculatorScreen> createState() => _LoanCalculatorScreenState();
}

class _LoanCalculatorScreenState extends State<LoanCalculatorScreen> {
  final loanController = TextEditingController();
  final rateController = TextEditingController();
  final periodController = TextEditingController();

  String frequency = 'Monthly';
  double installment = 0.0;
  String summary = '';

  final List<String> frequencies = ['Monthly', 'Quarterly', 'Yearly'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Loan Repayment Calculator"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: loanController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Loan Amount (RM)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: rateController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Interest Rate (% per year)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: periodController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Loan Period (Years)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: frequency,
              items:
                  frequencies.map((String value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
              onChanged: (val) {
                setState(() {
                  frequency = val!;
                });
              },
              decoration: InputDecoration(
                labelText: "Payment Frequency",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: calculateLoan, child: Text("Calculate")),
            SizedBox(height: 24),
            if (summary.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(summary, style: TextStyle(fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void calculateLoan() {
    double? amount = double.tryParse(loanController.text);
    double? annualRate = double.tryParse(rateController.text);
    int? years = int.tryParse(periodController.text);

    if (amount == null ||
        annualRate == null ||
        years == null ||
        amount <= 0 ||
        years <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Please enter valid numbers.")));
      return;
    }

    int paymentsPerYear =
        {'Monthly': 12, 'Quarterly': 4, 'Yearly': 1}[frequency]!;

    int totalPayments = years * paymentsPerYear;
    double ratePerPeriod = (annualRate / 100) / paymentsPerYear;

    if (ratePerPeriod == 0) {
      installment = amount / totalPayments;
    } else {
      installment =
          (amount * ratePerPeriod) /
          (1 - pow(1 + ratePerPeriod, -totalPayments));
    }

    setState(() {
      summary = '''
Loan Amount: RM${amount.toStringAsFixed(2)}
Interest Rate: ${annualRate.toStringAsFixed(2)}%
Loan Period: $years years
Payment Frequency: $frequency

Installment: RM${installment.toStringAsFixed(2)} per $frequency
''';
    });
  }
}
