import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ui_library/ui_library.dart';
import 'package:feed/feed.dart';

import '../../infra.dart';
import 'swipable_panel_transition_controller.dart';

class SwipablePanelTransitionPageBuilder extends StatefulWidget {
  // ignore: public_member_api_docs
  SwipablePanelTransitionPageBuilder({required this.builder, double? initialHeight, double? maxHeight})
      : initialHeight = initialHeight ?? UIScale.height(50),
        maxHeight = maxHeight ?? UIScale.deviceHeight;

  final double initialHeight;
  final double maxHeight;

  final Widget Function(SwipablePanelTransitionController) builder;

  @protected
  MultiDragGestureRecognizer createRecognizer(GestureMultiDragStartCallback onStart) =>
      ImmediateMultiDragGestureRecognizer()..onStart = onStart;

  @override
  _SwipablePanelTransitionPageBuilderState createState() => _SwipablePanelTransitionPageBuilderState();
}

class _SwipablePanelTransitionPageBuilderState extends State<SwipablePanelTransitionPageBuilder>
    with Drag, TickerProviderStateMixin, WidgetsBindingObserver {
  late final Widget _page;
  late final GestureRecognizer _recognizer;
  late final SwipablePanelTransitionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SwipablePanelTransitionController(context, vsync: this)..init();
    _page = widget.builder(_controller);
    _recognizer = widget.createRecognizer((o) => _controller.handleDragInit(this, position: o));
    if (widget.initialHeight >= UIScale.height(100)) _controller.status.value = SwipablePanelTransitionStatus.stageTwo;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void update(DragUpdateDetails details) => _controller.handleDragUpdate(details);

  @override
  void cancel() => _controller.handleDragCancel();

  @override
  void end(DragEndDetails details) => _controller.handleDragEnd(details);

  @override
  void dispose() {
    _recognizer.dispose();
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    final isAtCurrentPageBuilder =
        RouteMiddleware.instance.currentRoute.runtimeType != SwipablePanelTransitionPageRouteBuilder;
    if (state != AppLifecycleState.inactive || isAtCurrentPageBuilder) return;
    --_controller.stageTwo.activeCount;
    _controller.stageTwo.reset();
  }

  @override
  Widget build(BuildContext context) {
    final Widget offsetArea = GestureDetector(
        onTap: _controller.close,
        child: AnimatedBuilder(
          animation: _controller.stageOne.animationController,
          builder: (_, child) {
            final double animValue = _controller.stageOne.animationController.value;
            final double diff = (1 - (widget.initialHeight / widget.maxHeight)) * widget.maxHeight;
            final double targetHeight = diff - (animValue * diff);
            return Container(height: targetHeight, color: Colors.transparent);
          },
        ));

    final Widget content = ValueListenableBuilder<SwipablePanelTransitionStageTwoState>(
      valueListenable: _controller.stageTwo.notifier,
      child: _page,
      builder: (_, SwipablePanelTransitionStageTwoState details, Widget? child) {
        final Widget innerContent = AnimatedBuilder(
            animation: _controller.stageOne.animationController,
            builder: (context, _) {
              final double animValue = _controller.stageOne.animationController.value;
              final BorderRadius borderRadius = BorderRadius.only(
                topLeft: Radius.circular(UIScale.width(7.5) * (1 - animValue)),
                topRight: Radius.circular(UIScale.width(7.5) * (1 - animValue)),
              );

              return ClipRRect(borderRadius: borderRadius, child: child!);
            });

        final Widget opaqueLayer = ValueListenableBuilder<SwipablePanelTransitionStatus>(
            valueListenable: _controller.status,
            builder: (_, status, Widget? child) {
              if (status == SwipablePanelTransitionStatus.stageOne) {
                return FadeTransition(
                    opacity: _controller.stageOne.wrapperAnimationController,
                    child: Container(color: Colors.black.withOpacity(0.85)));
              }

              return Container(color: Colors.black.withOpacity(details.scale));
            });

        return Stack(
          children: [
            opaqueLayer,
            SlideTransition(
              position: _controller.stageOne.wrapperAnimationTween,
              child: Opacity(
                opacity: details.opacity,
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(details.offset.dx, details.offset.dy)
                    ..scale(details.scale, details.scale),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(details.radius),
                      child: Column(children: [
                        offsetArea,
                        Expanded(child: IgnorePointer(ignoring: details.scale < 1.0, child: innerContent))
                      ])),
                ),
              ),
            ),
          ],
        );
      },
    );

    void onPointerDown(PointerDownEvent event) {
      if (_controller.stageTwo.activeCount < 1) ++_controller.stageTwo.activeCount;
      if (_controller.stageTwo.activeCount > 1) return;
      _recognizer.addPointer(event);
    }

    void onPointerUp(PointerUpEvent event) => --_controller.stageTwo.activeCount;

    return ValueListenableBuilder<SwipablePanelTransitionStatus>(
        valueListenable: _controller.status,
        builder: (_, status, Widget? child) {
          return Stack(
            children: [
              Listener(onPointerDown: onPointerDown, onPointerUp: onPointerUp, child: content),
              if (status == SwipablePanelTransitionStatus.stageOne)
                GestureRecogOverlay(
                    onInnerDragUpdate: (_) {},
                    onInnerDragEnd: (_) {},
                    onOutterDragUpdate: update,
                    onOutterDragEnd: end),
            ],
          );
        });
  }
}
