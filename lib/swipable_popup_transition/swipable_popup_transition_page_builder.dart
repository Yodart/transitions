import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SwipablePopUpTransitionPageBuilder extends StatefulWidget {
  const SwipablePopUpTransitionPageBuilder({required this.builder, this.initOffset});

  final Widget Function(SwipablePopUpTransitionController) builder;
  final Offset? initOffset;

  @protected
  // ignore: public_member_api_docs
  MultiDragGestureRecognizer createRecognizer(GestureMultiDragStartCallback onStart) =>
      ImmediateMultiDragGestureRecognizer()..onStart = onStart;

  @override
  _SwipablePopUpTransitionState createState() => _SwipablePopUpTransitionState();
}

class _SwipablePopUpTransitionState extends State<SwipablePopUpTransitionPageBuilder>
    with Drag, SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final Widget _page;
  late final GestureRecognizer _recognizer;
  late final SwipablePopUpTransitionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SwipablePopUpTransitionController(context, initOffset: widget.initOffset, vsync: this);
    _recognizer = widget.createRecognizer((o) => _controller.handleDragInit(this, position: o));
    _controller.init();
    _page = widget.builder(_controller);
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
        RouteMiddleware.instance.currentRoute.runtimeType != SwipablePopUpTransitionPageRouteBuilder;
    if (state != AppLifecycleState.inactive || isAtCurrentPageBuilder) return;
    --_controller.activeCount;
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    final content = ValueListenableBuilder<SwipablePopUpTransitionState>(
      valueListenable: _controller.notifier,
      child: _page,
      builder: (_, SwipablePopUpTransitionState details, Widget? child) {
        return Container(
          color: Colors.black.withOpacity(details.scale),
          child: Opacity(
            opacity: details.opacity,
            child: Transform(
              transform: Matrix4.identity()
                ..translate(details.offset.dx, details.offset.dy)
                ..scale(details.scale, details.scale),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(details.radius),
                child: IgnorePointer(ignoring: details.scale < 1.0, child: child),
              ),
            ),
          ),
        );
      },
    );

    void onPointerDown(PointerDownEvent event) {
      if (_controller.activeCount < 1) ++_controller.activeCount;
      if (_controller.activeCount > 1) return;
      _recognizer.addPointer(event);
    }

    void onPointerUp(PointerUpEvent event) => --_controller.activeCount;

    return Listener(onPointerDown: onPointerDown, onPointerUp: onPointerUp, child: content);
  }
}
