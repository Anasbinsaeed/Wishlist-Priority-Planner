import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppDeadlinePicker extends StatelessWidget {
  final DateTime? deadline;
  final void Function(DateTime) onPicked;
  final VoidCallback? onClear;

  const AppDeadlinePicker({
    super.key,
    required this.deadline,
    required this.onPicked,
    this.onClear,
  });

  String get _label {
    if (deadline == null) return 'Set Deadline';
    return DateFormat('MMM d, yyyy  •  h:mm a').format(deadline!);
  }

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: deadline ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: deadline != null
          ? TimeOfDay.fromDateTime(deadline!)
          : TimeOfDay.now(),
    );
    if (time == null || !context.mounted) return;

    onPicked(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Deadline',
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          suffixIcon: deadline != null && onClear != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: onClear,
                )
              : const Icon(Icons.access_time_outlined),
        ),
        child: Text(
          _label,
          style: TextStyle(
            color: deadline == null
                ? Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.45)
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
