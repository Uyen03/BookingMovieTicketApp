import 'dart:async';

import 'package:bookingmovieticket/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/mytheme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.bounceOut,
      reverseCurve: Curves.bounceIn,
    );

    _animationController.forward();

    // Sử dụng Timer với kiểm tra `mounted`
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    return Scaffold(
      backgroundColor: MyTheme.splash,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: SvgPicture.asset(
            "assets/icons/splash_icon.svg",
            height: 70,
          ),
        ),
      ),
    );
  }
}
