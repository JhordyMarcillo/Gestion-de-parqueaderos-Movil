import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/parking_provider.dart';
import 'screens/login_screen.dart'; // <--- Asegúrate de importar esto

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ParkingProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Parking',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),

        home: const LoginScreen(),
      ),
    );
  }
}