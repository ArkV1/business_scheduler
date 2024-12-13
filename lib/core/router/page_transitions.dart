import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animations/animations.dart';

class SharedAxisTransitionPage<T> extends CustomTransitionPage<T> {
  SharedAxisTransitionPage({
    required Widget child,
    String? name,
    Object? arguments,
    String? restorationId,
    LocalKey? key,
    SharedAxisTransitionType transitionType = SharedAxisTransitionType.horizontal,
  }) : super(
          child: child,
          name: name,
          arguments: arguments,
          restorationId: restorationId,
          key: key,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: transitionType,
              child: child,
            );
          },
        );
}

class FadeThroughTransitionPage<T> extends CustomTransitionPage<T> {
  FadeThroughTransitionPage({
    required Widget child,
    String? name,
    Object? arguments,
    String? restorationId,
    LocalKey? key,
  }) : super(
          child: child,
          name: name,
          arguments: arguments,
          restorationId: restorationId,
          key: key,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
        );
}

class OpenContainerTransitionPage<T> extends CustomTransitionPage<T> {
  OpenContainerTransitionPage({
    required Widget child,
    String? name,
    Object? arguments,
    String? restorationId,
    LocalKey? key,
    Color closedColor = Colors.transparent,
  }) : super(
          child: child,
          name: name,
          arguments: arguments,
          restorationId: restorationId,
          key: key,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return PageTransitionSwitcher(
              transitionBuilder: (child, animation, secondaryAnimation) {
                return FadeScaleTransition(
                  animation: animation,
                  child: child,
                );
              },
              child: child,
            );
          },
        );
} 