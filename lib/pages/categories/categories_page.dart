import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../blocs/category/category_bloc.dart';
import '../../blocs/category/category_event.dart';
import '../../blocs/category/category_state.dart';
import '../../core/models/category_model.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  String _filterType = 'all'; // 'all', 'income', 'expense'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Categorias'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            tooltip: 'Nova categoria',
            onPressed: () => _openCategoryForm(context),
          ),
        ],
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoryLoaded) {
            final allCategories = state.categories;

            // Filtrar categorias
            final filteredCategories = allCategories.where((cat) {
              if (_filterType == 'income') return cat.isIncome;
              if (_filterType == 'expense') return !cat.isIncome;
              return true;
            }).toList();

            if (filteredCategories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.category, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma categoria encontrada',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _openCategoryForm(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Criar Categoria'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Filter chips
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Todas', 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Entradas', 'income'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Saídas', 'expense'),
                      ],
                    ),
                  ),
                ),
                // Statistics
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total',
                          allCategories.length.toString(),
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Entradas',
                          allCategories
                              .where((c) => c.isIncome)
                              .length
                              .toString(),
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Saídas',
                          allCategories
                              .where((c) => !c.isIncome)
                              .length
                              .toString(),
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Categories list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredCategories.length,
                    itemBuilder: (_, index) {
                      final cat = filteredCategories[index];
                      return _buildCategoryCard(context, cat);
                    },
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Erro ao carregar categorias'));
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _filterType = value);
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.deepPurple[100],
      labelStyle: TextStyle(
        color: isSelected ? Colors.deepPurple : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      elevation: 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategoryModel cat) {
    final categoryColor = Color(cat.color);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              cat.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
              color: categoryColor,
              size: 24,
            ),
          ),
        ),
        title: Text(
          cat.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          cat.isIncome ? '📊 Entrada' : '📉 Saída',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteConfirmation(context, cat);
            } else if (value == 'edit') {
              _openCategoryForm(context, category: cat);
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, CategoryModel cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Categoria?'),
        content: Text(
          'Tem certeza que deseja excluir a categoria "${cat.name}"? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CategoryBloc>().add(DeleteCategory(cat.id!));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openCategoryForm(BuildContext context, {CategoryModel? category}) {
    showDialog(
      context: context,
      builder: (ctx) => _CategoryFormDialog(category: category),
    );
  }
}

class _CategoryFormDialog extends StatefulWidget {
  final CategoryModel? category;

  const _CategoryFormDialog({this.category});

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  late TextEditingController _nameCtrl;
  late bool _isIncome;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.category?.name ?? '');
    _isIncome = widget.category?.isIncome ?? false;
    _selectedColor = Color(widget.category?.color ?? Colors.blue.value);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.category == null ? 'Nova Categoria' : 'Editar Categoria',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nome da Categoria',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                hintText: 'Ex: Alimentação, Transporte...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tipo',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const <ButtonSegment<bool>>[
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('Entrada'),
                        icon: Icon(Icons.arrow_upward),
                      ),
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('Saída'),
                        icon: Icon(Icons.arrow_downward),
                      ),
                    ],
                    selected: <bool>{_isIncome},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setState(() => _isIncome = newSelection.first);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Cor',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showColorPicker,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Escolher Cor'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveCategory,
          child: Text(widget.category == null ? 'Criar' : 'Atualizar'),
        ),
      ],
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Escolher Cor'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() => _selectedColor = color);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  void _saveCategory() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um nome para a categoria')),
      );
      return;
    }

    final model = CategoryModel(
      id: widget.category?.id,
      name: _nameCtrl.text.trim(),
      isIncome: _isIncome,
      color: _selectedColor.value,
    );

    if (widget.category == null) {
      context.read<CategoryBloc>().add(AddCategory(model));
    } else {
      context.read<CategoryBloc>().add(UpdateCategory(model));
    }

    Navigator.pop(context);
  }
}
