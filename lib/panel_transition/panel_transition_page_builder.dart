import 'package:flutter/material.dart';

import '../gestures/gesture_recog_overlay.dart';
import 'panel_transition_controller.dart';
import 'panel_transition_page_route_builder.dart';

/// It allows opening a certain page under the responsiveness animation.
/// With slideup and slide down interactions.
class PanelTranstionPageBuilder extends StatefulWidget {
  // ignore: public_member_api_docs
  const PanelTranstionPageBuilder(
    this.context, {
    super.key,
    required this.builder,
    required this.initialHeight,
    required this.maxHeight,
  });

  /// Current context
  final BuildContext context;

  /// Initial page height
  final double initialHeight;

  /// Max page height
  final double maxHeight;

  /// Builder that is called with a [PanelTranstionController] and returns a widget
  final PanelTranstionBuilder builder;

  @override
  State<PanelTranstionPageBuilder> createState() => _PanelTranstionPageBuilderState();
}

class _PanelTranstionPageBuilderState extends State<PanelTranstionPageBuilder> with SingleTickerProviderStateMixin {
  late final Widget _page;
  late final PanelTranstionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PanelTranstionController(
      context,
      vsync: this,
      initialHeight: widget.initialHeight,
      maxHeight: widget.maxHeight,
    )..init();
    _page = widget.builder(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget page = ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(MediaQuery.of(context).size.width * 0.075),
            topRight: Radius.circular(MediaQuery.of(context).size.width * 0.075)),
        child: _page);

    return WillPopScope(
      onWillPop: () async {
        _controller.onClose?.call();
        return true;
      },
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          AnimatedBuilder(
            animation: _controller.animationController,
            builder: (_, child) {
              final double targetHeight = MediaQuery.of(context).size.height - _controller.animationController.value;
              final double targetOpacity = 1 - (targetHeight / MediaQuery.of(context).size.height);
              return Stack(
                children: [
                  Container(color: Colors.black.withOpacity(targetOpacity)),
                  Positioned(
                    top: targetHeight,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: page,
                    ),
                  ),
                ],
              );
            },
          ),
          GestureRecogOverlay(
              onInnerDragUpdate: (_) {},
              onInnerDragEnd: (_) {},
              onOutterDragUpdate: _controller.handleOutterVerticalDragUpdate,
              onOutterDragEnd: _controller.handleOutterVerticalDragEnd)
        ],
      ),
    );
  }
}
