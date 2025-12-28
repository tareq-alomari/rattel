# توثيق شامل للشفرة المصدرية (Arabic Documentation)

هذا المستند يضم توثيقًا مفصَّلًا لجميع ملفات Dart في مشروع **Rattel**. لكل ملف يتم توفير:
- رابط مباشر إلى الملف داخل المستودع.
- وصف مختصر للغرض من الملف.
- شرح للصفوف (Classes) والوظائف (Methods) الرئيسية.

---

## 1. `app/core/theme/app_theme.dart`
[app_theme.dart](file:///c:/projects/apps/rattel/lib/app/core/theme/app_theme.dart)

**الوصف:** تعريف سمة (Theme) التطبيق العامة، تشمل ألوان الخلفية، الخطوط، وأنماط الواجهة.

**المكونات الرئيسية:**
- `AppTheme` : فئة تحتوي على إعدادات الألوان والأنماط.

---

## 2. `app/core/theme/quran_theme.dart`
[quran_theme.dart](file:///c:/projects/apps/rattel/lib/app/core/theme/quran_theme.dart)

**الوصف:** سمة مخصصة لعرض القرآن، تشمل ألوان النصوص وتنسيق الآيات.

---

## 3. `app/core/translations/app_translations.dart`
[app_translations.dart](file:///c:/projects/apps/rattel/lib/app/core/translations/app_translations.dart)

**الوصف:** ملفات الترجمة للواجهة (عربي/إنجليزي) باستخدام مكتبة `GetX`.

---

## 4. `app/core/widgets/app_drawer.dart`
[app_drawer.dart](file:///c:/projects/apps/rattel/lib/app/core/widgets/app_drawer.dart)

**الوصف:** قائمة جانبية (Drawer) للتنقل بين أقسام التطبيق.

---

## 5. `app/core/widgets/custom_widgets.dart`
[custom_widgets.dart](file:///c:/projects/apps/rattel/lib/app/core/widgets/custom_widgets.dart)

**الوصف:** مجموعة من الودجات المخصصة (Custom Widgets) التي تُستخدم في شاشات متعددة.

---

## 6. `app/data/models/athan_model.dart`
[athan_model.dart](file:///c:/projects/apps/rattel/lib/app/data/models/athan_model.dart)

**الوصف:** نموذج بيانات يمثل الأذان، يحتوي على الحقول `id`, `title`, `audioUrl` وغيرها.

---

## 7. `app/data/models/reciter_model.dart`
[reciter_model.dart](file:///c:/projects/apps/rattel/lib/app/data/models/reciter_model.dart)

**الوصف:** نموذج بيانات للمقرئ (Reciter) مع خصائص `id`, `name`, `arabicName`.

---

## 8. `app/data/services/audio_service.dart`
[audio_service.dart](file:///c:/projects/apps/rattel/lib/app/data/services/audio_service.dart)

**الوصف:** خدمة تشغيل الصوت باستخدام مكتبة `just_audio`. تدير حالة التشغيل، السرعة، وضعية التكرار، وتوفر وظائف لتشغيل/إيقاف/إعادة تشغيل ملفات الصوت.

**الوظائف الرئيسية:**
- `playAyah(int surah, int ayah)` : تشغيل آية معينة.
- `playUrl(String url)` : تشغيل ملف صوتي من رابط مباشر (مستخدم في تشغيل الأذان).
- `changeReciter(String reciterId)` : تغيير المقرئ الحالي.
- `setPlaybackSpeed(double speed)` : تعديل سرعة التشغيل.
- `setRepeatMode(RepeatMode mode)` : ضبط وضعية التكرار (لا شيء، آية، نطاق).

---

## 9. `app/modules/athan/controllers/athan_controller.dart`
[athan_controller.dart](file:///c:/projects/apps/rattel/lib/app/modules/athan/controllers/athan_controller.dart)

**الوصف:** المتحكم (Controller) الخاص بصفحة الأذان. يتحكم في جلب قائمة الأذان من الخدمة، وإدارة حالة التحميل، وتشغيل/إيقاف الأذان.

**الخصائص:**
- `RxList<Athan> athans` : قائمة الأذان المتاحة.
- `RxBool isLoading` : حالة التحميل.
- `RxString selectedMuezzin` : المأذون المختار (غير مستخدم حاليًا).
- `RxString currentAthanId` : معرف الأذان المشغل حاليًا.
- `RxBool isPlaying` : حالة تشغيل الأذان.

**الوظائف الرئيسية:**
- `loadAthans()` : جلب الأذان من `AlFurqanService`.
- `playAthan(Athan athan)` : تشغيل الأذان عبر `AudioService.playUrl`.
- `pauseAthan()` / `stopAthan()` : إيقاف/إيقاف مؤقت.

---

## 10. `app/modules/athan/views/athan_view.dart`
[athan_view.dart](file:///c:/projects/apps/rattel/lib/app/modules/athan/views/athan_view.dart)

**الوصف:** واجهة المستخدم لعرض قائمة الأذان. تستخدم `GetBuilder` أو `Obx` لربط الحالة مع الواجهة، وتظهر زر تشغيل/إيقاف لكل أذان.

---

## 11. `app/modules/auth/controllers/auth_controller.dart`
[auth_controller.dart](file:///c:/projects/apps/rattel/lib/app/modules/auth/controllers/auth_controller.dart)

**الوصف:** متحكم المصادقة، يدير تسجيل الدخول، التسجيل، وتخزين حالة المستخدم.

---

## 12. `app/modules/auth/views/login_view.dart`
[login_view.dart](file:///c:/projects/apps/rattel/lib/app/modules/auth/views/login_view.dart)

**الوصف:** شاشة تسجيل الدخول مع حقول البريد الإلكتروني وكلمة المرور.

---

## 13. `app/modules/auth/views/register_view.dart`
[register_view.dart](file:///c:/projects/apps/rattel/lib/app/modules/auth/views/register_view.dart)

**الوصف:** شاشة التسجيل للمستخدمين الجدد.

---

## 14. `app/data/services/al_furqan_service.dart`
[al_furqan_service.dart](file:///c:/projects/apps/rattel/lib/app/data/services/al_furqan_service.dart)

**الوصف:** خدمة تتواصل مع API `AlFurqan` لجلب القرآن، الأذان، المقرئين، وغيرها من البيانات.

---

## 15. `app/data/models/quran_models.dart`
[quran_models.dart](file:///c:/projects/apps/rattel/lib/app/data/models/quran_models.dart)

**الوصف:** نماذج البيانات للقرآن (Surah, Ayah, Tafseer).

---

*(المزيد من الملفات موجود في المشروع، يمكن توسيع الوثيقة بإضافة أقسام مماثلة لكل ملف.)*

---

**ملحوظة:** تم إنشاء هذا المستند في مسار `docs/documentation_ar.md`. يمكن فتحه في أي محرر نصوص لقراءة الشرح الكامل أو تعديل التفاصيل حسب الحاجة.
