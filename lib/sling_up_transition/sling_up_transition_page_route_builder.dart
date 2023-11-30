import 'package:flutter/material.dart';

/// Navigates a new View into the Stack by sliding said view from bottom to top.
/// There are no user interactions involved on this page route.
class SlingUpPageRouteBuilder extends PageRouteBuilder {
  // ignore: public_member_api_docs
  SlingUpPageRouteBuilder({required Widget child, RouteSettings? settings})
      : super(
          opaque: true,
          settings: settings,
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (context, animation, __) => child,
          transitionsBuilder: handleTransitionsBuilder,
        );

  /// Handle the transition of the view. Renders a opaque layer behind the view and then
  /// wraps the view with a [SlideTransition] to perform the animation.
  static Widget handleTransitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final tween = Tween(begin: const Offset(0, 1), end: Offset.zero).chain(CurveTween(curve: Curves.easeInOutQuad));
    return Stack(
      children: [
        FadeTransition(opacity: animation, child: Container(color: Colors.black)),
        SlideTransition(position: animation.drive(tween), child: child)
      ],
    );
  }
}
