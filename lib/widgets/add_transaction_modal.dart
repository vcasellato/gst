import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';
import '../utils/constants.dart';

class AddTransactionModal extends StatefulWidget {
  const AddTransactionModal({super.key});

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  double _amount = 0;
  String _category = AppConstants.categories.first;
  bool _isIncome = false;
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final tx = Transaction(
      id: Random().nextDouble().toString(),
      title: _title,
      amount: _amount,
      date: DateTime.now(),
      category: _category,
      isIncome: _isIncome,
    );
    Provider.of<TransactionService>(context, listen: false).addTransaction(tx);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nova Transação',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Título'),
                onSaved: (v) => _title = v!.trim(),
                validator: (v) =>
                    v == null || v.isEmpty ? AppConstants.errorEmptyFields : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Valor'),
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onSaved: (v) => _amount = double.tryParse(v ?? '0') ?? 0,
                validator: (v) {
                  final val = double.tryParse(v ?? '');
                  if (val == null || val <= 0) {
                    return AppConstants.errorInvalidAmount;
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _category,
                items: AppConstants.categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
                decoration: const InputDecoration(labelText: 'Categoria'),
              ),
              SwitchListTile(
                title: const Text('Receita'),
                value: _isIncome,
                onChanged: (v) => setState(() => _isIncome = v),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _submit, child: const Text('Adicionar')),
            ],
          ),
        ),
      ),
    );
  }
}
