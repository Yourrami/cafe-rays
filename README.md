# Café Rays — تطبيق إدارة المبيعات

تطبيق Flutter عربي كامل لإدارة المبيعات اليومية لمحل قهوة عائلي.

## هيكل المشروع

```
cafe_rays/
├── lib/
│   ├── main.dart                    # نقطة الدخول + إعداد RTL + الـ locale
│   ├── models/
│   │   ├── category.dart            # نموذج الفئة
│   │   ├── product.dart             # نموذج المنتج
│   │   ├── sale.dart                # نماذج SaleItem و SaleSession و CartItem
│   │   └── settings.dart            # إعدادات التطبيق
│   ├── services/
│   │   ├── database_service.dart    # SQLite + seed data كامل
│   │   ├── sales_provider.dart      # Provider state management
│   │   └── pdf_service.dart         # توليد PDF عربي
│   ├── screens/
│   │   ├── splash_screen.dart       # شاشة البداية
│   │   ├── home_screen.dart         # الشاشة الرئيسية + Bottom Navigation
│   │   ├── sales_screen.dart        # شاشة البيع السريع
│   │   ├── summary_screen.dart      # ملخص اليوم
│   │   ├── history_screen.dart      # السجل اليومي
│   │   ├── manage_categories_screen.dart  # إدارة الفئات
│   │   ├── manage_products_screen.dart    # إدارة الأنواع/المنتجات
│   │   ├── add_edit_product_screen.dart   # إضافة/تعديل منتج
│   │   └── settings_screen.dart     # الإعدادات
│   ├── widgets/
│   │   ├── product_card.dart        # بطاقة المنتج مع أزرار +/-
│   │   ├── category_tab.dart        # تبويبات الفئات
│   │   └── confirm_bottom_bar.dart  # شريط تأكيد البيع
│   └── utils/
│       ├── theme.dart               # الثيم والألوان (بني قهوة + كريمي)
│       └── helpers.dart             # دوال مساعدة (formatPrice, formatDate...)
├── android/
│   └── app/src/main/AndroidManifest.xml
└── pubspec.yaml
```

## خطوات التثبيت والتشغيل

### 1. المتطلبات الأساسية
- Flutter SDK >= 3.10.0
- Android Studio أو VS Code
- Java JDK 17+

### 2. تثبيت Flutter
```bash
# تحقق من الإصدار
flutter --version

# إصلاح أي مشاكل
flutter doctor
```

### 3. تثبيت المشروع
```bash
# انتقل إلى مجلد المشروع
cd cafe_rays

# ثبّت الحزم
flutter pub get
```

### 4. تشغيل التطبيق (وضع التطوير)
```bash
# تشغيل على متصفح أو محاكي
flutter run

# تشغيل على جهاز Android متصل
flutter run -d android
```

### 5. بناء APK للإنتاج
```bash
# بناء APK (debug - للاختبار)
flutter build apk --debug

# بناء APK (release - للإنتاج)
flutter build apk --release

# بناء APK Split per ABI (أحجام أصغر)
flutter build apk --split-per-abi --release
```

APK يوجد في: `build/app/outputs/flutter-apk/`

### 6. توقيع APK للنشر (اختياري)
```bash
# إنشاء keystore
keytool -genkey -v -keystore cafe_rays.keystore -alias cafe_rays -keyalg RSA -keysize 2048 -validity 10000

# أضف إلى android/key.properties:
# storePassword=<كلمة المرور>
# keyPassword=<كلمة المرور>
# keyAlias=cafe_rays
# storeFile=../../cafe_rays.keystore
```

## الميزات الكاملة

### ✅ شاشة البيع السريع
- تبويبات الفئات مع تمييز واضح
- بطاقات المنتجات بأزرار كبيرة + و -
- شريط مجموع وتأكيد ثابت في الأسفل
- ردود فعل فورية عند كل نقرة

### ✅ البيانات الأولية (Seed Data)
- فئة "قهوة" مع 9 منتجات بالأسماء والأسعار المحددة
- فئتا "قهوة مطحونة" و"الشاي" و"العسل" مع أمثلة

### ✅ الفئات الديناميكية
- إضافة/تعديل/حذف أنواع
- دعم الوحدات (كيلوغرام، غرام، قطعة...)
- إدخال يدوي للكميات

### ✅ ملخص اليوم
- تقسيم بالفئات والمنتجات
- المجاميع الفرعية والكلية
- تصفية بالتاريخ

### ✅ تصدير PDF
- PDF عربي بخط Cairo
- RTL layout
- تقسيم بالفئات

### ✅ إدارة المنتجات
- حذف آمن مع تراجع (Snackbar)
- تفعيل/إخفاء بدون حذف
- إعادة ترتيب بالسحب

### ✅ الإعدادات
- اسم المحل
- رمز PIN
- إدارة الفئات والمنتجات

## الحزم المستخدمة
| الحزمة | الوظيفة |
|--------|---------|
| sqflite | قاعدة البيانات المحلية SQLite |
| provider | إدارة الحالة |
| pdf + printing | توليد PDF عربي |
| google_fonts | خط Cairo العربي |
| intl | التواريخ والأرقام |
| share_plus | مشاركة الملفات |
