import 'package:finance/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.isLoading,
    required this.text,
    this.onPressed,
  });

  final bool isLoading;
  final String text;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton(
        onPressed: isLoading || onPressed == null ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.violet20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.all(Radius.circular(16))
          )
        ),
        child: isLoading
            ? CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              )
            : Text(
                text,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
      ),
    );
  }
}
