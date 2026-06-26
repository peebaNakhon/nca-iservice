# เอกสารประกอบ NCA iService Version 2

## กรอบการทำงาน (Framework)
แอปพลิเคชันนี้พัฒนาด้วย Flutter Framework เวอร์ชัน 3.0.6 หรือสูงกว่า โดยใช้ Material Design 3 เป็นหลักในการออกแบบ UI

## การพึ่งพา (Dependencies)
แอปพลิเคชันนี้ใช้แพ็คเกจสำคัญดังนี้:
- webview_flutter: ^4.2.2 - สำหรับแสดงหน้าเว็บภายในแอป
- image_picker: ^1.0.2 - สำหรับการถ่ายภาพและเลือกภาพจากแกลเลอรี่
- flutter_image_compress: ^2.0.4 - สำหรับบีบอัดภาพ
- honeywell_scanner: ^4.0.0+14 - สำหรับสแกนบาร์โค้ดบนอุปกรณ์ Honeywell
- barcode_scan2: ^4.2.4 - สำหรับสแกนบาร์โค้ดทั่วไป
- device_info_plus: ^9.0.3 - สำหรับดึงข้อมูลอุปกรณ์
- package_info_plus: ^4.1.0 - สำหรับดึงข้อมูลแพ็คเกจ
- url_launcher: ^6.1.12 - สำหรับเปิด URL
- flutter_easyloading: ^3.0.5 - สำหรับแสดง loading

## ไฟล์สำคัญและหน้าที่การทำงาน

### ไฟล์หลัก
- `lib/main.dart` - ไฟล์หลักของแอปพลิเคชัน ประกอบด้วย:
  - การตั้งค่า WebView
  - ฟังก์ชันการสแกนบาร์โค้ด
  - ฟังก์ชันการถ่ายภาพ
  - การจัดการ JavaScript Bridge
  - การจัดการการอัพเดทแอป

- `lib/SplashScreen.dart` - หน้าจอเริ่มต้นของแอปพลิเคชัน

### ไฟล์การตั้งค่า
- `pubspec.yaml` - ไฟล์กำหนดค่าหลักของโปรเจค
- `shorebird.yaml` - ไฟล์กำหนดค่าสำหรับการอัพเดทผ่าน Shorebird
- `flutter_launcher_icons.yaml` - ไฟล์กำหนดค่าไอคอนแอป
- `flutter_native_splash.yaml` - ไฟล์กำหนดค่าหน้าจอเริ่มต้น

## ฟังก์ชันสำคัญ

### การสแกนบาร์โค้ด
- `scanBarcode()` - ฟังก์ชันสำหรับสแกนบาร์โค้ด
- `sendBarcodeValueToWebView()` - ส่งค่าบาร์โค้ดไปยัง WebView

### การจัดการรูปภาพ
- `takePhoto()` - ฟังก์ชันสำหรับถ่ายภาพ
- `sendPhotoToWebView()` - ส่งรูปภาพไปยัง WebView
- `sendPhotoToWebView2()` - ส่งรูปภาพแบบพิเศษไปยัง WebView

### การจัดการ JavaScript Bridge
- `_setupJavaScriptChannel()` - ตั้งค่าช่องทางการสื่อสารระหว่าง Flutter และ JavaScript
- `_setupJavaScriptHandler()` - จัดการการเรียกใช้ฟังก์ชัน JavaScript

## คุณสมบัติหลัก
- การแสดงหน้าเว็บผ่าน WebView
- การสแกนบาร์โค้ด
- การถ่ายภาพและอัพโหลด
- การจัดการรูปภาพแบบพิเศษ (หน้าหลังบัตร)
- การอัพเดทแอปอัตโนมัติผ่าน Shorebird
- การแสดงสถานะการโหลด
- การจัดการการเชื่อมต่ออินเทอร์เน็ต

## API และการสื่อสาร
แอปพลิเคชันนี้ใช้การสื่อสารระหว่าง Flutter และ WebView ผ่าน JavaScript Bridge โดยมีฟังก์ชันหลักดังนี้:

### JavaScript to Flutter
- `scanBarcode()` - เรียกใช้การสแกนบาร์โค้ด
- `takePhoto()` - เรียกใช้การถ่ายภาพ
- `takePhoto2()` - เรียกใช้การถ่ายภาพแบบพิเศษ
- `getDeviceInfo()` - ขอข้อมูลอุปกรณ์
- `getAppVersion()` - ขอเวอร์ชันแอป
- `openURL()` - เปิด URL

### Flutter to JavaScript
- `fireAlert()` - แสดงการแจ้งเตือน
- `sendBarcodeValue()` - ส่งค่าบาร์โค้ด
- `sendPhoto()` - ส่งรูปภาพ
- `sendPhoto2()` - ส่งรูปภาพแบบพิเศษ

## การรันในโหมดพัฒนา
1. ติดตั้ง Flutter SDK เวอร์ชัน 3.0.6 หรือสูงกว่า
2. รันคำสั่ง `flutter pub get` เพื่อติดตั้ง dependencies
3. รันคำสั่ง `flutter run` เพื่อเริ่มต้นแอปในโหมดพัฒนา

## การสร้างแอป (Build)
1. สำหรับ Android:
   ```
   flutter build apk
   ```
2. สำหรับ iOS:
   ```
   flutter build ios
   ```

## การใช้งาน Shorebird
แอปพลิเคชันนี้ใช้ Shorebird สำหรับการอัพเดทแบบ OTA (Over-The-Air) โดยมีการตั้งค่าดังนี้:

### การตั้งค่า
- App ID: a1c735a0-2b51-4ceb-9287-c6401d05bb5d  
- เปิดใช้งานการอัพเดทอัตโนมัติ (auto_update: true)

### การทำงาน
1. Shorebird จะตรวจสอบการอัพเดทอัตโนมัติเมื่อเปิดแอป
2. เมื่อมีการอัพเดทใหม่ แอปจะดาวน์โหลดและติดตั้งแพทช์โดยอัตโนมัติ
3. ผู้ใช้ไม่จำเป็นต้องดาวน์โหลดแอปใหม่จาก Play Store หรือ App Store

### การอัพเดทแอป
1. สร้างแพทช์ใหม่ด้วยคำสั่ง:
   ```
   shorebird patch android 
   ```
2. แพทช์จะถูกอัพโหลดไปยังเซิร์ฟเวอร์ Shorebird โดยอัตโนมัติ
3. ผู้ใช้จะได้รับอัพเดทในครั้งถัดไปที่เปิดแอป
# nca-iservice
