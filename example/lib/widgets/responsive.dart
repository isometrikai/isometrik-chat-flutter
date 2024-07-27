import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Widget used to check on which platform the app is running tablet, web or mobile
class ResponsiveExample extends StatelessWidget {
  const ResponsiveExample({
    super.key,
    required this.mobile,
    required this.tablet,
    // this.desktop,
    required this.web,
  });

  final Widget mobile;
  final Widget tablet;
  // final Widget desktop;
  final Widget web;

// This size work fine on my design, maybe you need some customization depends on your design

  // This isMobile, isTablet, isDesktop help us later
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 800;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100 &&
      MediaQuery.of(context).size.width >= 800;

  static bool isWeb(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static bool isWebOver(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1500;

  static bool isWebAndTablet(BuildContext context) =>
      ResponsiveExample.isWeb(context) || ResponsiveExample.isTablet(context);

  // static const layoutKey = Key('layout-builder-key');
  // static const containerKey = Key('container-key');

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        // key: layoutKey,
        // If our width is more than 1100 then we consider it a desktop
        builder: (context, constraints) {
          if (constraints.maxWidth < 650) {
            return mobile;
          } else if (constraints.maxWidth <= 1100 &&
              constraints.maxWidth >= 650) {
            return tablet;
          } else if (constraints.maxWidth >= 1100) {
            return web;
          }
          // If width it less then 1100 and more then 650 we consider it as tablet
          // else if (constraints.maxWidth >= 650) {
          //   return tablet;
          // }
          // Or less then that we called it mobile
          else {
            return Container(
                // key: containerKey,
                );
          }
        },
      );
}

class WebMob extends StatelessWidget {
  const WebMob({super.key, required this.web, required this.android});
  final Widget web;
  final Widget android;

  @override
  Widget build(BuildContext context) => kIsWeb ? web : android;
}
