import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'splash_screen.dart';
import 'login_register_screen.dart';
import 'home_screen.dart';
import 'create_course_screen.dart';
import 'attendance_control_screen.dart'; // Importa tu nueva pantalla

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Mi Aplicación',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => SplashScreen(),
            '/login': (context) => LoginRegisterScreen(),
            '/home': (context) => HomeScreen(),
            '/create_course': (context) => CreateCourseScreen(),
            '/attendance_control': (context) =>
                AttendanceControlScreen(), // Añade la nueva ruta
          },
        );
      },
    );
  }
}
