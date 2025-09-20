import 'package:flutter/material.dart';
import 'package:zaitoon/routes/app_routes.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  static Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  static void pop<T extends Object?>([T? result]) {
    navigatorKey.currentState!.pop<T>(result);
  }

  static void popUntil(String routeName) {
    navigatorKey.currentState!.popUntil(ModalRoute.withName(routeName));
  }

  // Convenience methods for common routes
  static Future<void> toOnboarding() {
    return pushNamedAndRemoveUntil(AppRoutes.onboarding);
  }

  static Future<void> toLogin() {
    return pushNamedAndRemoveUntil(AppRoutes.login);
  }

  static Future<void> toLanguageSelection() {
    return pushNamedAndRemoveUntil(AppRoutes.languageSelection);
  }

  static Future<void> toUserDataCollection({bool isFromOnboarding = false}) {
    return pushNamedAndRemoveUntil(
      AppRoutes.userDataCollection,
      arguments: {'isFromOnboarding': isFromOnboarding},
    );
  }

  static Future<void> toHome() {
    return pushNamedAndRemoveUntil(AppRoutes.bottomNavigation);
  }
}
