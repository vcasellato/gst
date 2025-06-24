import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pdf_service.dart';
import '../services/transaction_service.dart';

class ReportGenerator extends StatelessWidget {
  const ReportGenerator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionService>(
      builder: (context, service, child) {
        return ElevatedButton(
          onPressed: () async {
            final pdf = await PdfService.generateExpenseReport(
              transactions: service.transactions,
              expensesByCategory: service.expensesByCategory,
              totalIncome: service.totalIncome,
              totalExpenses: service.totalExpenses,
              period: 'Completo',
            );
            await PdfService.saveToDevice(pdf, 'relatorio.txt');
          },
          child: const Text('Gerar Relatório'),
        );
      },
    );
  }
}
