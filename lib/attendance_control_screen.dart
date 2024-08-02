import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'db_clase.dart'; // Importa tu clase DBHelper
import 'pdf_generator.dart'; // Importa tu clase de generación de PDF
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

class AttendanceControlScreen extends StatefulWidget {
  @override
  _AttendanceControlScreenState createState() =>
      _AttendanceControlScreenState();
}

class _AttendanceControlScreenState extends State<AttendanceControlScreen> {
  final DBHelper _dbHelper = DBHelper();
  late Future<List<Map<String, dynamic>>> _courses;
  int? _selectedCourseId;
  List<int> _absentStudents = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _courses = _dbHelper.getCourses();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    flutterLocalNotificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse: _onSelectNotification);
  }

  Future<void> _onSelectNotification(
      NotificationResponse notificationResponse) async {
    final String? filePath = notificationResponse.payload;
    if (filePath != null) {
      OpenFile.open(filePath);
    }
  }

  void _showNotification(String filePath) async {
    const android = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
    );
    const platform = NotificationDetails(android: android);
    await flutterLocalNotificationsPlugin.show(
      0,
      'PDF Generado',
      'El archivo PDF ha sido guardado',
      platform,
      payload: filePath,
    );
  }

  void _onCourseSelected(int? courseId) {
    setState(() {
      _selectedCourseId = courseId;
    });
  }

  Future<List<Map<String, dynamic>>> _getStudents() async {
    if (_selectedCourseId != null) {
      return await _dbHelper.getStudents(_selectedCourseId!);
    } else {
      return [];
    }
  }

  Future<void> _generatePdf(List<Map<String, dynamic>> students) async {
    final presentStudents = students
        .where((student) => !_absentStudents.contains(student['id']))
        .toList();
    final pdf = await generatePdf(presentStudents);
    final directory = await getExternalStorageDirectory();
    final filePath =
        '${directory!.path}/asistencia_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    _showNotification(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Controlar Asistencia'),
      ),
      body: Column(
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _courses,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error al cargar cursos'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No hay cursos disponibles'));
              } else {
                return DropdownButton<int>(
                  value: _selectedCourseId,
                  hint: Text('Seleccionar Curso'),
                  onChanged: _onCourseSelected,
                  items: snapshot.data!.map((course) {
                    return DropdownMenuItem<int>(
                      value: course['id'],
                      child: Text(course['name']),
                    );
                  }).toList(),
                );
              }
            },
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getStudents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar alumnos'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay alumnos para este curso'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final student = snapshot.data![index];
                      return CheckboxListTile(
                        title: Text(
                            '${student['last_name']} ${student['first_name']}'),
                        value: _absentStudents.contains(student['id']),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _absentStudents.add(student['id']);
                            } else {
                              _absentStudents.remove(student['id']);
                            }
                          });
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _getStudents().then((students) {
                  _generatePdf(students);
                });
              },
              child: Text('Generar PDF'),
            ),
          ),
        ],
      ),
    );
  }
}
