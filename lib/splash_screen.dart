import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

class SplashScreen extends StatelessWidget {
  // Variable para definir el color del símbolo de carga
  final Color loadingColor =
      Color.fromARGB(255, 20, 242, 168); // Cambia el color aquí

  @override
  Widget build(BuildContext context) {
    // Usar timeDilation para ralentizar las animaciones durante el desarrollo
    timeDilation = 1.0;

    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/login');
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen que ocupa toda la pantalla
          Image.asset(
            'assets/scren.png',
            fit: BoxFit
                .cover, // Ajusta la imagen para que cubra toda la pantalla
          ),
          // Columna para el símbolo de carga y el texto en la parte inferior
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
                  ), // Símbolo de carga con color editable
                  SizedBox(
                      height:
                          8.0), // Espacio entre el símbolo de carga y el texto
                  Text(
                    'QRapido',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
