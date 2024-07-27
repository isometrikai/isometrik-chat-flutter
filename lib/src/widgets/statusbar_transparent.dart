import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StatusBarTransparent extends StatelessWidget {
  const StatusBarTransparent({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        sized: false,
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
        child: child,
      );
}
