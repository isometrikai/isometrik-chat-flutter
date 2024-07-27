import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Dimens {
  const Dimens._();

  /// Get the height with the percent value of the screen height.
  static double percentHeight(double percentValue) => percentValue.sh;

  /// Get the width with the percent value of the screen width.
  static double percentWidth(double percentValue) => percentValue.sw;
  static final double eight = 8.sp;
  static final double ten = 10.sp;
  static final double sixTeen = 16.sp;
  static final double thirtyTwo = 32.sp;

  static final double appBarHeight = 56.sp;

  static final Widget boxHeight8 = SizedBox(height: eight);
  static final Widget boxHeight16 = SizedBox(height: sixTeen);
  static final Widget boxHeight32 = SizedBox(height: thirtyTwo);
  static final EdgeInsets edgeInsets16 = EdgeInsets.all(sixTeen);
}
