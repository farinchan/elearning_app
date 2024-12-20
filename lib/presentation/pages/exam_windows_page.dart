import 'dart:developer';
import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:elearning_app/common/helper/hotkey_blocker.dart';
import 'package:elearning_app/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ExamWindowsPage extends StatefulWidget {
  static const routeName = '/exam_windows_page';
  ExamWindowsPage({Key? key}) : super(key: key);

  @override
  _ExamWindowsPageState createState() => _ExamWindowsPageState();
}

class _ExamWindowsPageState extends State<ExamWindowsPage> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  double _progress = 0; // Menyimpan progress loading

  void snackBarAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Peringatan!',
          message: 'Kamu Terdeteksi melakukan tindakan ilegal! \n'
              'Jika kamu terus melakukan tindakan ini, maka kamu akan dikeluarkan dari ujian!',
          contentType: ContentType.failure,
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    HotkeyBlocker.blockHotkeys();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('E-Learning MAN 1 Padang Panjang'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              webViewController?.reload();
            },
          ),
          IconButton(
            icon: Icon(Icons.power_settings_new),
            onPressed: () async {
              return await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Konfirmasi'),
                    content: Text('Apakah Anda yakin ingin keluar?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          SystemNavigator.pop();
                          exit(0); // Menutup aplikasi secara paksa
                        },
                        child: Text('Keluar'),
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(3.0), // Tinggi progress bar
          child: _progress < 1.0
              ? LinearProgressIndicator(value: _progress)
              : Container(),
        ),
      ),
      body: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event.logicalKey == LogicalKeyboardKey.f5) {
            webViewController?.reload();
          }
          if (event.logicalKey == LogicalKeyboardKey.meta) {
            log('key pressed: ${event.logicalKey}');
            snackBarAlert();
          }
          if (event.logicalKey == LogicalKeyboardKey.altLeft ||
              event.logicalKey == LogicalKeyboardKey.altRight) {
            log('key pressed: ${event.logicalKey}');
            snackBarAlert();
          }
          if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
              event.logicalKey == LogicalKeyboardKey.controlRight) {
            log('key pressed: ${event.logicalKey}');
            snackBarAlert();
          }
        },
        child: InAppWebView(
          key: webViewKey,
          webViewEnvironment: webViewEnvironment,
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          initialUrlRequest: URLRequest(
              url: WebUri(
                  "https://elearning.man1kotapadangpanjang.sch.id/login")),
          onPermissionRequest: (controller, request) async {
            return PermissionResponse(
                resources: request.resources,
                action: PermissionResponseAction.GRANT);
          },
          onLoadStart: (controller, url) {
            setState(() {
              _progress = 0; // Reset progress saat mulai memuat
            });
          },
          onProgressChanged: (controller, progress) {
            setState(() {
              _progress = progress / 100; // Update progress
            });
          },
          onLoadStop: (controller, url) async {
            setState(() {
              _progress = 1.0; // Selesaikan progress saat selesai memuat
            });
          },
          onReceivedError: (controller, request, error) {
            setState(() {
              _progress = 0; // Reset progress jika terjadi error
            });
          },
          onConsoleMessage: (controller, consoleMessage) {
            if (kDebugMode) {
              print(consoleMessage);
            }
          },
        ),
      ),
    );
  }
}
