library dpad_detector;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_animations/simple_animations.dart';

part 'dpad_focus_group.dart';

class DPadDetector extends StatefulWidget {
  final Widget child;
  final FocusNode? focusNode;
  final Color focusColor;
  final double focusRadius;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final void Function()? onMenuTap;
  final void Function()? onVolumeUpTap;
  final void Function()? onVolumeDownTap;

  /// Passed along to the [FocusableActionDetector]
  final bool autoFocus;

  /// Passed to [FocusableActionDetector]. Controls whether this widget will accept focus or input of any kind.
  final bool enabled;

  DPadDetector({
    Key? key,
    required this.child,
    this.focusNode,
    this.focusColor = Colors.blue,
    this.focusRadius = 5.0,
    this.onTap,
    this.onLongPress,
    this.onMenuTap,
    this.onVolumeUpTap,
    this.onVolumeDownTap,
    this.enabled = true,
    this.autoFocus = false,
  }) : super(key: key);

  @override
  _DPadDetectorState createState() => _DPadDetectorState();
}

class _DPadDetectorState extends State<DPadDetector> {
  late FocusNode focusNode;
  bool hasFocus = false;

  @override
  void initState() {
    super.initState();
    focusNode = widget.focusNode ?? FocusNode();
    focusNode.addListener(didChangeFocusNode);
  }

  void didChangeFocusNode() {
    if (hasFocus != focusNode.hasFocus) {
      setState(() {
        hasFocus = focusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create the core FocusableActionDetector
    // Widget content = FocusableActionDetector(
    //   enabled: widget.enabled,
    //   autofocus: widget.autoFocus,
    //   child: widget.builder(context, this),
    // );
    return RawKeyboardListener(
      focusNode: focusNode,
      onKey: (event) {
        if (event.runtimeType != RawKeyUpEvent) {
          return;
        }
        if (event.physicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.select) {
          widget.onTap?.call();
        }
        if (event.logicalKey == LogicalKeyboardKey.contextMenu ||
            event.logicalKey == LogicalKeyboardKey.space) {
          widget.onMenuTap?.call();
        }
        if (event.logicalKey == LogicalKeyboardKey.audioVolumeUp) {
          widget.onVolumeUpTap?.call();
        }
        if (event.logicalKey == LogicalKeyboardKey.audioVolumeDown) {
          widget.onVolumeDownTap?.call();
        }
      },
      child: GestureDetector(
        onLongPressStart: (_) {
          widget.onLongPress?.call();
        },
        onTapDown: (_) {
          focusNode.requestFocus();
        },
        onTapUp: (_) {
          focusNode.unfocus();
          widget.onTap?.call();
        },
        onTapCancel: () {
          focusNode.unfocus();
        },
        onLongPress: () {
          widget.onMenuTap?.call();
        },
        child: CustomAnimation<double>(
          control: hasFocus
              ? CustomAnimationControl.playReverse
              : CustomAnimationControl.play,
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 250),
          builder: (context, child, value) {
            return Container(
              margin: EdgeInsets.all(value * 5),
              decoration: BoxDecoration(
                color: widget.focusColor.withOpacity(value * 0.2),
                border: Border.all(
                  color: widget.focusColor.withOpacity(value),
                  width: value,
                ),
                borderRadius: BorderRadius.circular(widget.focusRadius),
              ),
              child: widget.child,
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    focusNode.removeListener(didChangeFocusNode);
    if (widget.focusNode == null) {
      focusNode.dispose();
    }
    super.dispose();
  }
}