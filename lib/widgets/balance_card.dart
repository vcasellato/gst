import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/transaction_service.dart';
import '../utils/colors.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionService>(
      builder: (context, service, child) {
        final balance = service.totalBalance;
        final income = service.totalIncome;
        final expense = service.totalExpenses;
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saldo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'R\$ ${balance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    color: balance >= 0 ? AppColors.income : AppColors.expense,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Receitas: R\$ ${income.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.income),
                    ),
                    Text(
                      'Gastos: R\$ ${expense.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.expense),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
