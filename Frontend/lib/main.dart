import 'package:bookingmovieticket/controllers/auth_controller.dart';
import 'package:bookingmovieticket/controllers/location_controller.dart';
import 'package:bookingmovieticket/controllers/common_controller.dart';
import 'package:bookingmovieticket/controllers/movie_controller.dart'; // Make sure to import the MovieController
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bookingmovieticket/pages/splash_screen.dart';
import 'package:bookingmovieticket/utils/mytheme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase if needed
  await Firebase.initializeApp();

  // Initialize your controllers
  Get.put<AuthController>(AuthController());
  Get.put(LocationController());
  Get.put(CommonController());
  Get.put(MovieController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: MyTheme.myLightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
