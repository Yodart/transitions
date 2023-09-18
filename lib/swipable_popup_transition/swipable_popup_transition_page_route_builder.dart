import 'package:flutter/material.dart';

import 'swipable_popup_transition_controller.dart';
import 'swipable_popup_transition_page_builder.dart';

class SwipablePopUpTransitionPageRouteBuilder extends PageRouteBuilder {
  // ignore: public_member_api_docs
  SwipablePopUpTransitionPageRouteBuilder({required this.builder, required RouteSettings settings, this.initOffset})
      : super(
            opaque: false,
            settings: settings,
            pageBuilder: (context, _, __) =>
                SwipablePopUpTransitionPageBuilder(builder: builder, initOffset: initOffset),
            transitionsBuilder: (_, __, ___, child) => child);

  final Widget Function(SwipablePopUpTransitionController) builder;

  final Offset? initOffset;
}
