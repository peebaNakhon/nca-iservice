import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:ncaisbf/main.dart';

class SplashScreen extends StatefulWidget {
  final AssetImage assetImage;

  const SplashScreen({Key? key, required this.assetImage}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    log("SplashScreen initState called");
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _runsAfterBuild();
    });
  }

  Future<void> _runsAfterBuild() async {
    Future.delayed(const Duration(seconds: 2), () {
      // Navigate to the next screen after a delay
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WebViewApp()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(widget.assetImage, context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
                child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image(
                image: widget.assetImage,
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            )),
            const SizedBox(height: 100),
            CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.blue.shade400,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "v1.2.0",
              style: TextStyle(fontSize: 11),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              "28062024R1",
              style: TextStyle(fontSize: 9),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              "NCA IT",
              style: TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
