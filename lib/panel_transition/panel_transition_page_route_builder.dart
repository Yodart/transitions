import 'package:flutter/material.dart';

import 'panel_transition_controller.dart';
import 'panel_transition_page_builder.dart';

/// Widget builder that enforces the usage of [PanelTranstionController]
typedef PanelTranstionBuilder = Widget Function(PanelTranstionController);

/// Custom [PageRouteBuilder] to use with [PanelTranstion]
class PanelTranstionPageRouteBuilder extends PageRouteBuilder {
  // ignore: public_member_api_docs
  PanelTranstionPageRouteBuilder({
    required this.builder,
    required RouteSettings settings,
    this.initialHeight,
    this.maxHeight,
  }) : super(
          opaque: false,
          settings: settings,
          transitionDuration: const Duration(milliseconds: 50),
          reverseTransitionDuration: const Duration(milliseconds: 50),
          transitionsBuilder: (_, __, ___, child) => child,
          pageBuilder: (context, animation, __) =>
              PanelTranstionPageBuilder(initialHeight: initialHeight, maxHeight: maxHeight, builder: builder),
        );

  /// Initial page height.
  final double? initialHeight;

  /// Maximum page height.

  final double? maxHeight;

  /// Custom builder
  final PanelTranstionBuilder builder;
}
