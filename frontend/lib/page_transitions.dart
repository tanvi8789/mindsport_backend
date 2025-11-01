import 'package:flutter/material.dart';

// A custom PageRouteBuilder for a scale (zoom) transition.
class ScaleRoute extends PageRouteBuilder {
  final Widget page;

  ScaleRoute({required this.page})
      : super(
    // The duration of the transition.
    transitionDuration: const Duration(milliseconds: 300),
    // The page that will be displayed after the transition.
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    page,
    // The builder for the transition animation.
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
    // Use a ScaleTransition for the animation.
    ScaleTransition(
      scale: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn, // A smooth easing curve
        ),
      ),
      child: child,
    ),
  );
}