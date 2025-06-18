import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/transaction_service.dart';
import '../services/theme_service.dart';
import '../services/notification_service.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_list.dart';
import '../widgets/add_transaction_modal.dart';
import '../widgets/notification_center.dart';
import '../utils/colors.dart';
import 'charts_screen.dart';
import './settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Carrega as transações quando a tela inicia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionService>(context, listen: false).loadTransactions();
    });
  }

  void _showAddTransactionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionModal(),
    );
  }

  void _showNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationCenter()),
    );
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sair'),
          content: Text('Tem certeza que deseja sair?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout();
              },
              child: Text('Sair', style: TextStyle(color: AppColors.expense)),
            ),
          ],
        );
      },
    );
  }

  void _performLogout() async {
    // Aqui você pode limpar os dados se necessário
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeTab(),
      ChartsScreen(),
      SettingsScreen(),
    ];

    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_getPageTitle()),
            backgroundColor: themeService.isDarkMode
              ? Color(0xFF1E1E1E)
              : AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              // Notificações
              Consumer<NotificationService>(
                builder: (context, notificationService, child) {
                  return Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications),
                        onPressed: _showNotifications,
                      ),
                      if (notificationService.unreadCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${notificationService.unreadCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              // Menu
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'theme':
                      themeService.toggleTheme();
                      break;
                    case 'logout':
                      _logout();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'theme',
                    child: Row(
                      children: [
                        Icon(
                          themeService.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          themeService.isDarkMode
                            ? 'Modo Claro'
                            : 'Modo Escuro',
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 18),
                        SizedBox(width: 8),
                        Text('Sair'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: pages[_currentIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: themeService.getCardColor(),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: themeService.getCardColor(),
              selectedItemColor: AppColors.primary,
              unselectedItemColor: themeService.getTextSecondaryColor(),
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Início',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart),
                  label: 'Relatórios',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Configurações',
                ),
              ],
            ),
          ),
          floatingActionButton: _currentIndex == 0
            ? FloatingActionButton(
                onPressed: _showAddTransactionModal,
                child: Icon(Icons.add),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              )
            : null,
        );
      },
    );
  }

  String _getPageTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Controle de Gastos';
      case 1:
        return 'Relatórios e Análises';
      case 2:
        return 'Configurações';
      default:
        return 'Controle de Gastos';
    }
  }

  Widget _buildHomeTab() {
    return Consumer<TransactionService>(
      builder: (context, transactionService, child) {
        if (transactionService.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        return Column(
          children: [
            // Card com saldo
            BalanceCard(),

            // Lista de transações
            Expanded(
              child: TransactionList(),
            ),
          ],
        );
      },
    );
  }
}
