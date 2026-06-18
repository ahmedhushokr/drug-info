import 'package:flutter/material.dart';
import 'package:untitled7/core/routing/app_routes.dart';
import 'package:untitled7/features/auth/presentation/view/screen/create_account_screen.dart';
import 'package:untitled7/features/home/presentation/view/screens/home_screen.dart';
import 'package:untitled7/features/auth/presentation/view/screen/login_screen.dart';
import 'package:untitled7/features/splash/presentation/view/splash_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splashscreen:
        return MaterialPageRoute(builder: (context) => SplashScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (context) => LoginScreen());

      case AppRoutes.homeScreen:
        return MaterialPageRoute(builder: (context) => HomeScreen());

      case AppRoutes.createAccount:
        return MaterialPageRoute(builder: (context) => CreateAccountScreen());

      // case AppRoutes.DataOutputScreen:
      //   return MaterialPageRoute(builder: (context) => MedicineResultsScreen(results: [''],));
      //
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: Colors.red,
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
