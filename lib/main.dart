import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ncaisbf/SplashScreen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
//import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'dart:developer';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:honeywell_scanner/honeywell_scanner.dart';
//import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  HoneywellScanner honeywellScanner = HoneywellScanner();
  bool isDeviceSupported = await honeywellScanner.isSupported();
  log("EDA_I");
  log(isDeviceSupported.toString());
  runApp(
    MaterialApp(
        //theme: ThemeData(useMaterial3: true),
        theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255),
            fontFamily: 'Prompt'),
        home: const SplashScreen(
          assetImage: AssetImage('assets/wetiOS.png'),
        ),
        title: 'NCA iService',
        builder: EasyLoading.init()),
  );
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  static final DateTime _allowedAt = DateTime(2026, 7, 1, 5, 0);

  String open1stTime = '0';
  String barcodeValue = '';
  late WebViewController webViewcontroller;
  //HoneywellScanner honeywellScanner = HoneywellScanner(scannerCallback: this);
  ScannedData? scannedData;
  String? errorMessage;
  bool scannerEnabled = false;
  bool scan1DFormats = true;
  bool scan2DFormats = true;
  bool isDeviceSupported = false;

  bool enableZoom = false;
  bool _webViewLoaded = false;
  Timer? _countdownTimer;

  HoneywellScanner honeywellScanner =
      HoneywellScanner(onScannerDecodeCallback: (ScannedData? scannedData) {
    String? resultCode = scannedData?.code.toString();
    log('Decode Result Code: $resultCode');
  }, onScannerErrorCallback: (error) {
    log(error.toString());
  });

  // Future<void> deCodeEDA() async {
  //   honeywellScanner.onScannerDecodeCallback = (scannedData) {
  //   // Do something here
  //   };
  //   honeywellScanner.onScannerErrorCallback = (error) {
  //   // Do something here
  //   };
  // }

  Future<void> scanBarcode() async {
    try {
      // String barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
      //   '#FF0000', // Scanner overlay color
      //   'ออก', // Cancel button text
      //   true, // Show flash icon
      //   ScanMode.BARCODE, // Scan mode (optional, defaults to ScanMode.DEFAULT)
      // );
      // final possibleFormats = BarcodeFormat.values.toList()
      //   ..removeWhere((e) => e == BarcodeFormat.unknown);

      List<BarcodeFormat> selectedFormats = [BarcodeFormat.code39];

      log('barcode format list : $selectedFormats');

      final flashOnController = TextEditingController(text: 'Flash on');
      final flashOffController = TextEditingController(text: 'Flash off');
      final cancelController = TextEditingController(text: 'Cancel');

      var aspectTolerance = 0.0;
      //var numberOfCameras = 0;
      //var selectedCamera = -1;
      var useAutoFocus = true;
      var autoEnableFlash = false;

      var result = await BarcodeScanner.scan(
        options: ScanOptions(
          strings: {
            'cancel': cancelController.text,
            'flash_on': flashOnController.text,
            'flash_off': flashOffController.text,
          },
          restrictFormat: selectedFormats,
          //useCamera: selectedCamera,
          autoEnableFlash: autoEnableFlash,
          android: AndroidOptions(
            aspectTolerance: aspectTolerance,
            useAutoFocus: useAutoFocus,
          ),
        ),
      );

      log(result.type
          .toString()); // The result type (barcode, cancelled, failed)
      log(result.rawContent.toString()); // The barcode content
      log(result.format.toString()); // The barcode format (as enum)
      log(result.formatNote
          .toString()); // If a unknown format was scanned this field contains a note
      if (result.type.toString() == 'Cancelled') {
        return;
      }
      String barcodeScanResult = result.rawContent.toString();
      log('barcodeScanResult : $barcodeScanResult');
      if (barcodeScanResult.length < 8) {
        webViewcontroller.runJavaScript(
            "fireAlert('พบข้อผิดพลาดในการอ่านบาร์โค้ด<br>กรุณาลองอีกครั้ง');");
        return;
      }
      setState(() {
        barcodeValue = barcodeScanResult;
        log('data: $barcodeValue');
        log('----------------------------------------------------------------');
        if (barcodeValue != '-1') {
          sendBarcodeValueToWebView(barcodeValue);
        }
        //_showMyDialog();
        log('----------------------------------------------------------------');
      });
    } catch (e) {
      log("ERROR : $e");
    }
  }

  // Future<void> takePhoto(String seatname) async {
  //   if (!mounted) return; // Check if the widget is still mounted before updating the state.
  //   try {
  //     final XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.camera, maxHeight: 256, imageQuality: 100);
  //     if (pickedFile != null) {
  //       List<int>? compressedBytes = await FlutterImageCompress.compressWithFile(pickedFile.path);
  //       if (compressedBytes == null) return;
  //       final image = await pickedFile.readAsBytes();
  //       final Uint8List bitmapData = Uint8List.fromList(image);
  //       //String imgBitmapBase64 = base64Encode(bitmapData);
  //       final img.Image imageDe = img.decodeImage(bitmapData)!;
  //       final List<int> pngData = img.encodePng(imageDe);
  //       String imgBase64 = base64Encode(pngData);
  //       log('pngBase64');
  //       //String imgBase64 = base64Encode(bitmapData);
  //       //log(imgBase64);
  //       sendPhotoToWebView(imgBase64, seatname);
  //     }
  //   } catch (error) {
  //     log(error.toString());
  //   }
  // }

  Future<void> takePhoto(BuildContext context, String seatname) async {
    try {
      final choice = await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('เลือกรูปแบบการถ่ายรูป'),
            content: const Text(
                '1 รูปสำหรับถ่ายรูปทั่วไป\r\n2 รูปสำหรับถ่ายบัตรหน้าหลัง\r\nโปรดตั้งอัตราส่วนรูปเป็น 1:1 เมื่อถ่าย 2 รูป'),
            actions: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment
                    .stretch, // Aligns children to take full width
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(1),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue.shade400),
                    child: const Text(
                      'ถ่าย 1 รูป',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(2),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade400),
                    child: const Text(
                      'ถ่าย 2 รูป (หน้าหลังบัตร)',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(3),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent.shade400),
                    child: const Text(
                      'เลือกรูปจากแกลลอรี่',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );

      if (choice == null) return;

      final ImagePicker picker = ImagePicker();
      final List<XFile?> pickedFiles = [];

      EasyLoading.show();

      if (choice == 1 || choice == 2) {
        for (int i = 0; i < choice; i++) {
          final int countImg = i + 1;
          EasyLoading.show(status: "ถ่ายรูป $countImg / $choice รูป");
          final XFile? pickedFile = await picker.pickImage(
              source: ImageSource.camera, maxWidth: 300, imageQuality: 100);
          if (pickedFile != null) {
            pickedFiles.add(pickedFile);
          } else {
            EasyLoading.dismiss();
          }
        }
      } else {
        final XFile? pickedFile = await picker.pickImage(
            source: ImageSource.gallery, maxWidth: 300, imageQuality: 100);
        if (pickedFile != null) {
          pickedFiles.add(pickedFile);
        } else {
          EasyLoading.dismiss();
        }
      }

      if (pickedFiles.isEmpty || pickedFiles.contains(null)) {
        EasyLoading.dismiss();
        return;
      }

      EasyLoading.show(status: 'กำลังประมวลผลรูป...');

      if (choice == 1 || choice == 3) {
        final XFile pickedFile = pickedFiles.first!;
        final Uint8List bitmapData = await pickedFile.readAsBytes();
        List<int>? compressedBytes =
            await FlutterImageCompress.compressWithList(bitmapData);
        // if (compressedBytes == null) return;
        final img.Image imageDe =
            img.decodeImage(Uint8List.fromList(compressedBytes))!;
        // Encode the compressed image as PNG
        final List<int> pngData = img.encodePng(imageDe);
        String imgBase64 = base64Encode(pngData);
        log('pngBase64');
        EasyLoading.dismiss();
        sendPhotoToWebView(imgBase64, seatname);
      } else if (choice == 2) {
        final Uint8List firstImageBytes = await pickedFiles[0]!.readAsBytes();
        final Uint8List secondImageBytes = await pickedFiles[1]!.readAsBytes();

        if (firstImageBytes.isEmpty || secondImageBytes.isEmpty) {
          EasyLoading.dismiss();
          return;
        }

        final img.Image firstImage = img.decodeImage(firstImageBytes)!;
        final img.Image secondImage = img.decodeImage(secondImageBytes)!;

        final int combinedWidth = firstImage.width + secondImage.width;
        final int maxHeight = firstImage.height > secondImage.height
            ? firstImage.height
            : secondImage.height;

        final img.Image combinedImage =
            img.Image(width: combinedWidth, height: maxHeight);

        for (int y = 0; y < firstImage.height; y++) {
          for (int x = 0; x < firstImage.width; x++) {
            combinedImage.setPixel(x, y, firstImage.getPixel(x, y));
          }
        }

        for (int y = 0; y < secondImage.height; y++) {
          for (int x = 0; x < secondImage.width; x++) {
            combinedImage.setPixel(
                x + firstImage.width, y, secondImage.getPixel(x, y));
          }
        }

        final List<int> pngData = img.encodePng(combinedImage);
        List<int>? furtherCompressedBytes =
            await FlutterImageCompress.compressWithList(
                Uint8List.fromList(pngData));
        final img.Image finalImage =
            img.decodeImage(Uint8List.fromList(furtherCompressedBytes))!;
        final List<int> finalPngData = img.encodePng(finalImage);

        String imgBase64 = base64Encode(finalPngData);
        log(imgBase64);
        EasyLoading.dismiss();
        sendPhotoToWebView(imgBase64, seatname);
      }
    } catch (error) {
      log(error.toString());
    }
  }

  void startScanEDA() {
    honeywellScanner.startScanner();
  }

  void stopScanEDA() {
    honeywellScanner.stopScanner();
  }

  void sendBarcodeValueToWebView(String value) {
    // Load the WebView's JavaScript function and pass the barcode value.
    webViewcontroller.runJavaScript("findPassengerByTiketNoCamera('$value');");
  }

  void sendEDAValueToWebView(String value) {
    // Load the WebView's JavaScript function and pass the barcode value.
    webViewcontroller.runJavaScript("findPassengerByTiketNoEDA('$value');");
    log("EDA data sent to WebView!");
  }

  void sendPhotoToWebView(String base64img, String seatname) {
    // Load the WebView's JavaScript function and pass the barcode value.
    //log('Base64Img : $value');
    log("recivePhoto('$base64img','$seatname');");
    webViewcontroller.runJavaScript("recivePhoto('$base64img','$seatname');");
  }

  void sendDeviceInfo(String value) {
    // Load the WebView's JavaScript function and pass the barcode value.
    webViewcontroller.runJavaScript("deviceInfo('$value');");
    log("sendDeviceInfo");
  }

  // final Uri _url = Uri.parse(
  //     'http://203.146.21.210/edascan/update.html'); // this is url to update redirect page
  final Uri _url = Uri.parse(
      'http://203.151.125.243/edascan/update.html'); // this is url to update redirect page
  Future<void> userWantToUpdateApp() async {
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_url');
    }
  }

  Future<void> telphoneCall(url) async {
    log(url);
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $_url');
    }
  }

  bool _isUsageAllowed() {
    return !DateTime.now().isBefore(_allowedAt);
  }

  String _formatAllowedAt() {
    final day = _allowedAt.day.toString().padLeft(2, '0');
    final month = _allowedAt.month.toString().padLeft(2, '0');
    final year = _allowedAt.year.toString();
    final hour = _allowedAt.hour.toString().padLeft(2, '0');
    final minute = _allowedAt.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  String _formatRemainingTime() {
    final remaining = _allowedAt.difference(DateTime.now());
    if (remaining.isNegative || remaining.inSeconds <= 0) {
      return '0 วัน 0 ชม 0 นาที 0 วินาที';
    }

    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    return '$days วัน $hours ชม $minutes นาที $seconds วินาที';
  }

  Future<void> _loadWebViewIfNeeded() async {
    if (_webViewLoaded) {
      await webViewcontroller.reload();
      return;
    }

    _webViewLoaded = true;
    await webViewcontroller
        .loadRequest(Uri.parse('http://203.151.125.243/edascan/index.php'));
    await webViewcontroller.enableZoom(enableZoom);
  }

  Future<void> _attemptLaunchWebView() async {
    if (!mounted) return;

    if (_isUsageAllowed()) {
      _countdownTimer?.cancel();
      await _loadWebViewIfNeeded();
      if (mounted) {
        setState(() {});
      }
      return;
    }

    EasyLoading.dismiss();
    _startCountdown();
    if (mounted) {
      setState(() {});
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_isUsageAllowed()) {
        timer.cancel();
        _attemptLaunchWebView();
        return;
      }

      setState(() {});
    });
  }

  @override
  void initState() {
    EasyLoading.show(status: 'รอซักครู่...');
    initializeHoneywellScanner();
    webViewcontroller = WebViewController()
      ..clearCache()
      ..clearCache()
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          if (request.url.contains("tel:")) {
            log("user cliked on telNo.");
            telphoneCall(request.url);
            return NavigationDecision.prevent;
          } else {
            return NavigationDecision.navigate;
          }
        },
        onPageFinished: (String url) async {
          if (open1stTime != '1') {
            FlutterNativeSplash.remove();
            open1stTime = '1';
            log('FlutterNativeSplash.remove();');
            //startScanEDA();
            final deviceInfoPlugin = DeviceInfoPlugin();
            final deviceInfo = await deviceInfoPlugin.androidInfo;
            log(deviceInfo.toString());

            PackageInfo packageInfo = await PackageInfo.fromPlatform();
            String version = packageInfo.version;

            final allInfo =
                '${deviceInfo.model} | OSA:${deviceInfo.version.release} | $version';
            sendDeviceInfo(allInfo.toString().trim());
            log(allInfo.toString().trim());
            EasyLoading.dismiss();
          }
        },
      ))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('flutterCommu',
          onMessageReceived: (JavaScriptMessage message) {
        log('MessageReceived : ${message.message}');
        if (message.message == 'scanbarcode') {
          scanBarcode();
        } else if (message.message.contains('takePhoto')) {
          log(message.message.substring(11, 14).replaceAll("'", ''));
          takePhoto(
              context, message.message.substring(11, 14).replaceAll("'", ''));
        } else if (message.message == 'startEDA') {
          startScanEDA();
          log('EDA is Ready To Use!');
        } else if (message.message == 'stopEDA') {
          stopScanEDA();
          log('EDA is Disabled!');
        } else if (message.message == 'userWant2UpdateApp') {
          userWantToUpdateApp();
        }
      });
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptLaunchWebView();
    });
  }

  Future<void> initializeHoneywellScanner() async {
    honeywellScanner = HoneywellScanner(
      onScannerDecodeCallback: (ScannedData? scannedData) {
        String? resultCode = scannedData?.code.toString();
        log('Decode Result Code: $resultCode');
        sendEDAValueToWebView(resultCode.toString());
      },
      onScannerErrorCallback: (error) {
        log(error.toString());
      },
    );
  }

  Future<void> sendEDAResultToWebView(String value) async {
    sendBarcodeValueToWebView(value);
  }

  Future<bool> _onWillPop() async {
    EasyLoading.dismiss();
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('NCA iService'),
            content: const Text('ต้องการออกจากแอปพลิเคชันหรือไม่?'),
            actions: <Widget>[
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), //<-- SEE HERE
                child: const Text('ไม่'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(true), // <-- SEE HERE
                child: const Text('ใช่'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: null,
        body: SafeArea(
          child: _webViewLoaded
              ? WebViewWidget(controller: webViewcontroller)
              : Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blue.shade50, Colors.white],
                    ),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        'assets/wetiOS.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              const Text(
                                'ระบบยังไม่เปิดให้ใช้งาน',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'แอปจะเปิดให้ใช้งานวันที่ ${_formatAllowedAt()}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.5,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'พร้อมใช้งานในอีก',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatRemainingTime(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'ระบบจะเปิดให้ใช้งานโดยอัตโนมัติเมื่อถึงเวลาที่กำหนด',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
