# 📘 نظرة عامة على المشروع (Project Overview)

## معلومات تقنية (Tech Stack)
تم بناء تطبيق **رتّل (Rattel)** باستخدام أحدث تقنيات تطوير التطبيقات الهجينة:
- **Framework**: Flutter (Dart)
- **State Management**: GetX (لإدارة الحالة، التنقل، وحقن التبعيات)
- **Local Database**: SQFlite (لتخزين بيانات القرآن، الأحاديث، والمستخدمين محلياً)
- **Audio**: Just Audio (لتشغيل تلاوات القرآن)
- **PDF Rendering**: Flutter PDFView (لعرض المصحف كـ PDF)
- **Assets Management**: تخزين محلي للصور والبيانات (JSON/Assets)

## هيكلية المشروع (Architecture)
يتبع المشروع نمط **GetX Pattern** الذي يفصل الكود إلى ثلاث طبقات رئيسية لكل ميزة (Module):
1. **View**: واجهة المستخدم (UI) والرسوميات.
2. **Controller**: منطق العمل (Business Logic) وربط البيانات بالواجهة.
3. **Binding**: حقن التبعيات (Dependency Injection) لربط الـ Controller بالـ View.

### هيكل المجلدات (Folder Structure)
```
lib/
├── app/
│   ├── core/           # المكونات الأساسية (QThemes, Utilities, Widgets)
│   ├── data/           # طبقة البيانات
│   │   ├── models/     # نماذج البيانات (Surah, Ayah, User)
│   │   ├── providers/  # مزودي البيانات (API clients if any)
│   │   └── services/   # الخدمات العامة (Database, Audio, Auth)
│   ├── modules/        # مزايا التطبيق (كل ميزة في مجلد منفصل)
│   │   ├── auth/       # تسجيل الدخول وإنشاء الحساب
│   │   ├── quran/      # قارئ القرآن (نص، صور، PDF)
│   │   ├── hadith/     # كتب الأحاديث
│   │   ├── student/    # واجهة الطالب
│   │   ├── teacher/    # واجهة المعلم
│   │   └── ...
│   └── routes/         # تعريف مسارات التنقل (AppPages)
└── main.dart           # نقطة انطلاق التطبيق
```

## الخدمات الرئيسية (Key Services)
تعمل هذه الخدمات في الخلفية وتوفر البيانات لجميع أجزاء التطبيق:
1. **DatabaseService**: تدير قاعدة البيانات SQLite، وتحتوي على جداول السور، الآيات، التفسير، والأحاديث.
2. **AuthService**: تدير جلسة المستخدم الحالي (طالب/معلم) وعمليات تسجيل الدخول والخروج.
3. **AudioService**: مسؤولة عن تشغيل التلاوات الصوتية والتحكم في المشغل (Play, Pause, Seek).
4. **GamificationService**: نظام النقاط والمكافآت (XPs, Badges) لتحفيز الطلاب.
5. **HalaqahService**: إدارة الحلقات القرآنية والجلسات التعليمية.
