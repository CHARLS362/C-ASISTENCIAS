import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'db_clase.dart';
import 'student_screen.dart'; // Asegúrate de importar tu pantalla de estudiantes

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DBHelper _dbHelper = DBHelper();
  late Future<List<Map<String, dynamic>>> _courses;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _courses = _dbHelper.getCourses();
  }

  Future<void> _refreshCourses() async {
    setState(() {
      _courses = _dbHelper.getCourses();
    });
  }

  void _editCourse(int id, String currentName, String currentPeriod) async {
    TextEditingController nameController =
        TextEditingController(text: currentName);
    TextEditingController periodController =
        TextEditingController(text: currentPeriod);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Curso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nombre del Curso'),
            ),
            TextField(
              controller: periodController,
              decoration: InputDecoration(labelText: 'Periodo'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _dbHelper.updateCourse(
                  id, nameController.text, periodController.text);
              Navigator.pop(context);
              _refreshCourses();
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _deleteCourse(int id) async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Curso'),
        content: Text('¿Estás seguro de que deseas eliminar este curso?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await _dbHelper.deleteCourse(id);
      _refreshCourses();
    }
  }

  Color _getRandomColor(int index) {
    final List<Color> colors = [
      Color.fromARGB(255, 246, 161, 23),
      Color.fromARGB(255, 219, 22, 233),
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }

  IconData _getRandomIcon(int index) {
    final List<IconData> icons = [
      Icons.star,
      Icons.school,
      Icons.book,
      Icons.computer,
      Icons.pie_chart,
      Icons.lightbulb,
      Icons.gavel,
    ];
    return icons[index % icons.length];
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String username =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react,
        items: [
          TabItem(icon: Icons.home, title: 'Inicio'),
          TabItem(icon: Icons.class_, title: 'Registrar Clase'),
          TabItem(icon: Icons.check, title: 'Controlar Asistencia'),
          TabItem(icon: Icons.picture_as_pdf, title: 'Reportes PDF'),
        ],
        initialActiveIndex: 0,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home',
                  arguments: username);
              break;
            case 1:
              Navigator.pushNamed(context, '/create_course');
              break;
            case 2:
              Navigator.pushNamed(context, '/attendance_control');
              break;
            case 3:
              Navigator.pushNamed(context, '/pdf_reports');
              break;
          }
        },
      ),
      body: Column(
        children: [
          Container(
            height: 330,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Color.fromARGB(255, 20, 227, 227)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 125,
                  left: 20,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? Icon(Icons.camera_alt, color: Colors.grey[600])
                          : null,
                    ),
                  ),
                ),
                Positioned(
                  top: 140,
                  left: 135,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Bienvenido, $username!',
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Gestiona y controla asistencias.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 85,
                  right: 20,
                  child: Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.logout, color: Colors.white, size: 30),
                        onPressed: _logout,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Text(
                    'Lista de Clases',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _courses,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error al cargar cursos'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                              child: Text('No hay cursos disponibles'));
                        } else {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final course = snapshot.data![index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          StudentScreen(courseId: course['id']),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 250,
                                  height: 100,
                                  margin: EdgeInsets.all(8),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _getRandomColor(index),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        _getRandomIcon(index),
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        course['name'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Periodo: ${course['period']}',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Spacer(),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit,
                                                color: Colors.white),
                                            onPressed: () {
                                              _editCourse(
                                                  course['id'],
                                                  course['name'],
                                                  course['period']);
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete,
                                                color: Colors.white),
                                            onPressed: () {
                                              _deleteCourse(course['id']);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 270, // Espacio adicional en la parte inferior
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
