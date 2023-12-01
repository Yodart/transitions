import 'dart:math';

import 'package:flutter/material.dart';

/// Controller used to controls the [PanelTranstionPageBuilder]
class PanelTranstionController {
  // ignore: public_member_api_docs
  PanelTranstionController(
    this.context, {
    required this.vsync,
    required this.initialHeight,
    required this.maxHeight,
  });

  /// Ticker provided by view
  final BuildContext context;

  /// Ticker provided by view
  final TickerProvider vsync;

  /// Animation controller used to construct the animation over this transition
  late final AnimationController animationController;

  /// Initial page height
  /// Default value [UIScale.height(50)]
  final double initialHeight;

  /// Maximum page height.
  /// Default value  [UIScale.deviceHeight]
  final double maxHeight;

  /// Listener to transitionValue.
  /// Whether `transitionValue` is 0.0, then the page is on its initialHeight
  /// Whether `transitionValue` is 1.0, then the page is on its maxHeight
  final ValueNotifier<double> transitionValue = ValueNotifier(0);

  /// Optional callback called when page is closed.
  VoidCallback? onClose;

  /// Initialize the controller
  void init() {
    animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 350),
      lowerBound: 0,
      upperBound: maxHeight,
    );
    animationController.addListener(_animationListener);
    animationController.addStatusListener(_animationStatusListener);
    animationController.animateTo(initialHeight,
        duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
  }

  /// Handle verfical drag updates over the page
  void handleOutterVerticalDragUpdate(DragUpdateDetails details) {
    final double targetHeight = animationController.value - (details.delta.dy);
    animationController.value = targetHeight <= 0 ? 0 : min(targetHeight, maxHeight);
  }

  /// Handle verfical drag end over the page
  void handleOutterVerticalDragEnd(DragEndDetails details) {
    final double yVelocity = details.velocity.pixelsPerSecond.dy;
    final double exceededHeight = animationController.value - initialHeight;
    final double widgetHeightsDiff = maxHeight - initialHeight;
    final double value = exceededHeight / (widgetHeightsDiff == 0 ? 1 : widgetHeightsDiff);
    if (value <= 0.5 && value > 0) animationController.animateTo(initialHeight, curve: Curves.easeOutCubic);
    if (value < 0) animationController.animateTo(0, curve: Curves.easeOutCubic);
    if (value > 0.5 || yVelocity < -2500) animationController.animateTo(maxHeight, curve: Curves.easeOutCubic);
  }

  void _animationListener() {
    final double exceededHeight = animationController.value - initialHeight;
    final double widgetHeightsDiff = maxHeight - initialHeight;
    double value = exceededHeight / (widgetHeightsDiff == 0 ? 1 : widgetHeightsDiff);
    if (value > 1) value = 1.0;
    if (value < 0) value = 0.0;
    transitionValue.value = value;
  }

  void _animationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed && animationController.value == 0.0) Navigator.of(context).pop();
  }

  /// Closes the page
  void close() {
    onClose?.call();
    animationController.animateTo(0, curve: Curves.easeOutCubic);
  }

  /// Disposes the listenable values
  void dispose() {
    animationController.dispose();
    transitionValue.dispose();
  }
}
