# 🛠️ دليل المطور (Developer Guide)

هذا الدليل موجه للمطورين الذين يعملون على صيانة أو تطوير تطبيق **رتّل**.

## إضافة ملفات جديدة (Assets)
عند إضافة صور أو ملفات بيانات جديدة (JSON/PDF):
1. ضع الملف في المجلد المناسب تحت `assets/`.
   - الصور: `assets/images/`
   - البيانات: `assets/data/`
2. قم بتسجيل الملف أو المجلد في `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/images/new_image.png
   ```
3. أعد تشغيل الأمر: `flutter pub get`.

## قاعدة البيانات (Database)
- نستخدم `sqflite` مع ملف قاعدة بيانات جاهز يتم نسخه من `assets` عند أول تشغيل.
- المنطق موجود في `DatabaseService`.
- **لتحديث البيانات**: استبدل ملف قاعدة البيانات في `assets/data/` وقم بتغيير رقم الإصدار في `DatabaseService` لإجبار التطبيق على إعادة النسخ (أو احذف التطبيق وأعد تثبيته أثناء التطوير).

## إدارة الحالة (State Management)
نستخدم **GetX**:
- **Controllers**: تحتوي على المنطق والمتغيرات التفاعلية (`.obs`).
- **Obx**: تُستخدم في الواجهة (`View`) للاستماع للتغييرات وإعادة بناء الويدجت تلقائياً.
- **Get.put() / Get.find()**: لحقن واستدعاء الكنترولرز.

## الاختبارات (Testing)
- **Unit Tests**: في مجلد `test/`.
- **Integration Tests**: في مجلد `integration_test/`.
- لتشغيل الاختبارات: `flutter test`

## بناء النسخة النهائية (Build & Release)
لإنشاء ملف APK للأندرويد:
```bash
flutter build apk --release
```
الملف الناتج سيكون في: `build/app/outputs/flutter-apk/app-release.apk`.
