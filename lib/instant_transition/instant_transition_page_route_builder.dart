import 'package:flutter/material.dart';

/// Custom [PageRouteBuilder] that render the incoming view immediately.
class InstantTranstionPageRouteBuilder<T> extends PageRouteBuilder<T> {
  // ignore: public_member_api_docs
  InstantTranstionPageRouteBuilder({
    required Widget child,
    required RouteSettings settings,
  }) : super(
            transitionDuration: const Duration(milliseconds: 0),
            reverseTransitionDuration: const Duration(milliseconds: 0),
            pageBuilder: (context, animation, __) => child,
            settings: settings);
}
