import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter_example/res/dimens.dart';
import 'package:isometrik_chat_flutter_example/res/res.dart';

class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.onTap,
    required this.label,
  });

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.maxFinite,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColorLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              Dimens.sixTeen,
            ),
          ),
          foregroundColor: AppColors.whiteColor,
        ),
        onPressed: onTap,
        child: Text(
          label,
        ),
      ),
    );
  }
}
