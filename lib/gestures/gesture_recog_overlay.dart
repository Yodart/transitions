import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Widget responsible to regog the gestures.
/// Commonly used under transitions
class GestureRecogOverlay extends StatelessWidget {
  // ignore: public_member_api_docs
  const GestureRecogOverlay({
    super.key,
    this.onInnerDragUpdate,
    this.onInnerDragEnd,
    this.onOutterDragUpdate,
    this.onOutterDragEnd,
  });

  /// A pointer that is in contact with the screen with a primary button and moving has moved again.
  final void Function(DragUpdateDetails)? onInnerDragUpdate;

  /// A pointer that was previously in contact with the screen with a primary button and moving is
  /// no longer in contact with the screen and was moving at a specific velocity when it stopped contacting the screen.
  final void Function(DragEndDetails details)? onInnerDragEnd;

  /// A pointer that is in contact with the screen with a
  /// primary button and moving vertically has moved in the vertical direction.
  final void Function(DragUpdateDetails)? onOutterDragUpdate;

  /// A pointer that was previously in contact with the screen with a primary button
  /// and moving vertically is no longer in contact with the screen and was moving at a
  /// specific velocity when it stopped contacting the screen.
  final void Function(DragEndDetails details)? onOutterDragEnd;

  void _innerGestureDetectorInitializer(_AllowMultiplePanGestureRecognizer instance) => instance
    ..onUpdate = onInnerDragUpdate
    ..onEnd = onInnerDragEnd;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RawGestureDetector(
          gestures: {
            _AllowMultiplePanGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<_AllowMultiplePanGestureRecognizer>(
              _AllowMultiplePanGestureRecognizer.new,
              _innerGestureDetectorInitializer,
            )
          },
        ),
        GestureDetector(onVerticalDragUpdate: onOutterDragUpdate, onVerticalDragEnd: onOutterDragEnd),
      ],
    );
  }
}

class _AllowMultiplePanGestureRecognizer extends PanGestureRecognizer {
  @override
  void rejectGesture(int pointer) => acceptGesture(pointer);
}
