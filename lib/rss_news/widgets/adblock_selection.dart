import 'package:flutter/material.dart';

class OptionToggleWithSelection extends StatefulWidget {
  final List<String> values;
  final ValueChanged<String?> onSelectionChanged;
  final ValueChanged<bool> onToggle;

  const OptionToggleWithSelection({
    Key? key,
    required this.values,
    required this.onSelectionChanged,
    required this.onToggle,
  }) : super(key: key);

  @override
  State<OptionToggleWithSelection> createState() =>
      _OptionToggleWithSelectionState();
}

class _OptionToggleWithSelectionState extends State<OptionToggleWithSelection> {
  bool isEnabled = false;
  String? selectedValue;

  void _toggleOption() async {
    if (isEnabled) {
      setState(() {
        isEnabled = false;
        selectedValue = null;
      });
      widget.onToggle(false);
      widget.onSelectionChanged(null);
    } else {
      final result = await showDialog<String>(
        context: context,
        builder: (_) => _SelectionDialog(
            values: widget.values, selectedValue: selectedValue),
      );

      if (result != null) {
        setState(() {
          isEnabled = true;
          selectedValue = result;
        });
        widget.onToggle(true);
        widget.onSelectionChanged(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text("AdBlock Plus Filter List"),
      subtitle: Text(isEnabled ? selectedValue ?? 'None' : "Disabled"),
      trailing: Switch(value: isEnabled, onChanged: (_) => _toggleOption()),
    );
  }
}

class _SelectionDialog extends StatelessWidget {
  final List<String> values;
  final String? selectedValue;

  const _SelectionDialog(
      {required this.values, required this.selectedValue});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select an Item'),
      content: SingleChildScrollView(
        child: Column(
          children: values.map((value) {
            return RadioListTile<String>(
              title: Text(value),
              value: value,
              groupValue: selectedValue,
              onChanged: (selected) {
                Navigator.of(context).pop(selected);
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop(selectedValue);
          },
        ),
      ],
    );
  }
}
