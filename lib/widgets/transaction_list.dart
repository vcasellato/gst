import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/transaction_service.dart';
import '../models/transaction.dart';
import '../utils/colors.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionService>(
      builder: (context, service, child) {
        final List<Transaction> transactions = service.sortedTransactions;
        if (transactions.isEmpty) {
          return const Center(child: Text('Nenhuma transação'));
        }
        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final tx = transactions[index];
            return ListTile(
              leading: Icon(
                tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: tx.isIncome ? AppColors.income : AppColors.expense,
              ),
              title: Text(tx.title),
              subtitle: Text(
                '${tx.category} - ${tx.date.day.toString().padLeft(2, '0')}/${tx.date.month.toString().padLeft(2, '0')}/${tx.date.year}',
              ),
              trailing: Text(
                'R\$ ${tx.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: tx.isIncome ? AppColors.income : AppColors.expense,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
