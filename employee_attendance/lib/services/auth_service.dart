import 'package:employee_attendance/services/db_service.dart';
import 'package:employee_attendance/services/photo_service.dart';
import 'package:employee_attendance/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final DbService _dbService = DbService();
  String? _userPhotoPath;

  bool _isLoading = false;
  String? get userPhotoPath => _userPhotoPath;

  bool get isLoading => _isLoading;

  set setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  Future registerEmployee(
      String email, String password, String fullName, String site, File? photoFile, BuildContext context) async {
    try {
      setIsLoading = true;
      
      // Validation des champs
      if (email.isEmpty || password.isEmpty || fullName.isEmpty || site.isEmpty) {
        throw ("Tous les champs sont requis");
      }

      if (!_isValidEmail(email)) {
        throw ("Format d'email invalide");
      }

      if (!_isValidPassword(password)) {
        throw ("Le mot de passe doit contenir au moins 6 caractères");
      }

      final AuthResponse response =
          await _supabase.auth.signUp(email: email, password: password);
      
      if (response.user != null) {
        await _dbService.insertNewUser(email, response.user!.id, fullName, site);
        
        // Sauvegarder la photo si elle existe
        if (photoFile != null) {
          _userPhotoPath = await PhotoService.savePhoto(photoFile, response.user!.id);
        }
        
        Utils.showSnackBar("Inscription réussie !", context, color: Colors.green);
        
        // Connexion automatique après inscription
        await loginEmployee(email, password, context);
        Navigator.pop(context);
      } else {
        throw ("Erreur lors de l'inscription");
      }
    } catch (e) {
      Utils.showSnackBar(e.toString(), context, color: Colors.red);
    } finally {
      setIsLoading = false;
    }
  }

  Future loginEmployee(
      String email, String password, BuildContext context) async {
    try {
      setIsLoading = true;
      
      // Validation des champs
      if (email.isEmpty || password.isEmpty) {
        throw ("Tous les champs sont requis");
      }

      if (!_isValidEmail(email)) {
        throw ("Format d'email invalide");
      }

      final AuthResponse response = await _supabase.auth
          .signInWithPassword(email: email, password: password);
      
      if (response.user != null) {
        // Récupérer le chemin de la photo de l'utilisateur
        _userPhotoPath = await PhotoService.getPhotoPath(response.user!.id);
        
        Utils.showSnackBar("Connexion réussie !", context, color: Colors.green);
        // Navigation vers l'écran principal après connexion réussie
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        throw ("Erreur lors de la connexion");
      }
    } catch (e) {
      Utils.showSnackBar(e.toString(), context, color: Colors.red);
    } finally {
      setIsLoading = false;
    }
  }

  Future signOut() async {
    try {
      await _supabase.auth.signOut();
      _userPhotoPath = null;
      notifyListeners();
    } catch (e) {
      print("Erreur lors de la déconnexion: $e");
    }
  }

  User? get currentUser => _supabase.auth.currentUser;
}
