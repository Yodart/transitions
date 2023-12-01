import 'package:flutter/material.dart';

import 'panel_transition_controller.dart';
import 'panel_transition_page_builder.dart';

/// Widget builder that enforces the usage of [PanelTranstionController]
typedef PanelTranstionBuilder = Widget Function(PanelTranstionController);

/// Custom [PageRouteBuilder] to use with [PanelTranstion]
class PanelTranstionPageRouteBuilder extends PageRouteBuilder {
  // ignore: public_member_api_docs
  PanelTranstionPageRouteBuilder({
    required PanelTranstionBuilder builder,
    RouteSettings? settings,
    double? initialHeight,
    double? maxHeight,
  }) : super(
          opaque: false,
          settings: settings,
          transitionDuration: const Duration(milliseconds: 50),
          reverseTransitionDuration: const Duration(milliseconds: 50),
          transitionsBuilder: (_, __, ___, child) => child,
          pageBuilder: (context, animation, __) {
            return PanelTranstionPageBuilder(
              context,
              initialHeight: initialHeight ?? MediaQuery.of(context).size.height * 0.5,
              maxHeight: maxHeight ?? MediaQuery.of(context).size.height,
              builder: builder,
            );
          },
        );
}
