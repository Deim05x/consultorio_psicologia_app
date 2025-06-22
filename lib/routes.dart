import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

class AppRoutes {
  // Nombres de las rutas (puedes usarlos con Navigator.pushNamed)
  static const String login = '/login';
  static const String home = '/home';

  // Función para generar rutas según el nombre
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        // Si se intenta navegar a una ruta no definida, se muestra este mensaje
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}
