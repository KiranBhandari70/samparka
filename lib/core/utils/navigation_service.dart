import 'package:flutter/material.dart';

class NavigationService {
  NavigationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static NavigatorState? get currentState => navigatorKey.currentState;

  static BuildContext? get currentContext => navigatorKey.currentContext;

  static Future<T?> pushNamed<T extends Object?>(
      String routeName, {
        Object? arguments,
      }) {
    return currentState!.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
      String routeName, {
        Object? arguments,
        TO? result,
      }) {
    return currentState!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
      String newRouteName, {
        Object? arguments,
        bool Function(Route<dynamic>)? predicate,
      }) {
    return currentState!.pushNamedAndRemoveUntil<T>(
      newRouteName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  static void pop<T extends Object?>([T? result]) {
    currentState!.pop<T>(result);
  }

  static bool canPop() {
    return currentState!.canPop();
  }

  static void popUntil(RoutePredicate predicate) {
    currentState!.popUntil(predicate);
  }
}
