import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../blocs/category/category_bloc.dart';
import '../../blocs/category/category_event.dart';
import '../../core/models/category_model.dart';

class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({super.key});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final TextEditingController _nameController = TextEditingController();

  Color _selectedColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Categoria')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Nome da Categoria"),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Ex: Alimentação, Transporte...',
              ),
            ),

            const SizedBox(height: 24),

            const Text("Cor da Categoria"),
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDialog<Color>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Escolher cor"),
                        content: SingleChildScrollView(
                          child: BlockPicker(
                            pickerColor: _selectedColor,
                            onColorChanged: (color) {
                              Navigator.of(context).pop(color);
                            },
                          ),
                        ),
                      ),
                    );

                    if (picked != null) {
                      setState(() => _selectedColor = picked);
                    }
                  },
                  child: const Text("Selecionar cor"),
                ),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Digite um nome")),
                    );
                    return;
                  }

                  // ignore: deprecated_member_use
                  final category = CategoryModel(
                    id: null,
                    name: _nameController.text,
                    isIncome: false, // ou true, dependendo do que você quiser
                    color: _selectedColor.value,
                  );

                  context.read<CategoryBloc>().add(AddCategory(category));

                  Navigator.pop(context);
                },
                child: const Text("Salvar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
