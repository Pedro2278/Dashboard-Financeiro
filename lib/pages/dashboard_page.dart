import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_event.dart';
import '../blocs/transaction/transaction_state.dart';
import '../widgets/charts/bar_chart.dart';
import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_state.dart';
import '../core/utils/calculation_validator.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _loadMonthTransactions();
  }

  void _loadMonthTransactions() {
    context.read<TransactionBloc>().add(
      LoadTransactionsByMonth(
        year: _selectedMonth.year,
        month: _selectedMonth.month,
      ),
    );
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      _loadMonthTransactions();
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      _loadMonthTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text('Dashboard Financeiro'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar para Home',
          onPressed: () => Navigator.pushNamed(context, '/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMonthTransactions,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Seletor de Mês Melhorado
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade400,
                    Colors.deepPurple.shade600,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    onPressed: _previousMonth,
                  ),
                  Column(
                    children: [
                      const Text(
                        'Mês Selecionado',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getMonthYearString(_selectedMonth),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    onPressed: _nextMonth,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, txState) {
                  if (txState is TransactionLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (txState is TransactionLoaded) {
                    final txs = txState.transactions;

                    double totalIncome = 0;
                    double totalExpense = 0;
                    for (var t in txs) {
                      if (t.isIncome) {
                        totalIncome += t.amount;
                      } else {
                        totalExpense += t.amount;
                      }
                    }
                    final balance = totalIncome - totalExpense;

                    final validation =
                        CalculationValidator.validateAllCalculations(
                          totalIncome: totalIncome,
                          totalExpense: totalExpense,
                          balance: balance,
                          incomeByCategory: {},
                          expenseByCategory: {},
                        );

                    if (!validation['isValid']) {
                      debugPrint(
                        '❌ Calculation errors: ${validation['errors']}',
                      );
                    }

                    final catState = context.watch<CategoryBloc>().state;
                    Map<int, String> names = {};
                    if (catState is CategoryLoaded) {
                      for (var c in catState.categories) {
                        if (c.id != null) names[c.id!] = c.name;
                      }
                    }

                    Map<String, double> expenseByCategory = {};
                    Map<String, double> incomeByCategory = {};
                    for (var t in txs) {
                      final name = names[t.categoryId] ?? 'Sem categoria';
                      if (t.isIncome) {
                        incomeByCategory[name] =
                            (incomeByCategory[name] ?? 0) + t.amount;
                      } else {
                        expenseByCategory[name] =
                            (expenseByCategory[name] ?? 0) + t.amount;
                      }
                    }
                    final byCat = expenseByCategory;

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cards de Resumo
                          const Text(
                            'Resumo Financeiro',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  'Entradas',
                                  totalIncome,
                                  Colors.green,
                                  Icons.trending_up,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  'Saídas',
                                  totalExpense,
                                  Colors.red,
                                  Icons.trending_down,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildSummaryCard(
                            'Saldo',
                            balance,
                            balance >= 0 ? Colors.blue : Colors.orange,
                            balance >= 0
                                ? Icons.account_balance_wallet
                                : Icons.warning,
                          ),
                          const SizedBox(height: 24),

                          // Indicador de Saúde Financeira
                          _buildFinancialHealthIndicator(
                            balance,
                            totalIncome,
                            totalExpense,
                          ),
                          const SizedBox(height: 24),

                          // Meta de Economia Mensal
                          _buildSavingsGoalCard(totalIncome, totalExpense),
                          const SizedBox(height: 24),

                          // Evolução Acumulada do Ano
                          const Text(
                            'Evolução Acumulada do Ano',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: SizedBox(
                                height: 250,
                                child: _buildYearlyAccumulationChart(txs),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Gráfico de Barras
                          const Text(
                            'Gastos por Categoria',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: CategoryBarChart(data: byCat),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Gráfico Pizza
                          const Text(
                            'Distribuição de Gastos',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SizedBox(
                                height: 280,
                                child: PieChart(
                                  PieChartData(
                                    sections: _buildCategoryPieChartSections(
                                      txs,
                                      names,
                                    ),
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 40,
                                    borderData: FlBorderData(show: false),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Tabela Detalhada Profissional
                          const Text(
                            'Análise de Gastos por Categoria',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                // Cabeçalho da tabela profissional
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Categoria',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Valor',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          '%',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1),
                                // Linhas da tabela
                                SizedBox(
                                  height: 300,
                                  child: ListView(
                                    children: _buildProfessionalCategoryRows(
                                      txs,
                                      names,
                                      totalExpense,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Últimas Transações
                          const Text(
                            'Transações do Mês',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (txs.isEmpty)
                            Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.inbox,
                                        size: 48,
                                        color: Colors.grey[300],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Nenhuma transação neste mês',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: txs.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 1, indent: 16),
                                itemBuilder: (context, i) {
                                  final tx = txs[i];
                                  final isIncome = tx.isIncome;
                                  final color = isIncome
                                      ? Colors.green
                                      : Colors.red;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            isIncome
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            color: color,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                tx.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${tx.date.day.toString().padLeft(2, '0')}/${tx.date.month.toString().padLeft(2, '0')}/${tx.date.year}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${isIncome ? '+' : '-'} R\$ ${tx.amount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  }

                  return const Center(child: Text('Nenhum dado disponível'));
                },
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade600,
                    Colors.deepPurple.shade400,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'PH Finanças',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Menu de Navegação',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Início'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Transações'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/transactions');
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categorias'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/categories');
              },
            ),
            ListTile(
              leading: const Icon(Icons.filter_list),
              title: const Text('Filtros'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/filters');
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Versão 1.0',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialHealthIndicator(
    double balance,
    double totalIncome,
    double totalExpense,
  ) {
    // Determinar status de saúde financeira
    final isSavingMoney = balance > 0;
    final isNeutral = balance.abs() < (totalIncome * 0.05); // Margem de 5%
    final isHealthy = isSavingMoney && !isNeutral;

    late Color indicatorColor;
    late String healthStatus;
    late String healthDescription;
    late IconData healthIcon;

    if (isHealthy) {
      indicatorColor = Colors.green;
      healthStatus = 'Saudável 🟢';
      healthDescription = 'Você está economizando! Continue assim.';
      healthIcon = Icons.trending_up;
    } else if (isNeutral) {
      indicatorColor = Colors.amber;
      healthStatus = 'Neutro 🟡';
      healthDescription = 'Gastos equilibrados com suas entradas.';
      healthIcon = Icons.remove;
    } else {
      indicatorColor = Colors.red;
      healthStatus = 'Crítico 🔴';
      healthDescription = 'Gastos maiores que as entradas. Atenção!';
      healthIcon = Icons.trending_down;
    }

    final savingRate = totalIncome > 0 ? ((balance / totalIncome) * 100) : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              indicatorColor.withOpacity(0.1),
              indicatorColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: indicatorColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(healthIcon, color: indicatorColor, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saúde Financeira',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    healthStatus,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: indicatorColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    healthDescription,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Taxa de Economia: ${savingRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: indicatorColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsGoalCard(double totalIncome, double totalExpense) {
    // Meta padrão: economizar 20% da renda
    const savingsGoalPercentage = 0.20;
    final savingsGoal = totalIncome * savingsGoalPercentage;
    final actualSavings = totalIncome - totalExpense;
    final savingsProgress = savingsGoal > 0
        ? (actualSavings / savingsGoal).clamp(0.0, 1.0)
        : 0.0;

    final isMetGoal = actualSavings >= savingsGoal;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Meta de Economia Mensal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isMetGoal
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isMetGoal
                        ? '✓ Meta Atingida!'
                        : '${(savingsProgress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isMetGoal ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Objetivo: poupar 20% da renda',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Economizado: R\$ ${actualSavings.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Meta: R\$ ${savingsGoal.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: savingsProgress,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isMetGoal ? Colors.green : Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearlyAccumulationChart(List txs) {
    // Agrupar transações por mês
    final now = DateTime.now();
    final monthlyBalances = <int, double>{};

    for (int month = 1; month <= 12; month++) {
      monthlyBalances[month] = 0.0;
    }

    for (var tx in txs) {
      final month = tx.date.month;
      if (tx.isIncome) {
        monthlyBalances[month] = (monthlyBalances[month] ?? 0) + tx.amount;
      } else {
        monthlyBalances[month] = (monthlyBalances[month] ?? 0) - tx.amount;
      }
    }

    // Criar spots para o gráfico (apenas meses já passados)
    final spots = <FlSpot>[];
    double runningBalance = 0.0;

    for (int month = 1; month <= now.month; month++) {
      runningBalance += monthlyBalances[month] ?? 0.0;
      spots.add(FlSpot(month.toDouble(), runningBalance));
    }

    if (spots.isEmpty) {
      return Center(
        child: Text(
          'Sem dados para exibir evolução do ano',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    // Calcular min e max
    double minY = spots
        .map((spot) => spot.y)
        .fold<double>(double.infinity, (prev, y) => y < prev ? y : prev);
    double maxY = spots
        .map((spot) => spot.y)
        .fold<double>(
          double.negativeInfinity,
          (prev, y) => y > prev ? y : prev,
        );

    // Adicionar margem e garantir que não sejam iguais
    var range = maxY - minY;
    if (range == 0) {
      range = 100; // Valor padrão se forem iguais
      minY = minY - 50;
      maxY = maxY + 50;
    } else {
      minY -= range * 0.1;
      maxY += range * 0.1;
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: (maxY - minY) / 5 > 0 ? (maxY - minY) / 5 : 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey[300], strokeWidth: 0.5);
          },
          getDrawingVerticalLine: (value) {
            return FlLine(color: Colors.grey[300], strokeWidth: 0.5);
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                const months = [
                  'Jan',
                  'Fev',
                  'Mar',
                  'Abr',
                  'Mai',
                  'Jun',
                  'Jul',
                  'Ago',
                  'Set',
                  'Out',
                  'Nov',
                  'Dez',
                ];
                if (value.toInt() >= 1 && value.toInt() <= 12) {
                  return Text(
                    months[value.toInt() - 1],
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  'R\$ ${(value / 1000).toStringAsFixed(0)}k',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.deepPurple,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.deepPurple,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.deepPurple.withOpacity(0.1),
            ),
          ),
        ],
        minY: minY,
        maxY: maxY,
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'R\$ ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return '${months[date.month - 1]} de ${date.year}';
  }

  List<PieChartSectionData> _buildCategoryPieChartSections(
    List txs,
    Map<int, String> names,
  ) {
    // Agrupar gastos por categoria
    Map<String, double> expenseByCategory = {};
    for (var t in txs) {
      if (!t.isIncome) {
        final name = names[t.categoryId] ?? 'Sem categoria';
        expenseByCategory[name] = (expenseByCategory[name] ?? 0) + t.amount;
      }
    }

    if (expenseByCategory.isEmpty) {
      return [
        PieChartSectionData(
          value: 1,
          color: Colors.grey,
          title: 'Sem gastos',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ];
    }

    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.lime,
      Colors.green,
      Colors.teal,
      Colors.cyan,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];

    final sections = <PieChartSectionData>[];
    int colorIndex = 0;

    expenseByCategory.forEach((category, amount) {
      sections.add(
        PieChartSectionData(
          value: amount,
          color: colors[colorIndex % colors.length],
          title: '$category\nR\$ ${amount.toStringAsFixed(0)}',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return sections;
  }

  List<Widget> _buildProfessionalCategoryRows(
    List txs,
    Map<int, String> names,
    double totalExpense,
  ) {
    // Agrupar gastos por categoria
    Map<String, double> expenseByCategory = {};
    for (var t in txs) {
      if (!t.isIncome) {
        final name = names[t.categoryId] ?? 'Sem categoria';
        expenseByCategory[name] = (expenseByCategory[name] ?? 0) + t.amount;
      }
    }

    // Ordenar por valor decrescente
    final sortedEntries = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedEntries.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Nenhum gasto registrado',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ),
        ),
      ];
    }

    final colors = [
      Colors.red.shade400,
      Colors.orange.shade400,
      Colors.amber.shade400,
      Colors.lime.shade400,
      Colors.green.shade400,
      Colors.teal.shade400,
      Colors.cyan.shade400,
      Colors.blue.shade400,
      Colors.indigo.shade400,
      Colors.purple.shade400,
    ];

    return List.generate(sortedEntries.length, (index) {
      final entry = sortedEntries[index];
      final percentage = totalExpense > 0
          ? (entry.value / totalExpense * 100)
          : 0.0;
      final color = colors[index % colors.length];

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Indicador de cor
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Nome da categoria
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    // Valor
                    Expanded(
                      flex: 2,
                      child: Text(
                        'R\$ ${entry.value.toStringAsFixed(2)}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: color,
                        ),
                      ),
                    ),
                    // Percentual
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${percentage.toStringAsFixed(1)}%',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Barra de progresso visual
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 6,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          if (index < sortedEntries.length - 1)
            Divider(
              height: 1,
              indent: 40,
              endIndent: 16,
              color: Colors.grey[200],
            ),
        ],
      );
    });
  }
}
