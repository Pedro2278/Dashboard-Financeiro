import 'package:flutter/material.dart';

class SimpleDatePicker extends StatelessWidget {
  final DateTime? initialDate;
  final Function(DateTime) onDateSelected;

  const SimpleDatePicker({
    super.key,
    this.initialDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.date_range),
      label: const Text('Selecionar data'),
      onPressed: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: initialDate ?? now,
          firstDate: DateTime(now.year - 5),
          lastDate: DateTime(now.year + 5),
        );
        if (picked != null) onDateSelected(picked);
      },
    );
  }
}
