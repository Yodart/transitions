import 'package:flutter/material.dart';

import 'swipable_panel_transition_controller.dart';
import 'swipable_panel_transition_page_builder.dart';

class SwipablePanelTransitionPageRouteBuilder extends PageRouteBuilder {
  // ignore: public_member_api_docs
  SwipablePanelTransitionPageRouteBuilder(
      {required this.builder, required RouteSettings settings, double? initialHeight})
      : super(
            opaque: false,
            settings: settings,
            pageBuilder: (context, _, __) =>
                SwipablePanelTransitionPageBuilder(builder: builder, initialHeight: initialHeight),
            transitionsBuilder: (_, __, ___, child) => child);

  final Widget Function(SwipablePanelTransitionController) builder;
}
