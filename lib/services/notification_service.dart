import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationService extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _notificationsEnabled = true;

  List<AppNotification> get notifications => _notifications;
  bool get notificationsEnabled => _notificationsEnabled;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Carrega configuração
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

      // Carrega notificações
      final notificationsJson = prefs.getString('notifications');
      if (notificationsJson != null) {
        final List<dynamic> notificationsList = json.decode(notificationsJson);
        _notifications = notificationsList
            .map((json) => AppNotification.fromJson(json))
            .toList();
      }

      notifyListeners();
    } catch (e) {
      print('Erro ao carregar notificações: $e');
    }
  }

  Future<void> saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = json.encode(
        _notifications.map((n) => n.toJson()).toList(),
      );
      await prefs.setString('notifications', notificationsJson);
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
    } catch (e) {
      print('Erro ao salvar notificações: $e');
    }
  }

  Future<void> addNotification(AppNotification notification) async {
    if (!_notificationsEnabled) return;

    _notifications.insert(0, notification);

    // Limita a 50 notificações
    if (_notifications.length > 50) {
      _notifications = _notifications.take(50).toList();
    }

    await saveNotifications();
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await saveNotifications();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    _notifications = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    await saveNotifications();
    notifyListeners();
  }

  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    await saveNotifications();
    notifyListeners();
  }

  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await saveNotifications();
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    await saveNotifications();
    notifyListeners();
  }

  // Notificações específicas do app
  Future<void> budgetExceededNotification(String category, double amount, double limit) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Orçamento Ultrapassado!',
      message: 'Você gastou R\$ ${amount.toStringAsFixed(2)} em $category, ultrapassando o limite de R\$ ${limit.toStringAsFixed(2)}',
      type: NotificationType.budgetAlert,
      timestamp: DateTime.now(),
      isRead: false,
      icon: '⚠️',
      category: category,
    );

    await addNotification(notification);
  }

  Future<void> budgetWarningNotification(String category, double amount, double limit) async {
    final percentage = (amount / limit * 100).round();
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Atenção ao Orçamento',
      message: 'Você já gastou $percentage% do orçamento de $category. Faltam R\$ ${(limit - amount).toStringAsFixed(2)}',
      type: NotificationType.budgetWarning,
      timestamp: DateTime.now(),
      isRead: false,
      icon: '⚡',
      category: category,
    );

    await addNotification(notification);
  }

  Future<void> monthlyReportNotification(double totalExpenses, double totalIncome, String trend) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Relatório Mensal',
      message: 'Gastos: R\$ ${totalExpenses.toStringAsFixed(2)} | Receitas: R\$ ${totalIncome.toStringAsFixed(2)} | Tendência: $trend',
      type: NotificationType.monthlyReport,
      timestamp: DateTime.now(),
      isRead: false,
      icon: '📊',
    );

    await addNotification(notification);
  }

  Future<void> goalAchievedNotification(String message) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Meta Atingida! 🎉',
      message: message,
      type: NotificationType.goalAchieved,
      timestamp: DateTime.now(),
      isRead: false,
      icon: '🎯',
    );

    await addNotification(notification);
  }

  Future<void> tipNotification(String tip) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Dica Financeira',
      message: tip,
      type: NotificationType.tip,
      timestamp: DateTime.now(),
      isRead: false,
      icon: '💡',
    );

    await addNotification(notification);
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String icon;
  final String? category;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
    required this.icon,
    this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.index,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'icon': icon,
      'category': category,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values[json['type']],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'],
      icon: json['icon'],
      category: json['category'],
    );
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? icon,
    String? category,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      icon: icon ?? this.icon,
      category: category ?? this.category,
    );
  }
}

enum NotificationType {
  budgetAlert,
  budgetWarning,
  monthlyReport,
  goalAchieved,
  tip,
  general,
}
