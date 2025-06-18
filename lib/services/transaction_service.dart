import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';

class TransactionService extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  Map<String, double> _budgetLimits = {};

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  Map<String, double> get budgetLimits => _budgetLimits;

  // Cálculos financeiros básicos
  double get totalBalance {
    return _transactions.fold(0.0, (sum, transaction) {
      return transaction.isIncome
        ? sum + transaction.amount
        : sum - transaction.amount;
    });
  }

  double get totalIncome {
    return _transactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalExpenses {
    return _transactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // NOVAS FUNCIONALIDADES DE ANÁLISE

  // Gastos por categoria (para gráficos)
  Map<String, double> get expensesByCategory {
    Map<String, double> categoryTotals = {};

    for (var transaction in _transactions) {
      if (!transaction.isIncome) {
        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }

    return categoryTotals;
  }

  // Evolução mensal dos gastos
  Map<String, double> getMonthlyExpenses() {
    Map<String, double> monthlyData = {};

    for (var transaction in _transactions) {
      if (!transaction.isIncome) {
        String monthKey = '${transaction.date.month.toString().padLeft(2, '0')}/${transaction.date.year}';
        monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + transaction.amount;
      }
    }

    return monthlyData;
  }

  // Evolução mensal das receitas
  Map<String, double> getMonthlyIncome() {
    Map<String, double> monthlyData = {};

    for (var transaction in _transactions) {
      if (transaction.isIncome) {
        String monthKey = '${transaction.date.month.toString().padLeft(2, '0')}/${transaction.date.year}';
        monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + transaction.amount;
      }
    }

    return monthlyData;
  }

  // Gastos dos últimos 7 dias
  Map<String, double> getWeeklyExpenses() {
    Map<String, double> weeklyData = {};
    DateTime now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      DateTime day = now.subtract(Duration(days: i));
      String dayKey = '${day.day}/${day.month}';
      weeklyData[dayKey] = 0;
    }

    for (var transaction in _transactions) {
      if (!transaction.isIncome &&
          transaction.date.isAfter(now.subtract(Duration(days: 7)))) {
        String dayKey = '${transaction.date.day}/${transaction.date.month}';
        if (weeklyData.containsKey(dayKey)) {
          weeklyData[dayKey] = weeklyData[dayKey]! + transaction.amount;
        }
      }
    }

    return weeklyData;
  }

  // Verifica se ultrapassou orçamento
  Map<String, bool> getBudgetStatus() {
    Map<String, bool> status = {};
    Map<String, double> expenses = expensesByCategory;

    for (String category in AppConstants.categories) {
      double spent = expenses[category] ?? 0;
      double limit = _budgetLimits[category] ?? double.infinity;
      status[category] = spent > limit;
    }

    return status;
  }

  // Categorias que mais ultrapassaram orçamento
  List<String> getOverBudgetCategories() {
    Map<String, bool> status = getBudgetStatus();
    return status.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  // Média de gastos por categoria
  Map<String, double> getAverageExpensesByCategory() {
    Map<String, double> averages = {};
    Map<String, List<double>> categoryAmounts = {};

    for (var transaction in _transactions) {
      if (!transaction.isIncome) {
        if (!categoryAmounts.containsKey(transaction.category)) {
          categoryAmounts[transaction.category] = [];
        }
        categoryAmounts[transaction.category]!.add(transaction.amount);
      }
    }

    categoryAmounts.forEach((category, amounts) {
      averages[category] = amounts.reduce((a, b) => a + b) / amounts.length;
    });

    return averages;
  }

  // Maior gasto do mês
  Transaction? getBiggestExpenseThisMonth() {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);

    List<Transaction> thisMonthExpenses = _transactions
        .where((tx) => !tx.isIncome &&
               tx.date.isAfter(startOfMonth.subtract(Duration(days: 1))))
        .toList();

    if (thisMonthExpenses.isEmpty) return null;

    thisMonthExpenses.sort((a, b) => b.amount.compareTo(a.amount));
    return thisMonthExpenses.first;
  }

  // Tendência de gastos (crescente/decrescente)
  String getSpendingTrend() {
    Map<String, double> monthly = getMonthlyExpenses();
    if (monthly.length < 2) return 'Dados insuficientes';

    List<String> sortedMonths = monthly.keys.toList()..sort();
    double lastMonth = monthly[sortedMonths[sortedMonths.length - 1]] ?? 0;
    double previousMonth = monthly[sortedMonths[sortedMonths.length - 2]] ?? 0;

    if (lastMonth > previousMonth) {
      double increase = ((lastMonth - previousMonth) / previousMonth * 100);
      return 'Aumentou ${increase.toStringAsFixed(1)}%';
    } else if (lastMonth < previousMonth) {
      double decrease = ((previousMonth - lastMonth) / previousMonth * 100);
      return 'Diminuiu ${decrease.toStringAsFixed(1)}%';
    } else {
      return 'Manteve estável';
    }
  }

  // Definir limite de orçamento para categoria
  Future<void> setBudgetLimit(String category, double limit) async {
    _budgetLimits[category] = limit;
    await _saveBudgetLimits();
    notifyListeners();
  }

  // Transações ordenadas por data (mais recentes primeiro)
  List<Transaction> get sortedTransactions {
    List<Transaction> sorted = List.from(_transactions);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  // Adicionar transação
  Future<void> addTransaction(Transaction transaction) async {
    try {
      _isLoading = true;
      notifyListeners();

      _transactions.add(transaction);
      await _saveTransactions();

      // Verifica se ultrapassou orçamento
      _checkBudgetAlert(transaction);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception(AppConstants.errorSaveData);
    }
  }

  // Verifica alertas de orçamento
  void _checkBudgetAlert(Transaction transaction) {
    if (transaction.isIncome) return;

    double categorySpent = expensesByCategory[transaction.category] ?? 0;
    double categoryLimit = _budgetLimits[transaction.category] ?? double.infinity;

    if (categorySpent > categoryLimit) {
      // Aqui você pode implementar uma notificação
      print('ALERTA: Orçamento de ${transaction.category} ultrapassado!');
    }
  }

  // Remover transação
  Future<void> removeTransaction(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      _transactions.removeWhere((tx) => tx.id == id);
      await _saveTransactions();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception(AppConstants.errorSaveData);
    }
  }

  // Carregar transações do armazenamento local
  Future<void> loadTransactions() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();

      // Carrega transações
      final transactionsJson = prefs.getString(AppConstants.transactionsKey);
      if (transactionsJson != null) {
        final List<dynamic> transactionsList = json.decode(transactionsJson);
        _transactions = transactionsList
            .map((json) => Transaction.fromJson(json))
            .toList();
      }

      // Carrega limites de orçamento
      final budgetJson = prefs.getString('budget_limits');
      if (budgetJson != null) {
        final Map<String, dynamic> budgetMap = json.decode(budgetJson);
        _budgetLimits = budgetMap.map((key, value) =>
            MapEntry(key, value.toDouble()));
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception(AppConstants.errorLoadData);
    }
  }

  // Salvar transações no armazenamento local
  Future<void> _saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = json.encode(
        _transactions.map((tx) => tx.toJson()).toList(),
      );
      await prefs.setString(AppConstants.transactionsKey, transactionsJson);
    } catch (e) {
      throw Exception(AppConstants.errorSaveData);
    }
  }

  // Salvar limites de orçamento
  Future<void> _saveBudgetLimits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final budgetJson = json.encode(_budgetLimits);
      await prefs.setString('budget_limits', budgetJson);
    } catch (e) {
      throw Exception(AppConstants.errorSaveData);
    }
  }

  // Limpar todas as transações
  Future<void> clearAllTransactions() async {
    try {
      _transactions.clear();
      await _saveTransactions();
      notifyListeners();
    } catch (e) {
      throw Exception(AppConstants.errorSaveData);
    }
  }

  // Filtrar transações por período
  List<Transaction> getTransactionsByPeriod(DateTime start, DateTime end) {
    return _transactions.where((tx) =>
      tx.date.isAfter(start.subtract(Duration(days: 1))) &&
      tx.date.isBefore(end.add(Duration(days: 1)))
    ).toList();
  }

  // Filtrar transações por categoria
  List<Transaction> getTransactionsByCategory(String category) {
    return _transactions.where((tx) => tx.category == category).toList();
  }
}
