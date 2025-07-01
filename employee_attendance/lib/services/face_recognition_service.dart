import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:employee_attendance/utils/utils.dart';

class FaceRecognitionService {
  final SupabaseClient _supabase = Supabase.instance.client;
  // Remplacez cette URL par l'URL de votre service Cloud Run après le déploiement
  static const String cloudRunUrl = 'https://face-verification-service-xxxxx-xx.a.run.app';

  Future<bool> verifyFace(File imageFile, String userId) async {
    try {
      // 1. Convertir l'image en base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      print('Envoi de la requête de vérification faciale...');

      // 2. Récupérer l'URL de la photo de profil
      final response = await _supabase
          .from('profiles')
          .select('photo_url')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        throw Exception('Photo de profil non trouvée');
      }

      final profileData = response as Map<String, dynamic>;

      // 3. Appeler le service Cloud Run pour la vérification faciale
      final verifyResponse = await http.post(
        Uri.parse('$cloudRunUrl/verify-face'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'current_image': base64Image,
          'profile_image_url': profileData['photo_url'],
        }),
      );

      print('Réponse reçue: ${verifyResponse.statusCode}');
      print('Corps de la réponse: ${verifyResponse.body}');

      if (verifyResponse.statusCode == 200) {
        final result = jsonDecode(verifyResponse.body);
        return result['verified'] ?? false;
      } else {
        throw Exception('Erreur lors de la vérification faciale: ${verifyResponse.body}');
      }
    } catch (e) {
      print('Erreur lors de la vérification faciale: $e');
      return false;
    }
  }

  Future<String> uploadAttendancePhoto(File imageFile, String userId) async {
    try {
      final fileName = 'attendance_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final filePath = 'attendance_photos/$userId/$fileName';

      print('Upload de la photo de présence...');

      // Upload de l'image vers Supabase Storage
      await _supabase.storage
          .from('attendance_photos')
          .upload(filePath, imageFile);

      // Récupérer l'URL publique de l'image
      final imageUrl = _supabase.storage
          .from('attendance_photos')
          .getPublicUrl(filePath);

      print('Photo uploadée avec succès: $imageUrl');

      // Enregistrer les métadonnées dans la base de données
      await _supabase.from('attendance_records').insert({
        'user_id': userId,
        'photo_url': imageUrl,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'verified',
      });

      print('Métadonnées enregistrées avec succès');

      return imageUrl;
    } catch (e) {
      print('Erreur lors de l\'upload de la photo: $e');
      throw Exception('Erreur lors de l\'enregistrement de la photo');
    }
  }
} 