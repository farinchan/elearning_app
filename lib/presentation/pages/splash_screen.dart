import 'dart:async';

import 'package:elearning_app/presentation/pages/exam_android_page.dart';
import 'package:elearning_app/presentation/pages/exam_windows_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash_screen';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    Timer(Duration(seconds: 2), () async {
      if (defaultTargetPlatform == TargetPlatform.windows) {
        Navigator.of(context).pushReplacementNamed(ExamWindowsPage.routeName);
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        Navigator.of(context).pushReplacementNamed(ExamAndroidPage.routeName);
      } else {
        return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Unsupported Platform'),
              content: Text('This platform is not supported'),
              actions: [
                TextButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 228,
              child: Image.asset('assets/images/logo.png'),
            ),
            SizedBox(height: 20),
            Text(
              'Versi 1.5.5',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
