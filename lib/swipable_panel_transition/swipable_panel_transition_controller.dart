import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum SwipablePanelTransitionStatus { stageOne, stageTwo }

class SwipablePanelTransitionController {
  // ignore: public_member_api_docs
  SwipablePanelTransitionController(this.context, {required this.vsync}) {
    stageOne = _SwipablePanelTransitionStageOneController(vsync: vsync);
    stageTwo = _SwipablePanelTransitionStageTwoController(context, vsync: vsync);
  }

  final BuildContext context;
  final TickerProvider vsync;

  late final _SwipablePanelTransitionStageOneController stageOne;
  late final _SwipablePanelTransitionStageTwoController stageTwo;
  ValueNotifier<SwipablePanelTransitionStatus> status = ValueNotifier(SwipablePanelTransitionStatus.stageOne);

  void init() {
    stageTwo.init();
    stageOne.init();
    stageOne.animationController.addStatusListener((s) {
      if (s == AnimationStatus.completed) status.value = SwipablePanelTransitionStatus.stageTwo;
    });
  }

  Drag? handleDragInit(Drag? drag, {required Offset position}) {
    if (status.value == SwipablePanelTransitionStatus.stageOne)
      return stageOne.handleDragInit(drag, position: position);
    return stageTwo.handleDragInit(drag, position: position);
  }

  void handleDragUpdate(DragUpdateDetails details) {
    if (status.value == SwipablePanelTransitionStatus.stageOne) stageOne.handleDragUpdate(details);
    if (status.value == SwipablePanelTransitionStatus.stageTwo) stageTwo.handleDragUpdate(details);
  }

  void handleDragCancel() {
    if (status.value == SwipablePanelTransitionStatus.stageOne) stageOne.handleDragCancel();
    if (status.value == SwipablePanelTransitionStatus.stageTwo) stageTwo.handleDragCancel();
  }

  void handleDragEnd(DragEndDetails details) {
    if (status.value == SwipablePanelTransitionStatus.stageOne) stageOne.handleDragEnd(details);
    if (status.value == SwipablePanelTransitionStatus.stageTwo) stageTwo.handleDragEnd(details);
  }

  void close() {
    if (status.value == SwipablePanelTransitionStatus.stageOne) stageOne.close();
    if (status.value == SwipablePanelTransitionStatus.stageTwo) stageTwo.close();
  }

  void dispose() {
    stageOne.dispose();
    stageTwo.dispose();
  }
}

class _SwipablePanelTransitionStageOneController {
  _SwipablePanelTransitionStageOneController({required this.vsync});

  final TickerProvider vsync;
  late final AnimationController animationController;

  late final AnimationController wrapperAnimationController;
  late final Animation<Offset> wrapperAnimationTween;

  void init() {
    animationController = AnimationController(duration: Duration(milliseconds: 200), vsync: vsync);
    animationController.addStatusListener(animationStatusListener);
    wrapperAnimationController = AnimationController(duration: Duration(milliseconds: 200), vsync: vsync);
    wrapperAnimationTween = Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: wrapperAnimationController, curve: Curves.easeInOutQuad));
    wrapperAnimationController.animateTo(1);
  }

  void animationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) RouteOverlayManager.instance.turnOnLastOverlayOpaqueness();
    if (status != AnimationStatus.completed) RouteOverlayManager.instance.turnOffLastOverlayOpaqueness();
  }

  Drag? handleDragInit(Drag? drag, {required Offset position}) => drag;

  void handleDragUpdate(DragUpdateDetails details) {
    double targetHeight = animationController.value - ((details.delta.dy) / UIScale.height(110));
    animationController.value = targetHeight <= 0 ? 0 : targetHeight;
    if (animationController.value > 0.0 && wrapperAnimationController.value == 1.0) return;
    double targetWrapperHeight = wrapperAnimationController.value - ((details.delta.dy) / UIScale.height(110));
    wrapperAnimationController.value = targetWrapperHeight <= 0 ? 0 : targetWrapperHeight;
  }

  void handleDragCancel() => {};

  void handleDragEnd(DragEndDetails details) {
    final double yVelocity = details.velocity.pixelsPerSecond.dy;
    final double flingVelocity = (yVelocity > 3250) ? -1.0 : 1.0;
    final bool hasWrapperAnimChanged = wrapperAnimationController.value < 1;
    if (hasWrapperAnimChanged) {
      final double wrapperAnimValue = wrapperAnimationController.value;
      if (wrapperAnimValue < 0.9) close();
      if (wrapperAnimValue > 0.9) wrapperAnimationController.animateBack(1);
      return;
    } else {
      final double animvalue = animationController.value;
      if (animvalue < 0.1) animationController.animateBack(0);
      if (animvalue > 0.1) animationController.fling(velocity: flingVelocity);
      return;
    }
  }

  Future<void> close() async {
    wrapperAnimationController.animateTo(0);
    await Future.delayed(wrapperAnimationController.duration ?? const Duration(milliseconds: 200), () {});
    OasisNavigator.instance.pop();
  }

  void dispose() {
    animationController.removeStatusListener(animationStatusListener);
    animationController.dispose();
  }
}

