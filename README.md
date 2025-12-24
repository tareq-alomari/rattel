<div align="center">

![Rattel Logo](assets/images/logo.png)

# رتّل | Rattel

**تطبيق متكامل لتعليم وتحفيظ القرآن الكريم مع أدوات متابعة ذكية للمعلمين**

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev/)
[![GetX](https://img.shields.io/badge/State_Management-GetX-purple)]()
[![License](https://img.shields.io/badge/License-Waqf-green)]()

---

### 🕌 صَدَقَةٌ جَارِيَةٌ 🕌

**عن أبي هريرة رضي الله عنه أن رسول الله ﷺ قال:**
> "إذا مات ابن آدم انقطع عمله إلا من ثلاث: صدقة جارية، أو علم ينتفع به، أو ولد صالح يدعو له"

### 🤲 إهداء الثواب 🤲

**عن روح المغفور له بإذن الله**

# م. طارق العمري

*رحمه الله وغفر له وأسكنه فسيح جناته*

---

</div>

<br>

<div align="right" dir="rtl">

# 📖 دليل المستخدم (User Guide)

مرحباً بك في تطبيق "رتل". صُمم هذا التطبيق ليجمع بين جمالية المصحف الورقي وذكاء التقنية الحديثة، ليساعدك في رحلة حفظ كتاب الله.

## 🌟 المميزات الرئيسية

### 🎓 للطالب (Student)

1. **المصحف التفاعلي:**
    * عرض القرآن الكريم بخط عثماني واضح وعالي الجودة.
    * إمكانية البحث السريع عن أي سورة أو آية.
    * دعم الوضع الليلي (Dark Mode) لراحة العين.
  
2. **أدوات الحفظ والمراجعة:**
    * **سجل الحفظ:** قم بتحديد الآيات التي حفظتها يومياً لتتبع إنجازك.
    * **الأوسمة (Badges):** احصل على شارات تشجيعية (مثل "حارس الفاتحة"، "المثابر") عند تحقيق أهدافك.
    * **الاستمرارية (Streak):** حافظ على سلسلة أيام الحفظ المتتالية لتبقى متحفزاً.

3. **المكتبة الإسلامية:**
    * **الأذكار:** حصن نفسك بأذكار الصباح والمساء، أذكار الصلاة، والنوم.
    * **التجويد:** تعلم أحكام التجويد (النون الساكنة، المدود، المخارج) بشرح مبسط وأمثلة.

### 👨‍🏫 للمعلم (Teacher)

1. **لوحة القيادة (Dashboard):**
    * نظرة شاملة على عدد الطلاب المسجلين والأنشطة الحديثة.
    * إحصائيات حول التقييمات المعلقة.

2. **إدارة الفصل:**
    * قائمة بجميع الطلاب مع نسبة تقدم كل طالب.
    * الاطلاع على سجل حفظ الطالب وتفاصيله.

3. **نظام التقييم:**
    * إضافة تقييمات (ممتاز، جيد، يحتاج تحسين) لتسميع الطلاب.
    * كتابة ملاحظات خاصة وتوجيهات للطالب.

---

<br>

# 🛠️ دليل المطورين (Developer Guide)

هذا القسم موجه للمبرمجين والمساهمين في تطوير مشروع "رتل".

## 🏗️ التقنيات المستخدمة (Tech Stack)

* **Framework:** [Flutter](https://flutter.dev/) (Cross-platform UI toolkit).
* **Language:** [Dart](https://dart.dev/).
* **State Management:** [GetX](https://pub.dev/packages/get) (لإدارة الحالة، التوجيه، وحقن التبعيات).
* **Database:**
  * [sqflite](https://pub.dev/packages/sqflite) (للهواتف).
  * [sqflite_common_ffi](https://pub.dev/packages/sqflite_common_ffi) (لأنظمة سطح المكتب Windows/Linux/macOS).
* **Security:** `crypto` package لتشفير كلمات المرور (Hashing SHA-256).
* **Localization:** دعم كامل لتعدد اللغات (`ar`, `en`).

## ⚙️ متطلبات التشغيل (Prerequisites)

* **Flutter SDK:** الإصدار 3.10.0 أو أحدث.
* **Dart SDK:** متوافق مع نسخة Flutter.
* **IDE:** VS Code (موصى به) أو Android Studio.
* **Visual Studio C++ Compiler:** (مطلوب فقط عند التشغيل على Windows).

## 🚀 التثبيت والتشغيل (Installation)

1. **استنساخ المستودع (Clone):**

    ```bash
    git clone https://github.com/your-username/rattel.git
    cd rattel
    ```

2. **تثبيت التبعيات (Dependencies):**

    ```bash
    flutter pub get
    ```

3. **تشغيل التطبيق (Run):**

    ```bash
    # للتشغيل على سطح المكتب (Windows)
    flutter run -d windows
    
    # للتشغيل على الأندرويد أو iOS
    flutter run
    ```

    > **ملاحظة:** عند التشغيل لأول مرة، سيقوم التطبيق بتهيئة قاعدة البيانات (`rattel.db`) وملؤها ببيانات الأذكار والتجويد الافتراضية.

## 📂 هيكلية المشروع (Project Architecture)

نتبع نمط **MVVM** المحسن باستخدام GetX Pattern:

```
lib/
├── app/
│   ├── modules/            # (Views + Controllers + Bindings) - كل ميزة في مجلد منفصل
│   │   ├── auth/           # تسجيل الدخول
│   │   ├── student/        # ميزات الطالب
│   │   └── ...
│   ├── data/               # طبقة البيانات
│   │   ├── models/         # نماذج البيانات (PODOs)
│   │   ├── providers/      # مزودو البيانات (API / Database Clients)
│   │   └── services/       # الخدمات العامة (Global Services)
│   ├── core/               # (Themes, Translations, Utils)
│   └── routes/             # تعريف الصفحات والروابط
└── main.dart               # نقطة البداية
```

## 💾 مخطط قاعدة البيانات (Database Schema)

* **`users`**: تخزين بيانات المستخدمين والأدوار.
* **`quran`**: نص المصحف، رقم السورة، الآية، الصفحة.
* **`memorization`**: جدول الربط لتتبع حفظ الآيات.
* **`badges`**: تعريف الأوسمة وشروط الحصول عليها.
* **`tajweed_rules`**: محتوى دروس التجويد.
* **`duas`**: نصوص الأذكار.

---

</div>

<div align="center">

### 🤝 المساهمة (Contributing)

نرحب بمساهماتكم لتطوير هذا العمل الخيري. يرجى فتح [Issue] للإبلاغ عن المشاكل أو [Pull Request] للمساهمة بالكود.

<br>

**رَتِّلِ الْقُرْآنَ تَرْتِيلًا**

</div>
