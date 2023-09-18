import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../navigation/oasis_navigator.dart';
import '../../navigation/route_overlay_manager.dart';

enum SwipablePopUpTransitionStatus { forward, resetting, dismissing, idle }

class SwipablePopUpTransitionState {
  // ignore: public_member_api_docs
  SwipablePopUpTransitionState({
    this.offset = Offset.zero,
    this.scale = 1.0,
    required this.radius,
    required this.opacity,
    this.bgOpacity = 0.0,
  });

  final double radius;
  final double opacity;
  final double bgOpacity;
  final double scale;
  final Offset offset;
}

class SwipablePopUpTransitionController {
  // ignore: public_member_api_docs
  SwipablePopUpTransitionController(this.context, {required this.vsync, this.initOffset});

  final BuildContext context;
  final TickerProvider vsync;
  final Offset? initOffset;
  late final AnimationController animationController;

  final double _minRadius = 0;
  final double _maxRadius = 50;
  final double _dragSensivity = 0.8;
  final double _minScale = 0.75;
  final double _kDismissThreshold = 0.25;
  final double _initialScale = 0.1;
  int activeCount = 0;
  bool _dragUnderway = false;
  Offset _startOffset = Offset.zero;

  final ValueNotifier<SwipablePopUpTransitionState> notifier =
      ValueNotifier(SwipablePopUpTransitionState(radius: 50, opacity: 0.5, scale: 0.4));

  void init() {
    animationController = AnimationController(duration: Duration(milliseconds: 200), vsync: vsync);
    animationController.addListener(animationListener);
    animationController.addStatusListener(animationStatusListener);
    animationController.animateTo(1);
  }

  void animationListener() {
    if (status == SwipablePopUpTransitionStatus.forward) {
      final double m = Curves.easeIn.transform(animationController.value);
      final Offset offset = Offset.lerp(initOffset ?? Offset.zero, Offset.zero, m)!;
      final double k = animationController.value;
      final double targetRadius = lerpDouble(_maxRadius, _minRadius, k)!;
      final double targetOpacity = lerpDouble(_initialScale, 1, k)!;
      final double targetBgOpacity = animationController.value;
      final double targetScale = lerpDouble(_initialScale, 1, k)!;
      notifier.value = SwipablePopUpTransitionState(
          offset: offset, radius: targetRadius, opacity: targetOpacity, bgOpacity: targetBgOpacity, scale: targetScale);
      if (targetScale == 1) RouteOverlayManager.instance.turnOnLastOverlayOpaqueness();
    }

    if (status == SwipablePopUpTransitionStatus.resetting) {
      final double m = Curves.easeInOut.transform(animationController.value);
      final Offset offset = Offset.lerp(notifier.value.offset, Offset.zero, m)!;
      final double k = _offsetProgression(offset);
      final double targetRadius = lerpDouble(_minRadius, _maxRadius, k)!;
      final double targetOpacity = notifier.value.opacity;
      final double targetScale = lerpDouble(1, _minScale, k)!;
      notifier.value = SwipablePopUpTransitionState(
          offset: offset, radius: targetRadius, opacity: targetOpacity, scale: targetScale);
      if (targetScale == 1) RouteOverlayManager.instance.turnOnLastOverlayOpaqueness();
    }

    if (status == SwipablePopUpTransitionStatus.dismissing) {
      final double k = animationController.value;
      final Offset offset = notifier.value.offset;
      final double targetRadius = notifier.value.radius;
      final double targetOpacity = lerpDouble(1, .0, k)!;
      final double targetScale = lerpDouble(_minScale, .05, k)!;
      notifier.value = SwipablePopUpTransitionState(
          offset: offset, radius: targetRadius, opacity: targetOpacity, scale: targetScale);
      if (targetScale == 1) RouteOverlayManager.instance.turnOnLastOverlayOpaqueness();
    }
  }

  void animationStatusListener(AnimationStatus s) {
    if (!(s == AnimationStatus.completed) || (status == SwipablePopUpTransitionStatus.dismissing)) return;
    if (status == SwipablePopUpTransitionStatus.forward) status = SwipablePopUpTransitionStatus.idle;
    animationController.value = 0;
  }

  SwipablePopUpTransitionStatus status = SwipablePopUpTransitionStatus.forward;

  double _offsetProgression(Offset? offset) {
    final Offset _offset = offset ?? notifier.value.offset;
    final Size size = MediaQuery.of(context).size;
    final Offset distanceOffset = _offset - Offset.zero;
    final double w = distanceOffset.dx.abs() / size.width;
    final double h = distanceOffset.dy.abs() / size.height;
    return max(w, h);
  }

  Drag? handleDragInit(Drag? drag, {required Offset position}) {
    if (activeCount > 1) return null;
    RouteOverlayManager.instance.turnOffLastOverlayOpaqueness();
    _dragUnderway = true;
    final RenderBox renderObject = context.findRenderObject()! as RenderBox;
    _startOffset = renderObject.globalToLocal(position);
    return drag;
  }

  void handleDragUpdate(DragUpdateDetails details) {
    if (activeCount > 1) return;
    final Offset targetOffset = (details.globalPosition - _startOffset) * _dragSensivity;
    final double k = _offsetProgression(targetOffset);
    final double targetRadius = lerpDouble(_minRadius, _maxRadius, k)!;
    final double targetOpacity = notifier.value.opacity;
    final double targetScale = lerpDouble(1, _minScale, k)!;
    notifier.value = SwipablePopUpTransitionState(
        offset: targetOffset, radius: targetRadius, opacity: targetOpacity, scale: targetScale);
  }

  void handleDragCancel() => _dragUnderway = false;

  void handleDragEnd(DragEndDetails details) {
    if (!_dragUnderway) return;
    _dragUnderway = false;
    final bool shouldDismiss = _offsetProgression(null) > _kDismissThreshold;
    if (shouldDismiss) close();
    if (!shouldDismiss) reset();
  }

  void close() {
    RouteOverlayManager.instance.turnOffLastOverlayOpaqueness();
    status = SwipablePopUpTransitionStatus.dismissing;
    animationController.animateTo(1);
    Future.delayed(animationController.duration ?? const Duration(milliseconds: 200), () {});
    OasisNavigator.instance.pop();
  }

  void reset() {
    status = SwipablePopUpTransitionStatus.resetting;
    animationController.animateTo(1);
  }

  void dispose() {
    animationController.removeListener(animationListener);
    animationController.removeStatusListener(animationStatusListener);
    animationController.dispose();
    notifier.dispose();
  }
}
