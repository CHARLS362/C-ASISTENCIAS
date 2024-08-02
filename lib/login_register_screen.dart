import 'package:flutter/material.dart';
import 'db_helper.dart'; // Asegúrate de usar la ruta correcta para tu archivo
import 'package:fluttertoast/fluttertoast.dart';

class LoginRegisterScreen extends StatefulWidget {
  @override
  _LoginRegisterScreenState createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dbHelper = DBHelper();

  bool _isLogin = true;
  bool _obscurePassword = true; // Para mostrar/ocultar contraseña

  void _toggleView() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final user = await _dbHelper.getUser(username);
    if (user != null && user['password'] == password) {
      // Navegar a la pantalla de inicio y pasar el nombre de usuario
      Navigator.pushReplacementNamed(context, '/home', arguments: username);
    } else {
      Fluttertoast.showToast(msg: "Invalid credentials");
    }
  }

  Future<void> _handleRegister() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    try {
      await _dbHelper.insertUser(username, password);
      Fluttertoast.showToast(msg: "User registered successfully");
      setState(() {
        _isLogin = true; // Switch to login after registration
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Error registering user");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Evita que el contenido se mueva al aparecer el teclado
      body: Stack(
        children: [
          // Imagen de fondo para login o registro
          Positioned.fill(
            child: _isLogin
                ? Image.asset(
                    'assets/login.png',
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/registro.png',
                    fit: BoxFit.cover,
                  ),
          ),
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 280), // Ajuste vertical
                    // Campo de entrada de usuario
                    Container(
                      width: double.infinity, // Ajuste para tamaño horizontal
                      child: TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelText: 'Usuario',
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Campo de entrada de contraseña
                    Container(
                      width: double.infinity, // Ajuste para tamaño horizontal
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelText: 'Contraseña',
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    // Botón de login o registro
                    Container(
                      width: double.infinity, // Ajuste para tamaño horizontal
                      child: ElevatedButton(
                        onPressed: _isLogin ? _handleLogin : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 9, 176, 165),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _isLogin ? 'Ingresar' : 'Registrar',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    // Botón para alternar entre login y registro
                    TextButton(
                      onPressed: _toggleView,
                      child: Text(
                        _isLogin
                            ? 'No tienes cuenta? Regístrate'
                            : 'Ya tienes cuenta? Inicia sesión',
                        style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 13, 192, 132)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
