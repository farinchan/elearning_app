import 'dart:io';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ujian MAN 1 Kota Padang Panjang'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              webViewController?.reload();
            },
          ),
          IconButton(
            icon: Icon(Icons.power),
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
                          exit(0);
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
      body: InAppWebView(
        key: webViewKey,
        webViewEnvironment: webViewEnvironment,
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        initialUrlRequest: URLRequest(
            url:
                WebUri("https://elearning.man1kotapadangpanjang.sch.id/login")),
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
    );
  }
}
