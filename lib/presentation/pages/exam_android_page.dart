import 'dart:developer';
import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:elearning_app/common/helper/secure_mode.dart';
import 'package:elearning_app/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kiosk_mode/kiosk_mode.dart';

class ExamAndroidPage extends StatefulWidget {
  static const routeName = '/exam_android_page';
  ExamAndroidPage({Key? key}) : super(key: key);

  @override
  _ExamAndroidPageState createState() => _ExamAndroidPageState();
}

void InfoKioskMode(context) async {
  var kioskMode = await getKioskMode();

  if (kioskMode == KioskMode.enabled) {
    log('Kiosk mode enabled');
    return;
  } else {
    log('Kiosk mode disabled');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _CountdownDialog();
      },
    );
  }
}

class _CountdownDialog extends StatefulWidget {
  @override
  _CountdownDialogState createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<_CountdownDialog> {
  int _countdown = 15;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(Duration(seconds: 1), () {
      if (_isDisposed) return; // Jangan lanjutkan jika dialog sudah dispose

      if (_countdown > 1) {
        if (mounted) {
          setState(() {
            _countdown--;
          });
        }
        _startCountdown();
      } else {
        // Crash aplikasi
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        exit(0);
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('Peringatan!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kiosk Mode belum aktif!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Aplikasi akan ditutup dalam:'),
            SizedBox(height: 10),
            Text(
              '$_countdown',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 10),
            Text('detik'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await startKioskMode();
              Navigator.of(context).pop();
            },
            child: Text('Aktifkan Kiosk Mode'),
          ),
        ],
      ),
    );
  }
}

void enableKioskMode(context) async {
  await startKioskMode();
}

class _ExamAndroidPageState extends State<ExamAndroidPage>
    with WidgetsBindingObserver {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  double _progress = 0; // Menyimpan progress loading
  bool _isShowingKioskDialog = false; // Flag untuk mencegah dialog duplikat

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Konfirmasi"),
              content: Text("Anda yakin ingin keluar dari ujian?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("batal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await stopKioskMode();
                    SystemNavigator.pop();
                  },
                  child: Text("keluar"),
                ),
              ],
            );
          },
        ) ??
        false; // Default to false if dialog is dismissed
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.top,
    ]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));
    enableKioskMode(context);
    enableSecureMode();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    disableSecureMode();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      log('App is paused or inactive');

      // Cek kiosk mode tanpa menampilkan dialog
      getKioskMode().then((kioskMode) {
        if (kioskMode == KioskMode.disabled && !_isShowingKioskDialog) {
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

          _checkAndShowKioskDialog();
        }
      });
    }
  }

  void _checkAndShowKioskDialog() async {
    if (_isShowingKioskDialog) return; // Jangan tampilkan jika sudah ada dialog

    var kioskMode = await getKioskMode();
    if (kioskMode == KioskMode.disabled) {
      _isShowingKioskDialog = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return _CountdownDialog();
        },
      ).then((_) {
        _isShowingKioskDialog = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        await _showExitConfirmation(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('E-Learning MAN 1 Padang Panjang'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                webViewController?.reload();
              },
            ),
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
