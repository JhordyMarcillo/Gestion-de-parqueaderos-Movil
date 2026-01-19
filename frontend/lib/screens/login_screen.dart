import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import 'admin_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _navegar(String rol) {

    if (rol == 'ADMIN' || rol == 'ROLE_ADMIN') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AdminScreen()),
            (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_parking_rounded, size: 80, color: Colors.blueAccent),
                const SizedBox(height: 10),
                const Text("hola 1Parking", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Correo Institucional",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) => v!.isEmpty ? "Ingrese correo" : null,
                ),
                const SizedBox(height: 20),

                // Password
                TextFormField(
                  controller: _passController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Contraseña",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) => v!.isEmpty ? "Ingrese contraseña" : null,
                ),
                const SizedBox(height: 30),

                // BOTÓN DE LOGIN
                authProvider.isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final success = await authProvider.login(
                          _emailController.text.trim(),
                          _passController.text.trim(),
                        );

                        if (success && context.mounted) {
                          final prefs = await SharedPreferences.getInstance();
                          final role = prefs.getString('user_role')?.trim().toUpperCase() ?? "USER";

                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Login correcto. Rol: $role"),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 1),
                              )
                          );

                          await Future.delayed(const Duration(milliseconds: 500));

                          _navegar(role);

                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Error de credenciales o conexión"),
                                backgroundColor: Colors.red,
                              )
                          );
                        }
                      }
                    },
                    child: const Text("INGRESAR", style: TextStyle(fontSize: 18)),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}