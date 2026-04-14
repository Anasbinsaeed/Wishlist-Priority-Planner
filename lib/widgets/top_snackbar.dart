import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class TopSnackbar {
  static OverlayEntry? _current;

  static void show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    _current?.remove();
    _current = null;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlay = Overlay.of(context, rootOverlay: true);
    final topPadding = MediaQuery.of(context).padding.top;

    late OverlayEntry entry;
    Timer? timer;

    void dismiss() {
      timer?.cancel();
      entry.remove();
      if (_current == entry) _current = null;
    }

    entry = OverlayEntry(
      builder: (_) => _TopSnackbarWidget(
        message: message,
        actionLabel: actionLabel,
        onAction: () {
          dismiss();
          onAction?.call();
        },
        onDismiss: dismiss,
        isDark: isDark,
        topPadding: topPadding,
        duration: duration,
      ),
    );

    _current = entry;
    overlay.insert(entry);

    timer = Timer(duration, dismiss);
  }
}

class _TopSnackbarWidget extends StatefulWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;
  final bool isDark;
  final double topPadding;
  final Duration duration;

  const _TopSnackbarWidget({
    required this.message,
    required this.onDismiss,
    required this.isDark,
    required this.topPadding,
    required this.duration,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<_TopSnackbarWidget> createState() => _TopSnackbarWidgetState();
}

class _TopSnackbarWidgetState extends State<_TopSnackbarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AppColors.darkSurface2 : AppColors.lightSurface;
    final textColor = widget.isDark ? AppColors.darkText : AppColors.lightText;
    final borderColor = widget.isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;

    return Positioned(
      top: widget.topPadding + 50,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
                boxShadow: widget.isDark ? AppShadows.dark : AppShadows.light,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (widget.actionLabel != null &&
                      widget.onAction != null) ...[
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: widget.onAction,
                      child: Text(
                        widget.actionLabel!,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
