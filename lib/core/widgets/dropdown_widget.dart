import 'package:finance/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DropdownWidget extends StatefulWidget {
  const DropdownWidget({
    super.key,
    required this.controller,
    required this.items,
    this.validator,
    required this.placeholder,
  });

  final TextEditingController controller;
  final List<DropdownMenuItem<String>> items;
  final String? Function(String?)? validator;
  final String placeholder;

  @override
  State<DropdownWidget> createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      initialValue: widget.controller.text.isEmpty ? null : widget.controller.text,
      items: widget.items,
      onChanged: (value) {
        if(value != null) {
          widget.controller.text = value;
        }
      },
      style: Theme.of(context).textTheme.headlineLarge,
      decoration: InputDecoration(
        hintText: widget.placeholder,
        hintStyle: TextStyle(color: AppColors.dark25),
        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        suffixIcon: FaIcon(
          FontAwesomeIcons.chevronDown,
          color: Theme.of(context).textTheme.headlineLarge?.color,
        ),
      ),
    );
  }
}