/// ------------------------------------------------------------------------------------------

enum _SwipablePanelTransitionStageTwoStatus { forward, resetting, dismissing, idle }

class SwipablePanelTransitionStageTwoState {
  // ignore: public_member_api_docs
  SwipablePanelTransitionStageTwoState({
    this.offset = Offset.zero,
    this.scale = 1.0,
    required this.radius,
    required this.opacity,
  });

  final double radius;
  final double opacity;
  final double scale;
  final Offset offset;
}

class _SwipablePanelTransitionStageTwoController {
  _SwipablePanelTransitionStageTwoController(this.context, {required this.vsync});

  final BuildContext context;
  final TickerProvider vsync;
  late final AnimationController animationController;

  final double _minRadius = 0;
  final double _maxRadius = 50;
  final double _dragSensivity = 0.8;
  final double _minScale = 0.75;
  final double _kDismissThreshold = 0.25;
  final double _initialScale = 0.4;
  int activeCount = 0;
  bool _dragUnderway = false;
  Offset _startOffset = Offset.zero;
  _SwipablePanelTransitionStageTwoStatus status = _SwipablePanelTransitionStageTwoStatus.idle;

  final ValueNotifier<SwipablePanelTransitionStageTwoState> notifier =
      ValueNotifier(SwipablePanelTransitionStageTwoState(radius: 0, opacity: 1.0, scale: 1.0));

  void init() {
    animationController = AnimationController(duration: Duration(milliseconds: 200), vsync: vsync);
    animationController.addListener(animationListener);
    animationController.addStatusListener(animationStatusListener);
  }

  void animationListener() {
    if (status == _SwipablePanelTransitionStageTwoStatus.forward) {
      final double m = Curves.easeInOut.transform(animationController.value);
      final Offset offset = Offset.lerp(Offset(UIScale.width(25), UIScale.height(25)), Offset.zero, m)!;
      final double k = animationController.value;
      final double targetRadius = lerpDouble(_maxRadius, _minRadius, k)!;
      final double targetOpacity = k;
      final double targetScale = lerpDouble(_initialScale, 1, k)!;
      notifier.value = SwipablePanelTransitionStageTwoState(
          offset: offset, radius: targetRadius, opacity: targetOpacity, scale: targetScale);
      if (targetScale == 1) RouteOverlayManager.instance.turnOnLastOverlayOpaqueness();
    }

    if (status == _SwipablePanelTransitionStageTwoStatus.resetting) {
      final double m = Curves.easeInOut.transform(animationController.value);
      final Offset offset = Offset.lerp(notifier.value.offset, Offset.zero, m)!;
      final double k = _offsetProgression(offset);
      final double targetRadius = lerpDouble(_minRadius, _maxRadius, k)!;
      final double targetOpacity = notifier.value.opacity;
      final double targetScale = lerpDouble(1, _minScale, k)!;
      notifier.value = SwipablePanelTransitionStageTwoState(
          offset: offset, radius: targetRadius, opacity: targetOpacity, scale: targetScale);
      if (targetScale == 1) RouteOverlayManager.instance.turnOnLastOverlayOpaqueness();
    }

    if (status == _SwipablePanelTransitionStageTwoStatus.dismissing) {
      final double k = animationController.value;
      final Offset offset = notifier.value.offset;
      final double targetRadius = notifier.value.radius;
      final double targetOpacity = lerpDouble(1, .0, k)!;
      final double targetScale = lerpDouble(_minScale, .05, k)!;
      notifier.value = SwipablePanelTransitionStageTwoState(
          offset: offset, radius: targetRadius, opacity: targetOpacity, scale: targetScale);
      if (targetScale == 1) RouteOverlayManager.instance.turnOnLastOverlayOpaqueness();
    }
  }

  void animationStatusListener(AnimationStatus s) {
    if (!(s == AnimationStatus.completed) || (status == _SwipablePanelTransitionStageTwoStatus.dismissing)) return;
    if (status == _SwipablePanelTransitionStageTwoStatus.forward) status = _SwipablePanelTransitionStageTwoStatus.idle;
    animationController.value = 0;
  }

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
    notifier.value = SwipablePanelTransitionStageTwoState(
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
    status = _SwipablePanelTransitionStageTwoStatus.dismissing;
    animationController.animateTo(1);
    Future.delayed(animationController.duration ?? const Duration(milliseconds: 200), () {});
    OasisNavigator.instance.pop();
  }

  void reset() {
    status = _SwipablePanelTransitionStageTwoStatus.resetting;
    animationController.animateTo(1);
    Future.delayed(animationController.duration ?? const Duration(milliseconds: 200), () {});
    RouteOverlayManager.instance.turnOnLastOverlayOpaqueness();
  }

  void dispose() {
    animationController.removeListener(animationListener);
    animationController.removeStatusListener(animationStatusListener);
    animationController.dispose();
    notifier.dispose();
  }
}
