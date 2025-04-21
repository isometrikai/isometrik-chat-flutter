import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatContextWidget {
  IsmChatContextWidget._();

  static void goBack<T>([T? result]) {
    Navigator.of(IsmChatConfig.kNavigatorKey.currentContext!).pop(result);
  }

  static Future<T?> showDialogContext<T>({
    required Widget content,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
  }) async =>
      await showDialog(
        context: IsmChatConfig.kNavigatorKey.currentContext!,
        builder: (context) => content,
        anchorPoint: anchorPoint,
        barrierColor: barrierColor,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
        routeSettings: routeSettings,
        traversalEdgeBehavior: traversalEdgeBehavior,
        useRootNavigator: useRootNavigator,
        useSafeArea: useSafeArea,
      );
  static Future<T?> showBottomsheetContext<T>({
    required Widget content,
    Color? backgroundColor,
    String? barrierLabel,
    double elevation = 0,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? barrierColor,
    bool isScrollControlled = true,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool? showDragHandle,
    bool useSafeArea = true,
    RouteSettings? routeSettings,
    AnimationController? transitionAnimationController,
    Offset? anchorPoint,
    AnimationStyle? sheetAnimationStyle,
  }) async =>
      await showModalBottomSheet(
        context: IsmChatConfig.kNavigatorKey.currentContext!,
        builder: (context) => content,
        anchorPoint: anchorPoint,
        barrierColor: barrierColor,
        barrierLabel: barrierLabel,
        routeSettings: routeSettings,
        useRootNavigator: useRootNavigator,
        useSafeArea: useSafeArea,
        backgroundColor: backgroundColor,
        clipBehavior: clipBehavior,
        constraints: constraints,
        elevation: elevation,
        enableDrag: enableDrag,
        isDismissible: isDismissible,
        isScrollControlled: isScrollControlled,
        // scrollControlDisabledMaxHeightRatio:
        shape: shape,
        sheetAnimationStyle: sheetAnimationStyle,
        showDragHandle: showDragHandle,
        transitionAnimationController: transitionAnimationController,
      );
}
