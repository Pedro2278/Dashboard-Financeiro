import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/utils/financial_tips.dart';
import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_state.dart';
import '../blocs/transaction/transaction_event.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _tip;

  @override
  void initState() {
    super.initState();
    _tip = FinancialTips.getRandomTip();
    context.read<TransactionBloc>().add(const LoadTransactions());
  }

  void _refreshTip() => setState(() => _tip = FinancialTips.getRandomTip());

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'PH Finanças',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: scheme.primary,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Nova Transação',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => Navigator.pushNamed(context, '/transaction_form'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        children: [
          _BalanceHeader(scheme: scheme),
          const SizedBox(height: 18),
          _NavigationGrid(scheme: scheme),
          const SizedBox(height: 20),
          _QuickActions(scheme: scheme),
          const SizedBox(height: 22),
          _TipCard(text: _tip, onRefresh: _refreshTip, scheme: scheme),
        ],
      ),
    );
  }
}

// ================= COMPONENTES =================
class _BalanceHeader extends StatelessWidget {
  final ColorScheme scheme;
  const _BalanceHeader({required this.scheme});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return Container(
            height: 110,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: .25),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const CircularProgressIndicator(),
          );
        }
        double income = 0, expense = 0;
        if (state is TransactionLoaded) {
          for (final t in state.transactions) {
            if (t.isIncome) {
              income += t.amount;
            } else {
              expense += t.amount;
            }
          }
        }
        final balance = income - expense;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                scheme.primary.withValues(alpha: .85),
                scheme.primaryContainer.withValues(alpha: .60),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .20),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo Atual',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .82),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Entradas: R\$ ${income.toStringAsFixed(2)}  ·  Saídas: R\$ ${expense.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .82),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavigationGrid extends StatelessWidget {
  final ColorScheme scheme;
  const _NavigationGrid({required this.scheme});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem('Dashboard', Icons.dashboard, '/dashboard', scheme.primary),
      _NavItem(
        'Transações',
        Icons.receipt_long,
        '/transactions',
        scheme.secondary,
      ),
      _NavItem(
        'Categorias',
        Icons.category_rounded,
        '/categories',
        scheme.tertiary,
      ),
      _NavItem('Filtros', Icons.filter_list_alt, '/filters', scheme.error),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: 108,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () => Navigator.pushNamed(context, item.route),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: item.color.withValues(alpha: .18),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, size: 22, color: item.color),
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NavItem {
  final String title;
  final IconData icon;
  final String route;
  final Color color;
  _NavItem(this.title, this.icon, this.route, this.color);
}

class _QuickActions extends StatelessWidget {
  final ColorScheme scheme;
  const _QuickActions({required this.scheme});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            title: 'Adicionar\nTransação',
            icon: Icons.add_circle,
            color: scheme.primary,
            route: '/transaction_form',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionCard(
            title: 'Adicionar\nCategoria',
            icon: Icons.category_outlined,
            color: scheme.secondary,
            route: '/categories',
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String route;
  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: .20),
              color.withValues(alpha: .08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: .30)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String text;
  final VoidCallback onRefresh;
  final ColorScheme scheme;
  const _TipCard({
    required this.text,
    required this.onRefresh,
    required this.scheme,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.primary.withValues(alpha: .18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: scheme.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dica Financeira',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface.withValues(alpha: .65),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: scheme.onSurface.withValues(alpha: .80),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onRefresh,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.refresh, size: 18, color: scheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
