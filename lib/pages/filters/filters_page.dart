import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/filter/filter_bloc.dart';
import '../../blocs/filter/filter_event.dart';
import '../../blocs/category/category_bloc.dart';
import '../../blocs/category/category_state.dart';
import '../../core/models/category_model.dart';
import '../../core/repositories/transaction_repository.dart';

class FiltersPage extends StatefulWidget {
  const FiltersPage({super.key});

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  bool? _isIncome;
  int? _categoryId;
  DateTime? _startDate;
  DateTime? _endDate;
  int _resultCount = 0;
  List<dynamic> _filteredTransactions = [];
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<FilterBloc>().state;
    _isIncome = state.isIncome;
    _categoryId = state.categoryId;
    _startDate = state.startDate;
    _endDate = state.endDate;
    _updateResultCount();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart
        ? _startDate ?? DateTime.now()
        : _endDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: initial,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _updateResultCount();
    }
  }

  Future<void> _updateResultCount() async {
    try {
      final repo = TransactionRepository();
      final list = await repo.getAllFiltered(
        isIncome: _isIncome,
        categoryId: _categoryId,
        start: _startDate,
        end: _endDate,
      );
      setState(() => _resultCount = list.length);
    } catch (e) {
      setState(() => _resultCount = 0);
    }
  }

  Future<void> _applyFilters() async {
    if (_endDate != null &&
        _startDate != null &&
        _endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data final não pode ser anterior à data inicial'),
        ),
      );
      return;
    }

    final bloc = context.read<FilterBloc>();
    bloc.add(FilterByType(_isIncome));
    bloc.add(FilterByCategory(_categoryId));
    bloc.add(FilterByDate(start: _startDate, end: _endDate));

    try {
      final repo = TransactionRepository();
      final list = await repo.getAllFiltered(
        isIncome: _isIncome,
        categoryId: _categoryId,
        start: _startDate,
        end: _endDate,
      );
      setState(() {
        _filteredTransactions = list;
        _showResults = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao aplicar filtros')));
    }
  }

  void _clearFilters() {
    context.read<FilterBloc>().add(ClearFilters());
    setState(() {
      _isIncome = null;
      _categoryId = null;
      _startDate = null;
      _endDate = null;
      _resultCount = 0;
      _filteredTransactions = [];
      _showResults = false;
    });
  }

  String _getDateRangeLabel() {
    if (_startDate == null && _endDate == null) {
      return 'Qualquer período';
    }
    final start = _startDate != null
        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
        : 'Início';
    final end = _endDate != null
        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
        : 'Fim';
    return '$start até $end';
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = context.watch<CategoryBloc>().state;
    List<CategoryModel> categories = [];
    if (categoriesState is CategoryLoaded) {
      categories = categoriesState.categories;
    }

    final filteredCategories = categories
        .where((c) => _isIncome == null ? true : c.isIncome == _isIncome)
        .toList();

    String? selectedCategoryName;
    Color? selectedCategoryColor;
    if (_categoryId != null) {
      try {
        final cat = categories.firstWhere((c) => c.id == _categoryId);
        selectedCategoryName = cat.name;
        selectedCategoryColor = Color(cat.color);
      } catch (e) {
        // Category not found
      }
    }

    // Se há resultados para exibir, mostrar interface de resultados
    if (_showResults && _filteredTransactions.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Resultados dos Filtros'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _showResults = false),
          ),
        ),
        body: Column(
          children: [
            // Card de resumo dos resultados
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transações Encontradas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_filteredTransactions.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),

            // Lista de transações
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredTransactions.length,
                itemBuilder: (context, index) {
                  final tx = _filteredTransactions[index];
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
                      trailing: Text(
                        "${isIncome ? '+' : '-'} R\$ ${tx.amount.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Botão para voltar aos filtros
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _showResults = false),
                icon: const Icon(Icons.tune),
                label: const Text('Modificar Filtros'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Interface de filtros
    return Scaffold(
      appBar: AppBar(title: const Text('Filtros'), elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumo dos filtros aplicados
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade400,
                      Colors.deepPurple.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filtros Aplicados',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$_resultCount resultados',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_isIncome != null)
                          Chip(
                            label: Text(
                              _isIncome! ? 'Entradas' : 'Saídas',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: _isIncome!
                                ? Colors.green
                                : Colors.red,
                            deleteIcon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                            onDeleted: () {
                              setState(() => _isIncome = null);
                              _updateResultCount();
                            },
                          ),
                        if (selectedCategoryName != null)
                          Chip(
                            label: Text(
                              selectedCategoryName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: selectedCategoryColor,
                            deleteIcon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                            onDeleted: () {
                              setState(() => _categoryId = null);
                              _updateResultCount();
                            },
                          ),
                        if (_startDate != null || _endDate != null)
                          Chip(
                            label: Text(
                              _getDateRangeLabel(),
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.orange,
                            deleteIcon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                            onDeleted: () {
                              setState(() {
                                _startDate = null;
                                _endDate = null;
                              });
                              _updateResultCount();
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Filtro por Tipo
              const Text(
                'Tipo de Transação',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(
                            () => _isIncome = _isIncome == true ? null : true,
                          );
                          _updateResultCount();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isIncome == true
                                ? Colors.green
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.trending_up,
                                color: _isIncome == true
                                    ? Colors.white
                                    : Colors.grey,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Entradas',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _isIncome == true
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(
                            () => _isIncome = _isIncome == false ? null : false,
                          );
                          _updateResultCount();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isIncome == false
                                ? Colors.red
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.trending_down,
                                color: _isIncome == false
                                    ? Colors.white
                                    : Colors.grey,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Saídas',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _isIncome == false
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _isIncome = null);
                          _updateResultCount();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isIncome == null
                                ? Colors.deepPurple
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.filter_list,
                                color: _isIncome == null
                                    ? Colors.white
                                    : Colors.grey,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Todas',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _isIncome == null
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Filtro por Categoria
              const Text(
                'Categoria',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<int?>(
                  isExpanded: true,
                  value: _categoryId,
                  underline: const SizedBox(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Row(
                        children: [
                          Icon(Icons.inbox, color: Colors.grey[600], size: 18),
                          const SizedBox(width: 8),
                          const Text('Todas as categorias'),
                        ],
                      ),
                    ),
                    ...filteredCategories.map(
                      (cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Color(cat.color),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(cat.name),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() => _categoryId = v);
                    _updateResultCount();
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Filtro por Período
              const Text(
                'Período',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDate(isStart: true),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _startDate != null
                                ? Colors.deepPurple
                                : Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              color: _startDate != null
                                  ? Colors.deepPurple
                                  : Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _startDate != null
                                    ? '${_startDate!.day.toString().padLeft(2, '0')}/${_startDate!.month.toString().padLeft(2, '0')}/${_startDate!.year}'
                                    : 'Data inicial',
                                style: TextStyle(
                                  color: _startDate != null
                                      ? Colors.black
                                      : Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (_startDate != null)
                              GestureDetector(
                                onTap: () {
                                  setState(() => _startDate = null);
                                  _updateResultCount();
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDate(isStart: false),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _endDate != null
                                ? Colors.deepPurple
                                : Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              color: _endDate != null
                                  ? Colors.deepPurple
                                  : Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _endDate != null
                                    ? '${_endDate!.day.toString().padLeft(2, '0')}/${_endDate!.month.toString().padLeft(2, '0')}/${_endDate!.year}'
                                    : 'Data final',
                                style: TextStyle(
                                  color: _endDate != null
                                      ? Colors.black
                                      : Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (_endDate != null)
                              GestureDetector(
                                onTap: () {
                                  setState(() => _endDate = null);
                                  _updateResultCount();
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Botões de ação
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearFilters,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Limpar Filtros'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Aplicar Filtros',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
