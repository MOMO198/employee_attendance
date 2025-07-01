import 'package:employee_attendance/screens/register_screen.dart';
import 'package:employee_attendance/services/auth_service.dart';
import 'package:employee_attendance/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Connexion',
          style: TextStyle(color: Colors.white),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            height: screenHeight / 4,
            width: screenWidth,
            decoration: const BoxDecoration(
                color: Colors.redAccent,
                borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(70))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/artwork.png',
                  height: 80,
                  width: 80,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "SIMDCI",
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    label: Text(Strings.email),
                    prefixIcon: const Icon(Icons.person),
                    border: const OutlineInputBorder(),
                  ),
                  controller: _emailController,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  decoration: InputDecoration(
                    label: Text(Strings.password),
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                ),
                const SizedBox(
                  height: 30,
                ),
                Consumer<AuthService>(
                  builder: (context, authServiceProvider, child) {
                    return SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: authServiceProvider.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                authServiceProvider.loginEmployee(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                    context);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30))),
                              child: Text(
                                Strings.login.toUpperCase(),
                                style: const TextStyle(fontSize: 20, color: Colors.white),
                              ),
                            ),
                    );
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Vous êtes un nouvel employé ? Inscrivez-vous ici",
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

