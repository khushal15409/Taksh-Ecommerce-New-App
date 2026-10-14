import 'dart:async';

import 'package:flutter/material.dart';

enum AppToastType { success, error, warning, info }

/// Top-center toast (white card, coloured status icon, title + message, close
/// button and a countdown bar). Used for every success / error / warning / info
/// message in the app.
class AppToast {
  AppToast._();

  static OverlayEntry? _entry;
  static _ToastController? _controller;

  static void success(BuildContext context, String title, {String? message}) =>
      show(context, type: AppToastType.success, title: title, message: message);

  static void error(BuildContext context, String title, {String? message}) =>
      show(context, type: AppToastType.error, title: title, message: message);

  static void warning(BuildContext context, String title, {String? message}) =>
      show(context, type: AppToastType.warning, title: title, message: message);

  static void info(BuildContext context, String title, {String? message}) =>
      show(context, type: AppToastType.info, title: title, message: message);

  /// Shows a toast. Returns false when no overlay is available.
  static bool show(
    BuildContext context, {
    required AppToastType type,
    required String title,
    String? message,
    Widget? messageWidget,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return false;

    dismiss(immediately: true);

    final controller = _ToastController();
    final entry = OverlayEntry(
      builder: (_) => _ToastView(
        controller: controller,
        type: type,
        title: title,
        message: message,
        messageWidget: messageWidget,
        duration: duration,
        actionLabel: actionLabel,
        onAction: onAction,
        onFinished: () {
          if (identical(_controller, controller)) {
            _entry?.remove();
            _entry = null;
            _controller = null;
          }
        },
      ),
    );
    _entry = entry;
    _controller = controller;
    overlay.insert(entry);
    return true;
  }

  static void dismiss({bool immediately = false}) {
    if (immediately) {
      _entry?.remove();
      _entry = null;
      _controller = null;
    } else {
      _controller?.close();
    }
  }
}

class _ToastController {
  VoidCallback? _close;
  void close() => _close?.call();
}

/// Drop-in stand-in for `ScaffoldMessenger.of(context)` that renders
/// [SnackBar]s as [AppToast]s, so every existing call site gets the new look.
class AppToastMessenger {
  final BuildContext _context;

  AppToastMessenger._(this._context);

  static AppToastMessenger of(BuildContext context) =>
      AppToastMessenger._(context);

  void showSnackBar(SnackBar snackBar) {
    final content = snackBar.content;
    String? text;
    if (content is Text) {
      text = content.data ?? content.textSpan?.toPlainText();
    }

    final type = _inferType(snackBar.backgroundColor, text);
    final duration = snackBar.duration < const Duration(seconds: 2)
        ? const Duration(seconds: 2)
        : snackBar.duration;
    final action = snackBar.action;

    String title;
    String? message;
    Widget? messageWidget;
    if (text == null) {
      title = _defaultTitle(type);
      messageWidget = content;
    } else if (text.length <= 48 && !text.contains('\n')) {
      title = text;
    } else {
      title = _defaultTitle(type);
      message = text;
    }

    final shown = AppToast.show(
      _context,
      type: type,
      title: title,
      message: message,
      messageWidget: messageWidget,
      duration: action != null && duration < const Duration(seconds: 4)
          ? const Duration(seconds: 4)
          : duration,
      actionLabel: action?.label,
      onAction: action?.onPressed,
    );

    if (!shown) {
      // No overlay found: fall back to the regular snack bar.
      ScaffoldMessenger.of(_context).showSnackBar(snackBar);
    }
  }

  void hideCurrentSnackBar() => AppToast.dismiss();
  void removeCurrentSnackBar() => AppToast.dismiss(immediately: true);
  void clearSnackBars() => AppToast.dismiss(immediately: true);

  static String _defaultTitle(AppToastType type) {
    switch (type) {
      case AppToastType.success:
        return 'Success';
      case AppToastType.error:
        return 'Something went wrong';
      case AppToastType.warning:
        return 'Warning';
      case AppToastType.info:
        return 'Info';
    }
  }

