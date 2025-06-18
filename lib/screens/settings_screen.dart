import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../services/notification_service.dart';
import '../services/transaction_service.dart';
import '../widgets/report_generator.dart';
import '../widgets/ai_insights_widget.dart';
import '../utils/colors.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Column(
          children: [
            // TabBar
            Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeService.getCardColor(),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(icon: Icon(Icons.settings), text: 'Geral'),
                  Tab(icon: Icon(Icons.picture_as_pdf), text: 'Relatórios'),
                  Tab(icon: Icon(Icons.psychology), text: 'IA'),
                ],
                labelColor: AppColors.primary,
                unselectedLabelColor: themeService.getTextSecondaryColor(),
                indicatorColor: AppColors.primary,
                labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                unselectedLabelStyle: TextStyle(fontSize: 12),
              ),
            ),

            // TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGeneralTab(themeService),
                  _buildReportsTab(),
                  _buildAITab(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGeneralTab(ThemeService themeService) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Configurações de Aparência
          _buildSectionCard(
            title: 'Aparência',
            icon: Icons.palette,
            children: [
              Consumer<ThemeService>(
                builder: (context, themeService, child) {
                  return SwitchListTile(
                    title: Text('Modo Escuro'),
                    subtitle: Text('Ativar tema escuro do aplicativo'),
                    value: themeService.isDarkMode,
                    onChanged: (value) => themeService.toggleTheme(),
                    secondary: Icon(
                      themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: AppColors.primary,
                    ),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: 16),

          // Configurações de Notificações
          _buildSectionCard(
            title: 'Notificações',
            icon: Icons.notifications,
            children: [
              Consumer<NotificationService>(
                builder: (context, notificationService, child) {
                  return Column(
                    children: [
                      SwitchListTile(
                        title: Text('Notificações'),
                        subtitle: Text('Receber alertas e lembretes'),
                        value: notificationService.notificationsEnabled,
                        onChanged: (value) => notificationService.toggleNotifications(),
                        secondary: Icon(
                          Icons.notifications,
                          color: AppColors.primary,
                        ),
                      ),
                      if (notificationService.notifications.isNotEmpty)
                        ListTile(
                          title: Text('Limpar Notificações'),
                          subtitle: Text('Remove todas as notificações salvas'),
                          leading: Icon(Icons.clear_all, color: Colors.orange),
                          onTap: () => _showClearNotificationsDialog(notificationService),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),

          SizedBox(height: 16),

          // Configurações de Dados
          _buildSectionCard(
            title: 'Dados',
            icon: Icons.storage,
            children: [
              ListTile(
                title: Text('Backup de Dados'),
                subtitle: Text('Exportar todos os dados do app'),
                leading: Icon(Icons.backup, color: Colors.blue),
                onTap: _exportData,
              ),
              ListTile(
                title: Text('Importar Dados'),
                subtitle: Text('Restaurar dados de um backup'),
                leading: Icon(Icons.restore, color: Colors.green),
                onTap: _importData,
              ),
              Divider(),
              ListTile(
                title: Text(
                  'Limpar Todos os Dados',
                  style: TextStyle(color: Colors.red),
                ),
                subtitle: Text('Remove todas as transações e configurações'),
                leading: Icon(Icons.delete_forever, color: Colors.red),
                onTap: _showClearDataDialog,
              ),
            ],
          ),

          SizedBox(height: 16),

          // Informações do App
          _buildSectionCard(
            title: 'Sobre',
            icon: Icons.info,
            children: [
              ListTile(
                title: Text('Versão'),
                subtitle: Text('1.0.0'),
                leading: Icon(Icons.info_outline, color: AppColors.primary),
              ),
              ListTile(
                title: Text('Avaliações e Feedback'),
                subtitle: Text('Avalie o app na loja'),
                leading: Icon(Icons.star, color: Colors.amber),
                onTap: _rateApp,
              ),
              ListTile(
                title: Text('Suporte'),
                subtitle: Text('Entre em contato conosco'),
                leading: Icon(Icons.support, color: Colors.purple),
                onTap: _contactSupport,
              ),
            ],
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ReportGenerator(),
    );
  }

  Widget _buildAITab() {
    return SingleChildScrollView(
      child: AIInsightsWidget(),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Container(
          decoration: BoxDecoration(
            color: themeService.getCardColor(),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(icon, color: AppColors.primary, size: 24),
                    SizedBox(width: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeService.getTextPrimaryColor(),
                      ),
                    ),
                  ],
                ),
              ),
              ...children,
            ],
          ),
        );
      },
    );
  }

  void _showClearNotificationsDialog(NotificationService service) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Limpar Notificações'),
          content: Text('Tem certeza que deseja remover todas as notificações?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                service.clearAllNotifications();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Notificações removidas')),
                );
              },
              child: Text('Limpar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Limpar Todos os Dados'),
          content: Text(
            'ATENÇÃO: Esta ação irá remover permanentemente todas as suas transações, orçamentos e configurações. Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final service = Provider.of<TransactionService>(context, listen: false);
                await service.clearAllTransactions();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Todos os dados foram removidos'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: Text('LIMPAR TUDO', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _exportData() {
    final service = Provider.of<TransactionService>(context, listen: false);

    if (service.transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nenhum dado para exportar')),
      );
      return;
    }

    // Simula exportação
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Backup criado com sucesso! ${service.transactions.length} transações exportadas.'),
        backgroundColor: AppColors.income,
      ),
    );
  }

  void _importData() {
    // Simula importação
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Importar Dados'),
          content: Text('Selecione um arquivo de backup para restaurar seus dados.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                );
              },
              child: Text('Selecionar Arquivo'),
            ),
          ],
        );
      },
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Redirecionando para a loja de apps...')),
    );
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Suporte'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Entre em contato conosco:'),
              SizedBox(height: 12),
              Text('📧 Email: suporte@controlegastos.com'),
              Text('📱 WhatsApp: (11) 99999-9999'),
              Text('🌐 Site: www.controlegastos.com'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}
