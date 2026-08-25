import 'package:flutter/material.dart' as material;

extension LocalizedInterfaceText on material.BuildContext {
  String translateInterface(String source) {
    return material.Localizations.localeOf(this).languageCode == 'en'
        ? EnglishInterfaceTranslations.translate(source)
        : source;
  }
}

/// Drop-in localized replacement for Flutter's [material.Text].
///
/// Arabic remains the source language of the project. When the active locale
/// is English, known interface phrases are translated while user-generated
/// names and media titles remain untouched.
class Text extends material.StatelessWidget {
  const Text(
    String this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : textSpan = null;

  const Text.rich(
    material.InlineSpan this.textSpan, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : data = null;

  final String? data;
  final material.InlineSpan? textSpan;
  final material.TextStyle? style;
  final material.StrutStyle? strutStyle;
  final material.TextAlign? textAlign;
  final material.TextDirection? textDirection;
  final material.Locale? locale;
  final bool? softWrap;
  final material.TextOverflow? overflow;
  final material.TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final material.TextWidthBasis? textWidthBasis;
  final material.TextHeightBehavior? textHeightBehavior;
  final material.Color? selectionColor;

  @override
  material.Widget build(material.BuildContext context) {
    final english =
        material.Localizations.localeOf(context).languageCode == 'en';
    final translatedSemantics = english && semanticsLabel != null
        ? EnglishInterfaceTranslations.translate(semanticsLabel!)
        : semanticsLabel;

    if (textSpan != null) {
      return material.Text.rich(
        english ? _translateInlineSpan(textSpan!) : textSpan!,
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaler: textScaler,
        maxLines: maxLines,
        semanticsLabel: translatedSemantics,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );
    }

    final value = english
        ? EnglishInterfaceTranslations.translate(data!)
        : data!;
    return material.Text(
      value,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: translatedSemantics,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }

  material.InlineSpan _translateInlineSpan(material.InlineSpan span) {
    if (span is! material.TextSpan) return span;

    return material.TextSpan(
      text: span.text == null
          ? null
          : EnglishInterfaceTranslations.translate(span.text!),
      children: span.children
          ?.map(_translateInlineSpan)
          .toList(growable: false),
      style: span.style,
      recognizer: span.recognizer,
      mouseCursor: span.mouseCursor,
      onEnter: span.onEnter,
      onExit: span.onExit,
      semanticsLabel: span.semanticsLabel == null
          ? null
          : EnglishInterfaceTranslations.translate(span.semanticsLabel!),
      locale: span.locale,
      spellOut: span.spellOut,
    );
  }
}

abstract final class EnglishInterfaceTranslations {
  static const Map<String, String> _values = {
    // Global navigation
    'عودة': 'Back',
    'العودة': 'Back',
    'الإشعارات': 'Notifications',
    'الرئيسية': 'Home',
    'المكتبة': 'Library',
    'مكتبتي': 'My Library',
    'المزيد': 'More',
    'البحث': 'Search',
    'إذاعات FM': 'FM Radio',
    'برامج FM': 'FM Programs',
    'برامج إذاعة ألوان FM': 'Alwan FM Programs',
    'ألوان FM': 'Alwan FM',
    'ألوان تنبض بالحياة': 'Alwan pulses with life',
    'مزيج من البرامج الهادفة\nلإثراء يومك بكل ألوان الفائدة والمتعة':
        'A thoughtful mix of programs\nto enrich every part of your day',
    'مواعيد البث': 'Broadcast times',
    'بيانات البرنامج': 'Program details',
    'صورة البرنامج': 'Program image',
    'مواعيد الإعادة': 'Replay times',
    'حفظ': 'Save',
    'إلغاء': 'Cancel',
    'التالي': 'Next',
    'تم': 'Done',
    'إعلان': 'Ad',
    'بنر إعلاني': 'Advertising banner',
    'بنر إعلاني بمقاس 400 في 200': '400 × 200 advertising banner',

    // Home
    'صباحكم ألوان': 'A colorful morning',
    'البث المباشر': 'Live broadcast',
    'مباشر الآن': 'Live now',
    'مباشر': 'Live',
    'استمع الآن': 'Listen now',
    'استمع للبث المباشر': 'Listen live',
    'الوصول السريع': 'Quick access',
    'استراحة ألوان': 'Alwan Lounge',
    'بودكاست ألوان': 'Alwan Podcasts',
    'الكتب الصوتية': 'Audiobooks',
    'المفضلة': 'Favorites',
    'ألعاب ومسابقات': 'Games & Contests',
    'مسابقات وألعاب': 'Contests & Games',
    'شارك ودردش': 'Share & Chat',
    'شارك ودردش الآن': 'Share and chat now',
    'مشاركة البرنامج': 'Share program',
    'رابط البث غير متوفر حالياً.': 'The stream link is currently unavailable.',

    // Profile
    'الملف الشخصي': 'Profile',
    'تعديل الملف': 'Edit profile',
    'تعديل الملف الشخصي': 'Edit profile',
    'بيانات الحساب الشخصي': 'Personal account details',
    'الاسم': 'Name',
    'البريد الإلكتروني': 'Email address',
    'المدينة والدولة': 'City and country',
    'نبذة مختصرة': 'Short bio',
    'حفظ وتأكيد التغييرات': 'Save changes',
    'الإشعارات والتحديثات': 'Notifications & updates',
    'تابع أحدث التنبيهات والعروض وبث البرامج المباشرة':
        'Follow the latest alerts, offers, and live programs',
    'منبه الصلاة وتحديد القبلة': 'Prayer alarm & Qibla',
    'مواقيت الصلوات والنغمة وبوصلة اتجاه القبلة':
        'Prayer times, reminder sound, and Qibla compass',
    'اللغة لتصفح التطبيق': 'App language',
    'جودة البث المناسبة لك': 'Streaming quality',
    'المظهر': 'Appearance',
    'تقييم التطبيق': 'Rate the app',
    'مشاركة التطبيق': 'Share the app',
    'شاركنا رأيك واقترح علينا كيف نتحسن':
        'Share your feedback and help us improve',
    'شارك التطبيق مع أصدقائك عبر وسائل التواصل':
        'Share the app with friends on social media',
    'تلقائي حسب الجهاز': 'Automatic based on device',
    'نهاري': 'Light',
    'ليلي': 'Dark',
    'عالية': 'High',
    'متوسطة': 'Medium',
    'منخفضة': 'Low',
    '🟡 رصيد نقاط الألعاب والجوائز اليومي للفن اليماني':
        '🟡 Daily games and rewards points balance',

    // Language
    'اللغة / Language': 'Language / اللغة',
    'تجربة عالمية تبدأ بلغتك': 'A global experience in your language',
    'اختر لغة التطبيق': 'Choose app language',
    'عروض مختارة لجمهور ألوان حول العالم':
        'Selected offers for Alwan audiences worldwide',
    'مرحبًا بك': 'Welcome',
    'قريبًا': 'Coming soon',
    'يمكنك تغيير لغة التطبيق لاحقًا من الملف الشخصي':
        'You can change the app language later from Profile',
    'تأكيد اللغة والرجوع': 'Confirm language and return',
    'جارٍ الحفظ...': 'Saving...',
    'خريطة العالم واللغات المتنوعة': 'World map and supported languages',

    // Appearance
    'اختر المظهر الذي يناسبك': 'Choose your preferred appearance',
    'صمّم تجربتك كما تحب': 'Design the experience you love',
    'عاين النتيجة قبل تطبيقها على كامل المنصة':
        'Preview the result before applying it',
    'تلقائي': 'Automatic',
    'حسب الجهاز': 'Uses device settings',
    'فاتح وواضح': 'Bright and clear',
    'داكن ومريح': 'Dark and comfortable',
    'وضوح عالٍ وألوان مشرقة للاستخدام نهارًا':
        'High clarity and bright colors for daytime use',
    'إضاءة منخفضة وراحة أكبر للعين ليلًا':
        'Lower light for greater comfort at night',
    'يتغير تلقائيًا ليتوافق مع إعدادات جهازك':
        'Changes automatically with your device settings',
    'حفظ المظهر والرجوع': 'Save appearance and return',
    'اختيارات مميزة تضيف لونًا جديدًا ليومك':
        'Curated choices that add color to your day',

    // Streaming quality
    'اختر جودة البث المناسبة لك': 'Choose your streaming quality',
    'اختر التجربة الأنسب لشبكتك': 'Choose what suits your network',
    'كلما زادت قوة الشبكة حصلت على صوت أكثر نقاءً':
        'A stronger network gives you clearer sound',
    'جودة فائقة': 'Premium quality',
    'أفضل نقاء للصوت': 'Best sound clarity',
    'جودة متوازنة': 'Balanced quality',
    'مثالية للاستخدام اليومي': 'Ideal for everyday listening',
    'جودة اقتصادية': 'Data saver',
    'استهلاك أقل للبيانات': 'Lower data usage',
    'شبكة 4G': '4G network',
    'شبكة ضعيفة': 'Weak network',
    'مساحة إعلانية لشركاء منصة ألوان': 'Advertising space for Alwan partners',

    // Share
    'شارك ألوان راديو مع من تحب': 'Share Alwan Radio with those you love',
    'دع أصدقاءك يكتشفون صوت اليمن ومحتواه الجميل':
        'Let friends discover Yemen sound and stories',
    'نسخ رابط التطبيق': 'Copy app link',
    'تم نسخ رابط التطبيق': 'App link copied',
    'تم نسخ رابط التطبيق إلى الحافظة': 'App link copied to clipboard',
    'مشاركة عبر': 'Share via',
    'واتساب': 'WhatsApp',
    'تيليجرام': 'Telegram',
    'إنستغرام': 'Instagram',
    'خيارات مشاركة أخرى': 'More sharing options',
    'اختر المنصة المناسبة': 'Choose a platform',
    'كل مشاركة تساعد صوت الفن اليمني على الوصول أبعد':
        'Every share helps Yemeni art reach farther',
    'عروض مختارة من شركاء منصة ألوان': 'Selected offers from Alwan partners',
    'شارك ألوان وانشر الفرح': 'Share Alwan and spread joy',

    // Rating
    '✨ تقييمك يعني لنا الكثير': '✨ Your rating means a lot to us',
    'تفاصيل التقييم': 'Rating details',
    'سرعة التطبيق': 'App speed',
    'تصميم وواجهة المستخدم': 'Design & user interface',
    'تنوع المحتوى': 'Content variety',
    'جودة البث': 'Streaming quality',
    'هل توصي بتطبيق ألوان لراديو؟': 'Would you recommend Alwan Radio?',
    'نعم': 'Yes',
    'إلى حد ما': 'Somewhat',
    'لا': 'No',
    'اكتب رأيك': 'Write your feedback',
    'شاركنا رأيك واقتراحاتك لتحسين التطبيق...':
        'Share your feedback and suggestions to improve the app...',
    'إرسال التقييم': 'Submit rating',
    'جارٍ الإرسال...': 'Submitting...',
    'رأيك يصنع تجربة ألوان': 'Your feedback shapes Alwan',
    'شكرًا لمشاركتنا رأيك': 'Thank you for your feedback',
    'يُستخدم تقييمك لتحسين التطبيق فقط':
        'Your rating is used only to improve the app',

    // Prayer and Qibla
    'مواقيتك واتجاه قبلتك في مكان واحد':
        'Prayer times and Qibla direction in one place',
    'أوقات الصلاة': 'Prayer times',
    'القبلة': 'Qibla',
    'طريقة تحديد المواقيت': 'Prayer time calculation',
    'تحديد يدوي': 'Manual adjustment',
    'تُحدّث المواقيت تلقائيًا حسب الموقع':
        'Prayer times update automatically by location',
    'اضغط على وقت أي صلاة لتعديله يدويًا':
        'Tap any prayer time to adjust it manually',
    'تنبيهات الصلوات الخمس': 'Five prayer reminders',
    'التذكير مفعّل': 'Reminder enabled',
    'التذكير متوقف': 'Reminder disabled',
    'نغمة تذكير الصلاة': 'Prayer reminder sound',
    'اختيار نغمة من الجهاز': 'Choose sound from device',
    'يمكنك اختيار أي ملف صوتي محفوظ في جهازك كنغمة للتذكير.':
        'Choose any audio file saved on your device as the reminder sound.',
    'بوصلة اتجاه القبلة': 'Qibla direction compass',
    'زاوية اتجاه القبلة': 'Qibla bearing',
    'تُفعّل حركة البوصلة على جهاز يدعم مستشعر الاتجاه':
        'Compass motion activates on devices with a direction sensor',
    'الرجوع لمواقيت الصلاة': 'Return to prayer times',
    'جارٍ فتح الملفات...': 'Opening files...',
    'تعذر فتح الملفات الصوتية على هذا الجهاز':
        'Audio files could not be opened on this device',
    'الفجر': 'Fajr',
    'الظهر': 'Dhuhr',
    'العصر': 'Asr',
    'المغرب': 'Maghrib',
    'العشاء': 'Isha',
    'نغمة الأذان الافتراضية': 'Default Adhan sound',
    'الأحد': 'Sunday',
    'الإثنين': 'Monday',
    'الثلاثاء': 'Tuesday',
    'الأربعاء': 'Wednesday',
    'الخميس': 'Thursday',
    'الجمعة': 'Friday',
    'السبت': 'Saturday',
    'يناير': 'January',
    'فبراير': 'February',
    'مارس': 'March',
    'أبريل': 'April',
    'مايو': 'May',
    'يونيو': 'June',
    'يوليو': 'July',
    'أغسطس': 'August',
    'سبتمبر': 'September',
    'أكتوبر': 'October',
    'نوفمبر': 'November',
    'ديسمبر': 'December',

    // More
    'كل تفاصيل منصة ألوان في مكان واحد': 'Everything about Alwan in one place',
    'اكتشف عالم ألوان': 'Discover the world of Alwan',
    'أخبارنا وفريقنا ورسالتنا وطرق التواصل معنا':
        'News, team, mission, and ways to reach us',
    'منذ انطلاقنا': 'Since launch',
    'تردد ألوان': 'Alwan frequency',
    'مستمع شهريًا': 'Monthly listeners',
    'استكشف ألوان': 'Explore Alwan',
    'الأخبار': 'News',
    'رائجة وفنية وثقافية ورياضية وعالمية':
        'Trending, arts, culture, sports, and world news',
    'فريق ألوان': 'Alwan team',
    'تعرف على صناع محتوى المنصة': 'Meet the people behind Alwan',
    'من نحن': 'About us',
    'رؤيتنا ورسالتنا وقيمنا': 'Our vision, mission, and values',
    'تواصل معنا': 'Contact us',
    'نحن هنا للاستماع إليك': 'We are here to listen',
    'عن التطبيق': 'About the app',
    'المنصة والشركة المطورة': 'The platform and developer',
    'رأيك يساعدنا على التطور': 'Your feedback helps us grow',
    'ابقَ قريبًا من ألوان': 'Stay close to Alwan',
    'انشر صوت الفن اليمني مع أصدقائك': 'Share Yemeni art with friends',
    'آخر تحديثات التطبيق': 'Latest app updates',
    'اطلع على التحسينات والميزات الجديدة': 'See improvements and new features',
    'منصة ألوان FM • الإصدار 1.0.0': 'Alwan FM • Version 1.0.0',
    'مصممة لأندرويد وآيفون والويب': 'Designed for Android, iPhone, and web',
    'اكتشف عروض شركاء منصة ألوان': 'Discover offers from Alwan partners',
    'التحسينات والميزات الجديدة في ألوان':
        'Improvements and new Alwan features',
    'الإصدار الحالي 1.0.0': 'Current version 1.0.0',
    'أنت تستخدم أحدث إصدار': 'You are using the latest version',
    'ما الجديد؟': 'What is new?',
    'واجهات أكثر وضوحًا': 'Clearer interfaces',
    'مواقيت الصلاة والقبلة': 'Prayer times & Qibla',
    'خيارات استماع وشكل أفضل': 'Better listening and appearance',
    'التقييم ومشاركة التطبيق': 'Rating and app sharing',
    'قادم قريبًا': 'Coming soon',
    '• دعم أوسع للغة الإنجليزية\n• تنزيل المحتوى للاستماع دون اتصال\n• اقتراحات مخصصة حسب اهتماماتك':
        '• Expanded English support\n• Offline content downloads\n• Personalized suggestions',
    'تحديث الملف الشخصي وقسم المزيد وتوحيد الألوان والخطوط لتجربة أسهل.':
        'Updated Profile and More with unified colors and typography.',
    'منبه مخصص للصلوات الخمس مع واجهة احترافية لتحديد اتجاه القبلة.':
        'Custom reminders for five prayers and a professional Qibla compass.',
    'تحسين جودة البث واللغة والمظهر لتناسب سرعة الشبكة وتفضيلاتك.':
        'Improved streaming, language, and appearance settings.',
    'واجهات جديدة لتقييم تجربتك ومشاركة تطبيق ألوان مع أصدقائك بسهولة.':
        'New screens for rating and sharing Alwan with friends.',
    'الأخبار الرائجة': 'Trending',
    'تابع أبرز الأخبار والموضوعات الأكثر تداولًا الآن':
        'Follow the top news and most discussed topics now',
    'استكشف الأخبار': 'Explore news',
    'الأبراج اليومية': 'Daily horoscopes',
    'اكتشف توقعات برجك في الحب والعمل والصحة اليوم':
        'Discover today’s love, work, and health forecast',
    'اعرف حظك اليوم': 'See today’s horoscope',
    'توقعات اليوم للأبراج الاثني عشر':
        'Today’s forecasts for all twelve zodiac signs',
    'رسالتك من النجوم اليوم': 'Your message from the stars today',
    'اختر برجك': 'Choose your sign',
    'اضغط على البرج لعرض توقعاته اليومية بالتفصيل':
        'Tap your sign to view its detailed daily forecast',
    'محتوى الأبراج ترفيهي عام ولا يمثل نصيحة علمية أو قرارًا شخصيًا.':
        'Horoscope content is general entertainment, not scientific or personal advice.',
    'الحب والعلاقات': 'Love & relationships',
    'العمل والمال': 'Work & money',
    'الصحة والطاقة': 'Health & energy',
    'نصيحة اليوم': 'Today’s advice',
    'رقم الحظ': 'Lucky number',
    'لون الحظ': 'Lucky color',
    'العنصر': 'Element',
    'المزاج': 'Mood',
    'الفترة': 'Date range',
    'برج الحمل': 'Aries',
    'برج الثور': 'Taurus',
    'برج الجوزاء': 'Gemini',
    'برج السرطان': 'Cancer',
    'برج الأسد': 'Leo',
    'برج العذراء': 'Virgo',
    'برج الميزان': 'Libra',
    'برج العقرب': 'Scorpio',
    'برج القوس': 'Sagittarius',
    'برج الجدي': 'Capricorn',
    'برج الدلو': 'Aquarius',
    'برج الحوت': 'Pisces',
    'الأخبار الفنية': 'Arts',
    'الأخبار الثقافية': 'Culture',
    'الأخبار الرياضية': 'Sports',
    'الأخبار العالمية': 'World',
    'آخر الأخبار والتحديثات من إذاعة ألوان':
        'Latest news and updates from Alwan Radio',
    'آخر الأخبار': 'Latest news',
    'الأبرز الآن': 'Featured now',
    'أخبار اليوم': 'Today news',
    'آخر تحديث': 'Last updated',
    'الأكثر قراءة': 'Most read',
    'اقرأ المزيد': 'Read more',
    'تعرف على أعضاء فريق ألوان الإبداعي': 'Meet the creative Alwan team',
    'إعلاميون ومبدعون وتقنيون يعملون بروح فريق واحد':
        'Media professionals, creatives, and technologists as one team',
    'صنّاع صوت ألوان': 'The people behind Alwan',
    'مقدم برامج': 'Presenter',
    'منتج محتوى': 'Content producer',
    'مذيعة': 'Presenter',
    'مهندس صوت': 'Sound engineer',
    'مدققة أخبار': 'News editor',
    'إعداد برامج': 'Program producer',
    'تعرف على إذاعة ألوان ورؤيتنا ورسالتنا':
        'Discover Alwan Radio, our vision, and mission',
    'عن ألوان': 'About Alwan',
    'رسالتنا': 'Our mission',
    'رؤيتنا': 'Our vision',
    'قيمنا': 'Our values',
    'الجودة': 'Quality',
    'المجتمع': 'Community',
    'الإبداع': 'Creativity',
    'المصداقية': 'Credibility',
    'نحن هنا للاستماع إليك، تواصل معنا الآن':
        'We are here to listen. Contact us now',
    'تابعنا على المنصات': 'Follow us',
    'اتصل بنا': 'Call us',
    'أرسل لنا رسالة': 'Send us a message',
    'رقم الجوال': 'Mobile number',
    'اكتب رسالتك هنا': 'Write your message here',
    'إرسال الرسالة': 'Send message',
    'جارٍ التجهيز...': 'Preparing...',
    'أدخل اسمك من فضلك': 'Please enter your name',
    'أدخل بريدك الإلكتروني': 'Please enter your email address',
    'البريد الإلكتروني غير صحيح': 'Enter a valid email address',
    'اكتب رسالة أوضح من فضلك': 'Please write a more detailed message',
    'تعرف على التطبيق والشركة المطورة للمنصة':
        'Learn about the app and its developer',
    'الشركة المطورة': 'Developer',
    'شركة تطوير المنصات الرقمية': 'Digital Platforms Development Company',
    'راسل فريق المنصة': 'Contact the platform team',
    'مواقع التواصل': 'Social media',

    // Notifications
    'كل ما يهمك في منصة ألوان': 'Everything that matters on Alwan',
    'إعدادات الإشعارات والتذكير': 'Notification & reminder settings',
    'إشعارات التطبيق وبث المسابقات': 'App and contest broadcast alerts',
    'مفعّل للحصول على تنبيه البث المباشر فورًا':
        'Enabled for instant live broadcast alerts',
    'وضع كتم وإيقاف الإزعاج المؤقت': 'Temporary mute and do not disturb',
    'تعطيل مؤقت للتنبيهات الصوتية المزعجة': 'Temporarily disable sound alerts',
    'الفترة الزمنية للهدوء': 'Quiet hours',
    'آخر الإشعارات': 'Latest notifications',
    'الكل': 'All',
    'غير مقروء': 'Unread',
    'تمت القراءة': 'Read',
    'تحديد الكل كمقروء': 'Mark all as read',
    'تم تحديد جميع الإشعارات كمقروءة': 'All notifications marked as read',
    'لا توجد إشعارات حالياً لهذه الفئة':
        'There are no notifications in this category',
    'مساحتك الإعلانية تصل إلى جمهور ألوان':
        'Your advertising reaches the Alwan audience',

    // Games
    'مسابقات وألعاب ألوان': 'Alwan Contests & Games',
    'حلبة التحدي المباشر وبث الإشعارات الجماعية':
        'Live challenges and group notifications',
    'مساعد ألوان': 'Alwan Assistant',
    'مساعد ألوان جاهز لخدمتك': 'Alwan Assistant is ready to help',
    'إعلان راعٍ': 'Sponsored ad',
    'تصفح الخدمات والحلول الرقمية': 'Explore digital services and solutions',
    'الألعاب والتسلية': 'Games & entertainment',
    'شارك، تحدَّ واربح مع ألوان': 'Play, compete, and win with Alwan',
    'تحديات وجوائز': 'Challenges & prizes',
    'مسابقات يومية ونقاط وجوائز مميزة':
        'Daily contests, points, and special prizes',
    'المسابقات': 'Contests',
    'مسابقات برامج الـ FM': 'FM program contests',
    'مسابقة سين جيم': 'Quiz contest',
    'المسابقة الثقافية': 'Culture contest',
    'مسابقات البث الإذاعي المباشر': 'Live radio contests',
    'التذكير': 'Reminder',
    'اتصل للمشاركة': 'Call to participate',
    'استمع للبث': 'Listen live',
    'طلب اشتراك بالبرنامج': 'Request program registration',
    'تفعيل التذكير': 'Enable reminder',
    'عرض التفاصيل': 'View details',
    'ذكرني': 'Remind me',
    'إغلاق': 'Close',
    'تعذر فتح تطبيق الاتصال على هذا الجهاز':
        'Unable to open the phone app on this device',
    'اختر أحد خطوط الاتصال الرسمية للانتقال إلى تطبيق الهاتف':
        'Choose an official line to continue in your phone app',
    'اتصل الآن': 'Call now',
    'تفاصيل وشروط المشاركة بالمسابقة':
        'Contest details and participation terms',
    'تفاصيل البرنامج': 'Program details',
    'رعاة البرنامج': 'Program sponsors',
    'الفئة المستهدفة': 'Target audience',
    'نوع الجائزة': 'Prize type',
    'موعد السحب': 'Draw date',
    'شروط المشاركة': 'Participation terms',
    'طريقة احتساب النقاط': 'How points are calculated',
    'للإجابة الصحيحة': 'Correct answer',
    'للإجابة الخاطئة': 'Wrong answer',
    'لمشاركة المسابقة': 'Sharing the contest',
    'اشترك الآن': 'Register now',
    'سيتم نشر الأسئلة قريباً': 'Questions will be published soon',
    'التسجيل في البرامج الإذاعية': 'Radio program registration',
    'سجّل بياناتك لدخول السحب والمشاركة المباشرة على الهواء':
        'Enter your details to join the draw and participate live on air',
    'الاسم الرباعي الكامل': 'Full four-part name',
    'رقم الهاتف': 'Phone number',
    'المحافظة': 'Governorate',
    'حدد المحافظة': 'Select governorate',
    'عدد المشاركين بالبرنامج': 'Number of participants',
    'مشاركة': 'Share',
    'مشترك نشط': 'Active participant',
    'تأكيد وإرسال طلب الاشتراك': 'Confirm and submit registration',
    'عدد المشاركين': 'Participants',
    'نقاطك الحالية': 'Your current points',
    'تمت المشاركة': 'Shared',
    'شارك للمكافأة': 'Share for a bonus',
    'إنهاء الأسئلة': 'Finish questions',
    'رائع!': 'Great!',
    'انتهت الأسئلة': 'Questions completed',
    'الرجوع إلى قائمة المسابقات': 'Return to contests',
    'ألعاب ألوان التفاعلية': 'Alwan interactive games',
    'اختر لعبتك، اجمع النقاط وتقدّم في لوحة الصدارة':
        'Choose a game, earn points, and climb the leaderboard',
    'لعبة مطابقة الذاكرة': 'Memory matching game',
    'طابق بطاقات الأيقونات المتشابهة بأقل عدد من الحركات':
        'Match identical icon cards in the fewest moves',
    'لعبة إكس أو التفاعلية': 'Interactive Tic-Tac-Toe',
    'تحدَّ الذكاء الاصطناعي أو صديقاً في اللعبة الشهيرة':
        'Challenge the AI or a friend in the classic game',
    'تخمين الكلمات والبرامج': 'Guess words and programs',
    'رتّب الأحرف لتخمين أسماء برامج ومذيعي ألوان':
        'Arrange letters to guess Alwan programs and presenters',
    'العودة إلى قائمة الألعاب': 'Back to games',
    'الحركات:': 'Moves:',
    'إعادة اللعب': 'Restart game',
    'العب مرة أخرى': 'Play again',
    'أحسنت! أكملت اللعبة': 'Well done! You completed the game',
    'دورك: X': 'Your turn: X',
    'يفكر المنافس...': 'Opponent is thinking...',
    'أحسنت، فزت!': 'Well done, you won!',
    'فاز المنافس هذه الجولة': 'The opponent won this round',
    'تعادل رائع!': 'Great draw!',
    'رتّب الأحرف واكتب الإجابة الصحيحة':
        'Arrange the letters and enter the correct answer',
    'اكتب الكلمة هنا': 'Enter the word here',
    'تحقق من الإجابة': 'Check answer',
    'حاول مرة أخرى': 'Try again',
    'دعوة تحدي اللعبة': 'Game challenge invitation',
    'إشعار جماعي للمتحدين': 'Group notification to challengers',
    'دردشة المتحدين المباشرة': 'Live challenger chat',
    'متصل الآن': 'Online now',
    'اكتب رسالة للتحدي...': 'Write a challenge message...',
    'إرسال رسالة نصية': 'Send text message',
    'تسجيل رسالة صوتية': 'Record voice message',
    'إيقاف وإرسال الرسالة الصوتية': 'Stop and send voice message',
    'اضغط للإرسال': 'Tap to send',
    'ابدأ اللعب': 'Start playing',
    'اختر مجال التحدي وابدأ مسابقة سين جيم':
        'Choose a challenge category and start',
    'ابدأ التحدي': 'Start challenge',
    'لوحة الصدارة': 'Leaderboard',
    'لوحة صدارة المتسابقين': 'Contestant leaderboard',
    'اختر مجال مسابقة سين جيم': 'Choose a Sin Jeem category',
    'أربعة مجالات معرفية، ونقاط فورية لكل إجابة':
        'Four knowledge categories with instant points for every answer',
    'المسابقة الثقافية العامة': 'General culture contest',
    'أسئلة عامة متنوعة وتحديات مفتوحة للجميع':
        'Varied general questions and challenges open to everyone',
    'التاريخ والجغرافيا': 'History & geography',
    'العلوم والطبيعة': 'Science & nature',
    'الدين واللغات': 'Religion & languages',
    'الفنون والرياضة': 'Arts & sports',
    'المعلومات العامة': 'General knowledge',
    'ابدأ التحدي الفردي': 'Start solo challenge',
    'بطل التحدي الحالي': 'Current challenge champion',
    'نقاطك في هذا التحدي': 'Your challenge points',
    'المشاركون في التحدي': 'Challenge participants',
    'دعوة التحدي': 'Challenge invitation',
    'اختر وسيلة إرسال دعوة التحدي:':
        'Choose how to send the challenge invitation:',
    'إشعار جماعي لكل المستخدمين': 'Group notification to all users',
    'تمت إضافة الإشعار الجماعي': 'Group notification queued',
    'إرسال رسالة SMS': 'Send SMS',
    'إرسال رسالة WhatsApp': 'Send WhatsApp message',
    'انتهى التحدي': 'Challenge completed',
    'عرض الترتيب': 'View ranking',
    'إنهاء التحدي': 'Finish challenge',
    'السؤال التالي': 'Next question',
    'أدب': 'Literature',
    'تاريخ': 'History',
    'جغرافيا': 'Geography',
    'علوم': 'Science',

    // Library
    'كل ما تحفظه من ألوان في مكان واحد': 'Everything you save from Alwan',
    'مساحتك الصوتية الخاصة': 'Your personal audio space',
    'تصنيفات مكتبتي': 'My Library categories',
    'اختر التصنيف لعرض الملفات المحفوظة بداخله':
        'Choose a category to view its saved files',
    'تسجيلاتك الصوتية': 'Your recordings',
    'إنشاء مجلد جديد': 'Create a new folder',
    'إنشاء مجلد': 'Create folder',
    'اسم المجلد': 'Folder name',
    'إنشاء': 'Create',
    'حذف': 'Delete',
    'تشغيل': 'Play',
    'مشاركة الملف': 'Share file',
    'نقل الملف': 'Move file',
    'حذف الملف': 'Delete file',
    'المجلد فارغ': 'Folder is empty',
    'لا توجد مجلدات حالياً': 'No folders yet',

    // Browse cards and lounge catalog
    'تواصل واستمتع': 'Connect and enjoy',
    'استمع للروايات': 'Listen to novels',
    'حلقات ممتعة': 'Enjoyable episodes',
    'أغاني وبرامج': 'Songs and programs',
    'اختياراتك المفضلة': 'Your favorite picks',
    'إستراحة ألوان': 'Alwan Lounge',
    'جديد إستراحة ألوان': 'New in Alwan Lounge',
    'حديقة صوتية ملونة .. تزهر بتفاعلكم':
        'A colorful sound garden that grows with your engagement',
    'ألبوم الصيف حصرياً\nبدون فواصل إعلانية':
        'Exclusive summer album\nwith no ad breaks',
    'استمع إلى أفضل المحتوى الصوتي في مكان واحد':
        'Listen to the best audio content in one place',
    'إعلان مميز': 'Featured ad',
    'استمع إلى أحدث البرامج والبودكاست على مدار الساعة':
        'Listen to the latest programs and podcasts around the clock',
    'الأغاني اليمنية': 'Yemeni songs',
    'الأغاني العربية': 'Arabic songs',
    'الشيلات والقصائد الشعرية': 'Sheilat and poetry',
    'الأناشيد الدينية': 'Religious nasheeds',
    'القرآن الكريم': 'Holy Quran',
    'الموسيقى': 'Music',
    'مسلسلات إذاعية': 'Radio series',
    'البرامج الثقافية': 'Cultural programs',
    'البرامج الفنية': 'Art programs',
    'البرامج الطبية': 'Medical programs',
    'البرامج الاجتماعية': 'Social programs',
    'البرامج الدينية': 'Religious programs',
    'الفنانين اليمنيين': 'Yemeni artists',
    'الفنانين العرب': 'Arab artists',
    'التصنيفات': 'Categories',
    'المنشدين': 'Vocalists',
    'القراء': 'Reciters',
    'قائمة البرامج': 'Program list',
    'قائمة المسلسلات': 'Series list',
    'المسلسلات': 'Series',
    'المسلسلات الإذاعية': 'Radio series',
    'المسلسلات العربية': 'Arabic series',
    'المسلسلات اليمنية': 'Yemeni series',
    'التصنيفات الموسيقية': 'Music categories',
    'روائع الطرب الأصيل': 'Classics of authentic music',
    'جلسات صنعانية وحضرمية\nمتجددة باستمرار':
        'Sanaani and Hadrami sessions\nupdated regularly',
    'سحر الموسيقى العربية': 'The magic of Arabic music',
    'أجمل الأصوات والطرب العربي': 'The finest voices and Arabic classics',
    'أعذب الكلمات والقصائد': 'The sweetest words and poems',
    'شيلات وقصائد مختارة': 'Selected sheilat and poems',
    'روحانيات وأناشيد': 'Spirituality and nasheeds',
    'أناشيد إسلامية تلامس القلوب': 'Islamic nasheeds that touch hearts',
    'تلاوات خاشعة': 'Reverent recitations',
    'القرآن الكريم بأعذب الأصوات': 'Holy Quran in the finest voices',
    'عالم الألحان': 'A world of melodies',
    'مقطوعات موسيقية متنوعة': 'A variety of musical pieces',
    'حكايات تُروى بالصوت': 'Stories told through sound',
    'مسلسلات إذاعية ممتعة': 'Enjoyable radio series',
    'مسلسل إذاعي': 'Radio series',
    'أيام لا تُنسى': 'Unforgettable Days',
    'حكايات من الزمن الجميل': 'Tales from the Good Old Days',
    'رحلة إلى المجهول': 'Journey into the Unknown',
    'حكايات صنعاء': 'Tales of Sanaa',
    'ليالي عدن': 'Aden Nights',
    'دروب اليمن': 'Yemen Roads',
    'زاد المعرفة': 'A wealth of knowledge',
    'برامج ثقافية وأدبية': 'Cultural and literary programs',
    'عالم الفن': 'The world of art',
    'لقاءات وحوارات فنية': 'Art interviews and conversations',
    'صحتك تهمنا': 'Your health matters',
    'نصائح واستشارات طبية': 'Medical advice and consultations',
    'المجتمع والناس': 'Community and people',
    'قضايا وحوارات اجتماعية': 'Social issues and conversations',
    'نور على نور': 'Light upon light',
    'برامج ومواعظ دينية': 'Religious programs and sermons',
    'الملفات الصوتية': 'Audio files',
    'تشغيل الكل': 'Play all',
    'تعذر العثور على بيانات هذا القسم.':
        'This category data could not be found.',

    // FM stations and their card details
    'إذاعات عربية': 'Arabic stations',
    'إذاعة مجتمعية': 'Community radio',
    'إذاعة عامة': 'General radio',
    'إذاعة محلية': 'Local radio',
    'إذاعة دينية': 'Religious radio',
    'أخبار وثقافة': 'News & culture',
    'العربية': 'Arabic',
    'اليمن': 'Yemen',
    'الإمارات العربية المتحدة': 'United Arab Emirates',
    'المملكة العربية السعودية': 'Saudi Arabia',
    'مملكة البحرين': 'Bahrain',
    'سلطنة عُمان': 'Oman',
    'المملكة المتحدة': 'United Kingdom',
    'الولايات المتحدة': 'United States',
    'فرنسا': 'France',
    'صنعاء': 'Sana\'a',
    'عدن': 'Aden',
    'تعز': 'Taiz',
    'المكلا': 'Al Mukalla',
    'الحديدة': 'Al Hudaydah',
    'سيئون': 'Seiyun',
    'الرياض': 'Riyadh',
    'الدوحة': 'Doha',
    'مدينة الكويت': 'Kuwait City',
    'المنامة': 'Manama',
    'مسقط': 'Muscat',
    'أبوظبي': 'Abu Dhabi',
    'لندن': 'London',
    'واشنطن': 'Washington',
    'باريس': 'Paris',
    'إذاعة دلتا': 'Delta Radio',
    'إذاعة حضرموت': 'Hadramout Radio',
    'إذاعة المكلا': 'Al Mukalla Radio',
    'إذاعة تعز': 'Taiz Radio',
    'إذاعة صنعاء': 'Sana\'a Radio',
    'إذاعة عدن': 'Aden Radio',
    'إذاعة الحديدة': 'Al Hudaydah Radio',
    'إذاعة إب': 'Ibb Radio',
    'إذاعة سيئون': 'Seiyun Radio',
    'إذاعة القرآن الكريم اليمنية': 'Yemeni Holy Quran Radio',
    'إذاعة السعودية': 'Saudi Radio',
    'إذاعة قطر': 'Qatar Radio',
    'إذاعة الكويت': 'Kuwait Radio',
    'إذاعة البحرين': 'Bahrain Radio',
    'إذاعة سلطنة عُمان': 'Oman Radio',
    'إذاعة الإمارات': 'Emirates Radio',
    'إذاعة الشرق': 'Asharq Radio',
    'بي بي سي عربي': 'BBC Arabic',
    'مونت كارلو الدولية': 'Monte Carlo International',
    'راديو سوا': 'Radio Sawa',
    'إذاعة دلتا FM إذاعة يمنية مجتمعية تقدم برامج ثقافية واجتماعية وترفيهية وموسيقية، مع بث مباشر على مدار الساعة.':
        'Delta FM is a Yemeni community station offering cultural, social, entertainment, and music programs with live broadcasting around the clock.',
    'إذاعة حضرموت محطة إذاعية محلية تقدم برامج إخبارية وثقافية واجتماعية وتغطي مختلف مناطق حضرموت.':
        'Hadramout Radio is a local station providing news, cultural, and social programs across Hadramout.',
    'إذاعة محلية تخدم مدينة المكلا وساحل حضرموت، وتقدم برامج اجتماعية وثقافية وخدمية.':
        'A local station serving Al Mukalla and the Hadramout coast with social, cultural, and public-service programs.',
    'إذاعة تعز تقدم برامج محلية وثقافية وتوعوية، مع تغطية للأحداث والفعاليات في المحافظة.':
        'Taiz Radio offers local, cultural, and educational programs with coverage of events in the governorate.',
    'إذاعة يمنية عامة تبث برامج إخبارية وثقافية واجتماعية متنوعة.':
        'A general Yemeni station broadcasting diverse news, cultural, and social programs.',
    'إذاعة عدن من أقدم الإذاعات اليمنية، تقدم برامج إخبارية وثقافية واجتماعية متنوعة.':
        'Aden Radio is one of Yemen’s oldest stations, offering diverse news, cultural, and social programs.',
    'إذاعة محلية تهتم بالشؤون المجتمعية والثقافية والخدمية لمحافظة الحديدة.':
        'A local station focused on community, culture, and public services in Al Hudaydah.',
    'إذاعة محلية تقدم برامج ثقافية واجتماعية وتوعوية، مع اهتمام بالشأن المحلي في محافظة إب.':
        'A local station providing cultural, social, and educational programs focused on Ibb.',
    'إذاعة تخدم مناطق وادي حضرموت وتبث برامج اجتماعية وثقافية وإخبارية متنوعة.':
        'A station serving Wadi Hadramout with diverse social, cultural, and news programs.',
    'إذاعة متخصصة في تلاوة القرآن الكريم والبرامج الدينية والوعظ والإرشاد.':
        'A station dedicated to Quran recitation, religious programs, sermons, and guidance.',
    'الخدمة الإذاعية العربية التابعة لهيئة الإذاعة البريطانية، تقدم الأخبار والبرامج السياسية والثقافية على مدار الساعة.':
        'The BBC Arabic radio service delivers news and political and cultural programs around the clock.',
    'إذاعة مونت كارلو الدولية تقدم نشرات إخبارية وبرامج سياسية وثقافية واقتصادية موجهة للمستمع العربي.':
        'Monte Carlo International provides news bulletins and political, cultural, and economic programs for Arabic listeners.',
    'إذاعة عربية تقدم الأخبار والبرامج الحوارية والموسيقية، وتبث عبر الإنترنت والأقمار الصناعية.':
        'An Arabic station offering news, talk, and music programs via the internet and satellite.',
    'إذاعة الشرق تقدم نشرات إخبارية وبرامج ثقافية وحوارية موجهة إلى المستمع العربي.':
        'Asharq Radio provides news bulletins and cultural and talk programs for Arabic listeners.',
    'إذاعة رسمية تقدم الأخبار والبرامج الثقافية والدينية والترفيهية للمستمعين داخل الكويت وخارجها.':
        'An official station offering news, cultural, religious, and entertainment programs for listeners in and outside Kuwait.',
    'إذاعة قطر تقدم محتوى إخباريًا وثقافيًا واجتماعيًا وترفيهيًا على مدار اليوم.':
        'Qatar Radio provides news, cultural, social, and entertainment content throughout the day.',
    'إذاعة رسمية تقدم برامج إخبارية وثقافية ودينية وترفيهية وتغطي مختلف ولايات سلطنة عُمان.':
        'An official station offering news, cultural, religious, and entertainment programs across Oman.',
    'إذاعة رسمية تقدم نشرات الأخبار والبرامج الثقافية والاجتماعية والدينية على مدار اليوم.':
        'An official station providing news bulletins and cultural, social, and religious programs throughout the day.',
    'إذاعة إماراتية تقدم محتوى إخباريًا وثقافيًا وترفيهيًا مع تغطية للفعاليات المحلية والإقليمية.':
        'An Emirati station offering news, cultural, and entertainment content with local and regional event coverage.',
    'إذاعة البحرين تقدم نشرات إخبارية وبرامج ثقافية واجتماعية وترفيهية متنوعة تخدم المستمعين داخل البحرين وخارجها.':
        'Bahrain Radio offers news bulletins and diverse cultural, social, and entertainment programs for listeners in and outside Bahrain.',

    // Podcast catalog
    'فهم سلوك المستهلك وصدمات العرض والطلب':
        'Understanding consumer behavior and supply-and-demand shocks',
    'قراءة مبسطة في قرارات الشراء وكيف تغيّر الظروف اليومية سلوك الأسواق والمجتمع.':
        'A simple look at purchasing decisions and how daily conditions shape markets and society.',
    'أ. منير الشيباني': 'Munir Al-Shaibani',
    'اقتصاد ببساطة': 'Economics Made Simple',
    'تربية الأطفال في العصر الرقمي': 'Parenting in the digital age',
    'دليل عملي للأسرة لفهم التطبيقات والألعاب وبناء عادات رقمية أكثر توازنًا.':
        'A practical family guide to apps, games, and healthier digital habits.',
    'د. سارة العلواني': 'Dr. Sara Al-Alwani',
    'مساحة أسرة': 'Family Space',
    'كيف يصنع الشباب اليمني فرصته؟':
        'How can Yemeni youth create opportunities?',
    'حوار ملهم حول تحويل الأفكار الصغيرة إلى مشاريع مؤثرة وقابلة للنمو.':
        'An inspiring conversation about turning small ideas into impactful, scalable projects.',
    'شروق أحمد': 'Shorouq Ahmed',
    'حكاية نجاح': 'Success Story',

    // Audiobook catalog
    'تطوير الذات': 'Self-development',
    'علم النفس': 'Psychology',
    'روايات': 'Novels',
    'فن اللامبالاة': 'The Subtle Art of Not Giving a F*ck',
    'خريف العادات': 'The Fall of Habits',
    'دع القلق وابدأ الحياة': 'How to Stop Worrying and Start Living',
    'الذكاء العاطفي': 'Emotional Intelligence',
    'الرجل الذي باع سيارته': 'The Man Who Sold His Car',
    'قوة الآن': 'The Power of Now',
    'العادات الذرية': 'Atomic Habits',
    'فكر تصبح غنياً': 'Think and Grow Rich',
    'قواعد السطوة': 'The 48 Laws of Power',
    'الخيمياء': 'The Alchemist',
    'نظرية الفستق': 'The Pistachio Theory',
    'أب غني أب فقير': 'Rich Dad Poor Dad',
    'مارك مانسون': 'Mark Manson',
    'جيمس كلير': 'James Clear',
    'ديل كارنيجي': 'Dale Carnegie',
    'دانييل جولمان': 'Daniel Goleman',
    'روبن شارما': 'Robin Sharma',
    'إيكهارت تول': 'Eckhart Tolle',
    'قراءة الروايات': 'Novel narration',
    'قراءة كتب تطوير الذات': 'Self-development books',
    'قراءة الكتب الإسلامية': 'Islamic books',
    'قراءة كتب التاريخ': 'History books',
    'إدارة وأعمال': 'Business and management',
    'محمود فدع': 'Mahmoud Fada',
    'أحمد طه': 'Ahmed Taha',
    'سارة الخطيب': 'Sara Al-Khatib',
    'أحمد مجدي': 'Ahmed Magdy',
    'خالد النبوي': 'Khaled El Nabawy',
    'محمد القحطاني': 'Mohammed Al-Qahtani',
    'فاطمة الزهراء': 'Fatima Al-Zahra',
    'يوسف الصديق': 'Yousef Al-Siddiq',
    'ريم عبدالله': 'Reem Abdullah',
    'عمر الشريف': 'Omar Sharif',
    'منى زكي': 'Mona Zaki',
    'طارق العلي': 'Tariq Al-Ali',
    'يقدم هذا الكتاب نهجاً مختلفاً، حيث يوضح كيف أن قبولنا لواقعنا ومحدوديتنا هو الطريق الحقيقي للتحرر من الضغوط اليومية، وبناء عادات إيجابية تدوم طويلاً.':
        'This book presents a different approach, showing how accepting our reality and limitations can free us from daily pressure and build lasting positive habits.',
    'هذا اقتباس ملهم ومؤثر مأخوذ من سياق الكتاب يعكس حكمة المؤلف في التعامل مع تحديات الحياة.':
        'An inspiring quote from the book that reflects the author’s wisdom in facing life’s challenges.',
    'كتاب رائع جداً، أنصح الجميع بالاستماع إليه. أداء القارئ كان مميزاً وأضاف الكثير للتجربة.':
        'A wonderful book that I recommend to everyone. The narrator’s performance was outstanding and added greatly to the experience.',
    'مقدمة': 'Introduction',
    'بداية الرحلة': 'The journey begins',
    'التعمق': 'Going deeper',
    'الصراع': 'Conflict',
    'النهاية': 'The end',

    // News catalog
    'مهرجان ألوان للموسيقى العربية يعود في نسخته العاشرة':
        'Alwan Arabic Music Festival returns for its tenth edition',
    'استعدادات واسعة لإطلاق نسخة جديدة تجمع الأصوات اليمنية والعربية على مسرح واحد.':
        'Extensive preparations are underway for a new edition bringing Yemeni and Arab voices to one stage.',
    'حفل الفنانة روبي يحقق نجاحًا كبيرًا في ليلة استثنائية':
        'Ruby’s concert achieves major success on an exceptional night',
    'تفاعل جماهيري واسع مع برنامج فني متنوع.':
        'Strong audience engagement with a diverse artistic program.',
    'ألوان تطلق خريطة برامجها الجديدة لهذا الموسم':
        'Alwan launches its new program lineup for the season',
    'برامج مباشرة ومسابقات ومحتوى صوتي جديد.':
        'Live programs, contests, and new audio content.',
    'أصوات يمنية شابة تتألق في المشهد الفني العربي':
        'Young Yemeni voices shine in the Arab arts scene',
    'مواهب جديدة تمزج التراث بالإنتاج الموسيقي الحديث.':
        'New talents blend heritage with modern music production.',
    'جلسة غنائية خاصة تبث مباشرة عبر منصة ألوان':
        'A special music session broadcasts live on Alwan',
    'لقاء فني يجمع الموسيقى والحديث مع الجمهور.':
        'An artistic gathering that combines music and conversation with the audience.',
    'الكتاب الصوتي العربي يفتح آفاقًا جديدة للقراء':
        'Arabic audiobooks open new horizons for readers',
    'إصدارات جديدة وتجارب استماع أكثر قربًا وسهولة.':
        'New releases and more accessible, convenient listening experiences.',
    'ألوان تحتفي بالموروث الشعبي اليمني في برنامج وثائقي':
        'Alwan celebrates Yemeni folk heritage in a documentary',
    'رحلة صوتية بين الحكايات والموسيقى والذاكرة.':
        'An audio journey through stories, music, and memory.',
    'موجز ألوان الرياضي يعود بتغطية يومية موسعة':
        'Alwan Sports Brief returns with expanded daily coverage',
    'نتائج وتحليلات وأبرز أخبار الملاعب العربية والعالمية.':
        'Results, analysis, and the top news from Arab and global stadiums.',
    'مواهب يمنية واعدة تخطف الأنظار في البطولات المحلية':
        'Promising Yemeni talents capture attention in local tournaments',
    'قصص نجاح رياضية تستحق المتابعة.':
        'Sports success stories worth following.',
    'جولة سريعة في أبرز أحداث العالم اليوم':
        'A quick tour of today’s top world events',
    'ملخص موثوق لأهم الأخبار الدولية والتطورات الجديدة.':
        'A reliable summary of key international news and new developments.',
    'كيف تغير المنصات الرقمية مستقبل الإعلام الصوتي؟':
        'How are digital platforms changing the future of audio media?',
    'تجارب عالمية جديدة في البث والبودكاست.':
        'New global approaches to broadcasting and podcasts.',
  };

  static String translate(String source) {
    final exact = _values[source];
    if (exact != null) return exact;

    if (source.startsWith('اللغة الحالية: ')) {
      return 'Current language: ${_tail(source, 'اللغة الحالية: ')}';
    }
    if (source.startsWith('درجة الجودة الحالية: ')) {
      return 'Current quality: ${translate(_tail(source, 'درجة الجودة الحالية: '))}';
    }
    if (source.startsWith('المظهر الحالي: ')) {
      return 'Current appearance: ${translate(_tail(source, 'المظهر الحالي: '))}';
    }
    if (source.startsWith('المظهر ')) {
      return 'Appearance: ${translate(_tail(source, 'المظهر '))}';
    }
    if (source.endsWith(' نقطة')) {
      return '${source.substring(0, source.length - 5)} points';
    }
    if (source.startsWith('قوة تغطية الشبكة ')) {
      return source.replaceFirst('قوة تغطية الشبكة ', 'Network strength: ');
    }
    if (source.startsWith('سيتم تشغيل البث بسرعة ')) {
      return source.replaceFirst('سيتم تشغيل البث بسرعة ', 'Stream bitrate: ');
    }
    if (source.startsWith('تأكيد ') && source.endsWith(' والرجوع')) {
      return 'Confirm ${translate(source.substring(6, source.length - 8))} and return';
    }
    if (source.startsWith('الموقع المعتمد: ')) {
      return 'Selected location: ${_tail(source, 'الموقع المعتمد: ')}';
    }
    if (source.startsWith('صلاة ')) {
      return 'Prayer: ${translate(_tail(source, 'صلاة '))}';
    }
    if (source.startsWith('تم اعتماد اللغة ')) {
      return 'Language set to ${_tail(source, 'تم اعتماد اللغة ')}';
    }
    if (source.startsWith('منذ ') && source.endsWith(' دقيقة')) {
      return '${source.substring(4, source.length - 5)} minutes ago';
    }
    if (source.startsWith('منذ ') && source.endsWith(' ساعات')) {
      return '${source.substring(4, source.length - 6)} hours ago';
    }
    if (source.startsWith('منذ ') && source.endsWith(' ساعة')) {
      return '${source.substring(4, source.length - 4)} hour ago';
    }
    if (source.startsWith('الفصل ')) {
      return 'Chapter ${source.substring(6)}';
    }
    if (source.startsWith('كتاب ') && source.contains(' المتقدم ')) {
      return source
          .replaceFirst('كتاب ', 'Advanced ')
          .replaceFirst(' المتقدم ', ' book ');
    }
    if (source.startsWith('مستخدم ')) {
      return 'User ${source.substring(6)}';
    }
    if (source.startsWith('اختر ') && source.endsWith(' من قائمة المشاركة')) {
      return 'Choose ${source.substring(5, source.length - 19)} from the share menu';
    }
    return _translateFragments(source);
  }

  static String _translateFragments(String source) {
    var translated = source;
    for (final entry in _fragments.entries) {
      translated = translated.replaceAll(entry.key, entry.value);
    }
    return translated;
  }

  static String _tail(String source, String prefix) =>
      source.substring(prefix.length);

  /// Terms that can be combined by cards and data models at runtime.
  static const Map<String, String> _fragments = {
    'الفنانة': 'Artist',
    'الفنان': 'Artist',
    'المنشد': 'Vocalist',
    'القارئ': 'Reciter',
    'الشاعر/': 'Poet',
    'برنامج': 'Program',
    'حلقة': 'Episode',
    'أغنية': 'Song',
    'أنشودة': 'Nasheed',
    'تلاوة': 'Recitation',
    'مقطوعة': 'Track',
    'ملف': 'File',
    'أيوب طارش': 'Ayoub Tarish',
    'أبو بكر سالم': 'Abu Bakr Salem',
    'أحمد فتحي': 'Ahmed Fathi',
    'فؤاد عبدالواحد': 'Fouad Abdulwahed',
    'محمد عبده': 'Mohammed Abdu',
    'كاظم الساهر': 'Kazem Al Saher',
    'ماجدة الرومي': 'Majida El Roumi',
    'فهد بن فصلا': 'Fahad Bin Fasla',
    'عبدالله آل مخلص': 'Abdullah Al Mokhles',
    'الصوت الأول': 'First Voice',
    'الصوت الثاني': 'Second Voice',
    'عبدالله البردوني': 'Abdullah Al-Baradouni',
    'عبدالعزيز المقالح': 'Abdulaziz Al-Maqaleh',
    'مشاري العفاسي': 'Mishary Alafasy',
    'ماهر زين': 'Maher Zain',
    'سامي يوسف': 'Sami Yusuf',
    'عبدالباسط عبدالصمد': 'Abdul Basit Abdus-Samad',
    'محمود خليل الحصري': 'Mahmoud Khalil Al-Hussary',
    'ماهر المعيقلي': 'Maher Al-Muaiqly',
    'الموسيقى الهادئة': 'Relaxing music',
    'الموسيقى الكلاسيكية': 'Classical music',
    'الموسيقى التصويرية': 'Soundtracks',
    'آفاق وثائقية': 'Documentary Horizons',
    'حكاية مكان': 'A Place Story',
    'عالم المعرفة': 'World of Knowledge',
    'كتاب وحكاية': 'A Book and a Story',
    'نوافذ ثقافية': 'Cultural Windows',
    'لغة وفكر': 'Language and Thought',
    'ألوان فنية': 'Art Colors',
    'ليالي الفن': 'Art Nights',
    'خلف الكواليس': 'Behind the Scenes',
    'صحتك أولاً': 'Your Health First',
    'دقيقة طبية': 'Medical Minute',
    'اسأل الطبيب': 'Ask the Doctor',
    'حديث المجتمع': 'Community Talk',
    'بين الناس': 'Among People',
    'قضية وحوار': 'Issue and Dialogue',
    'نور القلوب': 'Light of Hearts',
    'نفحات إيمانية': 'Spiritual Breezes',
    'فقه الحياة': 'Understanding Life',
    'الشيلات': 'Sheilat',
    'الزوامل': 'Zawamil',
    'القصائد الشعرية': 'Poetry',
    'الأصوات والشعراء': 'Voices and Poets',
    'منشد الشيلة': 'Sheila Vocalist',
    'منشد الزامل': 'Zamil Vocalist',
    'الإعلامية شروق أحمد': 'Presenter Shorouq Ahmed',
    'تواصل الآن': 'Connect now',
    'اختياراتك': 'Your picks',
  };
}