  static AppToastType _inferType(Color? color, String? text) {
    if (color != null) {
      final hsl = HSLColor.fromColor(color);
      if (hsl.saturation > 0.25 && hsl.lightness > 0.12 && hsl.lightness < 0.9) {
        final h = hsl.hue;
        if (h >= 75 && h <= 170) return AppToastType.success;
        if (h < 20 || h > 335) return AppToastType.error;
        if (h >= 20 && h < 60) return AppToastType.warning;
        if (h >= 180 && h <= 260) return AppToastType.info;
      }
    }

    final t = (text ?? '').toLowerCase();
    const errorWords = [
      'fail', 'error', 'unable', 'invalid', 'wrong', 'could not', 'cannot',
      "can't", 'denied', 'declined', 'unavailable',
    ];
    const successWords = [
      'success', 'added', 'updated', 'saved', 'placed', 'downloaded',
      'removed', 'cleared', 'verified', 'sent', 'submitted', 'deleted',
      'cancelled', 'completed', 'copied',
    ];
    const warningWords = [
      'please', 'select', 'enter', 'wait', 'not available', 'required',
      'limit', 'no ',
    ];
    if (errorWords.any(t.contains)) return AppToastType.error;
    if (successWords.any(t.contains)) return AppToastType.success;
    if (warningWords.any(t.contains)) return AppToastType.warning;
    return AppToastType.info;
  }
}

class _ToastView extends StatefulWidget {
  final _ToastController controller;
  final AppToastType type;
  final String title;
  final String? message;
  final Widget? messageWidget;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onFinished;

  const _ToastView({
    required this.controller,
    required this.type,
    required this.title,
    required this.message,
    required this.messageWidget,
    required this.duration,
    required this.actionLabel,
    required this.onAction,
    required this.onFinished,
  });

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView> with TickerProviderStateMixin {
  late final AnimationController _slide = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    widget.controller._close = _close;
    _slide.forward();
    _progress.forward().whenComplete(_close);
  }

  Future<void> _close() async {
    if (_closing || !mounted) return;
    _closing = true;
    _progress.stop();
    try {
      await _slide.reverse();
    } finally {
      widget.onFinished();
    }
  }

  @override
  void dispose() {
    _slide.dispose();
    _progress.dispose();
    super.dispose();
  }

  Color get _color {
    switch (widget.type) {
      case AppToastType.success:
        return const Color(0xFF2E9E4F);
      case AppToastType.error:
        return const Color(0xFFE53935);
      case AppToastType.warning:
        return const Color(0xFFFF8A1F);
      case AppToastType.info:
        return const Color(0xFF2F80ED);
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case AppToastType.success:
        return Icons.check_circle_rounded;
      case AppToastType.error:
        return Icons.cancel_rounded;
      case AppToastType.warning:
        return Icons.warning_rounded;
      case AppToastType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + 8;
    final hasBody = widget.message != null || widget.messageWidget != null;

    return Positioned(
      top: top,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1.4),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _slide, curve: Curves.easeOutCubic)),
        child: FadeTransition(
          opacity: _slide,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: GestureDetector(
                onVerticalDragEnd: (d) {
                  if ((d.primaryVelocity ?? 0) < -150) _close();
                },
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.16),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
                          child: Row(
                            crossAxisAlignment: hasBody
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.center,
                            children: [
                              Icon(_icon, color: _color, size: 40),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: hasBody ? 2 : 0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF212121),
                                        ),
                                      ),
                                      if (widget.message != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2),
                                          child: Text(
                                            widget.message!,
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF616161),
                                              height: 1.25,
                                            ),
                                          ),
                                        ),
                                      if (widget.messageWidget != null)
                                        DefaultTextStyle(
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF616161),
                                          ),
                                          child: widget.messageWidget!,
                                        ),
                                      if (widget.actionLabel != null)
                                        GestureDetector(
                                          onTap: () {
                                            widget.onAction?.call();
                                            _close();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 6,
                                            ),
                                            child: Text(
                                              widget.actionLabel!,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: _color,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _close,
                                visualDensity: VisualDensity.compact,
                                icon: Icon(
                                  Icons.close_rounded,
                                  size: 22,
                                  color: _color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _progress,
                          builder: (context, _) => Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: 1 - _progress.value,
                              child: Container(height: 3, color: _color),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
