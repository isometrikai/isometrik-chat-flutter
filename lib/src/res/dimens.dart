import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IsmChatDimens {
  const IsmChatDimens._();

  /// Get the height with the percent value of the screen height.
  static double percentHeight(double percentValue) => percentValue.sh;

  /// Get the width with the percent value of the screen width.
  static double percentWidth(double percentValue) => percentValue.sw;

  static final double zero = 0.sp;
  static final double one = 1.sp;
  static final double two = 2.sp;
  static final double three = 3.sp;
  static final double four = 4.sp;
  static final double five = 5.sp;
  static final double six = 6.sp;
  static final double seven = 7.sp;

  static final double eight = 8.sp;
  static final double nine = 9.sp;
  static final double ten = 10.sp;
  static final double twelve = 12.sp;
  static final double eleven = 11.sp;

  static final double tharteen = 13.sp;
  static final double forteen = 14.sp;
  static final double fifteen = 15.sp;
  static final double sixteen = 16.sp;
  static final double seventeen = 17.sp;
  static final double eighteen = 18.sp;
  static final double twenty = 20.sp;
  static final double twentyFour = 24.sp;
  static final double twentyFive = 25.sp;

  static final double twentySeven = 27.sp;
  static final double twentyEight = 28.sp;
  static final double thirtyTwo = 32.sp;
  static final double thirtyFive = 35.sp;

  static final double thirty = 30.sp;

  static final double forty = 40.sp;
  static final double fortyFive = 45.sp;

  static final double fortyEight = 48.sp;

  static final double fifty = 50.sp;
  static final double fiftyFive = 55.sp;
  static final double sixty = 60.sp;
  static final double seventyEight = 78.sp;
  static final double seventy = 70.sp;

  static final double eighty = 80.sp;
  static final double ninty = 90.sp;

  static final double hundred = 100.sp;
  static final double oneHundredTwenty = 120.sp;
  static final double oneHundredThirty = 130.sp;

  static final double hundredFourty = 140.sp;
  static final double oneHundredFifty = 150.sp;
  static final double oneHundredSeventy = 170.sp;
  static final double hundredNintyThree = 193.sp;
  static final double twoHundred = 200.sp;
  static final double twoHundredTwenty = 220.sp;
  static final double twoHundredFifty = 250.sp;
  static final double threeHundredFourtyThree = 343.sp;

  static final double inputFieldHeight = 40.sp;
  static final double appBarHeight = 56.sp;
  static final double appBarElevation = 8.sp;

  static final Widget box0 = SizedBox(height: zero);

  static final Widget boxHeight4 = SizedBox(height: four);
  static final Widget boxHeight2 = SizedBox(height: two);
  static final Widget boxHeight5 = SizedBox(height: five);

  static final Widget boxHeight8 = SizedBox(height: eight);
  static final Widget boxHeight10 = SizedBox(height: ten);
  static final Widget boxHeight16 = SizedBox(height: sixteen);
  static final Widget boxHeight20 = SizedBox(height: twenty);
  static final Widget boxHeight24 = SizedBox(height: twentyFour);
  static final Widget boxHeight32 = SizedBox(height: thirtyTwo);
  static final Widget boxWidth2 = SizedBox(width: two);
  static final Widget boxWidth4 = SizedBox(width: four);
  static final Widget boxWidth8 = SizedBox(width: eight);
  static final Widget boxWidth12 = SizedBox(width: twelve);
  static final Widget boxWidth14 = SizedBox(width: forteen);
  static final Widget boxWidth16 = SizedBox(width: sixteen);
  static final Widget boxWidth20 = SizedBox(width: twenty);

  static final Widget boxWidth32 = SizedBox(width: thirtyTwo);

  static final EdgeInsets edgeInsets6 = EdgeInsets.all(six);
  static final EdgeInsets edgeInsets4 = EdgeInsets.all(four);
  static final EdgeInsets edgeInsets5 = EdgeInsets.all(five);

  static final EdgeInsets edgeInsets0 = EdgeInsets.all(zero);
  static final EdgeInsets edgeInsetsB25 = EdgeInsets.only(bottom: twentyFive);

  static final EdgeInsets edgeInsetsL2 = EdgeInsets.only(left: two);
  static final EdgeInsets edgeInsetsR4 = EdgeInsets.only(right: four);
  static final EdgeInsets edgeInsets5_5_5_20 =
      EdgeInsets.only(left: five, top: five, right: five, bottom: twenty);

  static final EdgeInsets edgeInsetsL4 = EdgeInsets.only(left: four);

  static final EdgeInsets edgeInsets2_0 = EdgeInsets.symmetric(horizontal: two);
  static final EdgeInsets edgeInsets4_0 =
      EdgeInsets.symmetric(horizontal: four);
  static final EdgeInsets edgeInsets0_4 = EdgeInsets.symmetric(vertical: four);
  static final EdgeInsets edgeInsets4_8 =
      EdgeInsets.symmetric(horizontal: four, vertical: eight);
  static final EdgeInsets edgeInsets8_4 =
      EdgeInsets.symmetric(horizontal: eight, vertical: four);
  static final EdgeInsets edgeInsets8_0 =
      EdgeInsets.symmetric(horizontal: eight, vertical: zero);
  static final EdgeInsets edgeInsets8 = EdgeInsets.all(eight);
  static final EdgeInsets edgeInsets10 = EdgeInsets.all(ten);

  static final EdgeInsets edgeInsets12 = EdgeInsets.all(twelve);
  static final EdgeInsets edgeInsets15 = EdgeInsets.all(fifteen);

  static EdgeInsets edgeInsetsHorizontal10 =
      EdgeInsets.symmetric(vertical: zero, horizontal: ten);

  static final EdgeInsets edgeInsets10_5_10_10 =
      EdgeInsets.only(left: ten, top: five, bottom: ten, right: ten);
  static final EdgeInsets edgeInsetsTop20 = EdgeInsets.only(top: twenty);
  static final EdgeInsets edgeInsetsTop10 = EdgeInsets.only(top: ten);

  static final EdgeInsets edgeInsetsTop5 = EdgeInsets.only(top: five);

  static final EdgeInsets edgeInsetsTop20Left5 =
      EdgeInsets.only(top: twenty, left: five);
  static final EdgeInsets edgeInsets16_0_19_8 =
      EdgeInsets.only(left: sixteen, right: ten, bottom: eight);

  static final EdgeInsets edgeInsets25_0_25_0 = EdgeInsets.only(
    left: twentyFive,
    right: twentyFive,
  );

  static final EdgeInsets edgeInsets16 = EdgeInsets.all(sixteen);
  static final EdgeInsets edgeInsets16_0_16_0 =
      EdgeInsets.only(left: sixteen, right: sixteen);
  static final EdgeInsets edgeInsets16_8_16_8 =
      EdgeInsets.only(left: sixteen, top: eight, right: sixteen, bottom: eight);
  static final EdgeInsets edgeInsets16_0 =
      EdgeInsets.symmetric(horizontal: sixteen, vertical: zero);
  static final EdgeInsets edgeInsets20_15 =
      EdgeInsets.symmetric(horizontal: twenty, vertical: fifteen);
  static final EdgeInsets edgeInsets16_8 =
      EdgeInsets.symmetric(horizontal: sixteen, vertical: eight);
  static final EdgeInsets edgeInsets5_10 =
      EdgeInsets.symmetric(horizontal: five, vertical: ten);

  static final EdgeInsets edgeInsets24_0 =
      EdgeInsets.symmetric(horizontal: twentyFour);
  static final EdgeInsets edgeInsets0_16_0_0 =
      EdgeInsets.fromLTRB(zero, sixteen, zero, zero);
  static final EdgeInsets edgeInsets20 = EdgeInsets.all(twenty);
  static final EdgeInsets edgeInsets40 = EdgeInsets.all(forty);

  static final EdgeInsets edgeInsets20_0 =
      EdgeInsets.symmetric(horizontal: twenty);

  static final EdgeInsets edgeInsets0_8 = EdgeInsets.symmetric(vertical: eight);
  static final EdgeInsets edgeInsets0_10 = EdgeInsets.symmetric(vertical: ten);
  static final EdgeInsets edgeInsets0_20 =
      EdgeInsets.symmetric(vertical: twenty);

  static final EdgeInsets edgeInsets10_0 =
      EdgeInsets.symmetric(horizontal: ten);

  static final EdgeInsets edgeInsets10_05 =
      EdgeInsets.symmetric(horizontal: ten, vertical: five);
  static final EdgeInsets edgeInsets10_4 =
      EdgeInsets.symmetric(horizontal: ten, vertical: four);
  static final EdgeInsets edgeInsets8_10 =
      EdgeInsets.symmetric(horizontal: eight, vertical: 10);
  static final EdgeInsets edgeInsetsBottom10 = EdgeInsets.only(bottom: ten);
  static final EdgeInsets edgeInsetsBottom8 = EdgeInsets.only(bottom: eight);
  static final EdgeInsets edgeInsetsBottom4 = EdgeInsets.only(bottom: four);

  static final EdgeInsets edgeInsetsBottom50 = EdgeInsets.only(bottom: fifty);
  static final EdgeInsets edgeInsetsLeft10 = EdgeInsets.only(left: ten);
  static final EdgeInsets edgeInsetsLeft120 =
      EdgeInsets.only(left: oneHundredTwenty);

  static final EdgeInsets edgeInsets10_20_10_0 =
      EdgeInsets.only(left: ten, top: twenty, right: ten);
}
