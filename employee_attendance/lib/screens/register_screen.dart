import 'package:employee_attendance/services/auth_service.dart';
import 'package:employee_attendance/services/permission_service.dart';
import 'package:employee_attendance/constants/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _siteController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _getImage() async {
    try {
      bool permissionsGranted = await PermissionService.checkAndRequestPermissions();
      if (!permissionsGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Les permissions sont nécessaires pour prendre une photo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la capture de la photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
          'Inscription',
          style: TextStyle(color: Colors.white),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
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
                      label: Text(Strings.fullName),
                      prefixIcon: const Icon(Icons.person_outline),
                      border: const OutlineInputBorder(),
                    ),
                    controller: _fullNameController,
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _getImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _image!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.camera_alt,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Prendre une photo',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      label: const Text('Site'),
                      prefixIcon: const Icon(Icons.location_city),
                      border: const OutlineInputBorder(),
                    ),
                    controller: _siteController,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      label: Text(Strings.email),
                      prefixIcon: const Icon(Icons.email),
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
                    ),
                    controller: _passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      label: Text(Strings.confirmPassword),
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                    ),
                    controller: _confirmPasswordController,
                    obscureText: true,
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
                                  if (_passwordController.text == _confirmPasswordController.text) {
                                    authServiceProvider.registerEmployee(
                                        _emailController.text.trim(),
                                        _passwordController.text.trim(),
                                        _fullNameController.text.trim(),
                                        _siteController.text.trim(),
                                        _image,
                                        context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Les mots de passe ne correspondent pas'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30))),
                                child: Text(
                                  Strings.register.toUpperCase(),
                                  style: const TextStyle(fontSize: 20, color: Colors.white),
                                ),
                              ),
                      );
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "${Strings.alreadyHaveAccount} ${Strings.signIn}",
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
