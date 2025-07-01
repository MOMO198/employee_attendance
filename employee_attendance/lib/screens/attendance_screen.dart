import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:employee_attendance/constants/strings.dart';
import 'package:employee_attendance/services/face_recognition_service.dart';
import 'package:employee_attendance/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AttendanceScreen extends StatefulWidget {
  final String? userPhotoPath;
  
  const AttendanceScreen({
    super.key,
    this.userPhotoPath,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _isCheckedIn = false;
  final DateTime _now = DateTime.now();
  final FaceRecognitionService _faceService = FaceRecognitionService();
  final ImagePicker _picker = ImagePicker();
  bool _isVerifying = false;

  Future<void> _takeAttendancePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() => _isVerifying = true);

        final authService = Provider.of<AuthService>(context, listen: false);
        final userId = authService.currentUser?.id;

        if (userId == null) {
          throw Exception('Utilisateur non connecté');
        }

        final imageFile = File(photo.path);
        
        // Vérification faciale
        final isVerified = await _faceService.verifyFace(imageFile, userId);
        
        if (isVerified) {
          // Upload de la photo et enregistrement du pointage
          await _faceService.uploadAttendancePhoto(imageFile, userId);
          
          setState(() => _isCheckedIn = true);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pointage effectué avec succès !'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vérification faciale échouée. Veuillez réessayer.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Strings.attendance,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          DateFormat('EEEE, MMMM d').format(_now),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      backgroundImage: widget.userPhotoPath != null
                          ? FileImage(File(widget.userPhotoPath!))
                          : null,
                      child: widget.userPhotoPath == null
                          ? Icon(
                              Icons.person,
                        color: theme.colorScheme.primary,
                            )
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        "Jours présents",
                        "22",
                        FontAwesomeIcons.calendarCheck,
                        theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        "Jours absents",
                        "2",
                        FontAwesomeIcons.calendarXmark,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        "Jours en retard",
                        "3",
                        FontAwesomeIcons.clock,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        "Heures travaillées",
                        "176",
                        FontAwesomeIcons.hourglassHalf,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Check In/Out Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          _isCheckedIn ? "Pointé" : "Non pointé",
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: _isCheckedIn ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isCheckedIn
                              ? DateFormat('HH:mm').format(_now)
                              : "Pas encore pointé",
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isVerifying ? null : _takeAttendancePhoto,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isCheckedIn
                                  ? Colors.red
                                  : theme.colorScheme.primary,
                            ),
                            child: _isVerifying
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                              _isCheckedIn ? Strings.checkOut : Strings.checkIn,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Recent Activity
                Text(
                  "Activité récente",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildActivityList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList(BuildContext context) {
    final theme = Theme.of(context);
    final activities = [
      {'date': 'Aujourd\'hui', 'time': '09:00', 'type': Strings.checkIn},
      {'date': 'Hier', 'time': '18:00', 'type': Strings.checkOut},
      {'date': 'Hier', 'time': '09:15', 'type': Strings.checkIn},
    ];

    return Column(
      children: activities.map((activity) {
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: activity['type'] == Strings.checkIn
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              child: Icon(
                activity['type'] == Strings.checkIn
                    ? Icons.login
                    : Icons.logout,
                color: activity['type'] == Strings.checkIn
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            title: Text(
              activity['type']!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${activity['date']} à ${activity['time']}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
