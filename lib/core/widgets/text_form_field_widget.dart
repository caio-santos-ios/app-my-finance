import 'package:finance/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFormFieldWidget extends StatefulWidget {
  const TextFormFieldWidget({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.type,
    this.inputFormatters,
    this.validator,
  });

  final TextEditingController controller;
  final String placeholder;
  final TextInputType type;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  State<TextFormFieldWidget> createState() => _TextFormFieldWidgetState();
}

class _TextFormFieldWidgetState extends State<TextFormFieldWidget> {
  bool _visiblePassword = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      style: TextStyle(color: AppColors.dark50),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        hintText: widget.placeholder,
        hintStyle: TextStyle(color: AppColors.dark25),
        filled: true,
        suffixIcon: widget.type == TextInputType.visiblePassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _visiblePassword = !_visiblePassword;
                  });
                },
                icon: Icon(
                  color: AppColors.light20,
                  _visiblePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              )
            : null,
      ),
      keyboardType: widget.type,
      obscureText: widget.type != TextInputType.visiblePassword
          ? false
          : !_visiblePassword,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
    );
  }
}
