import 'package:flutter/material.dart';
import 'db_clase.dart'; // Asegúrate de importar tu archivo DBHelper

class StudentScreen extends StatefulWidget {
  final int courseId;

  StudentScreen({required this.courseId});

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final DBHelper _dbHelper = DBHelper();
  late Future<List<Map<String, dynamic>>> _students;
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _students = _dbHelper.getStudents(widget.courseId);
  }

  Future<void> _refreshStudents() async {
    setState(() {
      _students = _dbHelper.getStudents(widget.courseId);
    });
  }

  Future<void> _saveStudent() async {
    final lastName = _lastNameController.text;
    final firstName = _firstNameController.text;
    final phoneNumber = _phoneNumberController.text;

    if (lastName.isEmpty || firstName.isEmpty || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    await _dbHelper.insertStudent(
        widget.courseId, lastName, firstName, phoneNumber);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alumno guardado con éxito')),
    );
    _lastNameController.clear();
    _firstNameController.clear();
    _phoneNumberController.clear();
    _refreshStudents();
  }

  void _editStudent(int id, String currentLastName, String currentFirstName,
      String currentPhoneNumber) async {
    TextEditingController lastNameController =
        TextEditingController(text: currentLastName);
    TextEditingController firstNameController =
        TextEditingController(text: currentFirstName);
    TextEditingController phoneNumberController =
        TextEditingController(text: currentPhoneNumber);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Alumno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: 'Apellidos'),
            ),
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: 'Nombres'),
            ),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(labelText: 'Celular'),
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
              await _dbHelper.updateStudent(id, lastNameController.text,
                  firstNameController.text, phoneNumberController.text);
              Navigator.pop(context);
              _refreshStudents();
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _deleteStudent(int id) async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Alumno'),
        content: Text('¿Estás seguro de que deseas eliminar este alumno?'),
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
      await _dbHelper.deleteStudent(id);
      _refreshStudents();
    }
  }

  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar Alumno'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Apellidos'),
            ),
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'Nombres'),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Celular'),
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
              await _saveStudent();
              Navigator.pop(context);
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alumnos'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _students,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar alumnos'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay alumnos disponibles'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final student = snapshot.data![index];
                      return Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                              '${student['last_name']} ${student['first_name']}'),
                          subtitle: Text(student['phone_number']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editStudent(
                                  student['id'],
                                  student['last_name'],
                                  student['first_name'],
                                  student['phone_number'],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteStudent(student['id']),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
