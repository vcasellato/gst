import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../models/transaction.dart';

class PdfService {
  // Simula a geração de PDF (em um app real, use a biblioteca pdf)
  static Future<Uint8List> generateExpenseReport({
    required List<Transaction> transactions,
    required Map<String, double> expensesByCategory,
    required double totalIncome,
    required double totalExpenses,
    required String period,
  }) async {
    // Em um app real, você usaria a biblioteca 'pdf' do Flutter
    // Para esta demonstração, vamos simular o conteúdo do PDF

    String reportContent = _generateReportContent(
      transactions: transactions,
      expensesByCategory: expensesByCategory,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      period: period,
    );

    // Converte o conteúdo para bytes (simulação)
    List<int> bytes = reportContent.codeUnits;
    return Uint8List.fromList(bytes);
  }

  static String _generateReportContent({
    required List<Transaction> transactions,
    required Map<String, double> expensesByCategory,
    required double totalIncome,
    required double totalExpenses,
    required String period,
  }) {
    StringBuffer content = StringBuffer();

    // Cabeçalho
    content.writeln('=== RELATÓRIO FINANCEIRO ===');
    content.writeln('Período: $period');
    content.writeln('Data de Geração: ${DateTime.now().toString().split('.')[0]}');
    content.writeln('');

    // Resumo financeiro
    content.writeln('--- RESUMO FINANCEIRO ---');
    content.writeln('Total de Receitas: R\$ ${totalIncome.toStringAsFixed(2)}');
    content.writeln('Total de Gastos: R\$ ${totalExpenses.toStringAsFixed(2)}');
    content.writeln('Saldo: R\$ ${(totalIncome - totalExpenses).toStringAsFixed(2)}');
    content.writeln('');

    // Gastos por categoria
    content.writeln('--- GASTOS POR CATEGORIA ---');
    var sortedCategories = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var entry in sortedCategories) {
      double percentage = (entry.value / totalExpenses * 100);
      content.writeln('${entry.key}: R\$ ${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)');
    }
    content.writeln('');

    // Transações detalhadas
    content.writeln('--- TRANSAÇÕES DETALHADAS ---');
    var sortedTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (var transaction in sortedTransactions.take(100)) { // Limita a 100 transações
      String type = transaction.isIncome ? 'RECEITA' : 'GASTO';
      String date = '${transaction.date.day.toString().padLeft(2, '0')}/${transaction.date.month.toString().padLeft(2, '0')}/${transaction.date.year}';
      content.writeln('$date | $type | ${transaction.category} | ${transaction.title} | R\$ ${transaction.amount.toStringAsFixed(2)}');
    }

    return content.toString();
  }

  static Future<void> shareReport(String content, String fileName) async {
    // Em um app real, você usaria o plugin share_plus para compartilhar
    print('Compartilhando relatório: $fileName');
    print('Conteúdo: ${content.substring(0, 200)}...');
  }

  static Future<void> saveToDevice(Uint8List pdfData, String fileName) async {
    // Em um app real, você salvaria o arquivo no dispositivo
    print('Salvando PDF: $fileName');
    print('Tamanho do arquivo: ${pdfData.length} bytes');
  }
}

// Classe para diferentes tipos de relatório
class ReportType {
  static const String monthly = 'Mensal';
  static const String weekly = 'Semanal';
  static const String yearly = 'Anual';
  static const String custom = 'Personalizado';
}

// Modelo para configuração de relatório
class ReportConfig {
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final bool includeCharts;
  final bool includeTransactionDetails;
  final List<String> selectedCategories;

  ReportConfig({
    required this.type,
    required this.startDate,
    required this.endDate,
    this.includeCharts = true,
    this.includeTransactionDetails = true,
    this.selectedCategories = const [],
  });
}
