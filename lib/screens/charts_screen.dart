import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/transaction_service.dart';
import '../widgets/expense_chart.dart';
import '../widgets/line_chart.dart';
import '../widgets/insights_widget.dart';
import '../widgets/budget_manager.dart';
import '../utils/colors.dart';

class ChartsScreen extends StatefulWidget {
  @override
  _ChartsScreenState createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionService>(
      builder: (context, transactionService, child) {
        return Column(
          children: [
            // TabBar
            Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
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
                  Tab(icon: Icon(Icons.pie_chart), text: 'Categorias'),
                  Tab(icon: Icon(Icons.show_chart), text: 'Evolução'),
                  Tab(icon: Icon(Icons.lightbulb), text: 'Insights'),
                  Tab(icon: Icon(Icons.account_balance_wallet), text: 'Orçamento'),
                ],
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                labelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                unselectedLabelStyle: TextStyle(fontSize: 10),
              ),
            ),

            // TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Aba 1: Gráfico de categorias
                  _buildCategoriesTab(transactionService),

                  // Aba 2: Evolução temporal
                  _buildEvolutionTab(transactionService),

                  // Aba 3: Insights
                  _buildInsightsTab(),

                  // Aba 4: Gerenciamento de orçamento
                  _buildBudgetTab(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoriesTab(TransactionService transactionService) {
    final expensesByCategory = transactionService.expensesByCategory;
    final hasExpenses = expensesByCategory.isNotEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cards de resumo
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total de Gastos',
                  value: transactionService.totalExpenses,
                  icon: Icons.trending_down,
                  color: AppColors.expense,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total de Receitas',
                  value: transactionService.totalIncome,
                  icon: Icons.trending_up,
                  color: AppColors.income,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Gráfico de pizza dos gastos
          if (hasExpenses) ...[
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
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
                  Text(
                    'Gastos por Categoria',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 300,
                    child: ExpenseChart(expensesByCategory: expensesByCategory),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Lista detalhada por categoria
            _buildCategoryDetailsList(expensesByCategory),
          ] else
            _buildNoExpensesState(),
        ],
      ),
    );
  }

  Widget _buildEvolutionTab(TransactionService transactionService) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Gráfico de evolução mensal
          LineChartWidget(
            monthlyExpenses: transactionService.getMonthlyExpenses(),
            monthlyIncome: transactionService.getMonthlyIncome(),
            title: 'Evolução Mensal',
          ),
          SizedBox(height: 24),

          // Gráfico semanal
          LineChartWidget(
            monthlyExpenses: transactionService.getWeeklyExpenses(),
            monthlyIncome: {}, // Só gastos para visualização semanal
            title: 'Últimos 7 Dias',
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: InsightsWidget(),
    );
  }

  Widget _buildBudgetTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: BudgetManager(),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              Spacer(),
            ],
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'R\$ ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDetailsList(Map<String, double> expensesByCategory) {
    final totalExpenses = expensesByCategory.values.fold(0.0, (a, b) => a + b);
    final sortedCategories = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Text(
            'Detalhes por Categoria',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          ...sortedCategories.map((entry) {
            final category = entry.key;
            final amount = entry.value;
            final percentage = (amount / totalExpenses * 100);
            final categoryIndex = sortedCategories.indexOf(entry);
            final color = AppColors.chartColors[categoryIndex % AppColors.chartColors.length];

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Indicador de cor
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12),

                  // Emoji e nome da categoria
                  Text(
                    '${_getCategoryIcon(category)} $category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),

                  // Valor e porcentagem
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'R\$ ${amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildNoExpensesState() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bar_chart,
                size: 64,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Nenhum gasto registrado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Adicione alguns gastos para ver\nseus gráficos e análises aqui',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryIcon(String category) {
    const icons = {
      'Alimentação': '🍽️',
      'Transporte': '🚗',
      'Lazer': '🎮',
      'Saúde': '⚕️',
      'Casa': '🏠',
      'Trabalho': '💼',
      'Educação': '📚',
      'Roupas': '👕',
      'Outros': '📦',
    };
    return icons[category] ?? '📦';
  }
}
