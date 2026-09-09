import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatContextWidget {
  IsmChatContextWidget._();

  static BuildContext _dialogContext(BuildContext? context) =>
      context ??
      IsmChatConfig.kNavigatorKey.currentContext ??
      IsmChatConfig.context;

  /// Themed alert used by [IsmChatShowDialogMixin] and confirmation flows.
  static Future<void> showThemedAlertDialog({
    required String title,
    List<String>? actionLabels,
    List<VoidCallback>? callbackActions,
    String? cancelLabel,
    VoidCallback? onCancel,
    Widget? content,
    TextStyle? contentTextStyle,
    bool barrierDismissible = true,
    BuildContext? context,
  }) =>
      showDialogContext(
        context: context,
        barrierDismissible: barrierDismissible,
        content: IsmChatAlertDialogBox(
          title: title,
          actionLabels: actionLabels,
          callbackActions: callbackActions,
          cancelLabel: cancelLabel ?? IsmChatStrings.cancel,
          onCancel: onCancel,
          content: content,
          contentTextStyle: contentTextStyle,
        ),
      );

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
    BuildContext? context,
  }) async {
    final hostContext = _dialogContext(context);
    final dialogTheme = IsmChatThemeResolver.dialogFromConfig(hostContext);
    return showDialog<T>(
      context: hostContext,
      builder: (dialogContext) => content,
      anchorPoint: anchorPoint,
      barrierColor: barrierColor ?? dialogTheme.barrierColor,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      routeSettings: routeSettings,
      traversalEdgeBehavior: traversalEdgeBehavior,
      useRootNavigator: useRootNavigator,
      useSafeArea: useSafeArea,
    );
  }

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
    BuildContext? context,
  }) async {
    final hostContext = _dialogContext(context);
    final dialogTheme = IsmChatThemeResolver.dialogFromConfig(hostContext);
    return showModalBottomSheet<T>(
      context: hostContext,
      builder: (sheetContext) => content,
      anchorPoint: anchorPoint,
      barrierColor: barrierColor ?? dialogTheme.barrierColor,
      barrierLabel: barrierLabel,
      routeSettings: routeSettings,
      useRootNavigator: useRootNavigator,
      useSafeArea: useSafeArea,
      backgroundColor: backgroundColor ?? dialogTheme.backgroundColor,
      clipBehavior: clipBehavior,
      constraints: constraints,
      elevation: elevation,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled,
      shape: shape,
      sheetAnimationStyle: sheetAnimationStyle,
      showDragHandle: showDragHandle,
      transitionAnimationController: transitionAnimationController,
    );
  }
}
