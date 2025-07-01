import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PhotoService {
  static Future<String> savePhoto(File photoFile, String userId) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'profile_$userId${path.extension(photoFile.path)}';
    final savedFile = await photoFile.copy('${directory.path}/$fileName');
    return savedFile.path;
  }

  static Future<String?> getPhotoPath(String userId) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'profile_$userId.jpg';
    final file = File('${directory.path}/$fileName');
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }
} 