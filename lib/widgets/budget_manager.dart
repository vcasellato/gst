import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/transaction_service.dart';
import '../utils/constants.dart';

class BudgetManager extends StatefulWidget {
  const BudgetManager({super.key});

  @override
  State<BudgetManager> createState() => _BudgetManagerState();
}

class _BudgetManagerState extends State<BudgetManager> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    final service = context.read<TransactionService>();
    for (final cat in AppConstants.categories) {
      final limit = service.budgetLimits[cat] ?? 0;
      _controllers[cat] = TextEditingController(
        text: limit > 0 ? limit.toStringAsFixed(2) : '',
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final service = context.read<TransactionService>();
    for (final cat in AppConstants.categories) {
      final value = double.tryParse(_controllers[cat]?.text ?? '');
      if (value != null && value > 0) {
        service.setBudgetLimit(cat, value);
      }
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orçamento')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...AppConstants.categories.map((c) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                controller: _controllers[c],
                decoration: InputDecoration(
                  labelText: c,
                  border: const OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            );
          }),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _save, child: const Text('Salvar')),
        ],
      ),
    );
  }
}
