import 'package:flutter/material.dart';

class AppDropdown<T> extends StatelessWidget {
  final T? initialValue;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;

  const AppDropdown({
    super.key,
    required this.initialValue,
    required this.label,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: initialValue,
      decoration: InputDecoration(labelText: label),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }
}
