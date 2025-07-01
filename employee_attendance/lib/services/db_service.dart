import 'dart:math';

import 'package:employee_attendance/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DbService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  String generateRandomEmployeeId() {
    final random = Random();
    const allChars = "simdciSIMDCI0123456789";
    final randomString =
        List.generate(8, (index) => allChars[random.nextInt(allChars.length)])
            .join();
    return randomString;
  }

  Future insertNewUser(String email, var id, String fullName, String site) async {
    await _supabase.from(Constants.employeeTable).insert({
      'id': id,
      'name': fullName,
      'site': null,
      'email': email,
      'employee_id': generateRandomEmployeeId(),
      
    });
  }
}
