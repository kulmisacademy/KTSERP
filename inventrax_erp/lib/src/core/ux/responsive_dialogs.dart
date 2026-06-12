import 'package:flutter/material.dart';

import 'responsive.dart';

/// Responsive dialog with inset padding and scrollable content on small screens.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required Widget title,
  required Widget content,
  List<Widget>? actions,
  bool scrollContent = true,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) {
      final inset = Responsive.dialogInset(ctx);
      Widget body = content;
      if (scrollContent) {
        body = SingleChildScrollView(child: body);
      }
      return Dialog(
        insetPadding: EdgeInsets.all(inset),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.isMobile(ctx) ? double.infinity : 560,
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.88,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(inset, inset, inset, 0),
                  child: DefaultTextStyle(
                    style: Theme.of(ctx).textTheme.titleLarge!,
                    child: title,
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.all(inset),
                  child: body,
                ),
              ),
              if (actions != null && actions.isNotEmpty)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(inset, 0, inset, inset),
                    child: OverflowBar(
                      alignment: MainAxisAlignment.end,
                      spacing: 8,
                      children: actions,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

/// Alert-style dialog using responsive insets.
Future<T?> showAppAlertDialog<T>({
  required BuildContext context,
  Widget? title,
  Widget? content,
  List<Widget>? actions,
  bool scrollContent = true,
}) {
  return showDialog<T>(
    context: context,
    builder: (ctx) {
      final inset = Responsive.dialogInset(ctx);
      Widget? body = content;
      if (body != null && scrollContent) {
        body = SingleChildScrollView(child: body);
      }
      return AlertDialog(
        insetPadding: EdgeInsets.all(inset),
        title: title,
        content: body,
        contentPadding: EdgeInsets.fromLTRB(inset, inset, inset, 0),
        actionsPadding: EdgeInsets.fromLTRB(inset, 0, inset, inset),
        actions: actions,
      );
    },
  );
}

/// Standard bottom sheet with safe area and keyboard inset.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
  bool showDragHandle = true,
  Color? backgroundColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    showDragHandle: showDragHandle,
    backgroundColor: backgroundColor,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(ctx).bottom,
        ),
        child: builder(ctx),
      );
    },
  );
}
