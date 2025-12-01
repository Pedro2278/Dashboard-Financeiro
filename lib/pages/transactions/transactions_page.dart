import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/transaction/transaction_state.dart';
import '../../blocs/transaction/transaction_event.dart';
import '../../blocs/filter/filter_bloc.dart';
import '../../blocs/filter/filter_state.dart';
import '../../core/models/transaction_model.dart';

/// Tela que exibe todas as transações cadastradas
/// Permite adicionar novas transações ou remover existentes
class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'Data'; // Data, Valor, Título

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactions());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionModel> _filterAndSort(List<TransactionModel> txs) {
    // Aplica busca por título
    List<TransactionModel> filtered = txs;
    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where(
            (t) => t.title.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ),
          )
          .toList();
    }

    // Aplica ordenação
    switch (_sortBy) {
      case 'Valor':
        // Ordenação crescente (menor para maior)
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'Título':
        // Ordenação alfabética (A-Z)
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Data':
      default:
        // Ordenação crescente (data mais antiga primeiro)
        filtered.sort((a, b) => a.date.compareTo(b.date));
    }

    return filtered;
  }

  void _deleteTransaction(TransactionModel tx) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Transação'),
        content: Text('Tem certeza que deseja deletar "${tx.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<TransactionBloc>().add(DeleteTransaction(tx.id!));
              Navigator.pop(context);
            },
            child: const Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FilterBloc, FilterState>(
      listener: (context, state) {
        context.read<TransactionBloc>().add(LoadTransactions());
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transações'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () =>
                  Navigator.pushNamed(context, '/transaction_form'),
            ),
          ],
        ),
        body: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            if (state is TransactionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is TransactionError) {
              return Center(child: Text(state.message));
            }

            if (state is TransactionLoaded) {
              final allTxs = state.transactions;
              final filteredTxs = _filterAndSort(allTxs);

              if (allTxs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma transação cadastrada',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/transaction_form'),
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar Transação'),
                      ),
                    ],
                  ),
                );
              }

              // Calcula estatísticas GLOBAIS (todas as transações de todos os meses)
              double totalIncome = allTxs
                  .where((t) => t.isIncome)
                  .fold(0.0, (a, b) => a + b.amount);
              double totalExpense = allTxs
                  .where((t) => !t.isIncome)
                  .fold(0.0, (a, b) => a + b.amount);
              double saldoTotal = totalIncome - totalExpense;

              return Column(
                children: [
                  // Cartões de resumo com totais globais
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _buildSummaryCard(
                          'Total de Entradas',
                          totalIncome,
                          Colors.green,
                          Icons.trending_up,
                        ),
                        const SizedBox(width: 12),
                        _buildSummaryCard(
                          'Total de Saídas',
                          totalExpense,
                          Colors.red,
                          Icons.trending_down,
                        ),
                        const SizedBox(width: 12),
                        _buildSummaryCard(
                          'Saldo Total',
                          saldoTotal,
                          saldoTotal >= 0 ? Colors.blue : Colors.orange,
                          Icons.account_balance_wallet,
                        ),
                      ],
                    ),
                  ),

                  // Filtros e busca
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Busca
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar transação...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          onChanged: (v) => setState(() {}),
                        ),
                        const SizedBox(height: 12),

                        // Filtro de tipo
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // Ordenação
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  setState(() => _sortBy = value);
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'Data',
                                    child: Text('Ordenar por Data'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Valor',
                                    child: Text('Ordenar por Valor'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Título',
                                    child: Text('Ordenar por Título'),
                                  ),
                                ],
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[400]!,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.sort, size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        _sortBy,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Contagem de resultados
                        if (filteredTxs.length != allTxs.length)
                          Text(
                            '${filteredTxs.length} de ${allTxs.length} transações',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Lista de transações
                  Expanded(
                    child: filteredTxs.isEmpty
                        ? Center(
                            child: Text(
                              'Nenhuma transação encontrada',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: filteredTxs.length,
                            itemBuilder: (_, i) {
                              final tx = filteredTxs[i];
                              return _buildTransactionCard(tx);
                            },
                          ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'R\$ ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel tx) {
    final isIncome = tx.isIncome;
    final color = isIncome ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isIncome ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          tx.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "${tx.date.day.toString().padLeft(2, '0')}/"
          "${tx.date.month.toString().padLeft(2, '0')}/"
          "${tx.date.year}",
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${isIncome ? '+' : '-'} R\$ ${tx.amount.toStringAsFixed(2)}",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteTransaction(tx);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('Deletar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              child: const Icon(Icons.more_vert, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
