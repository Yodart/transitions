import 'package:flutter/material.dart';

/// Navigates a new View into the Stack by sliding said view from bottom to top.
/// There are no user interactions involved on this page route.
class SlingUpPopUpPageRouteBuilder extends PageRouteBuilder {
  // ignore: public_member_api_docs
  SlingUpPopUpPageRouteBuilder({required Widget child, RouteSettings? settings})
      : super(
          opaque: false,
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
    const double fadeTransitionBegin = 0.0;
    const double fadeTransitionEnd = 1.0;
    final Tween<double> fadeTransitionTween = Tween(begin: fadeTransitionBegin, end: fadeTransitionEnd);
    final Animation<double> fadeTransitionAnimation = animation.drive(fadeTransitionTween);

    const Offset slideTransitionBegin = Offset(0.0, 1.0);
    const Offset slideTransitionEnd = Offset(0.0, 0.0);
    const slideTransitionCurve = Curves.easeInOutCubic;
    final slideTransitionTween =
        Tween(begin: slideTransitionBegin, end: slideTransitionEnd).chain(CurveTween(curve: slideTransitionCurve));
    final Animation<Offset> slideTransitionAnimation = animation.drive(slideTransitionTween);

    return FadeTransition(
      opacity: fadeTransitionAnimation,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.black.withOpacity(0.8),
          child: SlideTransition(
            position: slideTransitionAnimation,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
