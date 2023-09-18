import 'package:flutter/material.dart';
import 'package:ui_library/ui_library.dart';

import '../../infra.dart';

/// It allows opening a certain page under the responsiveness animation.
/// With slideup and slide down interactions.
class PanelTranstionPageBuilder extends StatefulWidget {
  // ignore: public_member_api_docs
  PanelTranstionPageBuilder({required this.builder, double? initialHeight, double? maxHeight})
      : initialHeight = initialHeight ?? UIScale.height(50),
        maxHeight = maxHeight ?? UIScale.deviceHeight;

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
            topLeft: Radius.circular(UIScale.width(7.5)), topRight: Radius.circular(UIScale.width(7.5))),
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
              final double targetHeight = UIScale.deviceHeight - _controller.animationController.value;
              final double targetOpacity = 1 - (targetHeight / UIScale.deviceHeight);
              return Stack(
                children: [
                  Container(color: Colors.black.withOpacity(targetOpacity)),
                  Positioned(
                      top: targetHeight,
                      child: Container(height: UIScale.deviceHeight, width: UIScale.deviceWidth, child: page)),
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
