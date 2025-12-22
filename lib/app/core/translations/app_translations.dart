import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'ar_SA': _arSA, 'en_US': _enUS};

  static const Map<String, String> _arSA = {
    // General
    'app_name': 'رتّل',
    'welcome': 'مرحباً',
    'home': 'الرئيسية',
    'settings': 'الإعدادات',
    'logout': 'تسجيل الخروج',
    'save': 'حفظ',
    'cancel': 'إلغاء',
    'confirm': 'تأكيد',
    'delete': 'حذف',
    'edit': 'تعديل',
    'search': 'بحث',
    'loading': 'جاري التحميل...',
    'error': 'خطأ',
    'success': 'تم بنجاح',

    // Auth
    'login': 'تسجيل الدخول',
    'register': 'إنشاء حساب',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'name': 'الاسم',
    'student': 'طالب',
    'teacher': 'معلم',
    'select_role': 'اختر نوع الحساب',
    'already_have_account': 'لديك حساب؟',
    'no_account': 'ليس لديك حساب؟',
    'login_success': 'تم تسجيل الدخول بنجاح',
    'register_success': 'تم إنشاء الحساب بنجاح',
    'invalid_credentials': 'بيانات الدخول غير صحيحة',
    'email_already_exists': 'البريد الإلكتروني مستخدم مسبقاً',

    // Quran
    'quran': 'القرآن الكريم',
    'surah': 'سورة',
    'ayah': 'آية',
    'juz': 'جزء',
    'page': 'صفحة',
    'memorization': 'حفظ',
    'revision': 'مراجعة',
    'start_memorization': 'ابدأ الحفظ',
    'start_revision': 'ابدأ المراجعة',
    'from_ayah': 'من آية',
    'to_ayah': 'إلى آية',
    'select_surah': 'اختر السورة',
    'no_quran_data': 'لا توجد بيانات للقرآن',
    'download_quran': 'تحميل بيانات القرآن',
    'downloading': 'جاري التحميل...',

    // Progress
    'progress': 'التقدم',
    'statistics': 'الإحصائيات',
    'total_verses': 'إجمالي الآيات',
    'memorized_verses': 'الآيات المحفوظة',
    'current_streak': 'أيام متتالية',
    'badges': 'الشارات',
    'achievements': 'الإنجازات',
    'activity': 'النشاط',

    // Teacher
    'students': 'الطلاب',
    'evaluations': 'التقييمات',
    'add_evaluation': 'إضافة تقييم',
    'score': 'الدرجة',
    'notes': 'ملاحظات',
    'excellent': 'ممتاز',
    'good': 'جيد',
    'needs_improvement': 'يحتاج تحسين',

    // Settings
    'language': 'اللغة',
    'theme': 'المظهر',
    'dark_mode': 'الوضع الداكن',
    'light_mode': 'الوضع الفاتح',
    'notifications': 'الإشعارات',
    'daily_reminder': 'تذكير يومي',
    'reading_mode': 'وضع القراءة',
    'font_size': 'حجم الخط',
    'account': 'الحساب',
    'delete_account': 'حذف الحساب',

    // Notifications
    'notification_daily_title': 'وقت القرآن 📖',
    'notification_daily_body': 'حان وقت مراجعة حفظك اليوم!',
  };

  static const Map<String, String> _enUS = {
    // General
    'app_name': 'Rattel',
    'welcome': 'Welcome',
    'home': 'Home',
    'settings': 'Settings',
    'logout': 'Logout',
    'save': 'Save',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'delete': 'Delete',
    'edit': 'Edit',
    'search': 'Search',
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',

    // Auth
    'login': 'Login',
    'register': 'Register',
    'email': 'Email',
    'password': 'Password',
    'name': 'Name',
    'student': 'Student',
    'teacher': 'Teacher',
    'select_role': 'Select Account Type',
    'already_have_account': 'Already have an account?',
    'no_account': "Don't have an account?",
    'login_success': 'Login successful',
    'register_success': 'Registration successful',
    'invalid_credentials': 'Invalid credentials',
    'email_already_exists': 'Email already exists',

    // Quran
    'quran': 'Holy Quran',
    'surah': 'Surah',
    'ayah': 'Ayah',
    'juz': 'Juz',
    'page': 'Page',
    'memorization': 'Memorization',
    'revision': 'Revision',
    'start_memorization': 'Start Memorization',
    'start_revision': 'Start Revision',
    'from_ayah': 'From Ayah',
    'to_ayah': 'To Ayah',
    'select_surah': 'Select Surah',
    'no_quran_data': 'No Quran data found',
    'download_quran': 'Download Quran Data',
    'downloading': 'Downloading...',

    // Progress
    'progress': 'Progress',
    'statistics': 'Statistics',
    'total_verses': 'Total Verses',
    'memorized_verses': 'Memorized Verses',
    'current_streak': 'Current Streak',
    'badges': 'Badges',
    'achievements': 'Achievements',
    'activity': 'Activity',

    // Teacher
    'students': 'Students',
    'evaluations': 'Evaluations',
    'add_evaluation': 'Add Evaluation',
    'score': 'Score',
    'notes': 'Notes',
    'excellent': 'Excellent',
    'good': 'Good',
    'needs_improvement': 'Needs Improvement',

    // Settings
    'language': 'Language',
    'theme': 'Theme',
    'dark_mode': 'Dark Mode',
    'light_mode': 'Light Mode',
    'notifications': 'Notifications',
    'daily_reminder': 'Daily Reminder',
    'reading_mode': 'Reading Mode',
    'font_size': 'Font Size',
    'account': 'Account',
    'delete_account': 'Delete Account',

    // Notifications
    'notification_daily_title': 'Quran Time 📖',
    'notification_daily_body': "It's time to review your memorization!",
  };
}
