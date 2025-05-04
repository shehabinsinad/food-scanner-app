import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
  final String title;
  final bool initialValue;
  final Function(bool) onChanged;

  const CustomCheckbox({
    Key? key,
    required this.title,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  _CustomCheckboxState createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      value: _checked,
      activeColor: Colors.yellow,
      checkColor: Colors.black,
      onChanged: (value) {
        setState(() {
          _checked = value!;
        });
        widget.onChanged(value!);
      },
    );
  }
}
