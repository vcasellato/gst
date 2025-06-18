import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'services/transaction_service.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';
import 'services/firebase_auth_service.dart';
import 'services/firestore_service.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeService()),
        ChangeNotifierProvider(create: (context) => FirebaseAuthService()),
        ChangeNotifierProvider(create: (context) => FirestoreService()),
        ChangeNotifierProvider(create: (context) => TransactionService()),
        ChangeNotifierProvider(create: (context) => NotificationService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'Controle de Gastos',
            debugShowCheckedModeBanner: false,
            theme: themeService.currentTheme,
            home: AuthWrapper(), // Wrapper para gerenciar estado de auth
          );
        },
      ),
    );
  }
}

// Wrapper que decide qual tela mostrar baseado no estado de autenticação
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseAuthService>(
      builder: (context, authService, child) {
        // Se o usuário está logado, vai direto para o app
        if (authService.isLoggedIn) {
          return SplashScreen(); // Splash vai para Home se já logado
        }

        // Se não está logado, vai para o fluxo de login
        return SplashScreen(); // Splash vai para Onboarding/Login
      },
    );
  }
}
