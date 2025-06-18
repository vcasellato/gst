import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/transaction.dart' as models;

class FirestoreService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Referências das coleções
  CollectionReference _getUserTransactions(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions');
  }

  CollectionReference _getUserBudgets(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets');
  }

  DocumentReference _getUserProfile(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  // ========== TRANSAÇÕES ==========

  // Adicionar transação
  Future<bool> addTransaction(String userId, models.Transaction transaction) async {
    try {
      _setLoading(true);
      _clearError();

      await _getUserTransactions(userId).add({
        'id': transaction.id,
        'title': transaction.title,
        'amount': transaction.amount,
        'date': Timestamp.fromDate(transaction.date),
        'category': transaction.category,
        'isIncome': transaction.isIncome,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Erro ao adicionar transação: ${e.toString()}');
      return false;
    }
  }

  // Atualizar transação
  Future<bool> updateTransaction(String userId, models.Transaction transaction) async {
    try {
      _setLoading(true);
      _clearError();

      final querySnapshot = await _getUserTransactions(userId)
          .where('id', isEqualTo: transaction.id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update({
          'title': transaction.title,
          'amount': transaction.amount,
          'date': Timestamp.fromDate(transaction.date),
          'category': transaction.category,
          'isIncome': transaction.isIncome,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Erro ao atualizar transação: ${e.toString()}');
      return false;
    }
  }

  // Deletar transação
  Future<bool> deleteTransaction(String userId, String transactionId) async {
    try {
      _setLoading(true);
      _clearError();

      final querySnapshot = await _getUserTransactions(userId)
          .where('id', isEqualTo: transactionId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Erro ao deletar transação: ${e.toString()}');
      return false;
    }
  }

  // Stream de transações (tempo real)
  Stream<List<models.Transaction>> getTransactionsStream(String userId) {
    return _getUserTransactions(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return models.Transaction(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          amount: (data['amount'] ?? 0).toDouble(),
          date: (data['date'] as Timestamp).toDate(),
          category: data['category'] ?? '',
          isIncome: data['isIncome'] ?? false,
        );
      }).toList();
    });
  }

  // Buscar transações por período
  Future<List<models.Transaction>> getTransactionsByPeriod(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      final querySnapshot = await _getUserTransactions(userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      final transactions = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return models.Transaction(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          amount: (data['amount'] ?? 0).toDouble(),
          date: (data['date'] as Timestamp).toDate(),
          category: data['category'] ?? '',
          isIncome: data['isIncome'] ?? false,
        );
      }).toList();

      _setLoading(false);
      return transactions;
    } catch (e) {
      _setLoading(false);
      _setError('Erro ao buscar transações: ${e.toString()}');
      return [];
    }
  }

  // ========== ORÇAMENTOS ==========

  // Salvar orçamento
  Future<bool> saveBudgetLimit(String userId, String category, double limit) async {
    try {
      _setLoading(true);
      _clearError();

      await _getUserBudgets(userId).doc(category).set({
        'category': category,
        'limit': limit,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Erro ao salvar orçamento: ${e.toString()}');
      return false;
    }
  }

  // Stream de orçamentos
  Stream<Map<String, double>> getBudgetLimitsStream(String userId) {
    return _getUserBudgets(userId).snapshots().map((snapshot) {
      Map<String, double> budgets = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        budgets[data['category']] = (data['limit'] ?? 0).toDouble();
      }
      return budgets;
    });
  }

  // ========== PERFIL DO USUÁRIO ==========

  // Salvar dados do perfil
  Future<bool> saveUserProfile(String userId, Map<String, dynamic> profileData) async {
    try {
      _setLoading(true);
      _clearError();

      await _getUserProfile(userId).set({
        ...profileData,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Erro ao salvar perfil: ${e.toString()}');
      return false;
    }
  }

  // Buscar dados do perfil
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final doc = await _getUserProfile(userId).get();

      _setLoading(false);

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      _setLoading(false);
      _setError('Erro ao buscar perfil: ${e.toString()}');
      return null;
    }
  }

  // ========== BACKUP E SYNC ==========

  // Fazer backup das transações locais para a nuvem
  Future<bool> backupLocalTransactions(String userId, List<models.Transaction> localTransactions) async {
    try {
      _setLoading(true);
      _clearError();

      final batch = _firestore.batch();
      final collection = _getUserTransactions(userId);

      for (var transaction in localTransactions) {
        final docRef = collection.doc();
        batch.set(docRef, {
          'id': transaction.id,
          'title': transaction.title,
          'amount': transaction.amount,
          'date': Timestamp.fromDate(transaction.date),
          'category': transaction.category,
          'isIncome': transaction.isIncome,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Erro no backup: ${e.toString()}');
      return false;
    }
  }

  // Sync de transações (merge local + nuvem)
  Future<List<models.Transaction>> syncTransactions(String userId, List<models.Transaction> localTransactions) async {
    try {
      _setLoading(true);
      _clearError();

      // Busca transações da nuvem
      final cloudSnapshot = await _getUserTransactions(userId).get();
      final cloudTransactions = cloudSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return models.Transaction(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          amount: (data['amount'] ?? 0).toDouble(),
          date: (data['date'] as Timestamp).toDate(),
          category: data['category'] ?? '',
          isIncome: data['isIncome'] ?? false,
        );
      }).toList();

      // Merge das transações (remove duplicatas por ID)
      final Map<String, models.Transaction> mergedMap = {};

      // Adiciona transações locais
      for (var transaction in localTransactions) {
        mergedMap[transaction.id] = transaction;
      }

      // Adiciona/sobrescreve com transações da nuvem
      for (var transaction in cloudTransactions) {
        mergedMap[transaction.id] = transaction;
      }

      final mergedTransactions = mergedMap.values.toList();
      mergedTransactions.sort((a, b) => b.date.compareTo(a.date));

      _setLoading(false);
      return mergedTransactions;
    } catch (e) {
      _setLoading(false);
      _setError('Erro na sincronização: ${e.toString()}');
      return localTransactions; // Retorna local em caso de erro
    }
  }

  // ========== MÉTODOS AUXILIARES ==========

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Limpar todos os dados do usuário
  Future<bool> deleteAllUserData(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final batch = _firestore.batch();

      // Deletar transações
      final transactionsSnapshot = await _getUserTransactions(userId).get();
      for (var doc in transactionsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Deletar orçamentos
      final budgetsSnapshot = await _getUserBudgets(userId).get();
      for (var doc in budgetsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Deletar perfil
      batch.delete(_getUserProfile(userId));

      await batch.commit();
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Erro ao deletar dados: ${e.toString()}');
      return false;
    }
  }

  // Estatísticas de uso (para analytics)
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final transactionsSnapshot = await _getUserTransactions(userId).get();
      final budgetsSnapshot = await _getUserBudgets(userId).get();

      int totalTransactions = transactionsSnapshot.size;
      int totalBudgets = budgetsSnapshot.size;

      double totalIncome = 0;
      double totalExpenses = 0;

      for (var doc in transactionsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        double amount = (data['amount'] ?? 0).toDouble();
        bool isIncome = data['isIncome'] ?? false;

        if (isIncome) {
          totalIncome += amount;
        } else {
          totalExpenses += amount;
        }
      }

      return {
        'totalTransactions': totalTransactions,
        'totalBudgets': totalBudgets,
        'totalIncome': totalIncome,
        'totalExpenses': totalExpenses,
        'balance': totalIncome - totalExpenses,
      };
    } catch (e) {
      return {};
    }
  }
}
