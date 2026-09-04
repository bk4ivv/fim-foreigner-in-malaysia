// FIM - Foreigner in Malaysia: a language-first, worker-focused route to official Malaysian services.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

const _appTitle = 'FIM - Foreigner in Malaysia';
const _workerLogoAsset = 'assets/images/fim_malaysia_flag_logo.jpg';
const _creatorAvatarAsset =
    'assets/images/khandaker-md-borhan-kabir-profile.jpg';

abstract final class AppPalette {
  // Malaysian flag-inspired system: blue for trust, red for urgency,
  // white for clarity, and yellow for action and national warmth.
  static const flagNavy = Color(0xFF010066);
  static const flagRed = Color(0xFFCC0001);
  static const flagYellow = Color(0xFFFFCC00);
  static const flagWhite = Color(0xFFFFFFFF);

  // Existing semantic names remain stable so every established component
  // receives the new FIM palette without screen-by-screen rewrites.
  static const ink = Color(0xFF08104A);
  static const midnight = Color(0xFF020633);
  static const evergreen = flagNavy;
  static const emerald = flagNavy;
  static const civicBlue = flagNavy;
  static const hibiscus = flagRed;
  static const saffron = flagYellow;
  static const paper = Color(0xFFF7F8FE);
  static const mist = Color(0xFFE8EBF5);
  static const surface = flagWhite;
  static const outline = Color(0xFFD7DCEE);
  static const muted = Color(0xFF43517A);
  static const softGold = Color(0xFFFFE49A);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The core app is intentionally offline-first. Optional community/backend
  // code is not part of the active navigation, so never block the utility UI
  // on a network session during startup.
  runApp(const ForeignWorkerMalaysiaApp());
}

enum AppLanguage {
  english,
  bangla,
  malay,
  indonesian,
  tamil,
  urdu,
  hindi,
  nepali,
  burmese,
  thai,
  khmer,
  filipino,
  chinese,
  vietnamese,
  sinhala,
  korean,
  japanese,
  german,
  french,
  spanish,
  arabic,
  russian,
}

class CountryOption {
  const CountryOption({
    required this.name,
    required this.code,
    required this.region,
    required this.languages,
    required this.currencyCode,
  });

  final String name;
  final String code;
  final String region;
  final List<String> languages;
  final String currencyCode;

  String get flag => String.fromCharCodes(
    code.toUpperCase().codeUnits.map((unit) => unit + 127397),
  );

  bool get isMalaysiaWorkerSourceCountry =>
      malaysiaWorkerSourceCountries.contains(code.toUpperCase());
}

const malaysiaWorkerSourceCountries = <String>{
  'BD',
  'KH',
  'CN',
  'IN',
  'ID',
  'LA',
  'MM',
  'NP',
  'PK',
  'PH',
  'LK',
  'TH',
  'VN',
};

const _countryLanguageDefaults = <String, AppLanguage>{
  'BD': AppLanguage.bangla,
  'MY': AppLanguage.malay,
  'ID': AppLanguage.indonesian,
  'IN': AppLanguage.hindi,
  'PK': AppLanguage.urdu,
  'NP': AppLanguage.nepali,
  'MM': AppLanguage.burmese,
  'TH': AppLanguage.thai,
  'KH': AppLanguage.khmer,
  'PH': AppLanguage.filipino,
  'CN': AppLanguage.chinese,
  'VN': AppLanguage.vietnamese,
  'LK': AppLanguage.sinhala,
};

const _languageAliases = <String, AppLanguage>{
  'english': AppLanguage.english,
  'bengali': AppLanguage.bangla,
  'bangla': AppLanguage.bangla,
  'malay': AppLanguage.malay,
  'indonesian': AppLanguage.indonesian,
  'tamil': AppLanguage.tamil,
  'urdu': AppLanguage.urdu,
  'hindi': AppLanguage.hindi,
  'nepali': AppLanguage.nepali,
  'burmese': AppLanguage.burmese,
  'myanmar': AppLanguage.burmese,
  'thai': AppLanguage.thai,
  'khmer': AppLanguage.khmer,
  'filipino': AppLanguage.filipino,
  'tagalog': AppLanguage.filipino,
  'chinese': AppLanguage.chinese,
  'mandarin': AppLanguage.chinese,
  'vietnamese': AppLanguage.vietnamese,
  'sinhala': AppLanguage.sinhala,
  'korean': AppLanguage.korean,
  '한국어': AppLanguage.korean,
  'japanese': AppLanguage.japanese,
  '日本語': AppLanguage.japanese,
  'german': AppLanguage.german,
  'deutsch': AppLanguage.german,
  'french': AppLanguage.french,
  'français': AppLanguage.french,
  'spanish': AppLanguage.spanish,
  'español': AppLanguage.spanish,
  'arabic': AppLanguage.arabic,
  'العربية': AppLanguage.arabic,
  'russian': AppLanguage.russian,
  'русский': AppLanguage.russian,
};

AppLanguage? _appLanguageForLabel(String label) =>
    _languageAliases[label.trim().toLowerCase()];

enum ServiceId { visa, fomema, student, epf, cidb, fwcms }

enum ToolId { translate, qrScanner, fileConverter, exchangeRates, trips }

class AppCopy {
  const AppCopy({
    required this.languageName,
    required this.direction,
    required this.languagePageTitle,
    required this.languagePageSubtitle,
    required this.chooseLanguage,
    required this.servicePageTitle,
    required this.servicePageSubtitle,
    required this.visaTitle,
    required this.visaDescription,
    required this.fomemaTitle,
    required this.fomemaDescription,
    required this.officialService,
    required this.adTitle,
    required this.adSubtitle,
    required this.creditTitle,
    required this.creatorCredit,
    required this.contact,
    required this.backToLanguages,
    required this.backToServices,
    required this.reload,
    required this.contactTitle,
  });

  final String languageName;
  final TextDirection direction;
  final String languagePageTitle;
  final String languagePageSubtitle;
  final String chooseLanguage;
  final String servicePageTitle;
  final String servicePageSubtitle;
  final String visaTitle;
  final String visaDescription;
  final String fomemaTitle;
  final String fomemaDescription;
  final String officialService;
  final String adTitle;
  final String adSubtitle;
  final String creditTitle;
  final String creatorCredit;
  final String contact;
  final String backToLanguages;
  final String backToServices;
  final String reload;
  final String contactTitle;
}

const appCopies = <AppLanguage, AppCopy>{
  AppLanguage.english: AppCopy(
    languageName: 'English',
    direction: TextDirection.ltr,
    languagePageTitle: 'Choose your language',
    languagePageSubtitle:
        'Start in the language that feels most comfortable for you.',
    chooseLanguage: 'Available worker languages',
    servicePageTitle: 'Official checks, made easier',
    servicePageSubtitle: 'Choose the service you need. Each option opens its official Malaysian page.',
    visaTitle: 'Visa Status',
    visaDescription: 'Check visa application and immigration status.',
    fomemaTitle: 'FOMEMA Check',
    fomemaDescription: 'Check FOMEMA medical screening status.',
    officialService: 'Official Malaysian service',
    adTitle: 'Advertisement',
    adSubtitle: 'Reserved for a future partner or useful worker information.',
    creditTitle: 'Made for workers, with care',
    creatorCredit: 'Created by Khandaker Md Borhan Kabir (@bk4ivv), a Malaysia-based foreign worker and Metal CNC Operator. This app was made to give workers a simple route to official Visa Status and FOMEMA Check services. Thanks for installing; share any idea or improvement on email.',
    contact: 'Contact on email',
    backToLanguages: 'Change language',
    backToServices: 'Back to services',
    reload: 'Reload page',
    contactTitle: 'email contact',
  ),
  AppLanguage.bangla: AppCopy(
    languageName: 'বাংলা',
    direction: TextDirection.ltr,
    languagePageTitle: 'আপনার ভাষা নির্বাচন করুন',
    languagePageSubtitle:
        'যে ভাষায় আপনি সবচেয়ে স্বাচ্ছন্দ্যবোধ করেন, সেটি দিয়ে শুরু করুন।',
    chooseLanguage: 'কর্মীদের জন্য উপলব্ধ ভাষা',
    servicePageTitle: 'সরকারি চেক, এখন আরও সহজ',
    servicePageSubtitle: 'আপনার প্রয়োজনীয় সেবা বেছে নিন। প্রতিটি অপশন সরকারি মালয়েশিয়ান পেজ খুলবে।',
    visaTitle: 'ভিসা স্ট্যাটাস',
    visaDescription: 'ভিসা আবেদন ও ইমিগ্রেশন স্ট্যাটাস পরীক্ষা করুন।',
    fomemaTitle: 'FOMEMA চেক',
    fomemaDescription: 'FOMEMA মেডিকেল স্ক্রিনিংয়ের স্ট্যাটাস পরীক্ষা করুন।',
    officialService: 'সরকারি মালয়েশিয়ান সেবা',
    adTitle: 'বিজ্ঞাপন',
    adSubtitle:
        'ভবিষ্যৎ অংশীদার বা কর্মীদের জন্য দরকারি তথ্যের জায়গা সংরক্ষিত।',
    creditTitle: 'কর্মীদের জন্য, যত্নের সাথে তৈরি',
    creatorCredit: 'কুয়ালালামপুরে কর্মরত বিদেশি শ্রমিক ও মেটাল CNC অপারেটর খন্দকার মো: বোরহান কাবির (@bk4ivv) এই অ্যাপটি তৈরি করেছেন। সরকারি ভিসা স্ট্যাটাস ও FOMEMA চেক সেবায় সহজে পৌঁছাতে কর্মীদের সাহায্য করাই এর উদ্দেশ্য। অ্যাপটি ইনস্টল করার জন্য ধন্যবাদ; যেকোনো পরামর্শ email-এ জানান।',
    contact: 'email-এ যোগাযোগ করুন',
    backToLanguages: 'ভাষা পরিবর্তন করুন',
    backToServices: 'সেবায় ফিরে যান',
    reload: 'পেজ রিলোড করুন',
    contactTitle: 'email যোগাযোগ',
  ),
  AppLanguage.malay: AppCopy(
    languageName: 'Bahasa Melayu',
    direction: TextDirection.ltr,
    languagePageTitle: 'Pilih bahasa anda',
    languagePageSubtitle: 'Mulakan dalam bahasa yang paling selesa untuk anda.',
    chooseLanguage: 'Bahasa untuk komuniti pekerja',
    servicePageTitle: 'Semakan rasmi, lebih mudah',
    servicePageSubtitle: 'Pilih perkhidmatan yang anda perlukan. Setiap pilihan membuka halaman rasmi Malaysia.',
    visaTitle: 'Status Visa',
    visaDescription: 'Semak permohonan visa dan status imigresen.',
    fomemaTitle: 'Semakan FOMEMA',
    fomemaDescription: 'Semak status saringan kesihatan FOMEMA.',
    officialService: 'Perkhidmatan rasmi Malaysia',
    adTitle: 'Iklan',
    adSubtitle: 'Ruang disediakan untuk rakan masa depan atau maklumat berguna pekerja.',
    creditTitle: 'Dibuat untuk pekerja, dengan prihatin',
    creatorCredit: 'Dicipta oleh Khandaker Md Borhan Kabir (@bk4ivv), seorang pekerja asing di Malaysia dan Operator CNC Metal. Aplikasi ini dibuat untuk memudahkan pekerja mengakses perkhidmatan rasmi Status Visa dan Semakan FOMEMA. Terima kasih kerana memasang aplikasi ini; kongsikan cadangan anda melalui email.',
    contact: 'Hubungi melalui email',
    backToLanguages: 'Tukar bahasa',
    backToServices: 'Kembali ke perkhidmatan',
    reload: 'Muat semula halaman',
    contactTitle: 'Hubungi email',
  ),
  AppLanguage.indonesian: AppCopy(
    languageName: 'Bahasa Indonesia',
    direction: TextDirection.ltr,
    languagePageTitle: 'Pilih bahasa Anda',
    languagePageSubtitle: 'Mulai dengan bahasa yang paling nyaman untuk Anda.',
    chooseLanguage: 'Bahasa untuk komunitas pekerja',
    servicePageTitle: 'Pemeriksaan resmi, lebih mudah',
    servicePageSubtitle: 'Pilih layanan yang Anda perlukan. Setiap pilihan membuka halaman resmi Malaysia.',
    visaTitle: 'Status Visa',
    visaDescription: 'Periksa pengajuan visa dan status imigrasi.',
    fomemaTitle: 'Pemeriksaan FOMEMA',
    fomemaDescription: 'Periksa status pemeriksaan kesehatan FOMEMA.',
    officialService: 'Layanan resmi Malaysia',
    adTitle: 'Iklan',
    adSubtitle:
        'Ruang untuk mitra mendatang atau informasi bermanfaat bagi pekerja.',
    creditTitle: 'Dibuat untuk pekerja, dengan perhatian',
    creatorCredit: 'Dibuat oleh Khandaker Md Borhan Kabir (@bk4ivv), pekerja asing di Malaysia dan Operator CNC Metal. Aplikasi ini dibuat agar pekerja lebih mudah mengakses layanan resmi Status Visa dan Pemeriksaan FOMEMA. Terima kasih telah memasang aplikasi ini; kirimkan saran Anda melalui email.',
    contact: 'Hubungi di email',
    backToLanguages: 'Ganti bahasa',
    backToServices: 'Kembali ke layanan',
    reload: 'Muat ulang halaman',
    contactTitle: 'Kontak email',
  ),
  AppLanguage.tamil: AppCopy(
    languageName: 'தமிழ்',
    direction: TextDirection.ltr,
    languagePageTitle: 'உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்',
    languagePageSubtitle: 'உங்களுக்கு மிகவும் வசதியான மொழியில் தொடங்குங்கள்.',
    chooseLanguage: 'தொழிலாளர் சமூகங்களுக்கான மொழிகள்',
    servicePageTitle: 'அதிகாரப்பூர்வ சரிபார்ப்புகள், எளிமையாக',
    servicePageSubtitle: 'தேவையான சேவையைத் தேர்ந்தெடுக்கவும். ஒவ்வொரு தேர்வும் அதிகாரப்பூர்வ மலேசியப் பக்கத்தைத் திறக்கும்.',
    visaTitle: 'விசா நிலை',
    visaDescription:
        'விசா விண்ணப்பம் மற்றும் குடியேற்ற நிலையைச் சரிபார்க்கவும்.',
    fomemaTitle: 'FOMEMA சரிபார்ப்பு',
    fomemaDescription: 'FOMEMA மருத்துவ பரிசோதனை நிலையைச் சரிபார்க்கவும்.',
    officialService: 'அதிகாரப்பூர்வ மலேசிய சேவை',
    adTitle: 'விளம்பரம்',
    adSubtitle: 'எதிர்கால கூட்டாளர் அல்லது பயனுள்ள தொழிலாளர் தகவலுக்கான இடம் ஒதுக்கப்பட்டுள்ளது.',
    creditTitle: 'தொழிலாளர்களுக்காக, அக்கறையுடன் உருவாக்கப்பட்டது',
    creatorCredit: 'மலேசியாவில் பணிபுரியும் வெளிநாட்டு தொழிலாளரும் மெட்டல் CNC ஆபரேட்டருமான Khandaker Md Borhan Kabir (@bk4ivv) இந்த செயலியை உருவாக்கினார். அதிகாரப்பூர்வ விசா நிலை மற்றும் FOMEMA சரிபார்ப்பு சேவைகளை தொழிலாளர்கள் எளிதாக அணுகுவதற்காக இது உருவாக்கப்பட்டது. நிறுவியதற்கு நன்றி; உங்கள் ஆலோசனைகளை email-ல் பகிரவும்.',
    contact: 'email-ல் தொடர்புகொள்ளவும்',
    backToLanguages: 'மொழியை மாற்றவும்',
    backToServices: 'சேவைகளுக்குத் திரும்பவும்',
    reload: 'பக்கத்தை மீண்டும் ஏற்றவும்',
    contactTitle: 'email தொடர்பு',
  ),
  AppLanguage.urdu: AppCopy(
    languageName: 'اردو',
    direction: TextDirection.rtl,
    languagePageTitle: 'اپنی زبان منتخب کریں',
    languagePageSubtitle:
        'اس زبان میں شروع کریں جس میں آپ سب سے زیادہ آرام محسوس کرتے ہیں۔',
    chooseLanguage: 'ورکر کمیونٹیز کے لیے دستیاب زبانیں',
    servicePageTitle: 'سرکاری چیک، اب زیادہ آسان',
    servicePageSubtitle:
        'اپنی مطلوبہ سروس منتخب کریں۔ ہر انتخاب سرکاری ملائیشین صفحہ کھولے گا۔',
    visaTitle: 'ویزا اسٹیٹس',
    visaDescription: 'ویزا درخواست اور امیگریشن اسٹیٹس چیک کریں۔',
    fomemaTitle: 'FOMEMA چیک',
    fomemaDescription: 'FOMEMA میڈیکل اسکریننگ کا اسٹیٹس چیک کریں۔',
    officialService: 'سرکاری ملائیشین سروس',
    adTitle: 'اشتہار',
    adSubtitle:
        'آئندہ شراکت دار یا کارکنوں کی مفید معلومات کے لیے جگہ مخصوص ہے۔',
    creditTitle: 'کارکنوں کے لیے، توجہ کے ساتھ تیار کردہ',
    creatorCredit: 'یہ ایپ Khandaker Md Borhan Kabir (@bk4ivv) نے بنائی ہے، جو ملائیشیا میں غیر ملکی کارکن اور میٹل CNC آپریٹر ہیں۔ اس کا مقصد کارکنوں کو سرکاری ویزا اسٹیٹس اور FOMEMA چیک سروسز تک آسان رسائی دینا ہے۔ انسٹال کرنے کا شکریہ؛ اپنی تجاویز email پر شیئر کریں۔',
    contact: 'email پر رابطہ کریں',
    backToLanguages: 'زبان تبدیل کریں',
    backToServices: 'سروسز پر واپس جائیں',
    reload: 'صفحہ دوبارہ لوڈ کریں',
    contactTitle: 'email رابطہ',
  ),
  AppLanguage.hindi: AppCopy(
    languageName: 'हिन्दी',
    direction: TextDirection.ltr,
    languagePageTitle: 'अपनी भाषा चुनें',
    languagePageSubtitle: 'उस भाषा से शुरुआत करें जिसमें आप सबसे सहज हों।',
    chooseLanguage: 'कामगार समुदायों के लिए भाषाएँ',
    servicePageTitle: 'आधिकारिक जांच, अब आसान',
    servicePageSubtitle:
        'अपनी जरूरत की सेवा चुनें। हर विकल्प आधिकारिक मलेशियाई पेज खोलेगा।',
    visaTitle: 'वीज़ा स्थिति',
    visaDescription: 'वीज़ा आवेदन और आव्रजन स्थिति जांचें।',
    fomemaTitle: 'FOMEMA जांच',
    fomemaDescription: 'FOMEMA मेडिकल स्क्रीनिंग की स्थिति जांचें।',
    officialService: 'आधिकारिक मलेशियाई सेवा',
    adTitle: 'विज्ञापन',
    adSubtitle: 'भविष्य के भागीदार या कामगारों की उपयोगी जानकारी के लिए जगह आरक्षित है।',
    creditTitle: 'कामगारों के लिए, सावधानी से बनाया गया',
    creatorCredit: 'यह ऐप Khandaker Md Borhan Kabir (@bk4ivv) ने बनाया है, जो मलेशिया में विदेशी कामगार और मेटल CNC ऑपरेटर हैं। इसका उद्देश्य कामगारों को आधिकारिक वीज़ा स्थिति और FOMEMA जांच सेवाओं तक आसान पहुंच देना है। इंस्टॉल करने के लिए धन्यवाद; अपने सुझाव email पर भेजें।',
    contact: 'email पर संपर्क करें',
    backToLanguages: 'भाषा बदलें',
    backToServices: 'सेवाओं पर वापस जाएँ',
    reload: 'पेज फिर से लोड करें',
    contactTitle: 'email संपर्क',
  ),
  AppLanguage.nepali: AppCopy(
    languageName: 'नेपाली',
    direction: TextDirection.ltr,
    languagePageTitle: 'आफ्नो भाषा छनोट गर्नुहोस्',
    languagePageSubtitle:
        'तपाईंलाई सबैभन्दा सहज लाग्ने भाषाबाट सुरु गर्नुहोस्।',
    chooseLanguage: 'कामदार समुदायका लागि भाषाहरू',
    servicePageTitle: 'आधिकारिक जाँच, अझ सजिलो',
    servicePageSubtitle: 'तपाईंलाई चाहिएको सेवा छनोट गर्नुहोस्। प्रत्येक विकल्पले आधिकारिक मलेसियाली पृष्ठ खोल्छ।',
    visaTitle: 'भिसा स्थिति',
    visaDescription: 'भिसा आवेदन र अध्यागमन स्थिति जाँच गर्नुहोस्।',
    fomemaTitle: 'FOMEMA जाँच',
    fomemaDescription: 'FOMEMA मेडिकल स्क्रिनिङको स्थिति जाँच गर्नुहोस्।',
    officialService: 'आधिकारिक मलेसियाली सेवा',
    adTitle: 'विज्ञापन',
    adSubtitle: 'भविष्यका साझेदार वा कामदारका लागि उपयोगी जानकारीका लागि स्थान सुरक्षित छ।',
    creditTitle: 'कामदारका लागि, हेरचाहका साथ बनाइएको',
    creatorCredit: 'यो एप Khandaker Md Borhan Kabir (@bk4ivv) ले बनाउनुभएको हो, जो मलेसियामा विदेशी कामदार र मेटल CNC अपरेटर हुनुहुन्छ। कामदारलाई आधिकारिक भिसा स्थिति र FOMEMA जाँच सेवामा सजिलो पहुँच दिन यो बनाइएको हो। स्थापना गर्नुभएकोमा धन्यवाद; आफ्नो सुझाव email मा पठाउनुहोस्।',
    contact: 'email मा सम्पर्क गर्नुहोस्',
    backToLanguages: 'भाषा परिवर्तन गर्नुहोस्',
    backToServices: 'सेवामा फर्कनुहोस्',
    reload: 'पृष्ठ फेरि लोड गर्नुहोस्',
    contactTitle: 'email सम्पर्क',
  ),
  AppLanguage.burmese: AppCopy(
    languageName: 'မြန်မာ',
    direction: TextDirection.ltr,
    languagePageTitle: 'သင့်ဘာသာစကားကို ရွေးချယ်ပါ',
    languagePageSubtitle: 'သင်အဆင်ပြေဆုံး ဘာသာစကားဖြင့် စတင်ပါ။',
    chooseLanguage: 'အလုပ်သမားအသိုင်းအဝိုင်းအတွက် ဘာသာစကားများ',
    servicePageTitle: 'တရားဝင် စစ်ဆေးမှုများကို လွယ်ကူစွာ',
    servicePageSubtitle: 'သင်လိုအပ်သော ဝန်ဆောင်မှုကို ရွေးချယ်ပါ။ ရွေးချယ်မှုတိုင်းသည် တရားဝင် မလေးရှားစာမျက်နှာကို ဖွင့်ပေးသည်။',
    visaTitle: 'ဗီဇာ အခြေအနေ',
    visaDescription:
        'ဗီဇာလျှောက်လွှာနှင့် လူဝင်မှုကြီးကြပ်ရေး အခြေအနေကို စစ်ဆေးပါ။',
    fomemaTitle: 'FOMEMA စစ်ဆေးမှု',
    fomemaDescription: 'FOMEMA ဆေးဘက်ဆိုင်ရာ စစ်ဆေးမှုအခြေအနေကို စစ်ဆေးပါ။',
    officialService: 'တရားဝင် မလေးရှား ဝန်ဆောင်မှု',
    adTitle: 'ကြော်ငြာ',
    adSubtitle: 'အနာဂတ်မိတ်ဖက် သို့မဟုတ် အလုပ်သမားအတွက် အသုံးဝင်သော အချက်အလက်အတွက် နေရာသတ်မှတ်ထားသည်။',
    creditTitle: 'အလုပ်သမားများအတွက် ဂရုစိုက်ပြီး ဖန်တီးထားသည်',
    creatorCredit: 'ဤအက်ပ်ကို မလေးရှားရှိ နိုင်ငံခြားအလုပ်သမားနှင့် Metal CNC Operator ဖြစ်သူ Khandaker Md Borhan Kabir (@bk4ivv) က ဖန်တီးခဲ့သည်။ အလုပ်သမားများ တရားဝင် Visa Status နှင့် FOMEMA Check ဝန်ဆောင်မှုများသို့ လွယ်ကူစွာရောက်ရှိရန် ရည်ရွယ်သည်။ ထည့်သွင်းအသုံးပြုသည့်အတွက် ကျေးဇူးတင်ပါသည်။ အကြံပြုချက်များကို email မှ ပို့ပါ။',
    contact: 'email မှ ဆက်သွယ်ပါ',
    backToLanguages: 'ဘာသာစကား ပြောင်းပါ',
    backToServices: 'ဝန်ဆောင်မှုများသို့ ပြန်သွားပါ',
    reload: 'စာမျက်နှာ ပြန်ဖွင့်ပါ',
    contactTitle: 'email ဆက်သွယ်ရန်',
  ),
  AppLanguage.thai: AppCopy(
    languageName: 'ไทย',
    direction: TextDirection.ltr,
    languagePageTitle: 'เลือกภาษาของคุณ',
    languagePageSubtitle: 'เริ่มต้นด้วยภาษาที่คุณรู้สึกสบายที่สุด',
    chooseLanguage: 'ภาษาสำหรับชุมชนแรงงาน',
    servicePageTitle: 'ตรวจสอบข้อมูลทางการได้ง่ายขึ้น',
    servicePageSubtitle: 'เลือกบริการที่คุณต้องการ แต่ละตัวเลือกจะเปิดหน้าอย่างเป็นทางการของมาเลเซีย',
    visaTitle: 'สถานะวีซ่า',
    visaDescription: 'ตรวจสอบคำขอวีซ่าและสถานะตรวจคนเข้าเมือง',
    fomemaTitle: 'ตรวจสอบ FOMEMA',
    fomemaDescription: 'ตรวจสอบสถานะการตรวจสุขภาพ FOMEMA',
    officialService: 'บริการทางการของมาเลเซีย',
    adTitle: 'โฆษณา',
    adSubtitle:
        'พื้นที่สำหรับพันธมิตรในอนาคตหรือข้อมูลที่เป็นประโยชน์สำหรับแรงงาน',
    creditTitle: 'สร้างเพื่อแรงงานด้วยความใส่ใจ',
    creatorCredit: 'แอปนี้สร้างโดย Khandaker Md Borhan Kabir (@bk4ivv) แรงงานต่างชาติในมาเลเซียและผู้ปฏิบัติงาน Metal CNC แอปนี้ช่วยให้แรงงานเข้าถึงบริการสถานะวีซ่าและการตรวจ FOMEMA อย่างเป็นทางการได้ง่ายขึ้น ขอบคุณที่ติดตั้งแอป และส่งข้อเสนอแนะผ่าน email ได้เสมอ',
    contact: 'ติดต่อทาง email',
    backToLanguages: 'เปลี่ยนภาษา',
    backToServices: 'กลับไปที่บริการ',
    reload: 'โหลดหน้าใหม่',
    contactTitle: 'ติดต่อ email',
  ),
  AppLanguage.khmer: AppCopy(
    languageName: 'ខ្មែរ',
    direction: TextDirection.ltr,
    languagePageTitle: 'ជ្រើសរើសភាសារបស់អ្នក',
    languagePageSubtitle: 'ចាប់ផ្តើមជាមួយភាសាដែលអ្នកមានអារម្មណ៍ស្រួលបំផុត។',
    chooseLanguage: 'ភាសាសម្រាប់សហគមន៍កម្មករ',
    servicePageTitle: 'ការត្រួតពិនិត្យផ្លូវការ កាន់តែងាយស្រួល',
    servicePageSubtitle: 'ជ្រើសរើសសេវាកម្មដែលអ្នកត្រូវការ។ ជម្រើសនីមួយៗបើកទំព័រផ្លូវការរបស់ម៉ាឡេស៊ី។',
    visaTitle: 'ស្ថានភាពទិដ្ឋាការ',
    visaDescription: 'ពិនិត្យពាក្យសុំទិដ្ឋាការ និងស្ថានភាពអន្តោប្រវេសន៍។',
    fomemaTitle: 'ពិនិត្យ FOMEMA',
    fomemaDescription: 'ពិនិត្យស្ថានភាពការពិនិត្យសុខភាព FOMEMA។',
    officialService: 'សេវាកម្មផ្លូវការរបស់ម៉ាឡេស៊ី',
    adTitle: 'ការផ្សាយពាណិជ្ជកម្ម',
    adSubtitle:
        'កន្លែងរក្សាទុកសម្រាប់ដៃគូនាពេលអនាគត ឬព័ត៌មានមានប្រយោជន៍សម្រាប់កម្មករ។',
    creditTitle: 'បង្កើតសម្រាប់កម្មករ ដោយយកចិត្តទុកដាក់',
    creatorCredit: 'កម្មវិធីនេះបង្កើតដោយ Khandaker Md Borhan Kabir (@bk4ivv) ជាកម្មករបរទេសនៅម៉ាឡេស៊ី និងជាអ្នកប្រតិបត្តិការ Metal CNC។ វាត្រូវបានបង្កើតឡើងដើម្បីឱ្យកម្មករងាយស្រួលចូលដល់សេវាស្ថានភាពទិដ្ឋាការ និងការពិនិត្យ FOMEMA ផ្លូវការ។ អរគុណសម្រាប់ការដំឡើងកម្មវិធីនេះ ហើយផ្ញើយោបល់របស់អ្នកតាម email។',
    contact: 'ទាក់ទងតាម email',
    backToLanguages: 'ប្ដូរភាសា',
    backToServices: 'ត្រលប់ទៅសេវាកម្ម',
    reload: 'ផ្ទុកទំព័រឡើងវិញ',
    contactTitle: 'ទំនាក់ទំនង email',
  ),
  AppLanguage.filipino: AppCopy(
    languageName: 'Filipino',
    direction: TextDirection.ltr,
    languagePageTitle: 'Piliin ang iyong wika',
    languagePageSubtitle: 'Magsimula sa wikang pinakakomportable para sa iyo.',
    chooseLanguage: 'Mga wika para sa komunidad ng manggagawa',
    servicePageTitle: 'Mas madaling opisyal na pagsusuri',
    servicePageSubtitle: 'Piliin ang serbisyong kailangan mo. Bawat opsyon ay magbubukas ng opisyal na pahina ng Malaysia.',
    visaTitle: 'Katayuan ng Visa',
    visaDescription: 'Suriin ang aplikasyon sa visa at katayuan sa imigrasyon.',
    fomemaTitle: 'FOMEMA Check',
    fomemaDescription: 'Suriin ang katayuan ng FOMEMA medical screening.',
    officialService: 'Opisyal na serbisyong Malaysian',
    adTitle: 'Advertisement',
    adSubtitle: 'Nakalaang puwang para sa partner sa hinaharap o kapaki-pakinabang na impormasyon para sa manggagawa.',
    creditTitle: 'Ginawa para sa mga manggagawa, nang may malasakit',
    creatorCredit: 'Ginawa ni Khandaker Md Borhan Kabir (@bk4ivv), isang dayuhang manggagawa sa Malaysia at Metal CNC Operator. Ginawa ang app na ito upang gawing mas madali para sa mga manggagawa ang pag-access sa opisyal na Visa Status at FOMEMA Check. Salamat sa pag-install; ipadala ang iyong mga mungkahi sa email.',
    contact: 'Makipag-ugnayan sa email',
    backToLanguages: 'Palitan ang wika',
    backToServices: 'Bumalik sa mga serbisyo',
    reload: 'I-reload ang pahina',
    contactTitle: 'email contact',
  ),
  AppLanguage.chinese: AppCopy(
    languageName: '中文',
    direction: TextDirection.ltr,
    languagePageTitle: '选择您的语言',
    languagePageSubtitle: '请以您最熟悉的语言开始。',
    chooseLanguage: '工人社区可用语言',
    servicePageTitle: '官方查询，更简单',
    servicePageSubtitle: '选择您需要的服务。每个选项都会打开马来西亚官方网站。',
    visaTitle: '签证状态',
    visaDescription: '查询签证申请和移民状态。',
    fomemaTitle: 'FOMEMA 查询',
    fomemaDescription: '查询 FOMEMA 医疗筛查状态。',
    officialService: '马来西亚官方服务',
    adTitle: '广告',
    adSubtitle: '预留给未来合作伙伴或对工人有用的信息。',
    creditTitle: '为工人而做，用心打造',
    creatorCredit: '由 Khandaker Md Borhan Kabir (@bk4ivv) 创建，他是在马来西亚工作的外籍工人及金属 CNC 操作员。此应用旨在让工人更容易使用官方签证状态和 FOMEMA 查询服务。感谢安装此应用；如有建议，请通过 email 联系。',
    contact: '通过 email 联系',
    backToLanguages: '更改语言',
    backToServices: '返回服务',
    reload: '重新加载页面',
    contactTitle: 'email 联系方式',
  ),
  AppLanguage.vietnamese: AppCopy(
    languageName: 'Tiếng Việt',
    direction: TextDirection.ltr,
    languagePageTitle: 'Chọn ngôn ngữ của bạn',
    languagePageSubtitle:
        'Bắt đầu bằng ngôn ngữ mà bạn cảm thấy thoải mái nhất.',
    chooseLanguage: 'Ngôn ngữ cho cộng đồng người lao động',
    servicePageTitle: 'Kiểm tra chính thức, dễ dàng hơn',
    servicePageSubtitle: 'Chọn dịch vụ bạn cần. Mỗi lựa chọn sẽ mở trang chính thức của Malaysia.',
    visaTitle: 'Tình trạng thị thực',
    visaDescription: 'Kiểm tra hồ sơ thị thực và tình trạng nhập cư.',
    fomemaTitle: 'Kiểm tra FOMEMA',
    fomemaDescription: 'Kiểm tra tình trạng sàng lọc y tế FOMEMA.',
    officialService: 'Dịch vụ chính thức của Malaysia',
    adTitle: 'Quảng cáo',
    adSubtitle: 'Không gian dành cho đối tác tương lai hoặc thông tin hữu ích cho người lao động.',
    creditTitle: 'Được tạo cho người lao động, với sự quan tâm',
    creatorCredit: 'Ứng dụng này được tạo bởi Khandaker Md Borhan Kabir (@bk4ivv), một lao động nước ngoài tại Malaysia và Nhân viên vận hành CNC kim loại. Ứng dụng giúp người lao động tiếp cận dễ dàng các dịch vụ chính thức về Tình trạng thị thực và Kiểm tra FOMEMA. Cảm ơn bạn đã cài đặt; hãy gửi góp ý qua email.',
    contact: 'Liên hệ qua email',
    backToLanguages: 'Đổi ngôn ngữ',
    backToServices: 'Quay lại dịch vụ',
    reload: 'Tải lại trang',
    contactTitle: 'Liên hệ email',
  ),
  AppLanguage.sinhala: AppCopy(
    languageName: 'සිංහල',
    direction: TextDirection.ltr,
    languagePageTitle: 'ඔබේ භාෂාව තෝරන්න',
    languagePageSubtitle: 'ඔබට වඩාත් පහසු භාෂාවෙන් ආරම්භ කරන්න.',
    chooseLanguage: 'සේවක ප්‍රජාවන් සඳහා භාෂා',
    servicePageTitle: 'නිල පරීක්ෂණ, වඩාත් පහසුවෙන්',
    servicePageSubtitle: 'ඔබට අවශ්‍ය සේවාව තෝරන්න. සෑම විකල්පයක්ම නිල මැලේසියානු පිටුව විවෘත කරයි.',
    visaTitle: 'වීසා තත්ත්වය',
    visaDescription: 'වීසා අයදුම්පත සහ ආගමන තත්ත්වය පරීක්ෂා කරන්න.',
    fomemaTitle: 'FOMEMA පරීක්ෂාව',
    fomemaDescription: 'FOMEMA වෛද්‍ය පරීක්ෂණ තත්ත්වය පරීක්ෂා කරන්න.',
    officialService: 'නිල මැලේසියානු සේවාව',
    adTitle: 'දැන්වීම',
    adSubtitle: 'අනාගත හවුල්කරුවෙකු හෝ සේවකයන්ට ප්‍රයෝජනවත් තොරතුරු සඳහා ඉඩ වෙන් කර ඇත.',
    creditTitle: 'සේවකයන් සඳහා, සැලකිල්ලෙන් නිර්මාණය කළ',
    creatorCredit: 'මෙම යෙදුම Khandaker Md Borhan Kabir (@bk4ivv) විසින් නිර්මාණය කර ඇත. ඔහු මැලේසියාවේ විදේශීය සේවකයෙකු සහ Metal CNC Operator කෙනෙකි. සේවකයන්ට නිල Visa Status සහ FOMEMA Check සේවාවන් වෙත පහසුවෙන් පිවිසීමට මෙය නිර්මාණය කරන ලදී. ස්ථාපනය කිරීම ගැන ස්තුතියි; ඔබේ යෝජනා email හරහා එවන්න.',
    contact: 'email හරහා සම්බන්ධ වන්න',
    backToLanguages: 'භාෂාව වෙනස් කරන්න',
    backToServices: 'සේවා වෙත ආපසු යන්න',
    reload: 'පිටුව නැවත පූරණය කරන්න',
    contactTitle: 'email සම්බන්ධතාව',
  ),
  AppLanguage.korean: AppCopy(
    languageName: '한국어',
    direction: TextDirection.ltr,
    languagePageTitle: '언어를 선택하세요',
    languagePageSubtitle: '가장 편한 언어로 시작하세요.',
    chooseLanguage: '근로자를 위한 언어',
    servicePageTitle: '공식 확인을 더 쉽게',
    servicePageSubtitle: '필요한 서비스를 선택하세요. 공식 말레이시아 페이지가 앱 안에서 열립니다.',
    visaTitle: '비자 상태',
    visaDescription: '비자 신청과 이민국 상태를 확인하세요.',
    fomemaTitle: 'FOMEMA 확인',
    fomemaDescription: 'FOMEMA 건강검진 상태를 확인하세요.',
    officialService: '말레이시아 공식 서비스',
    adTitle: '광고',
    adSubtitle: '향후 파트너 또는 근로자에게 유용한 정보가 표시됩니다.',
    creditTitle: '근로자를 위해 정성껏 제작',
    creatorCredit:
        '말레이시아에서 근무하는 외국인 근로자 Khandaker Md Borhan Kabir (@bk4ivv)가 제작했습니다.',
    contact: '이메일로 문의',
    backToLanguages: '언어 변경',
    backToServices: '서비스로 돌아가기',
    reload: '페이지 새로고침',
    contactTitle: '이메일 문의',
  ),
  AppLanguage.japanese: AppCopy(
    languageName: '日本語',
    direction: TextDirection.ltr,
    languagePageTitle: '言語を選択',
    languagePageSubtitle: '使いやすい言語から始めましょう。',
    chooseLanguage: '働く人のための言語',
    servicePageTitle: '公式確認をもっと簡単に',
    servicePageSubtitle: '必要なサービスを選択してください。公式マレーシアページがアプリ内で開きます。',
    visaTitle: 'ビザの状況',
    visaDescription: 'ビザ申請と入国管理の状況を確認します。',
    fomemaTitle: 'FOMEMA確認',
    fomemaDescription: 'FOMEMA健康診断の状況を確認します。',
    officialService: 'マレーシア公式サービス',
    adTitle: '広告',
    adSubtitle: '今後のパートナーや役立つ情報のためのスペースです。',
    creditTitle: '働く人のために丁寧に制作',
    creatorCredit:
        'マレーシアで働く外国人労働者 Khandaker Md Borhan Kabir (@bk4ivv) が制作しました。',
    contact: 'メールで連絡',
    backToLanguages: '言語を変更',
    backToServices: 'サービスに戻る',
    reload: 'ページを再読み込み',
    contactTitle: 'メール連絡',
  ),
  AppLanguage.german: AppCopy(
    languageName: 'Deutsch',
    direction: TextDirection.ltr,
    languagePageTitle: 'Sprache auswählen',
    languagePageSubtitle:
        'Beginnen Sie mit der Sprache, die für Sie am bequemsten ist.',
    chooseLanguage: 'Sprachen für Arbeitnehmer',
    servicePageTitle: 'Offizielle Prüfungen, einfacher gemacht',
    servicePageSubtitle: 'Wählen Sie den gewünschten Dienst. Die offizielle Malaysia-Seite öffnet sich in der App.',
    visaTitle: 'Visastatus',
    visaDescription: 'Visumantrag und Einwanderungsstatus prüfen.',
    fomemaTitle: 'FOMEMA-Prüfung',
    fomemaDescription: 'Status der FOMEMA-Gesundheitsuntersuchung prüfen.',
    officialService: 'Offizieller malaysischer Dienst',
    adTitle: 'Werbung',
    adSubtitle: 'Platz für künftige Partner oder nützliche Informationen für Arbeitnehmer.',
    creditTitle: 'Mit Sorgfalt für Arbeitnehmer entwickelt',
    creatorCredit: 'Erstellt von Khandaker Md Borhan Kabir (@bk4ivv), einem ausländischen Arbeitnehmer und Metal-CNC-Bediener in Malaysia.',
    contact: 'Per E-Mail kontaktieren',
    backToLanguages: 'Sprache ändern',
    backToServices: 'Zurück zu den Diensten',
    reload: 'Seite neu laden',
    contactTitle: 'E-Mail-Kontakt',
  ),
  AppLanguage.french: AppCopy(
    languageName: 'Français',
    direction: TextDirection.ltr,
    languagePageTitle: 'Choisissez votre langue',
    languagePageSubtitle:
        'Commencez avec la langue qui vous convient le mieux.',
    chooseLanguage: 'Langues pour les travailleurs',
    servicePageTitle: 'Vérifications officielles, simplifiées',
    servicePageSubtitle: 'Choisissez le service dont vous avez besoin. La page officielle de Malaisie s’ouvre dans l’application.',
    visaTitle: 'Statut du visa',
    visaDescription:
        'Vérifiez la demande de visa et le statut de l’immigration.',
    fomemaTitle: 'Vérification FOMEMA',
    fomemaDescription: 'Vérifiez le statut de l’examen médical FOMEMA.',
    officialService: 'Service officiel de Malaisie',
    adTitle: 'Publicité',
    adSubtitle: 'Espace réservé à un futur partenaire ou à des informations utiles aux travailleurs.',
    creditTitle: 'Créée avec soin pour les travailleurs',
    creatorCredit: 'Créée par Khandaker Md Borhan Kabir (@bk4ivv), travailleur étranger et opérateur CNC métal en Malaisie.',
    contact: 'Contacter par e-mail',
    backToLanguages: 'Changer de langue',
    backToServices: 'Retour aux services',
    reload: 'Recharger la page',
    contactTitle: 'Contact e-mail',
  ),
  AppLanguage.spanish: AppCopy(
    languageName: 'Español',
    direction: TextDirection.ltr,
    languagePageTitle: 'Elige tu idioma',
    languagePageSubtitle: 'Empieza con el idioma que te resulte más cómodo.',
    chooseLanguage: 'Idiomas para trabajadores',
    servicePageTitle: 'Comprobaciones oficiales, más fáciles',
    servicePageSubtitle: 'Elige el servicio que necesitas. La página oficial de Malasia se abre dentro de la aplicación.',
    visaTitle: 'Estado del visado',
    visaDescription: 'Consulta la solicitud de visado y el estado migratorio.',
    fomemaTitle: 'Consulta FOMEMA',
    fomemaDescription: 'Consulta el estado del examen médico FOMEMA.',
    officialService: 'Servicio oficial de Malasia',
    adTitle: 'Publicidad',
    adSubtitle: 'Espacio reservado para futuros socios o información útil para trabajadores.',
    creditTitle: 'Creada con cuidado para trabajadores',
    creatorCredit: 'Creada por Khandaker Md Borhan Kabir (@bk4ivv), trabajador extranjero y operador de CNC metal en Malasia.',
    contact: 'Contactar por correo',
    backToLanguages: 'Cambiar idioma',
    backToServices: 'Volver a servicios',
    reload: 'Recargar página',
    contactTitle: 'Contacto por correo',
  ),
  AppLanguage.arabic: AppCopy(
    languageName: 'العربية',
    direction: TextDirection.rtl,
    languagePageTitle: 'اختر لغتك',
    languagePageSubtitle: 'ابدأ باللغة التي تشعر معها بالراحة.',
    chooseLanguage: 'لغات للعمال',
    servicePageTitle: 'فحوصات رسمية بطريقة أسهل',
    servicePageSubtitle: 'اختر الخدمة التي تحتاجها. ستفتح الصفحة الماليزية الرسمية داخل التطبيق.',
    visaTitle: 'حالة التأشيرة',
    visaDescription: 'تحقق من طلب التأشيرة وحالة الهجرة.',
    fomemaTitle: 'فحص FOMEMA',
    fomemaDescription: 'تحقق من حالة الفحص الطبي FOMEMA.',
    officialService: 'خدمة ماليزية رسمية',
    adTitle: 'إعلان',
    adSubtitle: 'مساحة لشريك مستقبلي أو معلومات مفيدة للعمال.',
    creditTitle: 'صُنع للعمال بعناية',
    creatorCredit: 'أنشأه Khandaker Md Borhan Kabir (@bk4ivv)، عامل أجنبي ومشغل CNC للمعادن في ماليزيا.',
    contact: 'تواصل عبر البريد الإلكتروني',
    backToLanguages: 'تغيير اللغة',
    backToServices: 'العودة إلى الخدمات',
    reload: 'إعادة تحميل الصفحة',
    contactTitle: 'التواصل عبر البريد',
  ),
  AppLanguage.russian: AppCopy(
    languageName: 'Русский',
    direction: TextDirection.ltr,
    languagePageTitle: 'Выберите язык',
    languagePageSubtitle: 'Начните с языка, который вам удобнее.',
    chooseLanguage: 'Языки для работников',
    servicePageTitle: 'Официальные проверки проще',
    servicePageSubtitle: 'Выберите нужную услугу. Официальная страница Малайзии откроется внутри приложения.',
    visaTitle: 'Статус визы',
    visaDescription: 'Проверьте заявление на визу и иммиграционный статус.',
    fomemaTitle: 'Проверка FOMEMA',
    fomemaDescription: 'Проверьте статус медицинского обследования FOMEMA.',
    officialService: 'Официальная служба Малайзии',
    adTitle: 'Реклама',
    adSubtitle:
        'Место для будущего партнёра или полезной информации для работников.',
    creditTitle: 'Создано с заботой о работниках',
    creatorCredit: 'Создано Khandaker Md Borhan Kabir (@bk4ivv), иностранным работником и оператором металлообрабатывающего ЧПУ в Малайзии.',
    contact: 'Связаться по электронной почте',
    backToLanguages: 'Изменить язык',
    backToServices: 'Вернуться к услугам',
    reload: 'Перезагрузить страницу',
    contactTitle: 'Контакт по электронной почте',
  ),
};

class FirstUseCopy {
  const FirstUseCopy({
    required this.question,
    required this.continueLabel,
    required this.videoLabel,
    required this.videoPending,
    required this.continueAnyway,
  });

  final String question;
  final String continueLabel;
  final String videoLabel;
  final String videoPending;
  final String continueAnyway;
}

const firstUseCopies = <AppLanguage, FirstUseCopy>{
  AppLanguage.english: FirstUseCopy(
    question: 'Do you know how to use this app?',
    continueLabel: 'Yes, continue to the app',
    videoLabel: 'Watch the user manual video',
    videoPending: 'The video guide will be added here soon.',
    continueAnyway: 'Continue anyway',
  ),
  AppLanguage.bangla: FirstUseCopy(
    question: 'আপনি কি এই অ্যাপটি ব্যবহার করতে জানেন?',
    continueLabel: 'হ্যাঁ, অ্যাপে চালিয়ে যান',
    videoLabel: 'ব্যবহার নির্দেশিকা ভিডিও দেখুন',
    videoPending: 'ভিডিও নির্দেশিকা শিগগির এখানে যোগ করা হবে।',
    continueAnyway: 'তবুও চালিয়ে যান',
  ),
  AppLanguage.malay: FirstUseCopy(
    question: 'Adakah anda tahu cara menggunakan aplikasi ini?',
    continueLabel: 'Ya, teruskan ke aplikasi',
    videoLabel: 'Tonton video panduan pengguna',
    videoPending: 'Video panduan akan ditambah di sini tidak lama lagi.',
    continueAnyway: 'Teruskan juga',
  ),
  AppLanguage.indonesian: FirstUseCopy(
    question: 'Apakah Anda tahu cara menggunakan aplikasi ini?',
    continueLabel: 'Ya, lanjutkan ke aplikasi',
    videoLabel: 'Tonton video panduan pengguna',
    videoPending: 'Video panduan akan segera ditambahkan di sini.',
    continueAnyway: 'Tetap lanjutkan',
  ),
  AppLanguage.tamil: FirstUseCopy(
    question: 'இந்த செயலியை எப்படி பயன்படுத்துவது உங்களுக்குத் தெரியுமா?',
    continueLabel: 'ஆம், செயலிக்குச் செல்லவும்',
    videoLabel: 'பயனர் வழிகாட்டி வீடியோவைப் பார்க்கவும்',
    videoPending: 'வீடியோ வழிகாட்டி விரைவில் இங்கே சேர்க்கப்படும்.',
    continueAnyway: 'எப்படியும் தொடரவும்',
  ),
  AppLanguage.urdu: FirstUseCopy(
    question: 'کیا آپ جانتے ہیں کہ اس ایپ کو کیسے استعمال کرنا ہے؟',
    continueLabel: 'ہاں، ایپ پر جاری رکھیں',
    videoLabel: 'صارف رہنما ویڈیو دیکھیں',
    videoPending: 'ویڈیو گائیڈ جلد یہاں شامل کی جائے گی۔',
    continueAnyway: 'بہر حال جاری رکھیں',
  ),
  AppLanguage.hindi: FirstUseCopy(
    question: 'क्या आप जानते हैं कि इस ऐप का उपयोग कैसे करना है?',
    continueLabel: 'हाँ, ऐप पर जारी रखें',
    videoLabel: 'उपयोगकर्ता मार्गदर्शिका वीडियो देखें',
    videoPending: 'वीडियो गाइड जल्द ही यहां जोड़ी जाएगी।',
    continueAnyway: 'फिर भी जारी रखें',
  ),
  AppLanguage.nepali: FirstUseCopy(
    question: 'तपाईंलाई यो एप कसरी प्रयोग गर्ने थाहा छ?',
    continueLabel: 'हो, एपमा जानुहोस्',
    videoLabel: 'प्रयोगकर्ता गाइड भिडियो हेर्नुहोस्',
    videoPending: 'भिडियो गाइड चाँडै यहाँ थपिनेछ।',
    continueAnyway: 'जे भए पनि जारी राख्नुहोस्',
  ),
  AppLanguage.burmese: FirstUseCopy(
    question: 'ဤအက်ပ်ကို မည်သို့အသုံးပြုရမည်ကို သင်သိပါသလား?',
    continueLabel: 'ဟုတ်ကဲ့၊ အက်ပ်သို့ ဆက်သွားပါ',
    videoLabel: 'အသုံးပြုသူလမ်းညွှန် ဗီဒီယိုကြည့်ပါ',
    videoPending: 'ဗီဒီယိုလမ်းညွှန်ကို မကြာမီ ဤနေရာတွင် ထည့်သွင်းပါမည်။',
    continueAnyway: 'မည်သို့ပင်ဖြစ်စေ ဆက်သွားပါ',
  ),
  AppLanguage.thai: FirstUseCopy(
    question: 'คุณรู้วิธีใช้แอปนี้หรือไม่?',
    continueLabel: 'ใช่ ไปที่แอปต่อ',
    videoLabel: 'ดูวิดีโอคู่มือผู้ใช้',
    videoPending: 'วิดีโอคู่มือจะเพิ่มที่นี่เร็ว ๆ นี้',
    continueAnyway: 'ไปต่อเลย',
  ),
  AppLanguage.khmer: FirstUseCopy(
    question: 'តើអ្នកដឹងពីរបៀបប្រើកម្មវិធីនេះទេ?',
    continueLabel: 'បាទ/ចាស បន្តទៅកម្មវិធី',
    videoLabel: 'មើលវីដេអូណែនាំអ្នកប្រើប្រាស់',
    videoPending: 'វីដេអូណែនាំនឹងត្រូវបន្ថែមនៅទីនេះឆាប់ៗនេះ។',
    continueAnyway: 'បន្តទោះយ៉ាងណាក៏ដោយ',
  ),
  AppLanguage.filipino: FirstUseCopy(
    question: 'Alam mo ba kung paano gamitin ang app na ito?',
    continueLabel: 'Oo, magpatuloy sa app',
    videoLabel: 'Panoorin ang video ng gabay',
    videoPending: 'Idaragdag dito ang video guide sa lalong madaling panahon.',
    continueAnyway: 'Magpatuloy pa rin',
  ),
  AppLanguage.chinese: FirstUseCopy(
    question: '您知道如何使用此应用吗？',
    continueLabel: '是，继续进入应用',
    videoLabel: '观看用户指南视频',
    videoPending: '用户指南视频很快会添加到这里。',
    continueAnyway: '仍然继续',
  ),
  AppLanguage.vietnamese: FirstUseCopy(
    question: 'Bạn có biết cách sử dụng ứng dụng này không?',
    continueLabel: 'Có, tiếp tục vào ứng dụng',
    videoLabel: 'Xem video hướng dẫn sử dụng',
    videoPending: 'Video hướng dẫn sẽ sớm được thêm tại đây.',
    continueAnyway: 'Vẫn tiếp tục',
  ),
  AppLanguage.sinhala: FirstUseCopy(
    question: 'මෙම යෙදුම භාවිත කරන ආකාරය ඔබ දන්නවාද?',
    continueLabel: 'ඔව්, යෙදුමට යන්න',
    videoLabel: 'පරිශීලක මාර්ගෝපදේශ වීඩියෝව නරඹන්න',
    videoPending: 'වීඩියෝ මාර්ගෝපදේශය ඉක්මනින් මෙහි එක් කරනු ඇත.',
    continueAnyway: 'කෙසේ වෙතත් ඉදිරියට යන්න',
  ),
  AppLanguage.korean: FirstUseCopy(
    question: '이 앱을 사용하는 방법을 알고 있나요?',
    continueLabel: '네, 앱으로 계속하기',
    videoLabel: '사용 설명서 영상 보기',
    videoPending: '사용 설명서 영상이 곧 추가됩니다.',
    continueAnyway: '그래도 계속하기',
  ),
  AppLanguage.japanese: FirstUseCopy(
    question: 'このアプリの使い方を知っていますか？',
    continueLabel: 'はい、アプリを続ける',
    videoLabel: '利用ガイド動画を見る',
    videoPending: '利用ガイド動画は近日追加されます。',
    continueAnyway: 'そのまま続ける',
  ),
  AppLanguage.german: FirstUseCopy(
    question: 'Wissen Sie, wie diese App funktioniert?',
    continueLabel: 'Ja, zur App weiter',
    videoLabel: 'Videoanleitung ansehen',
    videoPending: 'Die Videoanleitung wird bald hinzugefügt.',
    continueAnyway: 'Trotzdem fortfahren',
  ),
  AppLanguage.french: FirstUseCopy(
    question: 'Savez-vous comment utiliser cette application ?',
    continueLabel: 'Oui, continuer vers l’application',
    videoLabel: 'Voir la vidéo du guide utilisateur',
    videoPending: 'La vidéo du guide sera bientôt ajoutée.',
    continueAnyway: 'Continuer quand même',
  ),
  AppLanguage.spanish: FirstUseCopy(
    question: '¿Sabes cómo usar esta aplicación?',
    continueLabel: 'Sí, continuar a la aplicación',
    videoLabel: 'Ver el vídeo de la guía',
    videoPending: 'El vídeo de la guía se añadirá pronto.',
    continueAnyway: 'Continuar de todos modos',
  ),
  AppLanguage.arabic: FirstUseCopy(
    question: 'هل تعرف كيفية استخدام هذا التطبيق؟',
    continueLabel: 'نعم، متابعة إلى التطبيق',
    videoLabel: 'مشاهدة فيديو دليل المستخدم',
    videoPending: 'ستتم إضافة فيديو الدليل قريباً.',
    continueAnyway: 'المتابعة على أي حال',
  ),
  AppLanguage.russian: FirstUseCopy(
    question: 'Вы знаете, как пользоваться этим приложением?',
    continueLabel: 'Да, продолжить в приложении',
    videoLabel: 'Посмотреть видеоинструкцию',
    videoPending: 'Видеоинструкция скоро будет добавлена.',
    continueAnyway: 'Всё равно продолжить',
  ),
};

class LanguageVisual {
  const LanguageVisual({
    required this.accent,
    required this.wash,
    required this.motif,
  });

  final Color accent;
  final Color wash;
  final IconData motif;
}

const languageVisuals = <AppLanguage, LanguageVisual>{
  AppLanguage.english: LanguageVisual(
    accent: Color(0xFF2C5AA0),
    wash: Color(0xFFE7EEF9),
    motif: Icons.auto_awesome_mosaic_rounded,
  ),
  AppLanguage.bangla: LanguageVisual(
    accent: Color(0xFFB74B3C),
    wash: Color(0xFFF9E9E5),
    motif: Icons.diamond_outlined,
  ),
  AppLanguage.malay: LanguageVisual(
    accent: Color(0xFFB98522),
    wash: Color(0xFFFBF3DE),
    motif: Icons.grid_4x4_rounded,
  ),
  AppLanguage.indonesian: LanguageVisual(
    accent: Color(0xFF9C3C32),
    wash: Color(0xFFF8E6E3),
    motif: Icons.blur_on_rounded,
  ),
  AppLanguage.tamil: LanguageVisual(
    accent: Color(0xFF8A4C99),
    wash: Color(0xFFF3E8F6),
    motif: Icons.filter_vintage_rounded,
  ),
  AppLanguage.urdu: LanguageVisual(
    accent: Color(0xFF277A5D),
    wash: Color(0xFFE3F2EB),
    motif: Icons.change_history_rounded,
  ),
  AppLanguage.hindi: LanguageVisual(
    accent: Color(0xFFD36C2C),
    wash: Color(0xFFFAECE1),
    motif: Icons.local_fire_department_outlined,
  ),
  AppLanguage.nepali: LanguageVisual(
    accent: Color(0xFF365E9D),
    wash: Color(0xFFE8EEF8),
    motif: Icons.terrain_rounded,
  ),
  AppLanguage.burmese: LanguageVisual(
    accent: Color(0xFFB78B25),
    wash: Color(0xFFF8F1DF),
    motif: Icons.hexagon_outlined,
  ),
  AppLanguage.thai: LanguageVisual(
    accent: Color(0xFF9B5266),
    wash: Color(0xFFF6E8EC),
    motif: Icons.water_drop_outlined,
  ),
  AppLanguage.khmer: LanguageVisual(
    accent: Color(0xFF9B5B2E),
    wash: Color(0xFFF7EADF),
    motif: Icons.account_tree_outlined,
  ),
  AppLanguage.filipino: LanguageVisual(
    accent: Color(0xFF4074A6),
    wash: Color(0xFFE6EFF8),
    motif: Icons.wb_sunny_outlined,
  ),
  AppLanguage.chinese: LanguageVisual(
    accent: Color(0xFFB4413E),
    wash: Color(0xFFF8E7E5),
    motif: Icons.circle_outlined,
  ),
  AppLanguage.vietnamese: LanguageVisual(
    accent: Color(0xFFB55A2B),
    wash: Color(0xFFF9ECE3),
    motif: Icons.star_outline_rounded,
  ),
  AppLanguage.sinhala: LanguageVisual(
    accent: Color(0xFF95583B),
    wash: Color(0xFFF6EAE3),
    motif: Icons.spa_outlined,
  ),
  AppLanguage.korean: LanguageVisual(
    accent: Color(0xFF3A6EA5),
    wash: Color(0xFFE7F0F9),
    motif: Icons.waves_rounded,
  ),
  AppLanguage.japanese: LanguageVisual(
    accent: Color(0xFFB23A48),
    wash: Color(0xFFF9E7EA),
    motif: Icons.local_florist_outlined,
  ),
  AppLanguage.german: LanguageVisual(
    accent: Color(0xFF8A6E2F),
    wash: Color(0xFFF7F0DD),
    motif: Icons.architecture_rounded,
  ),
  AppLanguage.french: LanguageVisual(
    accent: Color(0xFF4966A8),
    wash: Color(0xFFE9EEFA),
    motif: Icons.auto_awesome_rounded,
  ),
  AppLanguage.spanish: LanguageVisual(
    accent: Color(0xFFB75A2B),
    wash: Color(0xFFF9ECE2),
    motif: Icons.wb_sunny_outlined,
  ),
  AppLanguage.arabic: LanguageVisual(
    accent: Color(0xFF2C806A),
    wash: Color(0xFFE5F3EE),
    motif: Icons.mosque_outlined,
  ),
  AppLanguage.russian: LanguageVisual(
    accent: Color(0xFF4D659C),
    wash: Color(0xFFE8EDF8),
    motif: Icons.ac_unit_rounded,
  ),
};

final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier<ThemeMode>(
  ThemeMode.system,
);
final ValueNotifier<AppLanguage?> activeWorkerLanguage =
    ValueNotifier<AppLanguage?>(null);
final ValueNotifier<CountryOption?> activeWorkerCountry =
    ValueNotifier<CountryOption?>(null);

class ForeignWorkerMalaysiaApp extends StatelessWidget {
  const ForeignWorkerMalaysiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, _) => MaterialApp(
        title: _appTitle,
        debugShowCheckedModeBanner: false,
        themeMode: mode,
        theme: _buildAppTheme(Brightness.light),
        darkTheme: _buildAppTheme(Brightness.dark),
        builder: (context, child) => CivicAppBackdrop(
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontFamilyFallback: ['NotoSansBengali']),
            child: child ?? const SizedBox.shrink(),
          ),
        ),
        home: const _ExitConfirmationRoot(child: WorkerLaunchPage()),
      ),
    );
  }
}

class _ExitConfirmationRoot extends StatefulWidget {
  const _ExitConfirmationRoot({required this.child});

  final Widget child;

  @override
  State<_ExitConfirmationRoot> createState() => _ExitConfirmationRootState();
}

class _ExitConfirmationRootState extends State<_ExitConfirmationRoot> {
  var _isDialogOpen = false;

  Future<void> _confirmExit() async {
    if (_isDialogOpen || !mounted) return;
    _isDialogOpen = true;
    final exitCopy = _exitCopyFor(activeWorkerLanguage.value);
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: activeWorkerLanguage.value == AppLanguage.urdu
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(dialogContext).colorScheme.onSurface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Theme.of(dialogContext).colorScheme.surface,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  exitCopy.title,
                  style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  exitCopy.body,
                  style: TextStyle(
                    color: Theme.of(dialogContext).colorScheme.onSurface
                        .withValues(alpha: 0.68),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: Text(exitCopy.stay),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: Text(exitCopy.exit),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    _isDialogOpen = false;
    if (shouldExit == true && mounted) {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage?>(
      valueListenable: activeWorkerLanguage,
      builder: (context, _, child) => PopScope<void>(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _confirmExit();
        },
        child: child!,
      ),
      child: widget.child,
    );
  }
}

class _ExitCopy {
  const _ExitCopy(this.title, this.body, this.stay, this.exit);

  final String title;
  final String body;
  final String stay;
  final String exit;
}

_ExitCopy _exitCopyFor(AppLanguage? language) {
  switch (language) {
    case AppLanguage.bangla:
      return const _ExitCopy(
        'অ্যাপ থেকে বের হবেন?',
        'আপনি এখনই অ্যাপ থেকে বের হতে পারেন অথবা ব্যবহার চালিয়ে যেতে পারেন।',
        'থাকুন',
        'বের হোন',
      );
    case AppLanguage.malay:
      return const _ExitCopy(
        'Keluar daripada aplikasi?',
        'Anda boleh terus menggunakan aplikasi atau keluar sekarang.',
        'Kekal',
        'Keluar',
      );
    case AppLanguage.indonesian:
      return const _ExitCopy(
        'Keluar dari aplikasi?',
        'Anda dapat tetap menggunakan aplikasi atau keluar sekarang.',
        'Tetap di sini',
        'Keluar',
      );
    case AppLanguage.tamil:
      return const _ExitCopy(
        'செயலியிலிருந்து வெளியேறவா?',
        'நீங்கள் செயலியில் தொடரலாம் அல்லது இப்போது வெளியேறலாம்.',
        'இருங்கள்',
        'வெளியேறு',
      );
    case AppLanguage.urdu:
      return const _ExitCopy(
        'ایپ سے باہر نکلیں؟',
        'آپ ایپ استعمال کرتے رہ سکتے ہیں یا ابھی باہر نکل سکتے ہیں۔',
        'رکیں',
        'باہر نکلیں',
      );
    case AppLanguage.hindi:
      return const _ExitCopy(
        'ऐप से बाहर निकलें?',
        'आप ऐप का उपयोग जारी रख सकते हैं या अभी बाहर निकल सकते हैं।',
        'रुकें',
        'बाहर निकलें',
      );
    case AppLanguage.nepali:
      return const _ExitCopy(
        'एपबाट बाहिर निस्कनुहुन्छ?',
        'तपाईं एप प्रयोग गरिरहन वा अहिले बाहिर निस्कन सक्नुहुन्छ।',
        'बस्नुहोस्',
        'बाहिर निस्कनुहोस्',
      );
    case AppLanguage.burmese:
      return const _ExitCopy(
        'အက်ပ်မှ ထွက်မလား?',
        'အက်ပ်ကို ဆက်သုံးနိုင်သည် သို့မဟုတ် ယခုထွက်နိုင်သည်။',
        'ဆက်နေမည်',
        'ထွက်မည်',
      );
    case AppLanguage.thai:
      return const _ExitCopy(
        'ออกจากแอปหรือไม่?',
        'คุณสามารถใช้แอปต่อหรือออกตอนนี้ได้',
        'อยู่ต่อ',
        'ออกจากแอป',
      );
    case AppLanguage.khmer:
      return const _ExitCopy(
        'ចាកចេញពីកម្មវិធី?',
        'អ្នកអាចបន្តប្រើកម្មវិធី ឬចាកចេញឥឡូវនេះ។',
        'បន្តនៅទីនេះ',
        'ចាកចេញ',
      );
    case AppLanguage.filipino:
      return const _ExitCopy(
        'Lumabas sa app?',
        'Maaari kang magpatuloy sa paggamit o lumabas ngayon.',
        'Manatili',
        'Lumabas',
      );
    case AppLanguage.chinese:
      return const _ExitCopy('退出应用？', '您可以继续使用应用，或现在退出。', '继续使用', '退出');
    case AppLanguage.vietnamese:
      return const _ExitCopy(
        'Thoát ứng dụng?',
        'Bạn có thể tiếp tục dùng ứng dụng hoặc thoát ngay bây giờ.',
        'Ở lại',
        'Thoát',
      );
    case AppLanguage.sinhala:
      return const _ExitCopy(
        'යෙදුමෙන් පිටවන්නද?',
        'ඔබට යෙදුම දිගටම භාවිතා කිරීමට හෝ දැන් පිටවීමට හැකිය.',
        'රැඳී සිටින්න',
        'පිටවන්න',
      );
    case AppLanguage.korean:
      return const _ExitCopy(
        '앱을 종료할까요?',
        '앱을 계속 사용하거나 지금 종료할 수 있습니다.',
        '계속 사용',
        '종료',
      );
    case AppLanguage.japanese:
      return const _ExitCopy(
        'アプリを終了しますか？',
        'アプリを続けて使うか、今すぐ終了できます。',
        '続ける',
        '終了',
      );
    case AppLanguage.german:
      return const _ExitCopy(
        'FIM beenden?',
        'Sie können die App weiter verwenden oder jetzt beenden.',
        'Bleiben',
        'Beenden',
      );
    case AppLanguage.french:
      return const _ExitCopy(
        'Quitter FIM ?',
        'Vous pouvez continuer à utiliser l’application ou quitter maintenant.',
        'Rester',
        'Quitter',
      );
    case AppLanguage.spanish:
      return const _ExitCopy(
        '¿Salir de FIM?',
        'Puedes seguir usando la aplicación o salir ahora.',
        'Quedarme',
        'Salir',
      );
    case AppLanguage.arabic:
      return const _ExitCopy(
        'الخروج من التطبيق؟',
        'يمكنك متابعة استخدام التطبيق أو الخروج الآن.',
        'البقاء',
        'الخروج',
      );
    case AppLanguage.russian:
      return const _ExitCopy(
        'Выйти из FIM?',
        'Можно продолжить пользоваться приложением или выйти сейчас.',
        'Остаться',
        'Выйти',
      );
    case AppLanguage.english:
    case null:
      return const _ExitCopy(
        'Exit FIM - Foreigner in Malaysia?',
        'You can continue using the app or exit now.',
        'Stay',
        'Exit app',
      );
  }
}

ThemeData _buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: isDark ? AppPalette.flagYellow : AppPalette.flagNavy,
    onPrimary: isDark ? AppPalette.flagNavy : AppPalette.flagWhite,
    secondary: AppPalette.flagRed,
    onSecondary: AppPalette.flagWhite,
    error: AppPalette.flagRed,
    onError: AppPalette.flagWhite,
    surface: isDark ? const Color(0xFF0B1242) : AppPalette.surface,
    onSurface: isDark ? const Color(0xFFF8F9FF) : AppPalette.ink,
  );
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    colorScheme: scheme,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: _CivicPageTransitionsBuilder(),
        TargetPlatform.iOS: _CivicPageTransitionsBuilder(),
        TargetPlatform.linux: _CivicPageTransitionsBuilder(),
        TargetPlatform.macOS: _CivicPageTransitionsBuilder(),
        TargetPlatform.windows: _CivicPageTransitionsBuilder(),
        TargetPlatform.fuchsia: _CivicPageTransitionsBuilder(),
      },
    ),
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.35,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: isDark ? const Color(0xFF29356E) : AppPalette.outline,
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.28 : 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? const Color(0xFF29356E) : AppPalette.outline,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 0.1,
        ),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: isDark
          ? const Color(0xFF050A34)
          : const Color(0xFFFEFEFC),
      surfaceTintColor: Colors.transparent,
      indicatorColor: isDark
          ? const Color(0xFF29356E)
          : const Color(0xFFE7EBFF),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          color: scheme.onSurface,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? scheme.primary
              : (isDark ? const Color(0xFFC8D0F5) : AppPalette.muted),
        ),
      ),
    ),
  );
}

class CivicAppBackdrop extends StatefulWidget {
  const CivicAppBackdrop({super.key, required this.child});

  final Widget child;

  @override
  State<CivicAppBackdrop> createState() => _CivicAppBackdropState();
}

class _CivicAppBackdropState extends State<CivicAppBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: isDark ? AppPalette.midnight : AppPalette.paper,
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _CivicBackdropPainter(isDark: isDark)),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: isDark ? 0.045 : 0.075,
              child: Image.asset(
                'assets/images/culture_batik_texture.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final travel = reduceMotion ? 0.0 : (_controller.value - 0.5) * 18;
            return Stack(
              children: [
                Positioned(
                  top: -54 + travel,
                  right: -74 - travel,
                  child: _CulturalOrb(
                    asset: 'assets/images/culture_rainforest_durian.jpg',
                    size: 190,
                    opacity: isDark ? 0.08 : 0.11,
                  ),
                ),
                Positioned(
                  bottom: -74 - travel,
                  left: -82 + travel,
                  child: _CulturalOrb(
                    asset: 'assets/images/culture_lrt_heritage.jpg',
                    size: 220,
                    opacity: isDark ? 0.06 : 0.085,
                  ),
                ),
              ],
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _CulturalOrb extends StatelessWidget {
  const _CulturalOrb({
    required this.asset,
    required this.size,
    required this.opacity,
  });

  final String asset;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Opacity(
        opacity: opacity,
        child: Image.asset(
          asset,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _CivicBackdropPainter extends CustomPainter {
  const _CivicBackdropPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final softWash = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.055 : 0.46);
    final blueWash = Paint()
      ..color = Colors.black.withValues(alpha: isDark ? 0.18 : 0.025);
    final rule = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.075 : 0.055)
      ..strokeWidth = 1;
    canvas.drawCircle(
      Offset(size.width * 1.08, -size.height * 0.02),
      size.width * 0.43,
      softWash,
    );
    canvas.drawCircle(
      Offset(-size.width * 0.18, size.height * 0.72),
      size.width * 0.42,
      blueWash,
    );
    for (var i = 0; i < 8; i++) {
      final start = Offset(-40, size.height * (0.09 + i * 0.16));
      final end = Offset(size.width + 40, start.dy - size.width * 0.18);
      canvas.drawLine(start, end, rule);
    }
  }

  @override
  bool shouldRepaint(covariant _CivicBackdropPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class CivicPressable extends StatefulWidget {
  const CivicPressable({
    super.key,
    required this.onTap,
    required this.child,
    this.radius = 22,
    this.color,
  });

  final VoidCallback onTap;
  final Widget child;
  final double radius;
  final Color? color;

  @override
  State<CivicPressable> createState() => _CivicPressableState();
}

class _CivicPressableState extends State<CivicPressable> {
  var _pressed = false;

  void _setPressed(bool value) {
    if (mounted) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedScale(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      scale: _pressed ? 0.985 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _pressed ? 1.5 : 0, 0),
        decoration: BoxDecoration(
          color: widget.color ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(
            color: isDark ? const Color(0xFF29356E) : AppPalette.outline,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _pressed ? 0.05 : 0.12),
              blurRadius: _pressed ? 7 : 17,
              offset: Offset(0, _pressed ? 3 : 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.radius),
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: _setPressed,
            borderRadius: BorderRadius.circular(widget.radius),
            splashColor: Theme.of(context).colorScheme.primary
                .withValues(alpha: 0.12),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class CivicPageReveal extends StatefulWidget {
  const CivicPageReveal({super.key, required this.child});

  final Widget child;

  @override
  State<CivicPageReveal> createState() => _CivicPageRevealState();
}

class _CivicPageRevealState extends State<CivicPageReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, 0.035),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    if (WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      return widget.child;
    }
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}

class _CivicPageTransitionsBuilder extends PageTransitionsBuilder {
  const _CivicPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      return child;
    }
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final fade = CurvedAnimation(
      parent: animation,
      curve: const Interval(0, 0.82, curve: Curves.easeOut),
    );
    final offset = Tween<Offset>(
      begin: const Offset(0.025, 0.012),
      end: Offset.zero,
    ).animate(curved);
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: offset, child: child),
    );
  }
}

class CivicHeroPanel extends StatefulWidget {
  const CivicHeroPanel({
    super.key,
    required this.child,
    this.accent = AppPalette.saffron,
  });

  final Widget child;
  final Color accent;

  @override
  State<CivicHeroPanel> createState() => _CivicHeroPanelState();
}

class _CivicHeroPanelState extends State<CivicHeroPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _auraController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 7200),
  );

  @override
  void initState() {
    super.initState();
    if (!WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations) {
      _auraController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _auraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motionDisabled =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppPalette.flagNavy, Color(0xFF0B1D83)],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.11)),
        boxShadow: [
          BoxShadow(
            color: AppPalette.midnight.withValues(alpha: 0.24),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.09,
                child: Image.asset(
                  'assets/images/culture_batik_texture.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          Positioned(
            right: -26,
            top: -34,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.28),
                  width: 1.2,
                ),
              ),
            ),
          ),
          Positioned(
            right: 7,
            top: -4,
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _auraController,
            builder: (context, _) {
              final t = motionDisabled ? 0.5 : _auraController.value;
              return Positioned(
                left: -34 + (t - 0.5) * 16,
                bottom: -62 - (t - 0.5) * 14,
                child: Transform.rotate(
                  angle: (t - 0.5) * 0.08,
                  child: _CulturalSignatureMark(accent: widget.accent),
                ),
              );
            },
          ),
          Positioned(
            left: 20,
            top: 0,
            child: Container(width: 56, height: 3, color: widget.accent),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: CivicPageReveal(child: widget.child),
          ),
        ],
      ),
    );
  }
}

class _CulturalSignatureMark extends StatelessWidget {
  const _CulturalSignatureMark({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.17,
      child: SizedBox(
        width: 148,
        height: 96,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/culture_lrt_heritage.jpg',
                width: 116,
                height: 116,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppPalette.flagNavy.withValues(alpha: 0.75),
                border: Border.all(
                  color: accent.withValues(alpha: 0.72),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Text(
                  'FIM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CivicSectionLabel extends StatelessWidget {
  const CivicSectionLabel({super.key, required this.label, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Container(width: 4, height: 22, color: onSurface),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.1,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class ServiceItem {
  const ServiceItem({
    required this.id,
    required this.url,
    required this.color,
    required this.icon,
    required this.badge,
    required this.logoAsset,
  });

  final ServiceId id;
  final String url;
  final Color color;
  final IconData icon;
  final String badge;
  final String logoAsset;
}

const services = <ServiceItem>[
  ServiceItem(
    id: ServiceId.visa,
    url: 'https://eservices.imi.gov.my/myimms/VPAStsInq?MAD_DOC_NO=&MAD_DOC_CTRY_CD=BGD&search=CARIAN&lang=en',
    color: Color(0xFF1A73C9),
    icon: Icons.assignment_turned_in_outlined,
    badge: 'VISA',
    logoAsset: 'assets/images/immigration-malaysia-logo.png',
  ),
  ServiceItem(
    id: ServiceId.fomema,
    url: 'https://eservices.imi.gov.my/myimms/FomemaStatus',
    color: Color(0xFF28905A),
    icon: Icons.fact_check_outlined,
    badge: 'FOMEMA',
    logoAsset: 'assets/images/fomema-logo.png',
  ),
  ServiceItem(
    id: ServiceId.student,
    url: 'https://visa.educationmalaysia.gov.my/emgs/application/searchForm/',
    color: Color(0xFFDC7A18),
    icon: Icons.school_outlined,
    badge: 'EMGS',
    logoAsset: 'assets/images/emgs-logo.jpg',
  ),
  ServiceItem(
    id: ServiceId.epf,
    url: 'https://www.kwsp.gov.my/ms/',
    color: Color(0xFF5145AA),
    icon: Icons.account_balance_wallet_outlined,
    badge: 'EPF',
    logoAsset: 'assets/images/kwsp-logo.webp',
  ),
  ServiceItem(
    id: ServiceId.cidb,
    url: 'https://cims.cidb.gov.my/pbsearch/Forms/Transactions/search.aspx',
    color: Color(0xFF137F7B),
    icon: Icons.engineering_outlined,
    badge: 'CIDB',
    logoAsset: 'assets/images/cidb-malaysia-official.png',
  ),
  ServiceItem(
    id: ServiceId.fwcms,
    url: 'https://fwcms.com.my/affiliates/',
    color: Color(0xFF1F5E96),
    icon: Icons.badge_outlined,
    badge: 'FWCMS',
    logoAsset: 'assets/images/fwcms-official.png',
  ),
];

Future<List<CountryOption>> _loadCountryOptions() async {
  final rawCountries = jsonDecode(
    await rootBundle.loadString('assets/data/iso_countries.json'),
  ) as List<dynamic>;
  final rawLanguages = jsonDecode(
    await rootBundle.loadString('assets/data/country_by_languages.json'),
  ) as List<dynamic>;
  final languageByCountry = <String, List<String>>{
    for (final item in rawLanguages)
      (item['country'] as String).toLowerCase():
          (item['languages'] as List<dynamic>).cast<String>(),
  };
  final rawCurrencies = jsonDecode(
    await rootBundle.loadString('assets/data/country_currencies.json'),
  ) as Map<String, dynamic>;
  final currencyByCountry = rawCurrencies.map(
    (key, value) => MapEntry(key.toUpperCase(), value.toString()),
  );
  return rawCountries
      .map((item) {
        final record = item as Map<String, dynamic>;
        final name = record['name'] as String;
        final languages =
            languageByCountry[name.toLowerCase()] ?? const <String>[];
        return CountryOption(
          name: name,
          code: record['alpha-2'] as String,
          region: (record['region'] as String?) ?? '',
          languages: languages.isEmpty ? const <String>['English'] : languages,
          currencyCode:
              currencyByCountry[(record['alpha-2'] as String).toUpperCase()] ??
              'USD',
        );
      })
      .where((country) => country.code != 'AQ')
      .toList(growable: false);
}

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) => const CountrySelectionPage();
}

class CountrySelectionPage extends StatefulWidget {
  const CountrySelectionPage({super.key});

  @override
  State<CountrySelectionPage> createState() => _CountrySelectionPageState();
}

class _CountrySelectionPageState extends State<CountrySelectionPage> {
  late final Future<List<CountryOption>> _countries = _loadCountryOptions();
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _chooseCountry(CountryOption country) {
    activeWorkerCountry.value = country;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CountryLanguageSelectionPage(country: country),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = appCopies[AppLanguage.english]!;
    return Scaffold(
      appBar: _AppBar(title: _appTitle),
      bottomNavigationBar: _CompactCreditBar(
        copy: copy,
        onOpenProfile: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CreatorProfilePage(copy: copy),
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<CountryOption>>(
          future: _countries,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 42,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Country data could not be loaded',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please try again. Your app content is kept on this device.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface
                              .withValues(alpha: 0.68),
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => const CountrySelectionPage(),
                          ),
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final countries = snapshot.data!
                .where(
                  (country) => country.name.toLowerCase().contains(
                    _query.trim().toLowerCase(),
                  ),
                )
                .toList(growable: false);
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
              children: [
                CivicHeroPanel(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          _workerLogoAsset,
                          width: 78,
                          height: 78,
                          fit: BoxFit.cover,
                          semanticLabel:
                              'FIM - Foreigner in Malaysia worker illustration',
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HeroStatusPill(label: 'WORKER UTILITY · MALAYSIA'),
                            SizedBox(height: 10),
                            Text(
                              'Choose your country first',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.9,
                                height: 1.03,
                              ),
                            ),
                            SizedBox(height: 7),
                            Text(
                              'Then choose your national language or English.',
                              style: TextStyle(
                                color: Color(0xFFD3E5E0),
                                fontSize: 11.5,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Where are you from?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'We will show official support routes and languages for your country. Work permission still depends on current Malaysian rules and your permit.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface
                        .withValues(alpha: 0.68),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _search,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded),
                    hintText: 'Search every country',
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CivicSectionLabel(
                  label: 'COUNTRIES',
                  trailing: _CountPill(
                    label: '${snapshot.data!.length} COUNTRIES',
                  ),
                ),
                const SizedBox(height: 10),
                for (final country in countries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: _CountryButton(
                      country: country,
                      onPressed: () => _chooseCountry(country),
                    ),
                  ),
                if (countries.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text('No country found. Try another spelling.'),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CountryLanguageSelectionPage extends StatelessWidget {
  const CountryLanguageSelectionPage({super.key, required this.country});

  final CountryOption country;

  void _chooseLanguage(BuildContext context, String languageName) {
    final language = _appLanguageForLabel(languageName) ?? AppLanguage.english;
    activeWorkerLanguage.value = language;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => FirstUseGuidePage(
          language: language,
          country: country,
          selectedLanguageName: languageName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suggestedLanguage = _countryLanguageDefaults[country.code];
    return Scaffold(
      appBar: _AppBar(
        title: country.name,
        leading: IconButton(
          tooltip: 'Back to countries',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      bottomNavigationBar: _CompactCreditBar(
        copy: appCopies[AppLanguage.english]!,
        onOpenProfile: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                CreatorProfilePage(copy: appCopies[AppLanguage.english]!),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          CivicHeroPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(country.flag, style: const TextStyle(fontSize: 34)),
                const SizedBox(height: 10),
                Text(
                  'Choose your language',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Select a national language when available, or use English for the common app interface.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.76),
                    height: 1.45,
                  ),
                ),
                if (suggestedLanguage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Suggested app language: ${appCopies[suggestedLanguage]!.languageName}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          for (final language in {...country.languages, 'English'}.toSet())
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LanguageChoiceButton(
                name: language,
                supported: _appLanguageForLabel(language) != null,
                onPressed: () => _chooseLanguage(context, language),
              ),
            ),
          const SizedBox(height: 10),
          Text(
            'For languages not yet translated in the app, English remains available while the official country-resource links still follow your selected country.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.62),
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class FirstUseGuidePage extends StatelessWidget {
  const FirstUseGuidePage({
    super.key,
    required this.language,
    this.country,
    this.selectedLanguageName,
  });

  final AppLanguage language;
  final CountryOption? country;
  final String? selectedLanguageName;

  void _continue(BuildContext context) {
    activeWorkerLanguage.value = language;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => WorkerUtilityShellPage(language: language),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = appCopies[language]!;
    final guide = firstUseCopies[language]!;
    final visual = languageVisuals[language]!;
    return Directionality(
      textDirection: copy.direction,
      child: Scaffold(
        appBar: _AppBar(
          title: _appTitle,
          leading: IconButton(
            tooltip: copy.backToLanguages,
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => const LanguageSelectionPage(),
              ),
            ),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        bottomNavigationBar: _CompactCreditBar(
          copy: copy,
          onOpenProfile: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CreatorProfilePage(copy: copy),
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: visual.wash,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: visual.accent.withValues(alpha: 0.42),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: visual.accent.withValues(alpha: 0.16),
                          blurRadius: 26,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(visual.motif, size: 46, color: visual.accent),
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  guide.question,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF163A38),
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                if (country != null) ...[
                  Text(
                    '${country!.flag}  ${country!.name} · ${selectedLanguageName ?? copy.languageName}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Text(
                  copy.languagePageSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface
                        .withValues(alpha: 0.68),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 30),
                CivicPressable(
                  radius: 19,
                  color: AppPalette.evergreen,
                  onTap: () => _continue(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 9),
                        Text(
                          guide.continueLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (sheetContext) => Directionality(
                        textDirection: copy.direction,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.ondemand_video_outlined,
                                color: Color(0xFF0E5C57),
                                size: 34,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                guide.videoPending,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF385852),
                                  fontSize: 14,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(sheetContext).pop();
                                  _continue(context);
                                },
                                child: Text(guide.continueAnyway),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_circle_outline_rounded),
                  label: Text(guide.videoLabel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: visual.accent,
                    side: BorderSide(
                      color: visual.accent.withValues(alpha: 0.55),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Reference-informed utility shell: compact worker actions, four clear destinations,
// monochrome surfaces, and retained access to every established service and country hub.
class WorkerLaunchPage extends StatefulWidget {
  const WorkerLaunchPage({super.key});

  @override
  State<WorkerLaunchPage> createState() => _WorkerLaunchPageState();
}

class _WorkerLaunchPageState extends State<WorkerLaunchPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 820),
  );
  Timer? _launchTimer;
  var _didNavigate = false;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) _openLanguageSelection();
    });
    _controller.forward();
    // Keep a timer guard as well: animation callbacks can be delayed or
    // skipped on slower devices while the first Flutter frame is starting.
    _launchTimer = Timer(
      const Duration(milliseconds: 900),
      _openLanguageSelection,
    );
  }

  void _openLanguageSelection() {
    if (!mounted || _didNavigate) return;
    _didNavigate = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LanguageSelectionPage()),
    );
  }

  @override
  void dispose() {
    _launchTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final value = Curves.easeOutCubic.transform(_controller.value);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onSurface
                              .withValues(alpha: 0.12),
                        ),
                      ),
                      child: Image.asset(_workerLogoAsset, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _appTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.7,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'OFFICIAL WORKER UTILITY · MALAYSIA',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface
                            .withValues(alpha: 0.56),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        backgroundColor: Theme.of(context).colorScheme.onSurface
                            .withValues(alpha: 0.1),
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(value * 100).round()}%',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface
                              .withValues(alpha: 0.62),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class WorkerUtilityShellPage extends StatefulWidget {
  const WorkerUtilityShellPage({super.key, required this.language});

  final AppLanguage language;

  @override
  State<WorkerUtilityShellPage> createState() => _WorkerUtilityShellPageState();
}

class _WorkerUtilityShellPageState extends State<WorkerUtilityShellPage> {
  var _selectedIndex = 0;
  var _isExitPromptOpen = false;

  AppCopy get _copy => appCopies[widget.language]!;

  Future<void> _confirmExit() async {
    if (_isExitPromptOpen || !mounted) return;
    _isExitPromptOpen = true;
    final exitCopy = _exitCopyFor(widget.language);
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: _copy.direction,
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(dialogContext).colorScheme.onSurface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Theme.of(dialogContext).colorScheme.surface,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  exitCopy.title,
                  style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(exitCopy.body, style: const TextStyle(height: 1.45)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: Text(exitCopy.stay),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: Text(exitCopy.exit),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    _isExitPromptOpen = false;
    if (shouldExit == true && mounted) await SystemNavigator.pop();
  }

  String _serviceTitle(ServiceId id) {
    switch (id) {
      case ServiceId.visa:
        return _copy.visaTitle;
      case ServiceId.fomema:
        return _copy.fomemaTitle;
      case ServiceId.student:
        return 'EMGS';
      case ServiceId.epf:
        return 'EPF / KWSP';
      case ServiceId.cidb:
        return 'CIDB CIMS';
      case ServiceId.fwcms:
        return 'FWCMS';
    }
  }

  void _openService(ServiceItem service) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StatusWebViewPage(
          title: _serviceTitle(service.id),
          url: service.url,
          copy: _copy,
        ),
      ),
    );
  }

  void _openToolsSection() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ToolsPage(language: widget.language, onTool: _openTool),
      ),
    );
  }

  void _openTool(ToolId tool) {
    switch (tool) {
      case ToolId.translate:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => TranslationHubPage(language: widget.language),
          ),
        );
      case ToolId.qrScanner:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => QrScannerPage(language: widget.language),
          ),
        );
      case ToolId.fileConverter:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => StatusWebViewPage(
              title: 'iLovePDF',
              url: 'https://www.ilovepdf.com/',
              copy: _copy,
            ),
          ),
        );
      case ToolId.exchangeRates:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ExchangeRatesPage(
              language: widget.language,
              selectedCountry: activeWorkerCountry.value,
            ),
          ),
        );
      case ToolId.trips:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => TripsPage(language: widget.language),
          ),
        );
    }
  }

  void _openCountryHub() {
    final country = activeWorkerCountry.value;
    final hasLocalizedHub =
        country != null &&
        widget.language != AppLanguage.english &&
        _countryLanguageDefaults[country.code.toUpperCase()] == widget.language;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => country == null
            ? widget.language == AppLanguage.bangla
                  ? const BanglaPriorityHubPage()
                  : CountryPriorityHubPage(
                      language: widget.language,
                      country: country,
                    )
            : country.code == 'BD' && widget.language == AppLanguage.bangla
            ? const BanglaPriorityHubPage()
            : hasLocalizedHub
            ? CountryPriorityHubPage(
                language: widget.language,
                country: country,
              )
            : GlobalCountrySupportPage(
                country: country,
                language: widget.language,
              ),
      ),
    );
  }

  String _navigationLabel(int index) {
    const labels = <AppLanguage, List<String>>{
      AppLanguage.english: ['Home', 'Learn', 'Help & info'],
      AppLanguage.bangla: ['হোম', 'শেখা', 'সহায়তা ও তথ্য'],
      AppLanguage.malay: ['Utama', 'Belajar', 'Bantuan & info'],
      AppLanguage.indonesian: ['Beranda', 'Belajar', 'Bantuan & info'],
      AppLanguage.tamil: ['முகப்பு', 'கற்றல்', 'உதவி & தகவல்'],
      AppLanguage.urdu: ['ہوم', 'سیکھیں', 'مدد اور معلومات'],
      AppLanguage.hindi: ['होम', 'सीखें', 'मदद और जानकारी'],
      AppLanguage.nepali: ['गृह', 'सिक्नुहोस्', 'सहायता र जानकारी'],
      AppLanguage.burmese: ['ပင်မ', 'လေ့လာရန်', 'အကူအညီနှင့် အချက်အလက်'],
      AppLanguage.thai: ['หน้าหลัก', 'เรียนรู้', 'ช่วยเหลือและข้อมูล'],
      AppLanguage.khmer: ['ទំព័រដើម', 'រៀន', 'ជំនួយ និងព័ត៌មាន'],
      AppLanguage.filipino: ['Home', 'Matuto', 'Tulong at impormasyon'],
      AppLanguage.chinese: ['首页', '学习', '帮助与信息'],
      AppLanguage.vietnamese: ['Trang chủ', 'Học', 'Trợ giúp & thông tin'],
      AppLanguage.sinhala: ['මුල් පිටුව', 'ඉගෙනීම', 'උදව් සහ තොරතුරු'],
      AppLanguage.korean: ['홈', '학습', '도움말 및 정보'],
      AppLanguage.japanese: ['ホーム', '学習', 'ヘルプと情報'],
      AppLanguage.german: ['Start', 'Lernen', 'Hilfe & Info'],
      AppLanguage.french: ['Accueil', 'Apprendre', 'Aide et infos'],
      AppLanguage.spanish: ['Inicio', 'Aprender', 'Ayuda e información'],
      AppLanguage.arabic: ['الرئيسية', 'تعلّم', 'المساعدة والمعلومات'],
      AppLanguage.russian: ['Главная', 'Учёба', 'Помощь и информация'],
    };
    return labels[widget.language]?[index] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _WorkerDashboardTab(
        language: widget.language,
        copy: _copy,
        serviceTitle: _serviceTitle,
        onService: _openService,
        onTool: _openTool,
        onOpenCountryHub: _openCountryHub,
        onOpenTools: _openToolsSection,
      ),
      _LearningTab(
        language: widget.language,
        onOpenCountryHub: _openCountryHub,
      ),
      _HelpTab(
        language: widget.language,
        onOpenCountryHub: _openCountryHub,
        onOpenAppInformation: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AppInformationPage(copy: _copy),
          ),
        ),
        onOpenPrivacy: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => PrivacyPage(copy: _copy)),
        ),
        onOpenCreatorProfile: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CreatorProfilePage(copy: _copy),
          ),
        ),
      ),
    ];
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Directionality(
        textDirection: _copy.direction,
        child: Scaffold(
          appBar: _AppBar(
            title: _selectedIndex == 0
                ? _appTitle
                : _navigationLabel(_selectedIndex),
            leading: IconButton(
              tooltip: _copy.backToLanguages,
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => const LanguageSelectionPage(),
                ),
              ),
              icon: const Icon(Icons.language_rounded),
            ),
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeOutCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.025, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey(_selectedIndex),
              child: pages[_selectedIndex],
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedIndex = index),
            height: 74,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.grid_view_rounded),
                label: _navigationLabel(0),
              ),
              NavigationDestination(
                icon: const Icon(Icons.menu_book_outlined),
                label: _navigationLabel(1),
              ),
              NavigationDestination(
                icon: const Icon(Icons.support_agent_outlined),
                label: _navigationLabel(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkerDashboardTab extends StatelessWidget {
  const _WorkerDashboardTab({
    required this.language,
    required this.copy,
    required this.serviceTitle,
    required this.onService,
    required this.onTool,
    required this.onOpenCountryHub,
    required this.onOpenTools,
  });

  final AppLanguage language;
  final AppCopy copy;
  final String Function(ServiceId) serviceTitle;
  final ValueChanged<ServiceItem> onService;
  final ValueChanged<ToolId> onTool;
  final VoidCallback onOpenCountryHub;
  final VoidCallback onOpenTools;

  @override
  Widget build(BuildContext context) {
    final actions = <_UtilityAction>[
      for (final service in services)
        _UtilityAction(
          label: serviceTitle(service.id),
          icon: service.icon,
          officialLogoAsset: service.logoAsset,
          onTap: () => onService(service),
        ),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      children: [
        CivicHeroPanel(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: Image.asset(_workerLogoAsset, fit: BoxFit.cover),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _HeroStatusPill(label: 'WORKER DASHBOARD'),
                    const SizedBox(height: 10),
                    Text(
                      copy.servicePageTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      copy.servicePageSubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFD8D8D2),
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _VerifiedAlertStrip(
          label: '${copy.officialService} · 999',
          onTap: onOpenCountryHub,
        ),
        const SizedBox(height: 24),
        CivicSectionLabel(
          label: copy.officialService,
          trailing: _CountPill(label: '${actions.length} SERVICES'),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.92,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) =>
              _UtilityActionTile(action: actions[index]),
        ),
        const SizedBox(height: 24),
        _UtilityListTile(
          icon: Icons.build_circle_outlined,
          title: language == AppLanguage.bangla ? 'টুলস' : 'Tools',
          subtitle: language == AppLanguage.bangla
              ? 'অনুবাদ, QR, রেট, ক্যালেন্ডার ও ফাইল কনভার্টার'
              : 'Translation, QR, rates, calendar, and file converter',
          onTap: onOpenTools,
        ),
        const SizedBox(height: 12),
        if (language != AppLanguage.english) ...[
          _UtilityListTile(
            icon: Icons.public_rounded,
            title: language == AppLanguage.bangla
                ? 'বাংলা সহায়তা কেন্দ্র'
                : _countryHubProfileFor(language).hubTitle,
            subtitle: language == AppLanguage.bangla
                ? 'শেখা, সহায়তা, সোনার রেফারেন্স ও সরকারি তথ্য'
                : _countryHubProfileFor(language).hubSubtitle,
            onTap: onOpenCountryHub,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

enum _TripMode { bus, plane, ferry, train }

class _TripProvider {
  const _TripProvider({
    required this.name,
    required this.url,
    required this.note,
  });

  final String name;
  final String url;
  final String note;
}

const _tripProviders = <_TripMode, List<_TripProvider>>{
  _TripMode.bus: [
    _TripProvider(
      name: 'redBus Malaysia',
      url: 'https://www.redbus.my/',
      note: 'Compare routes, operators, seats, and online bus tickets.',
    ),
    _TripProvider(
      name: 'BusOnlineTicket',
      url: 'https://www.busonlineticket.com/',
      note: 'Bus booking across Malaysia and Singapore.',
    ),
    _TripProvider(
      name: 'Easybook',
      url: 'https://www.easybook.com/en-my/bus',
      note: 'Bus schedules and online reservations in Malaysia.',
    ),
  ],
  _TripMode.plane: [
    _TripProvider(
      name: 'Malaysia Airlines',
      url: 'https://www.malaysiaairlines.com/my/en/home.html',
      note: 'Official Malaysia Airlines booking and manage-booking site.',
    ),
    _TripProvider(
      name: 'AirAsia',
      url: 'https://www.airasia.com/',
      note: 'Official AirAsia booking and flight search.',
    ),
    _TripProvider(
      name: 'Batik Air Malaysia',
      url: 'https://www.malindoair.com/',
      note: 'Malaysia-based airline booking and flight information.',
    ),
    _TripProvider(
      name: 'Cheapflights Malaysia',
      url: 'https://www.cheapflights.com.my/',
      note: 'Compare flight prices and routes available from Malaysia.',
    ),
    _TripProvider(
      name: 'Mynztrip',
      url: 'https://mynztrip.com/',
      note: 'Flight and travel booking option for Malaysia-based travellers.',
    ),
    _TripProvider(
      name: 'Trip.com Malaysia',
      url: 'https://my.trip.com/?locale=en-MY&curr=MYR',
      note: 'Malaysia-localized flight search and ticket booking.',
    ),
    _TripProvider(
      name: 'Google Flights',
      url: 'https://www.google.com/travel/flights',
      note: 'Compare flight schedules and fares before booking.',
    ),
  ],
  _TripMode.ferry: [
    _TripProvider(
      name: 'BusOnlineTicket Ferry',
      url: 'https://www.busonlineticket.com/booking/ferry-tickets.aspx',
      note: 'Ferry tickets for Langkawi, Tioman, Redang, Batam, Bintan, and more.',
    ),
    _TripProvider(
      name: 'Easybook Ferry',
      url: 'https://www.easybook.com/en-my/ferry',
      note: 'Online ferry booking for Malaysia routes.',
    ),
    _TripProvider(
      name: 'Malaysia Ferry',
      url: 'https://www.malaysiaferry.com/',
      note: 'Ferry route and ticket search.',
    ),
  ],
  _TripMode.train: [
    _TripProvider(
      name: 'KTMB',
      url: 'https://www.ktmb.com.my/',
      note: 'Official KTM Berhad passenger information and ticket access.',
    ),
    _TripProvider(
      name: 'BusOnlineTicket Train',
      url: 'https://www.busonlineticket.com/',
      note: 'Online bus and selected train ticket search.',
    ),
  ],
};

String _tripModeTitle(AppLanguage language, _TripMode mode) {
  if (language == AppLanguage.bangla) {
    return switch (mode) {
      _TripMode.bus => 'বাস',
      _TripMode.plane => 'বিমান',
      _TripMode.ferry => 'ফেরি',
      _TripMode.train => 'ট্রেন',
    };
  }
  return switch (mode) {
    _TripMode.bus => 'Bus',
    _TripMode.plane => 'Plane',
    _TripMode.ferry => 'Ferry',
    _TripMode.train => 'Train',
  };
}

IconData _tripModeIcon(_TripMode mode) => switch (mode) {
  _TripMode.bus => Icons.directions_bus_outlined,
  _TripMode.plane => Icons.flight_outlined,
  _TripMode.ferry => Icons.directions_boat_outlined,
  _TripMode.train => Icons.train_outlined,
};

class TripsPage extends StatelessWidget {
  const TripsPage({super.key, required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final copy = appCopies[language]!;
    final modes = _TripMode.values;
    return Directionality(
      textDirection: copy.direction,
      child: Scaffold(
        appBar: _AppBar(
          title: language == AppLanguage.bangla ? 'ভ্রমণ' : 'Trips',
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            CivicHeroPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.travel_explore_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    language == AppLanguage.bangla
                        ? 'যাতায়াতের ধরন বেছে নিন'
                        : 'Choose your way to travel',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    language == AppLanguage.bangla
                        ? 'বাস, বিমান, ফেরি বা ট্রেন বেছে নিয়ে টিকিট খোঁজার সাইট দেখুন।'
                        : 'Choose bus, plane, ferry, or train to see suitable ticket sites.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.74),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            for (final mode in modes) ...[
              _HelpActionCard(
                icon: _tripModeIcon(mode),
                title: _tripModeTitle(language, mode),
                subtitle: language == AppLanguage.bangla
                    ? 'টিকিট বুকিং সাইট দেখুন'
                    : 'Find ticket-booking websites',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        TripProvidersPage(language: language, mode: mode),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class TripProvidersPage extends StatelessWidget {
  const TripProvidersPage({
    super.key,
    required this.language,
    required this.mode,
  });

  final AppLanguage language;
  final _TripMode mode;

  @override
  Widget build(BuildContext context) {
    final copy = appCopies[language]!;
    final providers = _tripProviders[mode]!;
    final modeTitle = _tripModeTitle(language, mode);
    return Directionality(
      textDirection: copy.direction,
      child: Scaffold(
        appBar: _AppBar(
          title: language == AppLanguage.bangla
              ? '$modeTitle টিকিট'
              : '$modeTitle tickets',
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            _BanglaSection(
              icon: _tripModeIcon(mode),
              title: language == AppLanguage.bangla
                  ? '$modeTitle টিকিট খুঁজুন'
                  : 'Find $modeTitle tickets',
              body: language == AppLanguage.bangla
                  ? 'সাইটের নাম, রুট, মূল্য ও নিয়ম নিজে যাচাই করে তারপর বুক করুন।'
                  : 'Compare the route, fare, operator, and booking rules before paying.',
              color: AppPalette.flagRed,
            ),
            const SizedBox(height: 14),
            for (final provider in providers) ...[
              _HelpActionCard(
                icon: Icons.confirmation_number_outlined,
                title: provider.name,
                subtitle: provider.note,
                onTap: () => openWebsiteInApp(
                  context,
                  title: provider.name,
                  url: provider.url,
                  copy: copy,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key, required this.language, required this.onTool});

  final AppLanguage language;
  final ValueChanged<ToolId> onTool;

  @override
  Widget build(BuildContext context) {
    final copy = appCopies[language]!;
    final items = <_UtilityAction>[
      _UtilityAction(
        label: language == AppLanguage.bangla
            ? 'পাবলিক হলিডে ক্যালেন্ডার'
            : 'Public holiday calendar',
        icon: Icons.calendar_month_outlined,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => HolidayCalendarPage(language: language),
          ),
        ),
      ),
      _UtilityAction(
        label: language == AppLanguage.bangla ? 'অনুবাদ' : 'Translate',
        icon: Icons.translate_rounded,
        onTap: () => onTool(ToolId.translate),
      ),
      _UtilityAction(
        label: _exchangeTitleFor(language),
        icon: Icons.currency_exchange_rounded,
        onTap: () => onTool(ToolId.exchangeRates),
      ),
      _UtilityAction(
        label: _toolCopyFor(language).scanAction,
        icon: Icons.qr_code_scanner_rounded,
        onTap: () => onTool(ToolId.qrScanner),
      ),
      _UtilityAction(
        label: 'iLovePDF',
        icon: Icons.picture_as_pdf_outlined,
        onTap: () => onTool(ToolId.fileConverter),
      ),
      _UtilityAction(
        label: language == AppLanguage.bangla
            ? 'ভ্রমণ ও ফ্লাইট'
            : 'Trips & flights',
        icon: Icons.flight_takeoff_rounded,
        onTap: () => onTool(ToolId.trips),
      ),
    ];
    return Directionality(
      textDirection: copy.direction,
      child: Scaffold(
        appBar: _AppBar(
          title: language == AppLanguage.bangla ? 'টুলস' : 'Tools',
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            CivicHeroPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _HeroStatusPill(label: 'SECONDARY WORKER TOOLS'),
                  const SizedBox(height: 10),
                  Text(
                    language == AppLanguage.bangla
                        ? 'প্রয়োজনের সময় দরকারি টুল'
                        : 'Useful tools when you need them',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    language == AppLanguage.bangla
                        ? 'সরকারি সেবার পরিপূরক হিসেবে এই টুলগুলো ব্যবহার করুন।'
                        : 'Supporting tools, kept separate from the main official services.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.76),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            for (final item in items) ...[
              _UtilityListTile(
                icon: item.icon,
                title: item.label,
                subtitle: '',
                onTap: item.onTap,
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _UtilityAction {
  const _UtilityAction({
    required this.label,
    required this.icon,
    this.officialLogoAsset,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String? officialLogoAsset;
  final VoidCallback onTap;
}

// Official-service actions display their verified source mark; general utilities keep glyphs.
class _UtilityActionTile extends StatelessWidget {
  const _UtilityActionTile({required this.action});

  final _UtilityAction action;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final scheme = Theme.of(context).colorScheme;
    final hasOfficialLogo = action.officialLogoAsset != null;
    return CivicPressable(
      radius: 20,
      onTap: action.onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: hasOfficialLogo ? 72 : 42,
              height: 42,
              decoration: BoxDecoration(
                color: hasOfficialLogo
                    ? scheme.onSurface.withValues(alpha: 0.07)
                    : scheme.primary.withValues(alpha: 0.12),
                shape: hasOfficialLogo ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: hasOfficialLogo
                    ? BorderRadius.circular(12)
                    : null,
                border: hasOfficialLogo
                    ? Border.all(
                        color: scheme.onSurface.withValues(alpha: 0.14),
                      )
                    : null,
              ),
              child: hasOfficialLogo
                  ? Semantics(
                      label: '${action.label} official logo',
                      image: true,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Image.asset(
                          action.officialLogoAsset!,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          excludeFromSemantics: true,
                        ),
                      ),
                    )
                  : Icon(action.icon, color: scheme.primary, size: 22),
            ),
            const SizedBox(height: 9),
            Text(
              action.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: onSurface,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerifiedAlertStrip extends StatelessWidget {
  const _VerifiedAlertStrip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primary.withValues(alpha: 0.11),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.verified_outlined, color: scheme.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _UtilityListTile extends StatelessWidget {
  const _UtilityListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return CivicPressable(
      radius: 22,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: onSurface),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: onSurface,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.64),
                      fontSize: 11.2,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningTab extends StatelessWidget {
  const _LearningTab({required this.language, required this.onOpenCountryHub});

  final AppLanguage language;
  final VoidCallback onOpenCountryHub;

  @override
  Widget build(BuildContext context) {
    final isBangla = language == AppLanguage.bangla;
    final profile = language == AppLanguage.english
        ? null
        : _countryHubProfileFor(language);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        CivicHeroPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeroStatusPill(label: 'LEARNING SPACE'),
              const SizedBox(height: 14),
              Text(
                isBangla
                    ? 'মালাই ভাষা শিখুন'
                    : profile?.phrasebookTitle ?? 'Practical language tools',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isBangla
                    ? '৫৯৫টি বাক্য এবং ১,২০০টি দরকারি শব্দ অফলাইনে দেখুন।'
                    : profile?.phrasebookSubtitle ?? 'Use translation tools for day-to-day Bahasa Melayu communication.',
                style: const TextStyle(
                  color: Color(0xFFD8D8D2),
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _LearningCoverageChip(
                icon: Icons.chat_bubble_outline_rounded,
                value: '595',
                label: isBangla ? 'বাক্য' : 'Sentences',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _LearningCoverageChip(
                icon: Icons.menu_book_outlined,
                value: '1,200',
                label: isBangla ? 'শব্দ' : 'Words',
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _UtilityListTile(
          icon: Icons.menu_book_outlined,
          title: isBangla
              ? 'বাক্য ও শব্দের লাইব্রেরি'
              : profile?.phrasebookTitle ?? 'Google Translate',
          subtitle: isBangla
              ? 'ক্যাটাগরি, উচ্চারণ এবং বাংলা অর্থসহ শেখার লাইব্রেরি'
              : profile?.primaryMeaning ??
                    'Translate text, voice, and documents into Bahasa Melayu.',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CountryPhrasebookPage(
                language: language,
                profile: countryHubProfiles[language],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _UtilityListTile(
          icon: Icons.record_voice_over_outlined,
          title: isBangla
              ? 'জরুরি কথাবার্তা'
              : profile?.supportTitle ?? 'Voice & document translation',
          subtitle: isBangla
              ? 'ক্লিনিক, যাতায়াত, কাজ ও জরুরি সময়ের দরকারি ভাষা'
              : profile?.emergencyMeaning ??
                    'Speak or upload a document for translation.',
          onTap: () => isBangla ? onOpenCountryHub() : onOpenCountryHub(),
        ),
      ],
    );
  }
}

class _LearningCoverageChip extends StatelessWidget {
  const _LearningCoverageChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.63),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpTab extends StatelessWidget {
  const _HelpTab({
    required this.language,
    required this.onOpenCountryHub,
    required this.onOpenAppInformation,
    required this.onOpenPrivacy,
    required this.onOpenCreatorProfile,
  });

  final AppLanguage language;
  final VoidCallback onOpenCountryHub;
  final VoidCallback onOpenAppInformation;
  final VoidCallback onOpenPrivacy;
  final VoidCallback onOpenCreatorProfile;

  @override
  Widget build(BuildContext context) {
    final copy = appCopies[language]!;
    final isBangla = language == AppLanguage.bangla;
    final isEnglish = language == AppLanguage.english;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        CivicHeroPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeroStatusPill(label: 'HELP CENTRE · MALAYSIA'),
              const SizedBox(height: 14),
              Text(
                isBangla ? 'সাহায্য দরকার?' : 'Need help?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                isBangla
                    ? 'জরুরি যোগাযোগ, সরকারি সহায়তা এবং দরকারি তথ্য এক জায়গায়।'
                    : 'Emergency contacts, official support, and practical information in one place.',
                style: const TextStyle(
                  color: Color(0xFFD8D8D2),
                  fontSize: 12.5,
                  height: 1.42,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        CivicSectionLabel(
          label: isBangla ? 'দ্রুত সহায়তা' : 'Quick help',
          trailing: const _CountPill(label: '999 READY'),
        ),
        const SizedBox(height: 12),
        _HelpActionCard(
          icon: Icons.support_agent_rounded,
          title: isBangla ? 'আমার সাহায্য দরকার' : 'I need assistance',
          subtitle: isBangla
              ? 'কাজ, ক্লিনিক, যাতায়াত ও দরকারি সেবার তথ্য'
              : 'Practical support for work, clinics, transport, and services',
          onTap: onOpenCountryHub,
        ),
        const SizedBox(height: 12),
        _HelpActionCard(
          icon: Icons.emergency_rounded,
          title: isBangla ? 'এটি জরুরি অবস্থা' : 'This is an emergency',
          subtitle: isBangla
              ? 'পুলিশ, অ্যাম্বুলেন্স, ফায়ার বা তাৎক্ষণিক বিপদ'
              : 'Police, ambulance, fire, or immediate danger',
          danger: true,
          onTap: () => openAppDestination(
            context,
            title: 'Malaysia emergency 999',
            url: 'tel:999',
            copy: copy,
          ),
        ),
        const SizedBox(height: 12),
        _HelpActionCard(
          icon: Icons.badge_outlined,
          title: 'Immigration MyGCC',
          subtitle: isBangla
              ? 'ইমিগ্রেশন তথ্য ও সহায়তা · +60 3-8000 8000'
              : 'Immigration information and support · +60 3-8000 8000',
          onTap: () => openAppDestination(
            context,
            title: 'Immigration MyGCC',
            url: 'tel:+60380008000',
            copy: copy,
          ),
        ),
        const SizedBox(height: 22),
        CivicSectionLabel(label: isBangla ? 'আরও তথ্য' : 'More information'),
        const SizedBox(height: 12),
        _HelpActionCard(
          icon: Icons.public_outlined,
          title: isBangla
              ? 'দেশভিত্তিক সহায়তা'
              : isEnglish
              ? 'Country support'
              : _countryHubProfileFor(language).supportTitle,
          subtitle: isEnglish
              ? 'Choose a language to access country-specific sources.'
              : _countryHubProfileFor(language).supportSubtitle,
          onTap: isEnglish ? () {} : onOpenCountryHub,
        ),
        const SizedBox(height: 12),
        _HelpActionCard(
          icon: Icons.info_outline_rounded,
          title: isBangla ? 'অ্যাপ সম্পর্কে' : 'About FIM',
          subtitle: isBangla
              ? 'অ্যাপটি কেন তৈরি, কীভাবে কাজ করে ও ফ্রি ব্যবহারের তথ্য'
              : 'Why FIM exists, how it works, and free-use information',
          onTap: onOpenAppInformation,
        ),
        const SizedBox(height: 12),
        _HelpActionCard(
          icon: Icons.privacy_tip_outlined,
          title: isBangla ? 'গোপনীয়তা নীতি' : 'Privacy policy',
          subtitle: isBangla
              ? 'ডেটা, ক্যামেরা, বাহ্যিক সেবা ও আপনার নিয়ন্ত্রণ'
              : 'Data, camera access, external services, and your controls',
          onTap: onOpenPrivacy,
        ),
        const SizedBox(height: 12),
        _HelpActionCard(
          icon: Icons.badge_outlined,
          title: isBangla
              ? 'নির্মাতার ক্রেডিট ও যোগাযোগ'
              : 'Creator credit & contact',
          subtitle: isBangla
              ? 'অ্যাপটি কে তৈরি করেছেন এবং কাজের জন্য কীভাবে যোগাযোগ করবেন'
              : 'Who made the app and how to contact the creator for work',
          onTap: onOpenCreatorProfile,
        ),
      ],
    );
  }
}

class _HelpActionCard extends StatelessWidget {
  const _HelpActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = danger ? scheme.error : scheme.primary;
    return CivicPressable(
      radius: 24,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: accent, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.68),
                      fontSize: 11.8,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceHomePage extends StatelessWidget {
  const ServiceHomePage({super.key, required this.language});

  final AppLanguage language;

  AppCopy get _copy => appCopies[language]!;

  String _titleFor(ServiceId id) {
    switch (id) {
      case ServiceId.visa:
        return _copy.visaTitle;
      case ServiceId.fomema:
        return _copy.fomemaTitle;
      case ServiceId.student:
        return 'EMGS';
      case ServiceId.epf:
        return 'EPF / KWSP i-Akaun';
      case ServiceId.cidb:
        return 'Construction Industry Development Board search portal.';
      case ServiceId.fwcms:
        return 'Foreign Worker Centralized Management System resources.';
    }
  }

  String _descriptionFor(ServiceId id) {
    switch (id) {
      case ServiceId.visa:
        return _copy.visaDescription;
      case ServiceId.fomema:
        return _copy.fomemaDescription;
      case ServiceId.student:
        return 'Education Malaysia Global Services';
      case ServiceId.epf:
        return 'Open the Employees Provident Fund and i-Akaun information portal.';
      case ServiceId.cidb:
        return 'Search construction personnel information through CIDB CIMS.';
      case ServiceId.fwcms:
        return 'Open official FWCMS affiliate and worker-management information.';
    }
  }

  void _openService(BuildContext context, ServiceItem service) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StatusWebViewPage(
          title: _titleFor(service.id),
          url: service.url,
          copy: _copy,
        ),
      ),
    );
  }

  void _openCreatorProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => CreatorProfilePage(copy: _copy)),
    );
  }

  void _openTool(BuildContext context, ToolId tool) {
    switch (tool) {
      case ToolId.translate:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => TranslationHubPage(language: language),
          ),
        );
      case ToolId.qrScanner:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => QrScannerPage(language: language),
          ),
        );
      case ToolId.fileConverter:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => StatusWebViewPage(
              title: 'iLovePDF',
              url: 'https://www.ilovepdf.com/',
              copy: _copy,
            ),
          ),
        );
      case ToolId.exchangeRates:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ExchangeRatesPage(
              language: language,
              selectedCountry: activeWorkerCountry.value,
            ),
          ),
        );
      case ToolId.trips:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => TripsPage(language: language),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _copy.direction,
      child: Scaffold(
        appBar: _AppBar(
          title: _appTitle,
          leading: IconButton(
            tooltip: _copy.backToLanguages,
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => const LanguageSelectionPage(),
              ),
            ),
            icon: const Icon(Icons.language_rounded),
          ),
        ),
        bottomNavigationBar: _CreatorCreditPanel(
          copy: _copy,
          onOpenProfile: () => _openCreatorProfile(context),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
            children: [
              CivicHeroPanel(
                accent: AppPalette.saffron,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _HeroStatusPill(label: 'OFFICIAL ACCESS'),
                    const SizedBox(height: 14),
                    Text(
                      _copy.servicePageTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        height: 1.06,
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _copy.servicePageSubtitle,
                      style: const TextStyle(
                        color: Color(0xFFD5E8E3),
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 27),
              if (language != AppLanguage.english) ...[
                _LocalizedPriorityEntry(
                  profile: _countryHubProfileFor(language),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => language == AppLanguage.bangla
                          ? const BanglaPriorityHubPage()
                          : CountryPriorityHubPage(language: language),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
              ],
              const CivicSectionLabel(label: 'Official services'),
              const SizedBox(height: 10),
              for (final service in services) ...[
                _ServiceButton(
                  title: _titleFor(service.id),
                  description: _descriptionFor(service.id),
                  officialService: _copy.officialService,
                  service: service,
                  onPressed: () => _openService(context, service),
                ),
                const SizedBox(height: 14),
              ],
              _CalendarFeatureCard(
                copy: _copy,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => HolidayCalendarPage(language: language),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              CivicSectionLabel(label: _toolCopyFor(language).toolsTitle),
              const SizedBox(height: 10),
              _ToolFeatureCard(
                title: 'Google Translate',
                description: _toolCopyFor(language).translateDescription,
                icon: Icons.translate_rounded,
                color: const Color(0xFF1A73E8),
                onPressed: () => _openTool(context, ToolId.translate),
              ),
              const SizedBox(height: 10),
              _ToolFeatureCard(
                title: _exchangeTitleFor(language),
                description: _exchangeDescriptionFor(language),
                icon: Icons.currency_exchange_rounded,
                color: const Color(0xFFB4232A),
                onPressed: () => _openTool(context, ToolId.exchangeRates),
              ),
              const SizedBox(height: 10),
              _ToolFeatureCard(
                title: _toolCopyFor(language).scanAction,
                description: _toolCopyFor(language).qrDescription,
                icon: Icons.qr_code_scanner_rounded,
                color: const Color(0xFF5E35B1),
                onPressed: () => _openTool(context, ToolId.qrScanner),
              ),
              const SizedBox(height: 10),
              _ToolFeatureCard(
                title: 'iLovePDF',
                description: _toolCopyFor(language).converterDescription,
                icon: Icons.picture_as_pdf_outlined,
                color: const Color(0xFFE53935),
                onPressed: () => _openTool(context, ToolId.fileConverter),
              ),
              const SizedBox(height: 14),
              _FreeUseNotice(copy: _copy),
              const SizedBox(height: 12),
              _AdSlot(copy: _copy),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({required this.title, this.leading});

  final String title;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(74);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foreground = Theme.of(context).colorScheme.onSurface;
    return AppBar(
      leading: leading,
      titleSpacing: 12,
      title: Row(
        children: [
          ClipOval(
            child: Image.asset(
              _workerLogoAsset,
              width: 30,
              height: 30,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 30,
                height: 30,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.13)
                    : AppPalette.ink,
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.35,
              ),
            ),
          ),
        ],
      ),
      actions: [
        ValueListenableBuilder<ThemeMode>(
          valueListenable: appThemeMode,
          builder: (context, mode, _) => PopupMenuButton<ThemeMode>(
            tooltip: 'Appearance',
            icon: Icon(
              mode == ThemeMode.dark
                  ? Icons.dark_mode_rounded
                  : mode == ThemeMode.light
                  ? Icons.light_mode_rounded
                  : Icons.brightness_auto_rounded,
              color: foreground,
            ),
            onSelected: (value) => appThemeMode.value = value,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: ThemeMode.system,
                child: ListTile(
                  leading: Icon(Icons.brightness_auto_rounded),
                  title: Text('System default'),
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.light,
                child: ListTile(
                  leading: Icon(Icons.light_mode_rounded),
                  title: Text('Light mode'),
                ),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: ListTile(
                  leading: Icon(Icons.dark_mode_rounded),
                  title: Text('Dark mode'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(5),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 72,
            height: 2,
            margin: const EdgeInsets.only(left: 20, bottom: 3),
            color: foreground,
          ),
        ),
      ),
    );
  }
}

class _HeroStatusPill extends StatelessWidget {
  const _HeroStatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFF6F6F4),
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.75,
        ),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppPalette.softGold,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppPalette.saffron.withValues(alpha: 0.20)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppPalette.ink,
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.55,
        ),
      ),
    );
  }
}

class _CountryButton extends StatelessWidget {
  const _CountryButton({required this.country, required this.onPressed});

  final CountryOption country;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = country.isMalaysiaWorkerSourceCountry
        ? 'Malaysia-listed source country'
        : 'Eligibility check required';
    return CivicPressable(
      radius: 18,
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Text(country.flag, style: const TextStyle(fontSize: 23)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    country.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    status,
                    style: TextStyle(
                      color: country.isMalaysiaWorkerSourceCountry
                          ? scheme.primary
                          : scheme.onSurface.withValues(alpha: 0.58),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: scheme.onSurface.withValues(alpha: 0.58),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageChoiceButton extends StatelessWidget {
  const _LanguageChoiceButton({
    required this.name,
    required this.supported,
    required this.onPressed,
  });

  final String name;
  final bool supported;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CivicPressable(
      radius: 18,
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(Icons.translate_rounded, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (supported)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'In app',
                  style: TextStyle(
                    color: scheme.onPrimaryContainer,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            else
              Text(
                'English fallback',
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.56),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              color: scheme.onSurface.withValues(alpha: 0.58),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceButton extends StatelessWidget {
  const _ServiceButton({
    required this.title,
    required this.description,
    required this.officialService,
    required this.service,
    required this.onPressed,
  });

  final String title;
  final String description;
  final String officialService;
  final ServiceItem service;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CivicPressable(
      radius: 22,
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 15, 14, 15),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 54,
              decoration: BoxDecoration(
                color: service.color,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: service.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Image.asset(
                  service.logoAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      Icon(service.icon, color: service.color, size: 23),
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: service.color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      officialService.toUpperCase(),
                      style: TextStyle(
                        color: service.color,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppPalette.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppPalette.muted,
                      fontSize: 11.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: service.color.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_outward_rounded,
                color: service.color,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolFeatureCard extends StatelessWidget {
  const _ToolFeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CivicPressable(
      radius: 20,
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.13)),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppPalette.ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppPalette.muted,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.08),
              ),
              child: Icon(Icons.arrow_outward_rounded, color: color, size: 17),
            ),
          ],
        ),
      ),
    );
  }
}

class TranslationHubPage extends StatefulWidget {
  const TranslationHubPage({super.key, required this.language});

  final AppLanguage language;

  @override
  State<TranslationHubPage> createState() => _TranslationHubPageState();
}

class _TranslationHubPageState extends State<TranslationHubPage> {
  final TextEditingController _textController = TextEditingController();

  AppCopy get _copy => appCopies[widget.language]!;
  ToolCopy get _toolCopy => _toolCopyFor(widget.language);

  String get _sourceLanguageCode {
    switch (widget.language) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.bangla:
        return 'bn';
      case AppLanguage.malay:
        return 'ms';
      case AppLanguage.indonesian:
        return 'id';
      case AppLanguage.tamil:
        return 'ta';
      case AppLanguage.urdu:
        return 'ur';
      case AppLanguage.hindi:
        return 'hi';
      case AppLanguage.nepali:
        return 'ne';
      case AppLanguage.burmese:
        return 'my';
      case AppLanguage.thai:
        return 'th';
      case AppLanguage.khmer:
        return 'km';
      case AppLanguage.filipino:
        return 'tl';
      case AppLanguage.chinese:
        return 'zh-CN';
      case AppLanguage.vietnamese:
        return 'vi';
      case AppLanguage.sinhala:
        return 'si';
      case AppLanguage.korean:
        return 'ko';
      case AppLanguage.japanese:
        return 'ja';
      case AppLanguage.german:
        return 'de';
      case AppLanguage.french:
        return 'fr';
      case AppLanguage.spanish:
        return 'es';
      case AppLanguage.arabic:
        return 'ar';
      case AppLanguage.russian:
        return 'ru';
    }
  }

  void _openGoogleTranslate({String mode = 'translate'}) {
    final query = <String, String>{
      'sl': _sourceLanguageCode,
      'tl': 'ms',
      'op': mode,
    };
    if (_textController.text.trim().isNotEmpty && mode == 'translate') {
      query['text'] = _textController.text.trim();
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StatusWebViewPage(
          title: 'Google Translate',
          url: Uri.https('translate.google.com', '/', query).toString(),
          copy: _copy,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _copy.direction,
      child: Scaffold(
        appBar: _AppBar(
          title: 'Google Translate',
          leading: IconButton(
            tooltip: _copy.backToServices,
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        bottomNavigationBar: _CompactCreditBar(
          copy: _copy,
          onOpenProfile: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CreatorProfilePage(copy: _copy),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(
              Icons.translate_rounded,
              color: Color(0xFF1A73E8),
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              _toolCopy.translateDescription,
              style: const TextStyle(
                color: Color(0xFF526A65),
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _textController,
              maxLines: 6,
              textDirection: _copy.direction,
              decoration: InputDecoration(
                hintText: _copy.languagePageSubtitle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _openGoogleTranslate,
              icon: const Icon(Icons.translate_rounded),
              label: const Text('Google Translate'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _openGoogleTranslate(),
              icon: const Icon(Icons.mic_none_rounded),
              label: Text(_toolCopy.voiceAction),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _openGoogleTranslate(mode: 'docs'),
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(_toolCopy.documentAction),
            ),
          ],
        ),
      ),
    );
  }
}

String _exchangeTitleFor(AppLanguage language) {
  switch (language) {
    case AppLanguage.bangla:
      return 'লাইভ মুদ্রা রেট';
    case AppLanguage.malay:
      return 'Kadar mata wang';
    case AppLanguage.indonesian:
      return 'Kurs mata uang';
    case AppLanguage.tamil:
      return 'நேரடி நாணய விகிதம்';
    case AppLanguage.urdu:
      return 'لائیو کرنسی ریٹ';
    case AppLanguage.hindi:
      return 'लाइव मुद्रा दर';
    case AppLanguage.nepali:
      return 'लाइभ मुद्रा दर';
    case AppLanguage.burmese:
      return 'တိုက်ရိုက် ငွေလဲနှုန်း';
    case AppLanguage.thai:
      return 'อัตราแลกเปลี่ยนสด';
    case AppLanguage.khmer:
      return 'អត្រាប្តូរប្រាក់បន្តផ្ទាល់';
    case AppLanguage.filipino:
      return 'Live na palitan ng pera';
    case AppLanguage.chinese:
      return '实时汇率';
    case AppLanguage.vietnamese:
      return 'Tỷ giá trực tiếp';
    case AppLanguage.sinhala:
      return 'සජීවී විනිමය අනුපාත';
    case AppLanguage.korean:
      return '실시간 환율';
    case AppLanguage.japanese:
      return 'リアルタイム為替レート';
    case AppLanguage.german:
      return 'Live-Wechselkurse';
    case AppLanguage.french:
      return 'Taux de change en direct';
    case AppLanguage.spanish:
      return 'Tipos de cambio en directo';
    case AppLanguage.arabic:
      return 'أسعار الصرف المباشرة';
    case AppLanguage.russian:
      return 'Курсы валют в реальном времени';
    case AppLanguage.english:
      return 'Live exchange rates';
  }
}

String _exchangeDescriptionFor(AppLanguage language) {
  switch (language) {
    case AppLanguage.bangla:
      return 'এক মুদ্রা থেকে অন্য মুদ্রার রেফারেন্স রেট দেখুন। ব্যাংক বা রেমিট্যান্স কোম্পানির চূড়ান্ত রেট ভিন্ন হতে পারে।';
    case AppLanguage.malay:
      return 'Semak kadar rujukan antara mata wang. Kadar akhir bank atau syarikat kiriman wang mungkin berbeza.';
    case AppLanguage.indonesian:
      return 'Lihat kurs referensi antar mata uang. Kurs akhir bank atau perusahaan remitansi bisa berbeda.';
    case AppLanguage.english:
      return 'Check reference rates between currencies. Final bank and remittance-provider rates can differ.';
    default:
      return 'Check reference rates between currencies. Final bank and remittance-provider rates can differ.';
  }
}

class ExchangeRatesPage extends StatefulWidget {
  const ExchangeRatesPage({
    super.key,
    required this.language,
    this.selectedCountry,
  });

  final AppLanguage language;
  final CountryOption? selectedCountry;

  @override
  State<ExchangeRatesPage> createState() => _ExchangeRatesPageState();
}

class _ExchangeRatesPageState extends State<ExchangeRatesPage> {
  final TextEditingController _amountController = TextEditingController(
    text: '100',
  );
  final Map<String, double> _rates = <String, double>{};
  late String _base;
  late String _target;
  String? _updatedAt;
  String? _error;
  bool _isLoading = true;

  AppCopy get _copy => appCopies[widget.language]!;

  @override
  void initState() {
    super.initState();
    _base = widget.selectedCountry?.currencyCode ?? 'MYR';
    _target = _base == 'MYR' ? 'USD' : 'MYR';
    _loadRates();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadRates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final client = HttpClient();
    try {
      final request = await client
          .getUrl(Uri.parse('https://open.er-api.com/v6/latest/$_base'))
          .timeout(const Duration(seconds: 12));
      final response = await request.close().timeout(
        const Duration(seconds: 12),
      );
      final body = await utf8.decoder.bind(response).join();
      final payload = jsonDecode(body) as Map<String, dynamic>;
      if (response.statusCode != 200 || payload['result'] != 'success') {
        throw const HttpException(
          'Rate provider did not return a valid response.',
        );
      }
      final rawRates = Map<String, dynamic>.from(payload['rates'] as Map);
      final parsedRates = <String, double>{
        for (final entry in rawRates.entries)
          if (entry.value is num) entry.key: (entry.value as num).toDouble(),
      };
      if (!parsedRates.containsKey(_target)) _target = 'USD';
      if (mounted) {
        setState(() {
          _rates
            ..clear()
            ..addAll(parsedRates);
          _updatedAt = payload['time_last_update_utc']?.toString();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error =
              'Unable to load rates right now. Please refresh and try again.';
          _isLoading = false;
        });
      }
    } finally {
      client.close(force: true);
    }
  }

  double get _amount =>
      double.tryParse(_amountController.text.replaceAll(',', '').trim()) ?? 0;

  double? get _converted =>
      _rates[_target] == null ? null : _amount * _rates[_target]!;

  List<String> get _currencies {
    final codes = _rates.keys.toList()..sort();
    if (!codes.contains(_base)) codes.insert(0, _base);
    return codes;
  }

  void _openExternal(BuildContext context, String url) {
    openWebsiteInApp(context, title: 'Rate source', url: url, copy: _copy);
  }

  @override
  Widget build(BuildContext context) {
    final currencies = _currencies;
    final converted = _converted;
    return Directionality(
      textDirection: _copy.direction,
      child: Scaffold(
        appBar: _AppBar(
          title: _exchangeTitleFor(widget.language),
          leading: IconButton(
            tooltip: _copy.backToServices,
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        bottomNavigationBar: _CompactCreditBar(
          copy: _copy,
          onOpenProfile: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CreatorProfilePage(copy: _copy),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7A1524), Color(0xFFBD3A34)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.currency_exchange_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Live reference rates · ${_base.toUpperCase()} → ${_target.toUpperCase()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _exchangeDescriptionFor(widget.language),
              style: const TextStyle(
                color: Color(0xFF526A65),
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixIcon: const Icon(Icons.payments_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (currencies.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                key: ValueKey<String>(_base),
                initialValue: _base,
                decoration: InputDecoration(
                  labelText: 'From currency',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                items: currencies
                    .map(
                      (code) =>
                          DropdownMenuItem(value: code, child: Text(code)),
                    )
                    .toList(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        if (value == null || value == _base) return;
                        setState(() => _base = value);
                        _loadRates();
                      },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey<String>(_target),
                initialValue: currencies.contains(_target)
                    ? _target
                    : currencies.first,
                decoration: InputDecoration(
                  labelText: 'To currency',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                items: currencies
                    .map(
                      (code) =>
                          DropdownMenuItem(value: code, child: Text(code)),
                    )
                    .toList(),
                onChanged: _isLoading
                    ? null
                    : (value) => setState(() => _target = value ?? _target),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4F1),
                border: Border.all(color: const Color(0xFFF0C7C1)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Column(
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF8C2931)),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _loadRates,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Refresh rates'),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimated conversion',
                          style: TextStyle(
                            color: Color(0xFF8C2931),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          converted == null
                              ? 'Choose two currencies'
                              : '${_amount.toStringAsFixed(2)} $_base = ${converted.toStringAsFixed(2)} $_target',
                          style: const TextStyle(
                            color: Color(0xFF5A1C25),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _updatedAt == null
                              ? 'Reference-rate update time unavailable.'
                              : 'Reference data updated: $_updatedAt',
                          style: const TextStyle(
                            color: Color(0xFF765E5A),
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _loadRates,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh reference rate'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Official Malaysia and bank rate links',
              style: TextStyle(
                color: Color(0xFF163A38),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Use these sources to compare available bank counter or remittance rates before sending money.',
              style: TextStyle(
                color: Color(0xFF61736F),
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            _RateSourceTile(
              title: 'Bank Negara Malaysia',
              subtitle: 'Official Kuala Lumpur interbank and selected counter-rate reference.',
              onPressed: () => _openExternal(
                context,
                'https://www.bnm.gov.my/exchange-rates',
              ),
            ),
            const SizedBox(height: 8),
            _RateSourceTile(
              title: 'Maybank Malaysia',
              subtitle:
                  'Foreign exchange counter rates and remittance information.',
              onPressed: () => _openExternal(
                context,
                'https://www.maybank2u.com.my/maybank2u/malaysia/en/personal/rates/forex_rates.page',
              ),
            ),
            const SizedBox(height: 8),
            _RateSourceTile(
              title: 'CIMB Malaysia',
              subtitle:
                  'Foreign exchange buying and selling counter-rate table.',
              onPressed: () => _openExternal(
                context,
                'https://www.cimb.com.my/en/business/help-and-support/rates-charges/forex-rates.html',
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Reference data: ExchangeRate-API. Rates are indicative midpoint rates, not a guaranteed bank, cash, card, or remittance settlement rate.',
              style: TextStyle(
                color: Color(0xFF73827F),
                fontSize: 10.5,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RateSourceTile extends StatelessWidget {
  const _RateSourceTile({
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE1D4D0)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.account_balance_outlined,
                color: Color(0xFF8C2931),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF3E2723),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF6F625F),
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.open_in_new_rounded,
                color: Color(0xFF8C2931),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key, required this.language});

  final AppLanguage language;

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _handled = false;

  AppCopy get _copy => appCopies[widget.language]!;
  ToolCopy get _toolCopy => _toolCopyFor(widget.language);

  void _openLens(BuildContext context) {
    openWebsiteInApp(
      context,
      title: 'Google Lens',
      url: 'https://lens.google.com/',
      copy: _copy,
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null || value.isEmpty) return;
    setState(() => _handled = true);
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) =>
                QrResultPage(language: widget.language, value: value),
          ),
        )
        .then((_) {
          if (mounted) setState(() => _handled = false);
        });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _copy.direction,
      child: Scaffold(
        appBar: _AppBar(
          title: _toolCopy.scanAction,
          leading: IconButton(
            tooltip: _copy.backToServices,
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: _onDetect,
                  ),
                  Center(
                    child: Container(
                      width: 235,
                      height: 235,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 3),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Text(
                    _toolCopy.qrDescription,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF526A65),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _openLens(context),
                    icon: const Icon(Icons.center_focus_strong_rounded),
                    label: Text(_toolCopy.lensAction),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QrResultPage extends StatelessWidget {
  const QrResultPage({super.key, required this.language, required this.value});

  final AppLanguage language;
  final String value;

  @override
  Widget build(BuildContext context) {
    final copy = appCopies[language]!;
    final toolCopy = _toolCopyFor(language);
    final uri = Uri.tryParse(value);
    return Directionality(
      textDirection: copy.direction,
      child: Scaffold(
        appBar: _AppBar(
          title: toolCopy.resultTitle,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.qr_code_2_rounded,
                color: Color(0xFF5E35B1),
                size: 68,
              ),
              const SizedBox(height: 22),
              SelectableText(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF234A43),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              if (uri != null &&
                  (uri.scheme == 'https' || uri.scheme == 'http'))
                FilledButton.icon(
                  onPressed: () => openWebsiteInApp(
                    context,
                    title: toolCopy.resultTitle,
                    url: value,
                    copy: copy,
                  ),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Open link'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdSlot extends StatelessWidget {
  const _AdSlot({required this.copy});

  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEFEA),
        border: Border.all(color: AppPalette.outline),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFDDE3DC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bookmark_outline_rounded,
              color: AppPalette.evergreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  copy.adTitle,
                  style: const TextStyle(
                    color: AppPalette.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  copy.adSubtitle,
                  style: const TextStyle(
                    color: AppPalette.muted,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeUseNotice extends StatelessWidget {
  const _FreeUseNotice({required this.copy});

  final AppCopy copy;

  bool get _isBangla => copy.languageName == 'বাংলা';

  @override
  Widget build(BuildContext context) {
    final title = _isBangla ? 'এই অ্যাপটি সম্পূর্ণ ফ্রি' : 'Free to use';
    final body = _isBangla
        ? 'কোনো সাবস্ক্রিপশন বা সার্ভিস ফি নেই। সীমিত বিজ্ঞাপন বা স্পনসর তথ্য ভবিষ্যতে অ্যাপটি বিনামূল্যে রাখতে সাহায্য করতে পারে।'
        : 'There is no subscription and no service fee. Limited ads or sponsored information may help keep this app free.';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F1EE),
        border: Border.all(color: const Color(0xFFC9DDD6)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppPalette.evergreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.volunteer_activism_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppPalette.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppPalette.muted,
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreatorCreditPanel extends StatelessWidget {
  const _CreatorCreditPanel({required this.copy, required this.onOpenProfile});

  final AppCopy copy;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isBangla = copy.languageName == 'বাংলা';
    return Material(
      color: scheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: CivicPressable(
            radius: 20,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AppInformationPage(copy: copy),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      Icons.privacy_tip_outlined,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isBangla
                              ? 'অ্যাপ তথ্য ও গোপনীয়তা'
                              : 'App information & privacy',
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isBangla
                              ? 'ফ্রি ব্যবহার, তথ্যের গোপনীয়তা ও কমিউনিটি নিরাপত্তার তথ্য দেখুন'
                              : 'Read about free use, data privacy, and Community safety',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: scheme.onSurface.withValues(alpha: 0.66),
                            fontSize: 10,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_outward_rounded,
                      color: scheme.onSurface,
                      size: 17,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactCreditBar extends StatelessWidget {
  const _CompactCreditBar({required this.copy, required this.onOpenProfile});

  final AppCopy copy;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    // Dedicated About, Privacy, and Credit destinations live in Help & info.
    return const SizedBox.shrink();
  }
}

class CreatorProfileCopy {
  const CreatorProfileCopy({
    required this.pageTitle,
    required this.viewProfile,
    required this.contactError,
    required this.aboutTitle,
    required this.aboutBody,
    required this.hireTitle,
    required this.hireBody,
    required this.contactTitle,
    required this.emailLabel,
    required this.whatsAppLabel,
    required this.facebookLabel,
  });

  final String pageTitle;
  final String viewProfile;
  final String contactError;
  final String aboutTitle;
  final String aboutBody;
  final String hireTitle;
  final String hireBody;
  final String contactTitle;
  final String emailLabel;
  final String whatsAppLabel;
  final String facebookLabel;
}

const creatorProfileCopies = <AppLanguage, CreatorProfileCopy>{
  AppLanguage.english: CreatorProfileCopy(
    pageTitle: 'Creator profile',
    viewProfile: 'View full profile',
    contactError: 'Unable to open this contact link on this device.',
    aboutTitle: 'Who made this app',
    aboutBody: 'Khandaker Md Borhan Kabir is a Malaysia-based foreign worker and Metal CNC Operator. He created FIM - Foreigner in Malaysia as a free, practical starting point for workers who need official service links without extra searching.',
    hireTitle: 'Available for work',
    hireBody: 'Need an app, website, or a simple digital tool for your business or community? You can hire Borhan for project enquiries and discuss your idea directly through the contact options below.',
    contactTitle: 'Contact & hire me',
    emailLabel: 'Email',
    whatsAppLabel: 'email',
    facebookLabel: 'Facebook profile',
  ),
  AppLanguage.bangla: CreatorProfileCopy(
    pageTitle: 'নির্মাতার প্রোফাইল',
    viewProfile: 'সম্পূর্ণ প্রোফাইল দেখুন',
    contactError: 'এই ডিভাইসে যোগাযোগের লিংক খোলা যায়নি।',
    aboutTitle: 'অ্যাপটি কে তৈরি করেছেন',
    aboutBody: 'খন্দকার মো: বোরহান কাবির মালয়েশিয়ায় কর্মরত একজন বিদেশি শ্রমিক এবং মেটাল CNC অপারেটর। কর্মীদের সরকারি সেবার লিংক সহজে খুঁজে পেতে সহায়তা করার জন্য তিনি FIM - Foreigner in Malaysia বিনামূল্যে তৈরি করেছেন।',
    hireTitle: 'কাজের জন্য উপলব্ধ',
    hireBody: 'আপনার ব্যবসা বা কমিউনিটির জন্য অ্যাপ, ওয়েবসাইট বা সহজ কোনো ডিজিটাল টুল দরকার? প্রজেক্টের জন্য বোরহানকে নিয়োগ দিতে এবং আপনার ধারণা নিয়ে কথা বলতে নিচের যোগাযোগের অপশন ব্যবহার করুন।',
    contactTitle: 'যোগাযোগ ও কাজের জন্য নিয়োগ',
    emailLabel: 'ইমেইল',
    whatsAppLabel: 'email',
    facebookLabel: 'Facebook প্রোফাইল',
  ),
  AppLanguage.malay: CreatorProfileCopy(
    pageTitle: 'Profil pencipta',
    viewProfile: 'Lihat profil penuh',
    contactError: 'Pautan hubungan ini tidak dapat dibuka pada peranti ini.',
    aboutTitle: 'Siapa yang membuat aplikasi ini',
    aboutBody: 'Khandaker Md Borhan Kabir ialah pekerja asing di Malaysia dan Operator CNC Metal. Beliau mencipta FIM - Foreigner in Malaysia secara percuma sebagai cara praktikal untuk pekerja mendapatkan pautan perkhidmatan rasmi tanpa carian yang rumit.',
    hireTitle: 'Sedia untuk bekerja',
    hireBody: 'Perlukan aplikasi, laman web atau alat digital ringkas untuk perniagaan atau komuniti anda? Anda boleh mengupah Borhan untuk pertanyaan projek dan berbincang idea anda melalui pilihan hubungan di bawah.',
    contactTitle: 'Hubungi & upah saya',
    emailLabel: 'E-mel',
    whatsAppLabel: 'email',
    facebookLabel: 'Profil Facebook',
  ),
  AppLanguage.indonesian: CreatorProfileCopy(
    pageTitle: 'Profil pembuat',
    viewProfile: 'Lihat profil lengkap',
    contactError: 'Tautan kontak ini tidak dapat dibuka di perangkat ini.',
    aboutTitle: 'Siapa yang membuat aplikasi ini',
    aboutBody: 'Khandaker Md Borhan Kabir adalah pekerja asing di Malaysia dan Operator CNC Metal. Ia membuat FIM - Foreigner in Malaysia secara gratis sebagai cara praktis agar pekerja dapat menemukan tautan layanan resmi tanpa pencarian yang rumit.',
    hireTitle: 'Tersedia untuk pekerjaan',
    hireBody: 'Butuh aplikasi, situs web, atau alat digital sederhana untuk bisnis atau komunitas Anda? Anda dapat mempekerjakan Borhan untuk pertanyaan proyek dan membahas ide melalui pilihan kontak di bawah.',
    contactTitle: 'Hubungi & pekerjakan saya',
    emailLabel: 'Email',
    whatsAppLabel: 'email',
    facebookLabel: 'Profil Facebook',
  ),
  AppLanguage.tamil: CreatorProfileCopy(
    pageTitle: 'உருவாக்குநர் சுயவிவரம்',
    viewProfile: 'முழு சுயவிவரத்தைக் காண்க',
    contactError: 'இந்த சாதனத்தில் இந்த தொடர்பு இணைப்பைத் திறக்க முடியவில்லை.',
    aboutTitle: 'இந்த செயலியை உருவாக்கியவர்',
    aboutBody: 'Khandaker Md Borhan Kabir மலேசியாவில் உள்ள வெளிநாட்டு தொழிலாளரும் Metal CNC Operator-உம் ஆவார். அதிகாரப்பூர்வ சேவை இணைப்புகளை தொழிலாளர்கள் எளிதாகப் பெற FIM - Foreigner in Malaysia-யை இலவசமாக உருவாக்கினார்.',
    hireTitle: 'வேலைக்கு கிடைக்கிறார்',
    hireBody: 'உங்கள் வணிகம் அல்லது சமூகத்திற்காக செயலி, இணையதளம் அல்லது எளிய டிஜிட்டல் கருவி தேவைப்படுகிறதா? திட்ட விசாரணைகளுக்கும் உங்கள் யோசனையைப் பேசவும் கீழே உள்ள தொடர்பு வழிகள் மூலம் Borhan-ஐ பணியமர்த்தலாம்.',
    contactTitle: 'தொடர்பு கொண்டு பணியமர்த்துங்கள்',
    emailLabel: 'மின்னஞ்சல்',
    whatsAppLabel: 'email',
    facebookLabel: 'Facebook சுயவிவரம்',
  ),
  AppLanguage.urdu: CreatorProfileCopy(
    pageTitle: 'تخلیق کار کا پروفائل',
    viewProfile: 'مکمل پروفائل دیکھیں',
    contactError: 'اس ڈیوائس پر رابطے کا لنک نہیں کھولا جا سکا۔',
    aboutTitle: 'یہ ایپ کس نے بنائی',
    aboutBody: 'Khandaker Md Borhan Kabir ملائیشیا میں ایک غیر ملکی کارکن اور Metal CNC Operator ہیں۔ انہوں نے FIM - Foreigner in Malaysia مفت بنائی تاکہ کارکن پیچیدہ تلاش کے بغیر سرکاری سروس لنکس حاصل کر سکیں۔',
    hireTitle: 'کام کے لیے دستیاب',
    hireBody: 'اپنے کاروبار یا کمیونٹی کے لیے ایپ، ویب سائٹ یا سادہ ڈیجیٹل ٹول چاہیے؟ پروجیکٹ سے متعلق بات کرنے اور اپنی تجویز پر گفتگو کے لیے نیچے موجود رابطوں کے ذریعے Borhan کو ہائر کر سکتے ہیں۔',
    contactTitle: 'رابطہ کریں اور ہائر کریں',
    emailLabel: 'ای میل',
    whatsAppLabel: 'email',
    facebookLabel: 'Facebook پروفائل',
  ),
  AppLanguage.hindi: CreatorProfileCopy(
    pageTitle: 'निर्माता की प्रोफ़ाइल',
    viewProfile: 'पूरा प्रोफ़ाइल देखें',
    contactError: 'इस डिवाइस पर संपर्क लिंक नहीं खोला जा सका।',
    aboutTitle: 'यह ऐप किसने बनाया',
    aboutBody: 'Khandaker Md Borhan Kabir मलेशिया में विदेशी कामगार और मेटल CNC ऑपरेटर हैं। उन्होंने FIM - Foreigner in Malaysia को मुफ्त बनाया ताकि कामगार बिना कठिन खोज के आधिकारिक सेवा लिंक पा सकें।',
    hireTitle: 'काम के लिए उपलब्ध',
    hireBody: 'क्या आपके व्यवसाय या समुदाय के लिए ऐप, वेबसाइट या सरल डिजिटल टूल चाहिए? परियोजना के बारे में पूछने और अपना विचार साझा करने के लिए नीचे दिए संपर्क विकल्पों से Borhan को काम पर रख सकते हैं।',
    contactTitle: 'संपर्क करें और काम पर रखें',
    emailLabel: 'ईमेल',
    whatsAppLabel: 'email',
    facebookLabel: 'Facebook प्रोफ़ाइल',
  ),
  AppLanguage.nepali: CreatorProfileCopy(
    pageTitle: 'निर्माताको प्रोफाइल',
    viewProfile: 'पूरा प्रोफाइल हेर्नुहोस्',
    contactError: 'यस उपकरणमा सम्पर्क लिङ्क खोल्न सकिएन।',
    aboutTitle: 'यो एप कसले बनायो',
    aboutBody: 'Khandaker Md Borhan Kabir मलेसियामा रहेका विदेशी कामदार र Metal CNC Operator हुनुहुन्छ। कामदारले जटिल खोजबिनै आधिकारिक सेवा लिङ्क पाउन सकून् भनेर उहाँले FIM - Foreigner in Malaysia निःशुल्क बनाउनुभयो।',
    hireTitle: 'कामका लागि उपलब्ध',
    hireBody: 'तपाईंको व्यवसाय वा समुदायका लागि एप, वेबसाइट वा सरल डिजिटल उपकरण चाहिन्छ? परियोजनाबारे सोध्न र आफ्नो विचार छलफल गर्न तलका सम्पर्क विकल्पमार्फत Borhan लाई काममा लिन सक्नुहुन्छ।',
    contactTitle: 'सम्पर्क गर्नुहोस् र काममा लिनुहोस्',
    emailLabel: 'इमेल',
    whatsAppLabel: 'email',
    facebookLabel: 'Facebook प्रोफाइल',
  ),
  AppLanguage.burmese: CreatorProfileCopy(
    pageTitle: 'ဖန်တီးသူ၏ ကိုယ်ရေးအကျဉ်း',
    viewProfile: 'ကိုယ်ရေးအကျဉ်းအပြည့်အစုံကြည့်ပါ',
    contactError: 'ဤစက်တွင် ဆက်သွယ်ရေးလင့်ခ်ကို ဖွင့်၍မရပါ။',
    aboutTitle: 'ဤအက်ပ်ကို ဖန်တီးသူ',
    aboutBody: 'Khandaker Md Borhan Kabir သည် မလေးရှားရှိ နိုင်ငံခြားအလုပ်သမားနှင့် Metal CNC Operator ဖြစ်သည်။ အလုပ်သမားများအနေဖြင့် ရှုပ်ထွေးစွာရှာဖွေစရာမလိုဘဲ တရားဝင်ဝန်ဆောင်မှုလင့်ခ်များရရှိစေရန် FIM - Foreigner in Malaysia ကို အခမဲ့ဖန်တီးခဲ့သည်။',
    hireTitle: 'အလုပ်အတွက် ရရှိနိုင်သည်',
    hireBody: 'သင့်လုပ်ငန်း သို့မဟုတ် အသိုင်းအဝိုင်းအတွက် အက်ပ်၊ ဝဘ်ဆိုဒ် သို့မဟုတ် ရိုးရှင်းသော ဒစ်ဂျစ်တယ်ကိရိယာ လိုအပ်ပါသလား။ ပရောဂျက်အကြောင်းမေးမြန်းရန်နှင့် အကြံဉာဏ်ဆွေးနွေးရန် အောက်ပါဆက်သွယ်ရေးနည်းလမ်းများမှ Borhan ကို ငှားရမ်းနိုင်သည်။',
    contactTitle: 'ဆက်သွယ်ပြီး ငှားရမ်းပါ',
    emailLabel: 'အီးမေးလ်',
    whatsAppLabel: 'email',
    facebookLabel: 'Facebook ပရိုဖိုင်',
  ),
  AppLanguage.thai: CreatorProfileCopy(
    pageTitle: 'โปรไฟล์ผู้สร้าง',
    viewProfile: 'ดูโปรไฟล์เต็ม',
    contactError: 'ไม่สามารถเปิดลิงก์ติดต่อบนอุปกรณ์นี้ได้',
    aboutTitle: 'ใครเป็นผู้สร้างแอปนี้',
    aboutBody: 'Khandaker Md Borhan Kabir เป็นแรงงานต่างชาติในมาเลเซียและ Metal CNC Operator เขาสร้าง FIM - Foreigner in Malaysia ให้ใช้งานฟรี เพื่อให้แรงงานเข้าถึงลิงก์บริการทางการได้โดยไม่ต้องค้นหายาก',
    hireTitle: 'พร้อมรับงาน',
    hireBody: 'ต้องการแอป เว็บไซต์ หรือเครื่องมือดิจิทัลอย่างง่ายสำหรับธุรกิจหรือชุมชนของคุณหรือไม่? คุณสามารถจ้าง Borhan สำหรับสอบถามโครงการและพูดคุยไอเดียผ่านช่องทางติดต่อด้านล่าง',
    contactTitle: 'ติดต่อและจ้างงาน',
    emailLabel: 'อีเมล',
    whatsAppLabel: 'email',
    facebookLabel: 'โปรไฟล์ Facebook',
  ),
  AppLanguage.khmer: CreatorProfileCopy(
    pageTitle: 'ប្រវត្តិរូបអ្នកបង្កើត',
    viewProfile: 'មើលប្រវត្តិរូបពេញលេញ',
    contactError: 'មិនអាចបើកតំណទំនាក់ទំនងនៅលើឧបករណ៍នេះបានទេ។',
    aboutTitle: 'អ្នកណាបង្កើតកម្មវិធីនេះ',
    aboutBody: 'Khandaker Md Borhan Kabir គឺជាកម្មករបរទេសនៅម៉ាឡេស៊ី និងជា Metal CNC Operator។ គាត់បានបង្កើត FIM - Foreigner in Malaysia ដោយឥតគិតថ្លៃ ដើម្បីឱ្យកម្មករទទួលបានតំណសេវាផ្លូវការដោយមិនចាំបាច់ស្វែងរកពិបាក។',
    hireTitle: 'អាចទទួលការងារ',
    hireBody: 'តើអ្នកត្រូវការកម្មវិធី គេហទំព័រ ឬឧបករណ៍ឌីជីថលសាមញ្ញសម្រាប់អាជីវកម្ម ឬសហគមន៍របស់អ្នកទេ? អ្នកអាចជួល Borhan សម្រាប់សាកសួរអំពីគម្រោង និងពិភាក្សាគំនិតតាមជម្រើសទំនាក់ទំនងខាងក្រោម។',
    contactTitle: 'ទំនាក់ទំនង និងជួលខ្ញុំ',
    emailLabel: 'អ៊ីមែល',
    whatsAppLabel: 'email',
    facebookLabel: 'ប្រវត្តិរូប Facebook',
  ),
  AppLanguage.filipino: CreatorProfileCopy(
    pageTitle: 'Profile ng gumawa',
    viewProfile: 'Tingnan ang buong profile',
    contactError:
        'Hindi mabuksan ang link sa pakikipag-ugnayan sa device na ito.',
    aboutTitle: 'Sino ang gumawa ng app na ito',
    aboutBody: 'Si Khandaker Md Borhan Kabir ay isang dayuhang manggagawa sa Malaysia at Metal CNC Operator. Ginawa niya nang libre ang FIM - Foreigner in Malaysia upang madaling makita ng mga manggagawa ang mga opisyal na link ng serbisyo.',
    hireTitle: 'Available para sa trabaho',
    hireBody: 'Kailangan ng app, website, o simpleng digital tool para sa iyong negosyo o komunidad? Maaari mong kunin si Borhan para sa mga tanong tungkol sa proyekto at pag-usapan ang iyong ideya sa mga contact option sa ibaba.',
    contactTitle: 'Makipag-ugnayan at kunin ako',
    emailLabel: 'Email',
    whatsAppLabel: 'email',
    facebookLabel: 'Profile sa Facebook',
  ),
  AppLanguage.chinese: CreatorProfileCopy(
    pageTitle: '创建者资料',
    viewProfile: '查看完整资料',
    contactError: '无法在此设备上打开联系链接。',
    aboutTitle: '谁创建了这个应用',
    aboutBody: 'Khandaker Md Borhan Kabir 是一名在马来西亚工作的外籍工人和 Metal CNC Operator。他免费创建了 FIM - Foreigner in Malaysia，让工人无需复杂搜索即可获得官方服务链接。',
    hireTitle: '可接受工作委托',
    hireBody: '您的企业或社区需要应用、网站或简单的数字工具吗？您可以通过以下联系方式聘请 Borhan 咨询项目并讨论您的想法。',
    contactTitle: '联系并聘请我',
    emailLabel: '电子邮件',
    whatsAppLabel: 'email',
    facebookLabel: 'Facebook 资料',
  ),
  AppLanguage.vietnamese: CreatorProfileCopy(
    pageTitle: 'Hồ sơ người tạo',
    viewProfile: 'Xem hồ sơ đầy đủ',
    contactError: 'Không thể mở liên kết liên hệ trên thiết bị này.',
    aboutTitle: 'Ai đã tạo ứng dụng này',
    aboutBody: 'Khandaker Md Borhan Kabir là lao động nước ngoài tại Malaysia và là Metal CNC Operator. Anh đã tạo FIM - Foreigner in Malaysia miễn phí để người lao động có thể tìm các liên kết dịch vụ chính thức mà không cần tìm kiếm phức tạp.',
    hireTitle: 'Sẵn sàng nhận việc',
    hireBody: 'Bạn cần ứng dụng, website hoặc công cụ số đơn giản cho doanh nghiệp hay cộng đồng? Bạn có thể thuê Borhan để trao đổi về dự án và ý tưởng qua các lựa chọn liên hệ bên dưới.',
    contactTitle: 'Liên hệ và thuê tôi',
    emailLabel: 'Email',
    whatsAppLabel: 'email',
    facebookLabel: 'Hồ sơ Facebook',
  ),
  AppLanguage.sinhala: CreatorProfileCopy(
    pageTitle: 'නිර්මාතෘගේ පැතිකඩ',
    viewProfile: 'සම්පූර්ණ පැතිකඩ බලන්න',
    contactError: 'මෙම උපාංගයේ සම්බන්ධතා සබැඳිය විවෘත කළ නොහැක.',
    aboutTitle: 'මෙම යෙදුම නිර්මාණය කළේ කවුද',
    aboutBody: 'Khandaker Md Borhan Kabir මැලේසියාවේ විදේශීය සේවකයෙක් සහ Metal CNC Operator කෙනෙකි. සේවකයන්ට සංකීර්ණ සෙවීම් නොකර නිල සේවා සබැඳි ලබාගැනීමට FIM - Foreigner in Malaysia නොමිලේ නිර්මාණය කළේය.',
    hireTitle: 'වැඩ සඳහා සූදානම්',
    hireBody: 'ඔබගේ ව්‍යාපාරයට හෝ ප්‍රජාවට යෙදුමක්, වෙබ් අඩවියක් හෝ සරල ඩිජිටල් මෙවලමක් අවශ්‍යද? ව්‍යාපෘති විමසීම් සහ ඔබගේ අදහස සාකච්ඡා කිරීමට පහත සම්බන්ධතා මගින් Borhan බඳවා ගත හැක.',
    contactTitle: 'සම්බන්ධ වී බඳවා ගන්න',
    emailLabel: 'ඊමේල්',
    whatsAppLabel: 'email',
    facebookLabel: 'Facebook පැතිකඩ',
  ),
};

CreatorProfileCopy _creatorProfileCopyFor(AppCopy copy) {
  final language = appCopies.entries
      .firstWhere((entry) => entry.value.languageName == copy.languageName)
      .key;
  return creatorProfileCopies[language]!;
}

String _creatorDisplayNameFor(AppCopy copy) {
  final language = appCopies.entries
      .firstWhere((entry) => entry.value.languageName == copy.languageName)
      .key;
  return language == AppLanguage.bangla
      ? 'খন্দকার মো: বোরহান কাবির'
      : 'Khandaker Md Borhan Kabir';
}

class ToolCopy {
  const ToolCopy({
    required this.toolsTitle,
    required this.translateDescription,
    required this.voiceAction,
    required this.documentAction,
    required this.qrDescription,
    required this.scanAction,
    required this.lensAction,
    required this.converterDescription,
    required this.openConverter,
    required this.resultTitle,
  });

  final String toolsTitle;
  final String translateDescription;
  final String voiceAction;
  final String documentAction;
  final String qrDescription;
  final String scanAction;
  final String lensAction;
  final String converterDescription;
  final String openConverter;
  final String resultTitle;
}

const toolCopies = <AppLanguage, ToolCopy>{
  AppLanguage.english: ToolCopy(
    toolsTitle: 'Helpful tools',
    translateDescription: 'Translate text, voice, or documents from your selected language to Bahasa Melayu with Google Translate.',
    voiceAction: 'Translate by voice',
    documentAction: 'Translate a document',
    qrDescription:
        'Scan a QR code with your camera or continue with Google Lens.',
    scanAction: 'Scan QR code',
    lensAction: 'Open Google Lens',
    converterDescription:
        'Convert, merge, split, compress, or edit documents with iLovePDF.',
    openConverter: 'Open iLovePDF',
    resultTitle: 'Scanned result',
  ),
  AppLanguage.bangla: ToolCopy(
    toolsTitle: 'উপকারী টুল',
    translateDescription: 'Google Translate ব্যবহার করে আপনার নির্বাচিত ভাষা থেকে Bahasa Melayu-তে লেখা, কণ্ঠ বা ডকুমেন্ট অনুবাদ করুন।',
    voiceAction: 'কণ্ঠে অনুবাদ করুন',
    documentAction: 'ডকুমেন্ট অনুবাদ করুন',
    qrDescription:
        'ক্যামেরা দিয়ে QR কোড স্ক্যান করুন বা Google Lens ব্যবহার করুন।',
    scanAction: 'QR কোড স্ক্যান করুন',
    lensAction: 'Google Lens খুলুন',
    converterDescription: 'iLovePDF ব্যবহার করে ডকুমেন্ট কনভার্ট, মার্জ, স্প্লিট, কমপ্রেস বা এডিট করুন।',
    openConverter: 'iLovePDF খুলুন',
    resultTitle: 'স্ক্যানের ফলাফল',
  ),
  AppLanguage.malay: ToolCopy(
    toolsTitle: 'Alat berguna',
    translateDescription: 'Terjemah teks, suara atau dokumen daripada bahasa pilihan anda ke Bahasa Melayu melalui Google Translate.',
    voiceAction: 'Terjemah melalui suara',
    documentAction: 'Terjemah dokumen',
    qrDescription:
        'Imbas kod QR dengan kamera atau teruskan dengan Google Lens.',
    scanAction: 'Imbas kod QR',
    lensAction: 'Buka Google Lens',
    converterDescription:
        'Tukar, gabung, pecah, mampat atau edit dokumen melalui iLovePDF.',
    openConverter: 'Buka iLovePDF',
    resultTitle: 'Hasil imbasan',
  ),
  AppLanguage.indonesian: ToolCopy(
    toolsTitle: 'Alat bermanfaat',
    translateDescription: 'Terjemahkan teks, suara, atau dokumen dari bahasa pilihan Anda ke Bahasa Melayu melalui Google Translate.',
    voiceAction: 'Terjemahkan dengan suara',
    documentAction: 'Terjemahkan dokumen',
    qrDescription:
        'Pindai kode QR dengan kamera atau lanjutkan dengan Google Lens.',
    scanAction: 'Pindai kode QR',
    lensAction: 'Buka Google Lens',
    converterDescription: 'Konversi, gabungkan, pisahkan, kompres, atau edit dokumen melalui iLovePDF.',
    openConverter: 'Buka iLovePDF',
    resultTitle: 'Hasil pemindaian',
  ),
  AppLanguage.tamil: ToolCopy(
    toolsTitle: 'பயனுள்ள கருவிகள்',
    translateDescription: 'Google Translate மூலம் உங்கள் தேர்ந்தெடுத்த மொழியிலிருந்து Bahasa Melayu-க்கு உரை, குரல் அல்லது ஆவணங்களை மொழிபெயர்க்கவும்.',
    voiceAction: 'குரல் மூலம் மொழிபெயர்க்கவும்',
    documentAction: 'ஆவணத்தை மொழிபெயர்க்கவும்',
    qrDescription: 'கேமராவில் QR குறியீட்டை ஸ்கேன் செய்யவும் அல்லது Google Lens பயன்படுத்தவும்.',
    scanAction: 'QR குறியீட்டை ஸ்கேன் செய்யவும்',
    lensAction: 'Google Lens திறக்கவும்',
    converterDescription: 'iLovePDF மூலம் ஆவணங்களை மாற்றவும், இணைக்கவும், பிரிக்கவும், சுருக்கவும் அல்லது திருத்தவும்.',
    openConverter: 'iLovePDF திறக்கவும்',
    resultTitle: 'ஸ்கேன் முடிவு',
  ),
  AppLanguage.urdu: ToolCopy(
    toolsTitle: 'مفید ٹولز',
    translateDescription: 'Google Translate کے ذریعے اپنی منتخب زبان سے Bahasa Melayu میں متن، آواز یا دستاویز کا ترجمہ کریں۔',
    voiceAction: 'آواز سے ترجمہ کریں',
    documentAction: 'دستاویز کا ترجمہ کریں',
    qrDescription: 'کیمرے سے QR کوڈ اسکین کریں یا Google Lens استعمال کریں۔',
    scanAction: 'QR کوڈ اسکین کریں',
    lensAction: 'Google Lens کھولیں',
    converterDescription:
        'iLovePDF سے دستاویز کو تبدیل، یکجا، تقسیم، کمپریس یا ایڈٹ کریں۔',
    openConverter: 'iLovePDF کھولیں',
    resultTitle: 'اسکین نتیجہ',
  ),
  AppLanguage.hindi: ToolCopy(
    toolsTitle: 'उपयोगी टूल',
    translateDescription: 'Google Translate से अपनी चुनी भाषा से Bahasa Melayu में टेक्स्ट, आवाज़ या दस्तावेज़ अनुवाद करें।',
    voiceAction: 'आवाज़ से अनुवाद करें',
    documentAction: 'दस्तावेज़ अनुवाद करें',
    qrDescription: 'कैमरे से QR कोड स्कैन करें या Google Lens इस्तेमाल करें।',
    scanAction: 'QR कोड स्कैन करें',
    lensAction: 'Google Lens खोलें',
    converterDescription: 'iLovePDF से दस्तावेज़ बदलें, जोड़ें, अलग करें, कंप्रेस करें या संपादित करें।',
    openConverter: 'iLovePDF खोलें',
    resultTitle: 'स्कैन परिणाम',
  ),
  AppLanguage.nepali: ToolCopy(
    toolsTitle: 'उपयोगी उपकरण',
    translateDescription: 'Google Translate मार्फत आफ्नो रोजेको भाषाबाट Bahasa Melayu मा पाठ, आवाज वा कागजात अनुवाद गर्नुहोस्।',
    voiceAction: 'आवाजबाट अनुवाद गर्नुहोस्',
    documentAction: 'कागजात अनुवाद गर्नुहोस्',
    qrDescription:
        'क्यामेराबाट QR कोड स्क्यान गर्नुहोस् वा Google Lens प्रयोग गर्नुहोस्।',
    scanAction: 'QR कोड स्क्यान गर्नुहोस्',
    lensAction: 'Google Lens खोल्नुहोस्',
    converterDescription: 'iLovePDF मार्फत कागजात रूपान्तरण, जोड्ने, छुट्याउने, कम्प्रेस वा सम्पादन गर्नुहोस्।',
    openConverter: 'iLovePDF खोल्नुहोस्',
    resultTitle: 'स्क्यान नतिजा',
  ),
  AppLanguage.burmese: ToolCopy(
    toolsTitle: 'အသုံးဝင်သောကိရိယာများ',
    translateDescription: 'Google Translate ဖြင့် ရွေးချယ်ထားသောဘာသာစကားမှ Bahasa Melayu သို့ စာသား၊ အသံ သို့မဟုတ် စာရွက်စာတမ်းကို ဘာသာပြန်ပါ။',
    voiceAction: 'အသံဖြင့် ဘာသာပြန်ပါ',
    documentAction: 'စာရွက်စာတမ်း ဘာသာပြန်ပါ',
    qrDescription: 'ကင်မရာဖြင့် QR ကုဒ်စကန်ဖတ်ပါ သို့မဟုတ် Google Lens သုံးပါ။',
    scanAction: 'QR ကုဒ်စကန်ဖတ်ပါ',
    lensAction: 'Google Lens ဖွင့်ပါ',
    converterDescription: 'iLovePDF ဖြင့် စာရွက်စာတမ်း ပြောင်းလဲ၊ ပေါင်းစည်း၊ ခွဲခြား၊ ချုံ့ သို့မဟုတ် တည်းဖြတ်ပါ။',
    openConverter: 'iLovePDF ဖွင့်ပါ',
    resultTitle: 'စကန်ရလဒ်',
  ),
  AppLanguage.thai: ToolCopy(
    toolsTitle: 'เครื่องมือที่มีประโยชน์',
    translateDescription: 'แปลข้อความ เสียง หรือเอกสารจากภาษาที่เลือกเป็น Bahasa Melayu ด้วย Google Translate',
    voiceAction: 'แปลด้วยเสียง',
    documentAction: 'แปลเอกสาร',
    qrDescription: 'สแกน QR ด้วยกล้องหรือใช้ Google Lens',
    scanAction: 'สแกน QR',
    lensAction: 'เปิด Google Lens',
    converterDescription: 'แปลง รวม แยก บีบอัด หรือแก้ไขเอกสารด้วย iLovePDF',
    openConverter: 'เปิด iLovePDF',
    resultTitle: 'ผลการสแกน',
  ),
  AppLanguage.khmer: ToolCopy(
    toolsTitle: 'ឧបករណ៍មានប្រយោជន៍',
    translateDescription: 'បកប្រែអត្ថបទ សំឡេង ឬឯកសារពីភាសាដែលអ្នកជ្រើសរើសទៅ Bahasa Melayu ដោយ Google Translate។',
    voiceAction: 'បកប្រែដោយសំឡេង',
    documentAction: 'បកប្រែឯកសារ',
    qrDescription: 'ស្កេនកូដ QR ដោយកាមេរ៉ា ឬប្រើ Google Lens។',
    scanAction: 'ស្កេនកូដ QR',
    lensAction: 'បើក Google Lens',
    converterDescription:
        'បម្លែង បញ្ចូល បំបែក បង្ហាប់ ឬកែសម្រួលឯកសារដោយ iLovePDF។',
    openConverter: 'បើក iLovePDF',
    resultTitle: 'លទ្ធផលស្កេន',
  ),
  AppLanguage.filipino: ToolCopy(
    toolsTitle: 'Mga kapaki-pakinabang na tool',
    translateDescription: 'Isalin ang text, boses, o dokumento mula sa napili mong wika tungo sa Bahasa Melayu gamit ang Google Translate.',
    voiceAction: 'Isalin gamit ang boses',
    documentAction: 'Isalin ang dokumento',
    qrDescription:
        'Mag-scan ng QR code gamit ang camera o gamitin ang Google Lens.',
    scanAction: 'I-scan ang QR code',
    lensAction: 'Buksan ang Google Lens',
    converterDescription: 'Mag-convert, mag-merge, mag-split, mag-compress, o mag-edit ng dokumento gamit ang iLovePDF.',
    openConverter: 'Buksan ang iLovePDF',
    resultTitle: 'Resulta ng scan',
  ),
  AppLanguage.chinese: ToolCopy(
    toolsTitle: '实用工具',
    translateDescription: '使用 Google 翻译将您选择语言的文本、语音或文档翻译成 Bahasa Melayu。',
    voiceAction: '语音翻译',
    documentAction: '翻译文档',
    qrDescription: '使用相机扫描二维码，或使用 Google Lens。',
    scanAction: '扫描二维码',
    lensAction: '打开 Google Lens',
    converterDescription: '使用 iLovePDF 转换、合并、拆分、压缩或编辑文档。',
    openConverter: '打开 iLovePDF',
    resultTitle: '扫描结果',
  ),
  AppLanguage.vietnamese: ToolCopy(
    toolsTitle: 'Công cụ hữu ích',
    translateDescription: 'Dịch văn bản, giọng nói hoặc tài liệu từ ngôn ngữ bạn chọn sang Bahasa Melayu bằng Google Translate.',
    voiceAction: 'Dịch bằng giọng nói',
    documentAction: 'Dịch tài liệu',
    qrDescription: 'Quét mã QR bằng máy ảnh hoặc dùng Google Lens.',
    scanAction: 'Quét mã QR',
    lensAction: 'Mở Google Lens',
    converterDescription:
        'Chuyển đổi, gộp, tách, nén hoặc chỉnh sửa tài liệu bằng iLovePDF.',
    openConverter: 'Mở iLovePDF',
    resultTitle: 'Kết quả quét',
  ),
  AppLanguage.sinhala: ToolCopy(
    toolsTitle: 'ප්‍රයෝජනවත් මෙවලම්',
    translateDescription: 'Google Translate භාවිතයෙන් ඔබ තෝරාගත් භාෂාවෙන් Bahasa Melayu වෙත පෙළ, හඬ හෝ ලේඛන පරිවර්තනය කරන්න.',
    voiceAction: 'හඬින් පරිවර්තනය කරන්න',
    documentAction: 'ලේඛනය පරිවර්තනය කරන්න',
    qrDescription:
        'කැමරාවෙන් QR කේතයක් ස්කෑන් කරන්න හෝ Google Lens භාවිතා කරන්න.',
    scanAction: 'QR කේතය ස්කෑන් කරන්න',
    lensAction: 'Google Lens විවෘත කරන්න',
    converterDescription: 'iLovePDF මඟින් ලේඛන පරිවර්තනය, ඒකාබද්ධ, වෙන්, සම්පීඩනය හෝ සංස්කරණය කරන්න.',
    openConverter: 'iLovePDF විවෘත කරන්න',
    resultTitle: 'ස්කෑන් ප්‍රතිඵලය',
  ),
};

ToolCopy _toolCopyFor(AppLanguage language) => toolCopies[language]!;

class CreatorProfilePage extends StatelessWidget {
  const CreatorProfilePage({super.key, required this.copy});

  final AppCopy copy;

  Future<void> _launch(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_creatorProfileCopyFor(copy).contactError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _creatorProfileCopyFor(copy);
    return Directionality(
      textDirection: copy.direction,
      child: Scaffold(
        appBar: _AppBar(
          title: profile.pageTitle,
          leading: IconButton(
            tooltip: copy.backToServices,
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                _creatorAvatarAsset,
                height: 230,
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                semanticLabel: '${_creatorDisplayNameFor(copy)} profile photo',
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _creatorDisplayNameFor(copy),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF163A38),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '@bk4ivv · Kuala Lumpur, Malaysia',
              style: TextStyle(
                color: Color(0xFF57716B),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _ProfileSection(
              icon: Icons.engineering_outlined,
              title: profile.aboutTitle,
              body: profile.aboutBody,
            ),
            const SizedBox(height: 12),
            _ProfileSection(
              icon: Icons.design_services_outlined,
              title: profile.hireTitle,
              body: profile.hireBody,
            ),
            const SizedBox(height: 12),
            _ContactButton(
              icon: Icons.privacy_tip_outlined,
              title: copy.languageName == 'বাংলা'
                  ? 'অ্যাপের তথ্য ও গোপনীয়তা'
                  : 'App information & privacy',
              subtitle: copy.languageName == 'বাংলা'
                  ? 'ফ্রি ব্যবহার, বিজ্ঞাপন ও ডেটা ব্যবহারের তথ্য'
                  : 'Free use, advertising, and data-use information',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AppInformationPage(copy: copy),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              profile.contactTitle,
              style: const TextStyle(
                color: Color(0xFF163A38),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            _ContactButton(
              icon: Icons.mail_outline_rounded,
              title: profile.emailLabel,
              subtitle: 'hire.borhankabir@hotmail.com',
              onPressed: () => _launch(
                context,
                Uri(scheme: 'mailto', path: 'hire.borhankabir@hotmail.com'),
              ),
            ),
            const SizedBox(height: 10),
            _ContactButton(
              icon: Icons.public_rounded,
              title: profile.facebookLabel,
              subtitle: 'facebook.com/bk4ivv',
              onPressed: () => _launch(
                context,
                Uri.parse('https://www.facebook.com/bk4ivv/'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key, required this.copy});

  final AppCopy copy;

  bool get _isBangla => copy.languageName == 'বাংলা';

  String _text(String english, String bangla) => _isBangla ? bangla : english;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: copy.direction,
      child: Scaffold(
        appBar: _AppBar(
          title: _text('Privacy policy', 'গোপনীয়তা নীতি'),
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            CivicHeroPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.privacy_tip_outlined,
                    color: AppPalette.flagYellow,
                    size: 30,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _text(
                      'Your privacy stays in your hands',
                      'আপনার গোপনীয়তা আপনার নিয়ন্ত্রণে',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _text(
                      'FIM is free to use. Worker tools do not require an account.',
                      'FIM বিনামূল্যে ব্যবহার করা যায়। কর্মী টুল ব্যবহারে অ্যাকাউন্ট লাগে না।',
                    ),
                    style: const TextStyle(
                      color: Color(0xFFE6E7EF),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _InfoCard(
              icon: Icons.storage_outlined,
              title: _text(
                'No worker data is sold',
                'কর্মীর তথ্য বিক্রি করা হয় না',
              ),
              body: _text(
                'FIM does not ask for passport numbers, passwords, or payment details for its basic tools. Official websites may request information under their own policies.',
                'FIM-এর সাধারণ টুল পাসপোর্ট নম্বর, পাসওয়ার্ড বা পেমেন্ট তথ্য চায় না। সরকারি ওয়েবসাইট তাদের নিজস্ব নীতিতে তথ্য চাইতে পারে।',
              ),
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.camera_alt_outlined,
              title: _text('Camera and QR scanner', 'ক্যামেরা ও QR স্ক্যানার'),
              body: _text(
                'Camera access is used only when you open the QR scanner. The scanned value is used on your device to open the link you choose.',
                'QR স্ক্যানার খুললেই শুধু ক্যামেরা ব্যবহার হয়। স্ক্যান করা তথ্য আপনার ডিভাইসে আপনার বেছে নেওয়া লিংক খোলার জন্য ব্যবহৃত হয়।',
              ),
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.open_in_new_rounded,
              title: _text('External websites', 'বাহ্যিক ওয়েবসাইট'),
              body: _text(
                'Visa, FOMEMA, transport, translation, and government pages are operated by their respective providers. Review their privacy terms before submitting personal information.',
                'ভিসা, FOMEMA, যাতায়াত, অনুবাদ ও সরকারি পেজ সংশ্লিষ্ট প্রতিষ্ঠানের পরিচালিত। ব্যক্তিগত তথ্য দেওয়ার আগে তাদের গোপনীয়তা নীতি পড়ুন।',
              ),
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.mail_outline_rounded,
              title: 'hire.borhankabir@hotmail.com',
              body: _text(
                'Contact the creator about a privacy question or app issue.',
                'গোপনীয়তা বা অ্যাপের সমস্যা সম্পর্কে নির্মাতাকে ইমেইল করুন।',
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => launchUrl(
                Uri(scheme: 'mailto', path: 'hire.borhankabir@hotmail.com'),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.email_outlined),
              label: Text(
                _text('Email privacy contact', 'গোপনীয়তা যোগাযোগে ইমেইল করুন'),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _text(
                'Last reviewed for this app release. Information may change when an external service changes its own policy.',
                'এই অ্যাপ রিলিজের জন্য সর্বশেষ পর্যালোচনা করা হয়েছে। বাহ্যিক সেবা তাদের নীতি পরিবর্তন করলে তথ্য পরিবর্তিত হতে পারে।',
              ),
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.65),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppInformationPage extends StatelessWidget {
  const AppInformationPage({super.key, required this.copy});

  final AppCopy copy;

  bool get _isBangla => copy.languageName == 'বাংলা';

  String _text(String english, String bangla) => _isBangla ? bangla : english;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: copy.direction,
      child: Scaffold(
        appBar: _AppBar(
          title: _text('About FIM', 'FIM সম্পর্কে'),
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            CivicHeroPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    color: scheme.primary,
                    size: 26,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _text(
                      'Free for workers. No hidden fees.',
                      'কর্মীদের জন্য ফ্রি। কোনো লুকানো ফি নেই।',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _text(
                      'FIM - Foreigner in Malaysia does not charge a subscription or service fee. Limited, clearly labelled ads or sponsored information may help keep the app free.',
                      'FIM - Foreigner in Malaysia কোনো সাবস্ক্রিপশন বা সার্ভিস ফি নেয় না। সীমিত ও স্পষ্টভাবে চিহ্নিত বিজ্ঞাপন বা স্পনসর তথ্য অ্যাপটি ফ্রি রাখতে সাহায্য করতে পারে।',
                    ),
                    style: const TextStyle(
                      color: Color(0xFFD8D8D2),
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _InfoCard(
              icon: Icons.no_accounts_outlined,
              title: _text(
                'No account required for worker tools',
                'কর্মী টুলের জন্য অ্যাকাউন্ট লাগে না',
              ),
              body: _text(
                'Visa, FOMEMA, help, learning, and tools stay free without an account. A verified email account is optional for Community participation only.',
                'ভিসা, FOMEMA, সহায়তা, শেখা ও টুল অ্যাকাউন্ট ছাড়াই ফ্রি। শুধু কমিউনিটিতে অংশ নেওয়ার জন্য যাচাইকৃত ইমেইল অ্যাকাউন্ট ঐচ্ছিক।',
              ),
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.qr_code_scanner_rounded,
              title: _text('Camera use', 'ক্যামেরা ব্যবহার'),
              body: _text(
                'Camera permission is requested only when you choose the QR scanner. QR images and results are not sent to an app-owned server or kept as a history.',
                'শুধু QR স্ক্যানার বেছে নিলে ক্যামেরা অনুমতি চাওয়া হয়। QR ছবি বা ফলাফল অ্যাপের নিজস্ব সার্ভারে পাঠানো বা ইতিহাসে রাখা হয় না।',
              ),
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.open_in_new_rounded,
              title: _text('External services', 'বাহ্যিক সেবা'),
              body: _text(
                'Official portals, banks, translation, file, and contact services open as external services. Information you submit there is handled under that service’s own privacy policy.',
                'সরকারি পোর্টাল, ব্যাংক, অনুবাদ, ফাইল ও যোগাযোগ সেবা বাহ্যিক সেবা হিসেবে খোলে। সেখানে দেওয়া তথ্য সংশ্লিষ্ট সেবার নিজস্ব গোপনীয়তা নীতির অধীনে পরিচালিত হয়।',
              ),
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.campaign_outlined,
              title: _text('Advertising disclosure', 'বিজ্ঞাপন সম্পর্কিত তথ্য'),
              body: _text(
                'The current version does not include a third-party advertising SDK. If advertising technology is added later, this page and the public policy will be updated before that release.',
                'বর্তমান সংস্করণে কোনো থার্ড-পার্টি বিজ্ঞাপন SDK নেই। পরে বিজ্ঞাপন প্রযুক্তি যোগ করা হলে, সেই সংস্করণ প্রকাশের আগে এই পেজ ও পাবলিক নীতি আপডেট করা হবে।',
              ),
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.person_outline_rounded,
              title: _text(
                'Created by Khandaker Md Borhan Kabir',
                'তৈরি করেছেন খন্দকার মো: বোরহান কাবির',
              ),
              body: _text(
                'A Malaysia-based foreign worker and Metal CNC Operator. You can view the full credit, contact details, and project-enquiry options below.',
                'মালয়েশিয়ায় কর্মরত বিদেশি শ্রমিক ও মেটাল CNC অপারেটর। সম্পূর্ণ ক্রেডিট, যোগাযোগের তথ্য ও প্রজেক্টের বিষয়ে কথা বলার অপশন নিচে দেখুন।',
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CreatorProfilePage(copy: copy),
                ),
              ),
              icon: const Icon(Icons.badge_outlined),
              label: Text(
                _text(
                  'View credit & contact details',
                  'ক্রেডিট ও যোগাযোগের তথ্য দেখুন',
                ),
              ),
            ),
            const SizedBox(height: 20),
            CivicSectionLabel(
              label: _text('Privacy contact', 'গোপনীয়তা যোগাযোগ'),
            ),
            const SizedBox(height: 8),
            _InfoCard(
              icon: Icons.mail_outline_rounded,
              title: 'hire.borhankabir@hotmail.com',
              body: _text(
                'Email questions about privacy or the app.',
                'গোপনীয়তা বা অ্যাপ সম্পর্কে ইমেইল করুন।',
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => launchUrl(
                Uri(scheme: 'mailto', path: 'hire.borhankabir@hotmail.com'),
                mode: LaunchMode.externalApplication,
              ),
              icon: const Icon(Icons.email_outlined),
              label: Text(
                _text(
                  'Email the privacy contact',
                  'গোপনীয়তা যোগাযোগে ইমেইল করুন',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.14)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: scheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.68),
                    fontSize: 11.5,
                    height: 1.42,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CountryHubProfile {
  const CountryHubProfile({
    required this.hubTitle,
    required this.hubSubtitle,
    required this.heroTitle,
    required this.heroBody,
    required this.serviceGuideTitle,
    required this.serviceAdvice,
    required this.phrasebookTitle,
    required this.phrasebookSubtitle,
    required this.primaryMeaning,
    required this.emergencyMeaning,
    required this.supportTitle,
    required this.supportSubtitle,
    required this.supportName,
    required this.supportDescription,
    required this.supportUrl,
    required this.workerTitle,
    required this.workerBody,
    required this.openOfficialLabel,
  });

  final String hubTitle;
  final String hubSubtitle;
  final String heroTitle;
  final String heroBody;
  final String serviceGuideTitle;
  final String serviceAdvice;
  final String phrasebookTitle;
  final String phrasebookSubtitle;
  final String primaryMeaning;
  final String emergencyMeaning;
  final String supportTitle;
  final String supportSubtitle;
  final String supportName;
  final String supportDescription;
  final String supportUrl;
  final String workerTitle;
  final String workerBody;
  final String openOfficialLabel;
}

class CountryResourceProfile {
  const CountryResourceProfile({
    required this.goldReferenceUrl,
    required this.goldReferenceName,
    this.officialSocialUrl,
  });

  final String goldReferenceUrl;
  final String goldReferenceName;
  final String? officialSocialUrl;
}

CountryHubProfile _countryHubProfileFor(AppLanguage language) =>
    countryHubProfiles[language] ?? _genericCountryHubProfile;

const _genericCountryResourceProfile = CountryResourceProfile(
  goldReferenceUrl: 'https://www.goldprice.org/',
  goldReferenceName: 'International gold-price reference',
  officialSocialUrl: null,
);

const countryResourceProfiles = <AppLanguage, CountryResourceProfile>{
  AppLanguage.bangla: CountryResourceProfile(
    goldReferenceUrl: 'https://smsdeenjewels.com.my/',
    goldReferenceName: 'SMS Deen Jewellers · 916 Gold Rate',
    officialSocialUrl: 'https://www.facebook.com/bdhckl/',
  ),
  AppLanguage.malay: CountryResourceProfile(
    goldReferenceUrl: 'https://www.publicgold.com.my/',
    goldReferenceName: 'Public Gold Malaysia · rate reference',
  ),
  AppLanguage.indonesian: CountryResourceProfile(
    goldReferenceUrl: 'https://www.logammulia.com/id/harga-emas',
    goldReferenceName: 'ANTAM Logam Mulia · harga emas',
    officialSocialUrl: 'https://www.facebook.com/IndonesianEmbassyKualaLumpur/',
  ),
  AppLanguage.tamil: CountryResourceProfile(
    goldReferenceUrl: 'https://www.ibja.co/',
    goldReferenceName: 'IBJA India · bullion reference',
    officialSocialUrl:
        'https://www.facebook.com/HighCommissionofIndiaMalaysia/',
  ),
  AppLanguage.urdu: CountryResourceProfile(
    goldReferenceUrl: 'https://goldprice.org/gold-price-pakistan.html',
    goldReferenceName: 'Pakistan gold market reference',
    officialSocialUrl: 'https://www.facebook.com/PakistaninMy/',
  ),
  AppLanguage.hindi: CountryResourceProfile(
    goldReferenceUrl: 'https://www.ibja.co/',
    goldReferenceName: 'IBJA India · bullion reference',
    officialSocialUrl:
        'https://www.facebook.com/HighCommissionofIndiaMalaysia/',
  ),
  AppLanguage.nepali: CountryResourceProfile(
    goldReferenceUrl: 'https://goldprice.org/gold-price-nepal.html',
    goldReferenceName: 'Nepal gold market reference',
    officialSocialUrl: 'https://www.facebook.com/eonklmy/',
  ),
  AppLanguage.burmese: CountryResourceProfile(
    goldReferenceUrl: 'https://goldprice.org/gold-price-myanmar.html',
    goldReferenceName: 'Myanmar gold market reference',
    officialSocialUrl: 'https://www.facebook.com/1532321607022165/',
  ),
  AppLanguage.thai: CountryResourceProfile(
    goldReferenceUrl: 'https://www.goldtraders.or.th/',
    goldReferenceName: 'Thai Gold Traders Association',
    officialSocialUrl: 'https://www.facebook.com/ThaiEmbassyKL/',
  ),
  AppLanguage.khmer: CountryResourceProfile(
    goldReferenceUrl: 'https://goldprice.org/gold-price-cambodia.html',
    goldReferenceName: 'Cambodia gold market reference',
    officialSocialUrl: 'https://www.facebook.com/100064682740010/',
  ),
  AppLanguage.filipino: CountryResourceProfile(
    goldReferenceUrl: 'https://goldprice.org/gold-price-philippines.html',
    goldReferenceName: 'Philippines gold market reference',
    officialSocialUrl: 'https://www.facebook.com/PHinMalaysia/',
  ),
  AppLanguage.chinese: CountryResourceProfile(
    goldReferenceUrl: 'https://www.sge.com.cn/',
    goldReferenceName: 'Shanghai Gold Exchange',
    officialSocialUrl: 'https://www.facebook.com/chinaembmy/',
  ),
  AppLanguage.vietnamese: CountryResourceProfile(
    goldReferenceUrl: 'https://sjc.com.vn/',
    goldReferenceName: 'SJC Vietnam · gold reference',
  ),
  AppLanguage.sinhala: CountryResourceProfile(
    goldReferenceUrl: 'https://goldprice.org/gold-price-sri-lanka.html',
    goldReferenceName: 'Sri Lanka gold market reference',
    officialSocialUrl: 'https://www.facebook.com/srilankahcmalaysia/',
  ),
  AppLanguage.korean: CountryResourceProfile(
    goldReferenceUrl: 'https://goldprice.org/gold-price-south-korea.html',
    goldReferenceName: 'South Korea gold market reference',
  ),
  AppLanguage.japanese: CountryResourceProfile(
    goldReferenceUrl: 'https://goldprice.org/gold-price-japan.html',
    goldReferenceName: 'Japan gold market reference',
  ),
  AppLanguage.german: CountryResourceProfile(
    goldReferenceUrl: 'https://goldprice.org/gold-price-germany.html',
    goldReferenceName: 'Germany gold market reference',
  ),
  AppLanguage.french: CountryResourceProfile(
    goldReferenceUrl: 'https://goldprice.org/gold-price-france.html',
    goldReferenceName: 'France gold market reference',
  ),
  AppLanguage.spanish: CountryResourceProfile(
    goldReferenceUrl: 'https://goldprice.org/gold-price-spain.html',
    goldReferenceName: 'Spain gold market reference',
  ),
  AppLanguage.arabic: CountryResourceProfile(
    goldReferenceUrl: 'https://www.goldprice.org/',
    goldReferenceName: 'International gold-price reference',
  ),
  AppLanguage.russian: CountryResourceProfile(
    goldReferenceUrl: 'https://goldprice.org/gold-price-russia.html',
    goldReferenceName: 'Russia gold market reference',
  ),
};
CountryResourceProfile _countryResourceProfileFor(AppLanguage language) =>
    countryResourceProfiles[language] ?? _genericCountryResourceProfile;

const countryGovernmentPortals = <AppLanguage, String>{
  AppLanguage.bangla: 'https://bangladesh.gov.bd/',
  AppLanguage.malay: 'https://www.malaysia.gov.my/',
  AppLanguage.indonesian: 'https://www.indonesia.go.id/',
  AppLanguage.tamil: 'https://www.india.gov.in/',
  AppLanguage.urdu: 'https://www.pakistan.gov.pk/',
  AppLanguage.hindi: 'https://www.india.gov.in/',
  AppLanguage.nepali: 'https://nepal.gov.np/',
  AppLanguage.burmese: 'https://myanmar.gov.mm/',
  AppLanguage.thai: 'https://www.thaigov.go.th/',
  AppLanguage.khmer: 'https://www.cambodia.gov.kh/',
  AppLanguage.filipino: 'https://www.gov.ph/',
  AppLanguage.chinese: 'https://www.gov.cn/',
  AppLanguage.vietnamese: 'https://chinhphu.vn/',
  AppLanguage.sinhala: 'https://www.gov.lk/',
  AppLanguage.korean: 'https://www.korea.net/',
  AppLanguage.japanese: 'https://www.japan.go.jp/',
  AppLanguage.german: 'https://www.bundesregierung.de/breg-en',
  AppLanguage.french: 'https://www.gouvernement.fr/en',
  AppLanguage.spanish: 'https://administracion.gob.es/',
  AppLanguage.arabic:
      'https://www.kln.gov.my/web/guest/foreign-missions-in-malaysia',
  AppLanguage.russian: 'https://government.ru/en/',
};
const _foreignMissionsDirectoryUrl =
    'https://www.kln.gov.my/web/guest/foreign-missions-in-malaysia';
String _countryGovernmentPortalFor(AppLanguage language) =>
    countryGovernmentPortals[language] ?? _foreignMissionsDirectoryUrl;

String _localizedGoldTitle(AppLanguage language) => switch (language) {
  AppLanguage.bangla => 'দেশের সোনার রেফারেন্স',
  AppLanguage.malay => 'Rujukan harga emas',
  AppLanguage.indonesian => 'Referensi harga emas',
  AppLanguage.tamil => 'தங்க விலை குறிப்பு',
  AppLanguage.urdu => 'سونے کی قیمت کا حوالہ',
  AppLanguage.hindi => 'सोने की कीमत संदर्भ',
  AppLanguage.nepali => 'सुनको मूल्य सन्दर्भ',
  AppLanguage.burmese => 'ရွှေဈေး အညွှန်း',
  AppLanguage.thai => 'ข้อมูลอ้างอิงราคาทอง',
  AppLanguage.khmer => 'ព័ត៌មានយោងតម្លៃមាស',
  AppLanguage.filipino => 'Sanggunian sa presyo ng ginto',
  AppLanguage.chinese => '黄金价格参考',
  AppLanguage.vietnamese => 'Tham khảo giá vàng',
  AppLanguage.sinhala => 'රන් මිල යොමුව',
  AppLanguage.korean => '금 가격 참고',
  AppLanguage.japanese => '金価格の参考',
  AppLanguage.german => 'Goldpreis-Referenz',
  AppLanguage.french => 'Référence du prix de l’or',
  AppLanguage.spanish => 'Referencia del precio del oro',
  AppLanguage.arabic => 'مرجع سعر الذهب',
  AppLanguage.russian => 'Справка о цене золота',
  AppLanguage.english => 'Gold price reference',
};

String _localizedGovernmentPortalTitle(AppLanguage language) =>
    switch (language) {
      AppLanguage.bangla => 'দেশের সরকারি পোর্টাল',
      AppLanguage.malay => 'Portal kerajaan negara',
      AppLanguage.indonesian => 'Portal pemerintah negara',
      AppLanguage.tamil => 'நாட்டின் அரசு இணையதளம்',
      AppLanguage.urdu => 'ملکی سرکاری پورٹل',
      AppLanguage.hindi => 'देश का सरकारी पोर्टल',
      AppLanguage.nepali => 'देशको सरकारी पोर्टल',
      AppLanguage.burmese => 'နိုင်ငံ့အစိုးရ ပေါ်တယ်',
      AppLanguage.thai => 'พอร์ทัลรัฐบาลของประเทศ',
      AppLanguage.khmer => 'វិបផតថលរដ្ឋាភិបាលប្រទេស',
      AppLanguage.filipino => 'Portal ng pamahalaan ng bansa',
      AppLanguage.chinese => '本国政府门户网站',
      AppLanguage.vietnamese => 'Cổng thông tin chính phủ',
      AppLanguage.sinhala => 'රජයේ නිල ද්වාරය',
      AppLanguage.korean => '본국 정부 포털',
      AppLanguage.japanese => '母国政府ポータル',
      AppLanguage.german => 'Regierungsportal des Heimatlandes',
      AppLanguage.french => 'Portail gouvernemental du pays d’origine',
      AppLanguage.spanish => 'Portal gubernamental del país de origen',
      AppLanguage.arabic => 'بوابة حكومة بلدك',
      AppLanguage.russian => 'Правительственный портал страны',
      AppLanguage.english => 'Home-country government portal',
    };

String _localizedOfficialSocialLabel(AppLanguage language) =>
    switch (language) {
      AppLanguage.bangla => 'অফিসিয়াল Facebook',
      AppLanguage.malay => 'Facebook rasmi',
      AppLanguage.indonesian => 'Facebook resmi',
      AppLanguage.tamil => 'அதிகாரப்பூர்வ Facebook',
      AppLanguage.urdu => 'سرکاری Facebook',
      AppLanguage.hindi => 'आधिकारिक Facebook',
      AppLanguage.nepali => 'आधिकारिक Facebook',
      AppLanguage.burmese => 'တရားဝင် Facebook',
      AppLanguage.thai => 'Facebook ทางการ',
      AppLanguage.khmer => 'Facebook ផ្លូវការ',
      AppLanguage.filipino => 'Opisyal na Facebook',
      AppLanguage.chinese => '官方 Facebook',
      AppLanguage.vietnamese => 'Facebook chính thức',
      AppLanguage.sinhala => 'නිල Facebook',
      AppLanguage.korean => '공식 Facebook',
      AppLanguage.japanese => '公式 Facebook',
      AppLanguage.german => 'Offizielles Facebook',
      AppLanguage.french => 'Facebook officiel',
      AppLanguage.spanish => 'Facebook oficial',
      AppLanguage.arabic => 'فيسبوك الرسمي',
      AppLanguage.russian => 'Официальный Facebook',
      AppLanguage.english => 'Official Facebook',
    };

void openWebsiteInApp(
  BuildContext context, {
  required String title,
  required String url,
  required AppCopy copy,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => StatusWebViewPage(title: title, url: url, copy: copy),
    ),
  );
}

Future<void> openAppDestination(
  BuildContext context, {
  required String title,
  required String url,
  required AppCopy copy,
}) async {
  final uri = Uri.tryParse(url);
  if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
    openWebsiteInApp(context, title: title, url: url, copy: copy);
    return;
  }
  final opened =
      uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This link could not be opened.')),
    );
  }
}

const _genericCountryHubProfile = CountryHubProfile(
  hubTitle: 'Support',
  hubSubtitle: 'Official country support, Malay learning, and worker guidance',
  heroTitle: 'Handle important tasks with confidence',
  heroBody: 'Use official Malaysian services, the Malay learning library, and verified country support routes.',
  serviceGuideTitle: 'Before using an official service',
  serviceAdvice: 'Keep your passport and reference details ready. Enter personal information only on official websites.',
  phrasebookTitle: 'Useful Malay phrases',
  phrasebookSubtitle: 'Short phrases for work, clinics, and urgent situations',
  primaryMeaning: 'I need help.',
  emergencyMeaning: 'Please help, this is an emergency.',
  supportTitle: 'Country support',
  supportSubtitle: 'Official embassy and government routes',
  supportName: 'Official foreign-mission directory in Malaysia',
  supportDescription: 'Use the official directory to find your embassy or high commission in Malaysia.',
  supportUrl: 'https://www.kln.gov.my/web/guest/foreign-missions-in-malaysia',
  workerTitle: 'Work problem or complaint',
  workerBody: 'Keep your employment documents and use the official Malaysian labour channels for help.',
  openOfficialLabel: 'Open official page',
);

const countryHubProfiles = <AppLanguage, CountryHubProfile>{
  AppLanguage.bangla: CountryHubProfile(
    hubTitle: 'বাংলা সহায়তা কেন্দ্র',
    hubSubtitle: 'দরকারি মালাই ভাষা, সরকারি কাজের গাইড ও বাংলাদেশি সহায়তা',
    heroTitle: 'প্রয়োজনীয় কাজ সহজে করুন',
    heroBody: 'সরকারি সেবা, দরকারি মালাই ভাষা ও বাংলাদেশি সহায়তার সহজ পথ।',
    serviceGuideTitle: 'সরকারি কাজের আগে',
    serviceAdvice: 'পাসপোর্ট ও রেফারেন্স তথ্য প্রস্তুত রাখুন, তারপর শুধু অফিসিয়াল সাইটে তথ্য দিন।',
    phrasebookTitle: 'দরকারি মালাই ভাষা',
    phrasebookSubtitle: 'কাজ, ক্লিনিক ও জরুরি সময়ের ছোট বাক্য',
    primaryMeaning: 'আমার সাহায্য দরকার।',
    emergencyMeaning: 'দয়া করে সাহায্য করুন, এটি জরুরি।',
    supportTitle: 'বাংলাদেশি সহায়তা',
    supportSubtitle: 'হাই কমিশন, কনস্যুলার ও পাসপোর্ট সহায়তা',
    supportName: 'বাংলাদেশ হাই কমিশন, কুয়ালালামপুর',
    supportDescription: 'কনস্যুলার, পাসপোর্ট ও অফিসিয়াল নোটিশের জন্য অফিসিয়াল সাইট ব্যবহার করুন।',
    supportUrl: 'https://www.bdhckl.gov.bd/contact/',
    workerTitle: 'কাজের সমস্যা বা অভিযোগ',
    workerBody:
        'কাগজপত্র গুছিয়ে রাখুন এবং মালয়েশিয়ার সরকারি JTK সহায়তা নিন।',
    openOfficialLabel: 'অফিসিয়াল পেজ খুলুন',
  ),
  AppLanguage.malay: CountryHubProfile(
    hubTitle: 'Pusat Bantuan Pekerja',
    hubSubtitle: 'Panduan rasmi, frasa kerja dan bantuan pekerja Malaysia',
    heroTitle: 'Urus kerja penting dengan jelas',
    heroBody: 'Panduan ringkas untuk perkhidmatan rasmi, komunikasi dan bantuan pekerja.',
    serviceGuideTitle: 'Sebelum urusan rasmi',
    serviceAdvice: 'Sediakan pasport dan maklumat rujukan. Masukkan maklumat hanya di laman rasmi.',
    phrasebookTitle: 'Frasa kerja yang berguna',
    phrasebookSubtitle: 'Frasa ringkas untuk kerja, klinik dan kecemasan',
    primaryMeaning: 'Saya perlukan bantuan.',
    emergencyMeaning: 'Tolong, ini kecemasan.',
    supportTitle: 'Bantuan rasmi Malaysia',
    supportSubtitle: 'Maklumat pekerja dan saluran rasmi JTK',
    supportName: 'Jabatan Tenaga Kerja Semenanjung Malaysia',
    supportDescription:
        'Gunakan laman rasmi untuk bantuan dan maklumat berkaitan pekerjaan.',
    supportUrl: 'https://jtksm.mohr.gov.my/en/',
    workerTitle: 'Masalah atau aduan kerja',
    workerBody:
        'Simpan dokumen kerja dan gunakan saluran rasmi JTK untuk bantuan.',
    openOfficialLabel: 'Buka laman rasmi',
  ),
  AppLanguage.indonesian: CountryHubProfile(
    hubTitle: 'Pusat Bantuan Indonesia',
    hubSubtitle:
        'Panduan layanan Malaysia, bahasa Melayu, dan dukungan resmi Indonesia',
    heroTitle: 'Urus kebutuhan kerja dengan jelas',
    heroBody: 'Panduan sederhana untuk layanan resmi Malaysia dan bantuan warga Indonesia.',
    serviceGuideTitle: 'Sebelum layanan resmi',
    serviceAdvice: 'Siapkan paspor dan informasi referensi. Masukkan data hanya di situs resmi.',
    phrasebookTitle: 'Bahasa Melayu untuk kerja',
    phrasebookSubtitle:
        'Kalimat singkat untuk kerja, klinik, dan keadaan darurat',
    primaryMeaning: 'Saya butuh bantuan.',
    emergencyMeaning: 'Tolong, ini darurat.',
    supportTitle: 'Bantuan Indonesia',
    supportSubtitle: 'Informasi resmi Kedutaan Besar Republik Indonesia',
    supportName: 'Kedutaan Besar Republik Indonesia, Kuala Lumpur',
    supportDescription:
        'Gunakan situs KBRI untuk konsuler, paspor, dan pengumuman resmi.',
    supportUrl: 'https://kemlu.go.id/kualalumpur/en',
    workerTitle: 'Masalah atau pengaduan kerja',
    workerBody: 'Simpan dokumen kerja dan gunakan jalur resmi JTK Malaysia untuk bantuan.',
    openOfficialLabel: 'Buka situs resmi',
  ),
  AppLanguage.tamil: CountryHubProfile(
    hubTitle: 'இந்திய உதவி மையம்',
    hubSubtitle:
        'மலேசிய சேவை வழிகாட்டி, மலாய் சொற்றொடர்கள் மற்றும் இந்திய உதவி',
    heroTitle: 'முக்கிய பணிகளை தெளிவாக செய்யுங்கள்',
    heroBody:
        'அதிகாரப்பூர்வ மலேசிய சேவைகள் மற்றும் இந்திய உதவிக்கான எளிய வழிகாட்டி.',
    serviceGuideTitle: 'அதிகாரப்பூர்வ சேவைக்கு முன்',
    serviceAdvice: 'கடவுச்சீட்டு மற்றும் குறிப்பு விவரங்களை தயாராக வைத்திருங்கள். அதிகாரப்பூர்வ தளத்தில் மட்டும் தகவல் அளிக்கவும்.',
    phrasebookTitle: 'வேலைக்கான மலாய் மொழி',
    phrasebookSubtitle:
        'வேலை, மருத்துவம் மற்றும் அவசரநிலைக்கான குறும் வாக்கியங்கள்',
    primaryMeaning: 'எனக்கு உதவி வேண்டும்.',
    emergencyMeaning: 'தயவு செய்து உதவுங்கள், இது அவசரம்.',
    supportTitle: 'இந்திய உதவி',
    supportSubtitle: 'இந்திய உயர் ஆணையத்தின் அதிகாரப்பூர்வ தகவல்',
    supportName: 'இந்திய உயர் ஆணையம், கோலாலம்பூர்',
    supportDescription: 'தூதரக, கடவுச்சீட்டு மற்றும் அவசர தகவலுக்கு அதிகாரப்பூர்வ தளத்தை பயன்படுத்தவும்.',
    supportUrl: 'https://www.hcikl.gov.in/',
    workerTitle: 'வேலை பிரச்சினை அல்லது புகார்',
    workerBody:
        'வேலை ஆவணங்களை வைத்துக்கொண்டு மலேசிய அரசின் JTK உதவியை பயன்படுத்தவும்.',
    openOfficialLabel: 'அதிகாரப்பூர்வ பக்கத்தைத் திறக்கவும்',
  ),
  AppLanguage.urdu: CountryHubProfile(
    hubTitle: 'پاکستانی مدد مرکز',
    hubSubtitle: 'ملائیشیا کی سرکاری رہنمائی، مالائی جملے اور پاکستانی مدد',
    heroTitle: 'اہم کام آسانی سے کریں',
    heroBody: 'سرکاری ملائیشین خدمات اور پاکستانی مدد کے لیے سادہ رہنمائی۔',
    serviceGuideTitle: 'سرکاری کام سے پہلے',
    serviceAdvice: 'پاسپورٹ اور حوالہ معلومات تیار رکھیں۔ معلومات صرف سرکاری ویب سائٹ پر دیں۔',
    phrasebookTitle: 'کام کے لیے مالائی زبان',
    phrasebookSubtitle: 'کام، کلینک اور ہنگامی حالت کے مختصر جملے',
    primaryMeaning: 'مجھے مدد چاہیے۔',
    emergencyMeaning: 'براہ کرم مدد کریں، یہ ایمرجنسی ہے۔',
    supportTitle: 'پاکستانی مدد',
    supportSubtitle: 'ہائی کمیشن آف پاکستان کی سرکاری معلومات',
    supportName: 'ہائی کمیشن آف پاکستان، کوالالمپور',
    supportDescription:
        'قونصلر، پاسپورٹ اور رجسٹریشن کے لیے سرکاری ویب سائٹ استعمال کریں۔',
    supportUrl: 'https://mofa.gov.pk/kuala-lumpur-malaysia',
    workerTitle: 'کام کا مسئلہ یا شکایت',
    workerBody: 'کام کے کاغذات محفوظ رکھیں اور ملائیشیا کے سرکاری JTK راستے سے مدد لیں۔',
    openOfficialLabel: 'سرکاری صفحہ کھولیں',
  ),
  AppLanguage.hindi: CountryHubProfile(
    hubTitle: 'भारतीय सहायता केंद्र',
    hubSubtitle: 'मलेशिया सेवा गाइड, मलय वाक्य और भारतीय सहायता',
    heroTitle: 'ज़रूरी काम आसानी से करें',
    heroBody:
        'मलेशिया की आधिकारिक सेवाओं और भारतीय सहायता के लिए सरल मार्गदर्शन।',
    serviceGuideTitle: 'सरकारी सेवा से पहले',
    serviceAdvice: 'पासपोर्ट और संदर्भ जानकारी तैयार रखें। जानकारी केवल आधिकारिक वेबसाइट पर दें।',
    phrasebookTitle: 'काम के लिए मलय भाषा',
    phrasebookSubtitle: 'काम, क्लिनिक और आपात स्थिति के छोटे वाक्य',
    primaryMeaning: 'मुझे मदद चाहिए।',
    emergencyMeaning: 'कृपया मदद करें, यह आपात स्थिति है।',
    supportTitle: 'भारतीय सहायता',
    supportSubtitle: 'भारत के उच्चायोग की आधिकारिक जानकारी',
    supportName: 'भारत का उच्चायोग, कुआलालंपुर',
    supportDescription:
        'कांसुलर, पासपोर्ट और आपात जानकारी के लिए आधिकारिक साइट का उपयोग करें।',
    supportUrl: 'https://www.hcikl.gov.in/',
    workerTitle: 'काम की समस्या या शिकायत',
    workerBody: 'काम के दस्तावेज सुरक्षित रखें और मलेशिया के आधिकारिक JTK चैनल से सहायता लें।',
    openOfficialLabel: 'आधिकारिक पेज खोलें',
  ),
  AppLanguage.nepali: CountryHubProfile(
    hubTitle: 'नेपाली सहायता केन्द्र',
    hubSubtitle: 'मलेसिया सेवा मार्गदर्शन, मलय वाक्य र नेपाली सहयोग',
    heroTitle: 'महत्त्वपूर्ण काम सजिलै गर्नुहोस्',
    heroBody: 'आधिकारिक मलेसिया सेवा र नेपाली सहयोगका लागि सरल मार्गदर्शन।',
    serviceGuideTitle: 'सरकारी सेवा अघि',
    serviceAdvice: 'पासपोर्ट र सन्दर्भ विवरण तयार राख्नुहोस्। जानकारी आधिकारिक साइटमा मात्र दिनुहोस्।',
    phrasebookTitle: 'कामका लागि मलय भाषा',
    phrasebookSubtitle: 'काम, क्लिनिक र आपतकालका छोटा वाक्य',
    primaryMeaning: 'मलाई सहयोग चाहिन्छ।',
    emergencyMeaning: 'कृपया सहयोग गर्नुहोस्, यो आपतकाल हो।',
    supportTitle: 'नेपाली सहयोग',
    supportSubtitle: 'नेपाल दूतावासको आधिकारिक जानकारी',
    supportName: 'नेपाल दूतावास, मलेसिया',
    supportDescription: 'राहदानी, कन्सुलर र आधिकारिक सूचनाका लागि दूतावासको साइट प्रयोग गर्नुहोस्।',
    supportUrl: 'https://my.nepalembassy.gov.np/',
    workerTitle: 'कामको समस्या वा गुनासो',
    workerBody:
        'कामका कागजात राख्नुहोस् र मलेसियाको आधिकारिक JTK बाट सहयोग लिनुहोस्।',
    openOfficialLabel: 'आधिकारिक पृष्ठ खोल्नुहोस्',
  ),
  AppLanguage.burmese: CountryHubProfile(
    hubTitle: 'မြန်မာအကူအညီဌာန',
    hubSubtitle: 'မလေးရှားဝန်ဆောင်မှု လမ်းညွှန်၊ မလေးစကားနှင့် မြန်မာအကူအညီ',
    heroTitle: 'အရေးကြီးအလုပ်များကို လွယ်ကူစွာလုပ်ပါ',
    heroBody: 'တရားဝင်မလေးရှားဝန်ဆောင်မှုနှင့် မြန်မာအကူအညီအတွက် ရိုးရှင်းသောလမ်းညွှန်။',
    serviceGuideTitle: 'တရားဝင်ဝန်ဆောင်မှုမတိုင်မီ',
    serviceAdvice: 'ပတ်စပို့နှင့် ရည်ညွှန်းအချက်အလက်ကို ပြင်ဆင်ပါ။ တရားဝင်ဝဘ်ဆိုက်တွင်သာ အချက်အလက်ထည့်ပါ။',
    phrasebookTitle: 'အလုပ်အတွက် မလေးစကား',
    phrasebookSubtitle: 'အလုပ်၊ ဆေးခန်းနှင့် အရေးပေါ်အတွက် စာကြောင်းတိုများ',
    primaryMeaning: 'ကျွန်တော်/ကျွန်မ အကူအညီလိုအပ်သည်။',
    emergencyMeaning: 'ကျေးဇူးပြု၍ ကူညီပါ၊ အရေးပေါ်ဖြစ်သည်။',
    supportTitle: 'မြန်မာအကူအညီ',
    supportSubtitle: 'မြန်မာသံရုံး၏ တရားဝင်အချက်အလက်',
    supportName: 'မြန်မာသံရုံး၊ ကွာလာလမ်ပူ',
    supportDescription: 'ကောင်စစ်၊ ပတ်စပို့နှင့် တရားဝင်ကြေညာချက်များအတွက် သံရုံးဝဘ်ဆိုက်ကို အသုံးပြုပါ။',
    supportUrl: 'https://myanmarembassykl.org/',
    workerTitle: 'အလုပ်ပြဿနာ သို့မဟုတ် တိုင်ကြားချက်',
    workerBody: 'အလုပ်စာရွက်များသိမ်းထားပြီး မလေးရှား JTK တရားဝင်လမ်းကြောင်းမှ အကူအညီရယူပါ။',
    openOfficialLabel: 'တရားဝင်စာမျက်နှာဖွင့်ပါ',
  ),
  AppLanguage.thai: CountryHubProfile(
    hubTitle: 'ศูนย์ช่วยเหลือคนไทย',
    hubSubtitle: 'คู่มือบริการมาเลเซีย วลีภาษามลายู และความช่วยเหลือไทย',
    heroTitle: 'จัดการเรื่องสำคัญอย่างชัดเจน',
    heroBody: 'คำแนะนำง่าย ๆ สำหรับบริการทางการมาเลเซียและความช่วยเหลือคนไทย',
    serviceGuideTitle: 'ก่อนใช้บริการทางการ',
    serviceAdvice: 'เตรียมหนังสือเดินทางและข้อมูลอ้างอิง ให้ข้อมูลเฉพาะเว็บไซต์ทางการเท่านั้น',
    phrasebookTitle: 'ภาษามลายูสำหรับงาน',
    phrasebookSubtitle: 'ประโยคสั้นสำหรับงาน คลินิก และเหตุฉุกเฉิน',
    primaryMeaning: 'ฉันต้องการความช่วยเหลือ',
    emergencyMeaning: 'ช่วยด้วย นี่คือเหตุฉุกเฉิน',
    supportTitle: 'ความช่วยเหลือคนไทย',
    supportSubtitle: 'ข้อมูลทางการจากสถานเอกอัครราชทูตไทย',
    supportName: 'สถานเอกอัครราชทูตไทย ณ กรุงกัวลาลัมเปอร์',
    supportDescription:
        'ใช้เว็บไซต์ทางการสำหรับข้อมูลกงสุล หนังสือเดินทาง และเหตุฉุกเฉิน',
    supportUrl: 'https://kualalumpur.thaiembassy.org/',
    workerTitle: 'ปัญหางานหรือข้อร้องเรียน',
    workerBody:
        'เก็บเอกสารการทำงานและใช้ช่องทาง JTK ของมาเลเซียเพื่อขอความช่วยเหลือ',
    openOfficialLabel: 'เปิดหน้าอย่างเป็นทางการ',
  ),
  AppLanguage.khmer: CountryHubProfile(
    hubTitle: 'មជ្ឈមណ្ឌលជំនួយកម្ពុជា',
    hubSubtitle: 'មគ្គុទ្ទេសក៍សេវាម៉ាឡេស៊ី ឃ្លាភាសាម៉ាឡេ និងជំនួយកម្ពុជា',
    heroTitle: 'ធ្វើកិច្ចការសំខាន់ដោយច្បាស់លាស់',
    heroBody: 'ការណែនាំងាយស្រួលសម្រាប់សេវាផ្លូវការម៉ាឡេស៊ី និងជំនួយកម្ពុជា។',
    serviceGuideTitle: 'មុនសេវាផ្លូវការ',
    serviceAdvice:
        'ត្រៀមលិខិតឆ្លងដែន និងព័ត៌មានយោង។ បញ្ចូលព័ត៌មានតែនៅលើគេហទំព័រផ្លូវការ។',
    phrasebookTitle: 'ភាសាម៉ាឡេសម្រាប់ការងារ',
    phrasebookSubtitle: 'ប្រយោគខ្លីសម្រាប់ការងារ គ្លីនិក និងបន្ទាន់',
    primaryMeaning: 'ខ្ញុំត្រូវការជំនួយ។',
    emergencyMeaning: 'សូមជួយផង នេះជាករណីបន្ទាន់។',
    supportTitle: 'ជំនួយកម្ពុជា',
    supportSubtitle: 'ព័ត៌មានផ្លូវការពីស្ថានទូតកម្ពុជា',
    supportName: 'ស្ថានទូតព្រះរាជាណាចក្រកម្ពុជា កូឡាឡាំពួរ',
    supportDescription:
        'ប្រើទំព័រផ្លូវការសម្រាប់ព័ត៌មានកុងស៊ុល និងលិខិតឆ្លងដែន។',
    supportUrl:
        'https://www.mfaic.gov.kh/Embassies/Royal%20Embassy%20of%20Cambodia',
    workerTitle: 'បញ្ហាការងារ ឬបណ្តឹង',
    workerBody:
        'រក្សាទុកឯកសារការងារ ហើយប្រើផ្លូវការរបស់ JTK ម៉ាឡេស៊ីសម្រាប់ជំនួយ។',
    openOfficialLabel: 'បើកទំព័រផ្លូវការ',
  ),
  AppLanguage.filipino: CountryHubProfile(
    hubTitle: 'Sentro ng Tulong para sa Pilipino',
    hubSubtitle: 'Gabay sa serbisyo ng Malaysia, mga pariralang Malay at tulong Pilipino',
    heroTitle: 'Ayusin ang mahalagang gawain nang malinaw',
    heroBody: 'Simpleng gabay para sa opisyal na serbisyo ng Malaysia at tulong para sa Pilipino.',
    serviceGuideTitle: 'Bago ang opisyal na serbisyo',
    serviceAdvice: 'Ihanda ang pasaporte at reference details. Magbigay ng impormasyon sa opisyal na website lamang.',
    phrasebookTitle: 'Malay para sa trabaho',
    phrasebookSubtitle:
        'Maiikling parirala para sa trabaho, klinika at emergency',
    primaryMeaning: 'Kailangan ko ng tulong.',
    emergencyMeaning: 'Tulong, emergency ito.',
    supportTitle: 'Tulong para sa Pilipino',
    supportSubtitle: 'Opisyal na impormasyon mula sa Embahada ng Pilipinas',
    supportName: 'Embassy of the Philippines, Kuala Lumpur',
    supportDescription: 'Gamitin ang opisyal na site para sa konsular, pasaporte at manggagawang Pilipino.',
    supportUrl: 'https://kualalumpurpe.dfa.gov.ph/',
    workerTitle: 'Problema sa trabaho o reklamo',
    workerBody: 'Itago ang mga dokumento sa trabaho at gamitin ang opisyal na JTK Malaysia para sa tulong.',
    openOfficialLabel: 'Buksan ang opisyal na pahina',
  ),
  AppLanguage.chinese: CountryHubProfile(
    hubTitle: '华人援助中心',
    hubSubtitle: '马来西亚服务指南、马来语短句与中国领事协助',
    heroTitle: '清晰处理重要事项',
    heroBody: '为马来西亚官方服务和中国公民协助提供简单指引。',
    serviceGuideTitle: '使用官方服务前',
    serviceAdvice: '准备护照和参考资料。仅在官方网站提供个人信息。',
    phrasebookTitle: '工作常用马来语',
    phrasebookSubtitle: '工作、诊所和紧急情况的简短句子',
    primaryMeaning: '我需要帮助。',
    emergencyMeaning: '请帮忙，这是紧急情况。',
    supportTitle: '中国公民协助',
    supportSubtitle: '中国驻马来西亚使馆官方信息',
    supportName: '中华人民共和国驻马来西亚大使馆',
    supportDescription: '请使用使馆官方网站了解领事、护照和官方通知。',
    supportUrl: 'http://my.china-embassy.gov.cn/eng/',
    workerTitle: '工作问题或投诉',
    workerBody: '保存工作文件，并通过马来西亚官方 JTK 渠道寻求帮助。',
    openOfficialLabel: '打开官方网站',
  ),
  AppLanguage.vietnamese: CountryHubProfile(
    hubTitle: 'Trung tâm hỗ trợ Việt Nam',
    hubSubtitle: 'Hướng dẫn dịch vụ Malaysia, câu Malay và hỗ trợ Việt Nam',
    heroTitle: 'Giải quyết việc quan trọng rõ ràng',
    heroBody: 'Hướng dẫn đơn giản về dịch vụ chính thức Malaysia và hỗ trợ người Việt.',
    serviceGuideTitle: 'Trước khi dùng dịch vụ chính thức',
    serviceAdvice: 'Chuẩn bị hộ chiếu và thông tin tham chiếu. Chỉ cung cấp thông tin trên trang chính thức.',
    phrasebookTitle: 'Tiếng Malay cho công việc',
    phrasebookSubtitle:
        'Câu ngắn cho công việc, phòng khám và tình huống khẩn cấp',
    primaryMeaning: 'Tôi cần giúp đỡ.',
    emergencyMeaning: 'Xin giúp tôi, đây là tình huống khẩn cấp.',
    supportTitle: 'Hỗ trợ người Việt',
    supportSubtitle: 'Thông tin chính thức từ Đại sứ quán Việt Nam',
    supportName: 'Đại sứ quán Việt Nam tại Kuala Lumpur',
    supportDescription: 'Dùng trang chính thức để xem thông tin lãnh sự, hộ chiếu và thông báo.',
    supportUrl: 'https://vnembassy-kualalumpur.mofa.gov.vn/',
    workerTitle: 'Vấn đề công việc hoặc khiếu nại',
    workerBody: 'Giữ giấy tờ công việc và sử dụng kênh JTK chính thức của Malaysia để được hỗ trợ.',
    openOfficialLabel: 'Mở trang chính thức',
  ),
  AppLanguage.sinhala: CountryHubProfile(
    hubTitle: 'ශ්‍රී ලාංකික සහාය මධ්‍යස්ථානය',
    hubSubtitle: 'මැලේසියා සේවා මාර්ගෝපදේශ, මැලේ වාක්‍ය සහ ශ්‍රී ලාංකික සහාය',
    heroTitle: 'වැදගත් කටයුතු පැහැදිලිව කරන්න',
    heroBody: 'මැලේසියා නිල සේවා සහ ශ්‍රී ලාංකික සහාය සඳහා සරල මාර්ගෝපදේශය.',
    serviceGuideTitle: 'නිල සේවාවට පෙර',
    serviceAdvice: 'ගමන් බලපත්‍රය සහ යොමු තොරතුරු සූදානම් කරගන්න. තොරතුරු නිල වෙබ් අඩවියේ පමණක් ලබාදෙන්න.',
    phrasebookTitle: 'රැකියාව සඳහා මැලේ භාෂාව',
    phrasebookSubtitle: 'රැකියාව, සායනය සහ හදිසි අවස්ථා සඳහා කෙටි වාක්‍ය',
    primaryMeaning: 'මට උදව් අවශ්‍යයි.',
    emergencyMeaning: 'කරුණාකර උදව් කරන්න, මෙය හදිසි අවස්ථාවකි.',
    supportTitle: 'ශ්‍රී ලාංකික සහාය',
    supportSubtitle: 'ශ්‍රී ලංකා මහ කොමසාරිස් කාර්යාලයේ නිල තොරතුරු',
    supportName: 'ශ්‍රී ලංකා මහ කොමසාරිස් කාර්යාලය, කුවාලාලම්පූර්',
    supportDescription: 'කොන්සියුලර්, ගමන් බලපත්‍ර සහ නිල නිවේදන සඳහා නිල වෙබ් අඩවිය භාවිතා කරන්න.',
    supportUrl: 'https://slhc.com.my/',
    workerTitle: 'රැකියා ගැටලුවක් හෝ පැමිණිල්ලක්',
    workerBody: 'රැකියා ලේඛන තබාගෙන මැලේසියානු JTK නිල මාර්ගයෙන් සහාය ගන්න.',
    openOfficialLabel: 'නිල පිටුව විවෘත කරන්න',
  ),
  AppLanguage.korean: _genericCountryHubProfile,
  AppLanguage.japanese: _genericCountryHubProfile,
  AppLanguage.german: _genericCountryHubProfile,
  AppLanguage.french: _genericCountryHubProfile,
  AppLanguage.spanish: _genericCountryHubProfile,
  AppLanguage.arabic: _genericCountryHubProfile,
  AppLanguage.russian: _genericCountryHubProfile,
};

class GlobalCountrySupportPage extends StatelessWidget {
  const GlobalCountrySupportPage({
    super.key,
    required this.country,
    required this.language,
  });

  final CountryOption country;
  final AppLanguage language;

  void _open(BuildContext context, String title, String url) {
    openWebsiteInApp(
      context,
      title: title,
      url: url,
      copy: appCopies[language]!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = appCopies[language]!;
    final scheme = Theme.of(context).colorScheme;
    final eligibility = country.isMalaysiaWorkerSourceCountry
        ? 'Malaysia-listed source-country group'
        : 'Nationality alone does not confirm work eligibility';
    return Directionality(
      textDirection: copy.direction,
      child: Scaffold(
        appBar: _AppBar(
          title: country.name,
          leading: IconButton(
            tooltip: copy.backToServices,
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            CivicHeroPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(country.flag, style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 10),
                  Text(
                    '${country.name} support',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Official routes for workers from ${country.name}.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.76),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: scheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      eligibility,
                      style: TextStyle(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CivicSectionLabel(
              label: 'OFFICIAL MALAYSIA ROUTES',
              trailing: const _CountPill(label: 'VERIFIED'),
            ),
            const SizedBox(height: 10),
            _CountryResourceTile(
              icon: Icons.badge_outlined,
              title: 'Foreign worker rules',
              subtitle:
                  'Malaysia Immigration · check current permit conditions',
              onTap: () => _open(
                context,
                'Malaysia Immigration',
                'https://www.imi.gov.my/index.php/en/main-services/foreign-worker/',
              ),
            ),
            _CountryResourceTile(
              icon: Icons.public_outlined,
              title: '${country.name} government portal',
              subtitle: _knownCountryOfficialPortal(country) != null
                  ? 'Verified country-government starting point'
                  : 'Direct portal not verified; opens the official Malaysia MFA directory',
              onTap: () => _open(
                context,
                '${country.name} government portal',
                _officialCountryPortal(country),
              ),
            ),
            _CountryResourceTile(
              icon: Icons.work_outline_rounded,
              title: 'Work portal',
              subtitle: 'Malaysia MyGovernment worker guidance',
              onTap: () => _open(
                context,
                'MyGovernment work portal',
                'https://rai.malaysia.gov.my/work',
              ),
            ),
            _CountryResourceTile(
              icon: Icons.account_balance_outlined,
              title: 'Find your embassy or mission',
              subtitle: 'Malaysia MFA official directory',
              onTap: () => _open(
                context,
                'MFA directory',
                'https://direktori.kln.gov.my/',
              ),
            ),
            _CountryResourceTile(
              icon: Icons.phone_outlined,
              title: 'Malaysia MFA contact',
              subtitle: '+603-8000 8000 · official general assistance',
              onTap: () => launchUrl(Uri.parse('tel:+60380008000')),
            ),
            const SizedBox(height: 14),
            CivicSectionLabel(
              label: 'OFFICIAL MFA SOCIAL CHANNELS',
              trailing: const _CountPill(label: '3 CHANNELS'),
            ),
            const SizedBox(height: 10),
            _CountryResourceTile(
              icon: Icons.facebook_rounded,
              title: 'Facebook',
              subtitle: 'Ministry of Foreign Affairs Malaysia',
              onTap: () => _open(
                context,
                'MFA Facebook',
                'https://www.facebook.com/MOFAMalaysia/',
              ),
            ),
            _CountryResourceTile(
              icon: Icons.alternate_email_rounded,
              title: 'X',
              subtitle: 'Malaysia MFA',
              onTap: () => _open(
                context,
                'Malaysia MFA on X',
                'https://x.com/MalaysiaMFA',
              ),
            ),
            _CountryResourceTile(
              icon: Icons.camera_alt_outlined,
              title: 'Instagram',
              subtitle: 'MFA Malaysia',
              onTap: () => _open(
                context,
                'MFA Instagram',
                'https://www.instagram.com/mofamalaysia/',
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Country-specific embassy websites and social pages are not guessed here. Use the official directory to find the correct mission for your country, then verify any phone number before relying on it.',
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.62),
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryResourceTile extends StatelessWidget {
  const _CountryResourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _UtilityListTile(
        icon: icon,
        title: title,
        subtitle: subtitle,
        onTap: onTap,
      ),
    );
  }
}

const _countryOfficialPortals = <String, String>{
  'BD': 'https://bangladesh.gov.bd/',
  'KH': 'https://www.cambodia.gov.kh/',
  'CN': 'https://www.gov.cn/',
  'IN': 'https://www.india.gov.in/',
  'ID': 'https://www.indonesia.go.id/',
  'LA': 'https://www.laogov.gov.la/',
  'MM': 'https://myanmar.gov.mm/',
  'NP': 'https://nepal.gov.np/',
  'PK': 'https://www.pakistan.gov.pk/',
  'PH': 'https://www.gov.ph/',
  'LK': 'https://www.gov.lk/',
  'TH': 'https://www.thaigov.go.th/',
  'VN': 'https://chinhphu.vn/',
  'MY': 'https://www.malaysia.gov.my/',
};

String? _knownCountryOfficialPortal(CountryOption country) =>
    _countryOfficialPortals[country.code.toUpperCase()];

String _officialCountryPortal(CountryOption country) =>
    _knownCountryOfficialPortal(country) ??
    'https://www.kln.gov.my/web/guest/foreign-missions-in-malaysia';

class CountryPriorityHubPage extends StatelessWidget {
  const CountryPriorityHubPage({
    super.key,
    required this.language,
    this.country,
  });

  final AppLanguage language;
  final CountryOption? country;

  @override
  Widget build(BuildContext context) {
    final profile = _countryHubProfileFor(language);
    final copy = appCopies[language]!;
    final countryLabel = country == null
        ? null
        : '${country!.flag} ${country!.name}';
    return Directionality(
      textDirection: copy.direction,
      child: Scaffold(
        appBar: _AppBar(
          title: countryLabel == null
              ? profile.hubTitle
              : '$countryLabel · ${profile.hubTitle}',
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        bottomNavigationBar: _CompactCreditBar(
          copy: copy,
          onOpenProfile: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CreatorProfilePage(copy: copy),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            _CountryHubHero(profile: profile, country: country),
            const SizedBox(height: 18),
            _CountryHubCard(
              number: '01',
              icon: Icons.assignment_turned_in_outlined,
              title: profile.serviceGuideTitle,
              subtitle: profile.serviceAdvice,
              color: AppPalette.evergreen,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CountryServiceGuidePage(
                    language: language,
                    profile: profile,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _CountryHubCard(
              number: '02',
              icon: Icons.record_voice_over_outlined,
              title: profile.phrasebookTitle,
              subtitle: profile.phrasebookSubtitle,
              color: AppPalette.ink,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CountryPhrasebookPage(
                    language: language,
                    profile: profile,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _CountryHubCard(
              number: '03',
              icon: Icons.account_balance_outlined,
              title: profile.supportTitle,
              subtitle: profile.supportSubtitle,
              color: AppPalette.ink,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      CountrySupportPage(language: language, profile: profile),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _CountryHubCard(
              number: '04',
              icon: Icons.support_agent_outlined,
              title: profile.workerTitle,
              subtitle: profile.workerBody,
              color: AppPalette.ink,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CountryWorkerSupportPage(
                    language: language,
                    profile: profile,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _CountryHubCard(
              number: '05',
              icon: Icons.workspace_premium_outlined,
              title: _localizedGoldTitle(language),
              subtitle: _countryResourceProfileFor(language).goldReferenceName,
              color: AppPalette.ink,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CountryGoldReferencePage(language: language),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _CountryHubCard(
              number: '06',
              icon: Icons.public_outlined,
              title: _localizedGovernmentPortalTitle(language),
              subtitle: country == null
                  ? profile.supportDescription
                  : '${country!.name} official government portal or Malaysia MFA directory',
              color: AppPalette.ink,
              onTap: country == null
                  ? () => openWebsiteInApp(
                      context,
                      title: _localizedGovernmentPortalTitle(language),
                      url: _countryGovernmentPortalFor(language),
                      copy: copy,
                    )
                  : () => openWebsiteInApp(
                      context,
                      title: '${country!.name} official government portal',
                      url: _officialCountryPortal(country!),
                      copy: copy,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryHubHero extends StatelessWidget {
  const _CountryHubHero({required this.profile, this.country});

  final CountryHubProfile profile;
  final CountryOption? country;

  @override
  Widget build(BuildContext context) {
    return CivicHeroPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroStatusPill(
            label: country == null
                ? 'COUNTRY SUPPORT'
                : '${country!.code} SUPPORT',
          ),
          const SizedBox(height: 12),
          Text(
            country == null
                ? profile.heroTitle
                : '${country!.name}: ${profile.heroTitle}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            country == null
                ? profile.heroBody
                : '${profile.heroBody} Official home-country routes are shown for ${country!.name}; verify current contacts before use.',
            style: const TextStyle(
              color: Color(0xFFD8D8D2),
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

// Reference-informed monochrome utility row: supports semantic light and dark contrast.
class _CountryHubCard extends StatelessWidget {
  // semantic monochrome support row
  const _CountryHubCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final String number;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppPalette.outline),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 17, color: color),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: AppPalette.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppPalette.muted,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppPalette.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class CountryHubScaffold extends StatelessWidget {
  const CountryHubScaffold({
    super.key,
    required this.language,
    required this.title,
    required this.children,
  });

  final AppLanguage language;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final copy = appCopies[language]!;
    return Directionality(
      textDirection: copy.direction,
      child: Scaffold(
        appBar: _AppBar(
          title: title,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        bottomNavigationBar: _CompactCreditBar(
          copy: copy,
          onOpenProfile: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CreatorProfilePage(copy: copy),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: children,
        ),
      ),
    );
  }
}

class CountryServiceGuidePage extends StatelessWidget {
  const CountryServiceGuidePage({
    super.key,
    required this.language,
    required this.profile,
  });

  final AppLanguage language;
  final CountryHubProfile profile;

  Future<void> _open(BuildContext context, String url) async {
    openWebsiteInApp(
      context,
      title: profile.openOfficialLabel,
      url: url,
      copy: appCopies[language]!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CountryHubScaffold(
      language: language,
      title: profile.serviceGuideTitle,
      children: [
        _BanglaSection(
          icon: Icons.badge_outlined,
          title: profile.serviceGuideTitle,
          body: profile.serviceAdvice,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => _open(
            context,
            'https://eservices.imi.gov.my/myimms/VPAStsInq?MAD_DOC_NO=&MAD_DOC_CTRY_CD=BGD&search=CARIAN&lang=en',
          ),
          icon: const Icon(Icons.open_in_new_rounded),
          label: Text('Visa / pass · ${profile.openOfficialLabel}'),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () => _open(
            context,
            'https://eservices.imi.gov.my/myimms/FomemaStatus',
          ),
          icon: const Icon(Icons.open_in_new_rounded),
          label: Text('FOMEMA · ${profile.openOfficialLabel}'),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () => _open(context, 'https://www.kwsp.gov.my/ms/'),
          icon: const Icon(Icons.open_in_new_rounded),
          label: Text('EPF / KWSP · ${profile.openOfficialLabel}'),
        ),
      ],
    );
  }
}

String _learningSearchHint(AppLanguage language) => switch (language) {
  AppLanguage.bangla => 'মালয় শব্দ বা বাক্য খুঁজুন',
  AppLanguage.hindi => 'मलय शब्द या वाक्य खोजें',
  AppLanguage.urdu => 'ملائی الفاظ یا جملے تلاش کریں',
  AppLanguage.nepali => 'मलय शब्द वा वाक्य खोज्नुहोस्',
  AppLanguage.malay => 'Cari perkataan atau ayat Melayu',
  AppLanguage.indonesian => 'Cari kata atau kalimat Melayu',
  AppLanguage.tamil => 'மலாய் சொற்கள் அல்லது வாக்கியங்களைத் தேடுங்கள்',
  AppLanguage.chinese => '搜索马来语单词或句子',
  AppLanguage.thai => 'ค้นหาคำหรือประโยคภาษามลายู',
  AppLanguage.vietnamese => 'Tìm từ hoặc câu tiếng Malay',
  AppLanguage.burmese => 'မလေးစကားလုံး သို့မဟုတ် စာကြောင်း ရှာရန်',
  AppLanguage.khmer => 'ស្វែងរកពាក្យ ឬប្រយោគម៉ាឡេ',
  AppLanguage.filipino => 'Maghanap ng salitang o pangungusap sa Malay',
  AppLanguage.sinhala => 'මැලේ වචන හෝ වාක්‍ය සොයන්න',
  AppLanguage.korean => '말레이어 단어 또는 문장 검색',
  AppLanguage.japanese => 'マレー語の単語や文を検索',
  AppLanguage.german => 'Malaiische Wörter oder Sätze suchen',
  AppLanguage.french => 'Rechercher des mots ou phrases malais',
  AppLanguage.spanish => 'Buscar palabras o frases en malayo',
  AppLanguage.arabic => 'ابحث عن كلمات أو عبارات ملايوية',
  AppLanguage.russian => 'Поиск малайских слов или фраз',
  AppLanguage.english => 'Search Malay words or phrases',
};

String _learningNoMatch(AppLanguage language) => switch (language) {
  AppLanguage.bangla => 'মিল পাওয়া যায়নি।',
  AppLanguage.hindi => 'कोई मिलान नहीं मिला।',
  AppLanguage.urdu => 'کوئی مماثلت نہیں ملی۔',
  AppLanguage.nepali => 'कुनै मिल्दो कुरा भेटिएन।',
  AppLanguage.malay => 'Tiada padanan ditemui.',
  AppLanguage.indonesian => 'Tidak ada kecocokan.',
  AppLanguage.tamil => 'பொருத்தம் எதுவும் கிடைக்கவில்லை.',
  AppLanguage.chinese => '没有找到匹配内容。',
  AppLanguage.thai => 'ไม่พบรายการที่ตรงกัน',
  AppLanguage.vietnamese => 'Không tìm thấy kết quả phù hợp.',
  AppLanguage.burmese => 'ကိုက်ညီမှု မတွေ့ပါ။',
  AppLanguage.khmer => 'រកមិនឃើញលទ្ធផលដែលត្រូវគ្នា។',
  AppLanguage.filipino => 'Walang nahanap na tugma.',
  AppLanguage.sinhala => 'ගැළපෙන කිසිවක් හමු නොවීය.',
  AppLanguage.korean => '일치하는 말레이어 표현이 없습니다.',
  AppLanguage.japanese => '一致するマレー語の表現が見つかりません。',
  AppLanguage.german => 'Keine passende malaiische Phrase gefunden.',
  AppLanguage.french => 'Aucune phrase malaise correspondante trouvée.',
  AppLanguage.spanish => 'No se encontró ninguna frase en malayo.',
  AppLanguage.arabic => 'لم يتم العثور على عبارة ملايوية مطابقة.',
  AppLanguage.russian => 'Подходящая малайская фраза не найдена.',
  AppLanguage.english => 'No matching Malay phrase found.',
};

const _englishLearningProfile = CountryHubProfile(
  hubTitle: 'Support',
  hubSubtitle: 'Official support and practical tools',
  heroTitle: 'Learn Malay for daily life',
  heroBody: 'Use the complete Malay sentences and words library with pronunciation support.',
  serviceGuideTitle: 'Official services',
  serviceAdvice: 'Use official sources for current rules.',
  phrasebookTitle: 'Malay phrasebook',
  phrasebookSubtitle: 'Malay words and sentences with pronunciation support.',
  primaryMeaning: 'I need help.',
  emergencyMeaning: 'Please, this is an emergency.',
  supportTitle: 'Country support',
  supportSubtitle: 'Find official routes for your country.',
  supportName: 'Malaysia MFA directory',
  supportDescription: 'Official directory of foreign missions in Malaysia.',
  supportUrl: 'https://www.kln.gov.my/web/guest/foreign-missions-in-malaysia',
  workerTitle: 'Worker support',
  workerBody: 'Keep official contacts close when you need help.',
  openOfficialLabel: 'Open official site',
);

CountryHubProfile _learningProfileFor(AppLanguage language) =>
    _countryHubProfileFor(language);

class CountryPhrasebookPage extends StatefulWidget {
  const CountryPhrasebookPage({
    super.key,
    required this.language,
    this.profile,
  });
  final AppLanguage language;
  final CountryHubProfile? profile;

  @override
  State<CountryPhrasebookPage> createState() => _CountryPhrasebookPageState();
}

class _CountryPhrasebookPageState extends State<CountryPhrasebookPage> {
  late final Future<_MalayLearningLibrary> _library =
      _MalayLearningLibrary.load();
  final _searchController = TextEditingController();
  _LearningLibraryMode _mode = _LearningLibraryMode.sentences;
  String _query = '';
  int _visibleLimit = 40;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setMode(_LearningLibraryMode mode) {
    setState(() {
      _mode = mode;
      _visibleLimit = 40;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_MalayLearningLibrary>(
      future: _library,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CountryHubScaffold(
            language: widget.language,
            title: (widget.profile ?? _learningProfileFor(widget.language))
                .phrasebookTitle,
            children: const [
              Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        }
        return _buildLibrary(context, snapshot.data!);
      },
    );
  }

  Widget _buildLibrary(BuildContext context, _MalayLearningLibrary library) {
    final profile = widget.profile ?? _learningProfileFor(widget.language);
    final scheme = Theme.of(context).colorScheme;
    final sentenceMode = _mode == _LearningLibraryMode.sentences;
    final List<_CountryLearningItem> items = sentenceMode
        ? library.sentences
              .where(
                (item) => '${item.malay} ${item.pronunciation}'
                    .toLowerCase()
                    .contains(_query),
              )
              .map(
                (item) => _CountryLearningItem(
                  malay: item.malay,
                  pronunciation: item.pronunciation,
                  meaning: item.meaning,
                  label: item.category,
                ),
              )
              .toList(growable: false)
        : library.words
              .where(
                (item) => '${item.malay} ${item.pronunciation}'
                    .toLowerCase()
                    .contains(_query),
              )
              .map(
                (item) => _CountryLearningItem(
                  malay: item.malay,
                  pronunciation: item.pronunciation,
                  meaning: item.meaning,
                  label: item.wordType,
                ),
              )
              .toList(growable: false);
    final visible = items.take(_visibleLimit).toList(growable: false);
    return CountryHubScaffold(
      language: widget.language,
      title: profile.phrasebookTitle,
      children: [
        CivicHeroPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeroStatusPill(label: 'MALAY LEARNING LIBRARY'),
              const SizedBox(height: 14),
              Text(
                profile.phrasebookTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${library.sentences.length} Malay sentences · ${library.words.length} Malay words. ${profile.phrasebookSubtitle}',
                style: const TextStyle(
                  color: Color(0xFFD6E2F5),
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _LanguageLibraryModeCard(
                label: 'Sentences',
                count: '${library.sentences.length}',
                icon: Icons.chat_bubble_outline_rounded,
                selected: sentenceMode,
                onTap: () => _setMode(_LearningLibraryMode.sentences),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _LanguageLibraryModeCard(
                label: 'Words',
                count: '${library.words.length}',
                icon: Icons.menu_book_outlined,
                selected: !sentenceMode,
                onTap: () => _setMode(_LearningLibraryMode.words),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() {
            _query = value.trim().toLowerCase();
            _visibleLimit = 40;
          }),
          decoration: InputDecoration(
            hintText: _learningSearchHint(widget.language),
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: scheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: scheme.onSurface.withValues(alpha: 0.18),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _CountryLearningShortcut(
          malay: 'Saya perlukan bantuan.',
          meaning: profile.primaryMeaning,
          language: widget.language,
        ),
        const SizedBox(height: 10),
        _CountryLearningShortcut(
          malay: 'Tolong, ini kecemasan.',
          meaning: profile.emergencyMeaning,
          language: widget.language,
          emergency: true,
        ),
        const SizedBox(height: 18),
        CivicSectionLabel(
          label: sentenceMode
              ? (widget.language == AppLanguage.bangla
                    ? 'মালয় বাক্য'
                    : 'Malay sentences')
              : (widget.language == AppLanguage.bangla
                    ? 'মালয় শব্দ'
                    : 'Malay words'),
          trailing: _CountPill(label: '${items.length} results'),
        ),
        const SizedBox(height: 12),
        for (final item in visible) ...[
          _CountryLibraryItemCard(
            item: item,
            language: widget.language,
            targetLabel: profile.phrasebookTitle,
          ),
          const SizedBox(height: 10),
        ],
        if (visible.isEmpty)
          Text(
            _learningNoMatch(widget.language),
            style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.7)),
          ),
        if (items.length > visible.length)
          OutlinedButton.icon(
            onPressed: () => setState(() => _visibleLimit += 40),
            icon: const Icon(Icons.expand_more_rounded),
            label: Text(
              widget.language == AppLanguage.bangla
                  ? 'আরও ${items.length - visible.length}টি দেখুন'
                  : 'Show ${items.length - visible.length} more',
            ),
          ),
      ],
    );
  }
}

class _LanguageLibraryModeCard extends StatelessWidget {
  const _LanguageLibraryModeCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String count;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CivicPressable(
      radius: 19,
      color: selected ? scheme.primary : scheme.surface,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: selected ? scheme.onPrimary : scheme.primary),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? scheme.onPrimary : scheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              count,
              style: TextStyle(
                color: selected
                    ? scheme.onPrimary.withValues(alpha: 0.8)
                    : scheme.onSurface.withValues(alpha: 0.66),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryLearningShortcut extends StatelessWidget {
  const _CountryLearningShortcut({
    required this.malay,
    required this.meaning,
    required this.language,
    this.emergency = false,
  });

  final String malay;
  final String meaning;
  final AppLanguage language;
  final bool emergency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CivicPressable(
      onTap: () => _openCountryTranslation(context, language, malay),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: (emergency ? scheme.error : scheme.primary).withValues(
                  alpha: 0.13,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                emergency
                    ? Icons.emergency_outlined
                    : Icons.record_voice_over_outlined,
                color: emergency ? scheme.error : scheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    malay,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meaning,
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.68),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.translate_rounded, color: scheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _CountryLearningItem {
  const _CountryLearningItem({
    required this.malay,
    required this.pronunciation,
    required this.meaning,
    required this.label,
  });

  final String malay;
  final String pronunciation;
  final String meaning;
  final String label;
}

class _CountryLibraryItemCard extends StatelessWidget {
  const _CountryLibraryItemCard({
    required this.item,
    required this.language,
    required this.targetLabel,
  });

  final _CountryLearningItem item;
  final AppLanguage language;
  final String targetLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CivicPressable(
      onTap: () => _openCountryTranslation(context, language, item.malay),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(Icons.translate_rounded, color: scheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.malay,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.pronunciation,
                    style: TextStyle(
                      color: scheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    language == AppLanguage.bangla
                        ? item.meaning
                        : '$targetLabel · tap to translate and listen',
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.68),
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              item.label,
              style: TextStyle(
                color: scheme.primary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _openCountryTranslation(
  BuildContext context,
  AppLanguage language,
  String text,
) {
  final uri = Uri.https('translate.google.com', '/', {
    'sl': 'ms',
    'tl': _translateTargetCode(language),
    'text': text,
    'op': 'translate',
  });
  openWebsiteInApp(
    context,
    title: 'Google Translate',
    url: uri.toString(),
    copy: appCopies[language]!,
  );
}

String _translateTargetCode(AppLanguage language) {
  switch (language) {
    case AppLanguage.english:
      return 'en';
    case AppLanguage.bangla:
      return 'bn';
    case AppLanguage.malay:
      return 'ms';
    case AppLanguage.indonesian:
      return 'id';
    case AppLanguage.tamil:
      return 'ta';
    case AppLanguage.urdu:
      return 'ur';
    case AppLanguage.hindi:
      return 'hi';
    case AppLanguage.nepali:
      return 'ne';
    case AppLanguage.burmese:
      return 'my';
    case AppLanguage.thai:
      return 'th';
    case AppLanguage.khmer:
      return 'km';
    case AppLanguage.filipino:
      return 'tl';
    case AppLanguage.chinese:
      return 'zh-CN';
    case AppLanguage.vietnamese:
      return 'vi';
    case AppLanguage.sinhala:
      return 'si';
    case AppLanguage.korean:
      return 'ko';
    case AppLanguage.japanese:
      return 'ja';
    case AppLanguage.german:
      return 'de';
    case AppLanguage.french:
      return 'fr';
    case AppLanguage.spanish:
      return 'es';
    case AppLanguage.arabic:
      return 'ar';
    case AppLanguage.russian:
      return 'ru';
  }
}

class CountrySupportPage extends StatelessWidget {
  const CountrySupportPage({
    super.key,
    required this.language,
    required this.profile,
  });

  final AppLanguage language;
  final CountryHubProfile profile;

  @override
  Widget build(BuildContext context) {
    final resources = _countryResourceProfileFor(language);
    return CountryHubScaffold(
      language: language,
      title: profile.supportTitle,
      children: [
        _BanglaSection(
          icon: Icons.account_balance_outlined,
          title: profile.supportName,
          body: profile.supportDescription,
          color: const Color(0xFF7C2349),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => openWebsiteInApp(
            context,
            title: profile.supportName,
            url: profile.supportUrl,
            copy: appCopies[language]!,
          ),
          icon: const Icon(Icons.open_in_new_rounded),
          label: Text(profile.openOfficialLabel),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => openWebsiteInApp(
            context,
            title: _localizedGovernmentPortalTitle(language),
            url: _countryGovernmentPortalFor(language),
            copy: appCopies[language]!,
          ),
          icon: const Icon(Icons.public_outlined),
          label: Text(_localizedGovernmentPortalTitle(language)),
        ),
        if (resources.officialSocialUrl != null) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => openWebsiteInApp(
              context,
              title: '${profile.supportName} · Facebook',
              url: resources.officialSocialUrl!,
              copy: appCopies[language]!,
            ),
            icon: const Icon(Icons.facebook_rounded),
            label: Text(_localizedOfficialSocialLabel(language)),
          ),
        ],
      ],
    );
  }
}

class CountryWorkerSupportPage extends StatelessWidget {
  const CountryWorkerSupportPage({
    super.key,
    required this.language,
    required this.profile,
  });

  final AppLanguage language;
  final CountryHubProfile profile;

  @override
  Widget build(BuildContext context) {
    return CountryHubScaffold(
      language: language,
      title: profile.workerTitle,
      children: [
        _BanglaSection(
          icon: Icons.folder_copy_outlined,
          title: profile.workerTitle,
          body: profile.workerBody,
          color: const Color(0xFF314A7E),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => openWebsiteInApp(
            context,
            title: profile.workerTitle,
            url: 'https://jtksm.mohr.gov.my/en/services/labour-complaint/acts-guidelines',
            copy: appCopies[language]!,
          ),
          icon: const Icon(Icons.open_in_new_rounded),
          label: Text(profile.openOfficialLabel),
        ),
        const SizedBox(height: 16),
        const _BanglaSection(
          icon: Icons.emergency_rounded,
          title: 'Malaysia emergency · 999',
          body: 'For PDRM Police, ambulance, fire, or immediate danger, call 999. For Immigration contact access, use MyGCC at +60 3-8000 8000.',
          color: Color(0xFFB4232A),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => openAppDestination(
            context,
            title: 'Malaysia emergency 999',
            url: 'tel:999',
            copy: appCopies[language]!,
          ),
          icon: const Icon(Icons.local_police_rounded),
          label: const Text('PDRM / MERS 999'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => openAppDestination(
            context,
            title: 'Immigration MyGCC',
            url: 'tel:+60380008000',
            copy: appCopies[language]!,
          ),
          icon: const Icon(Icons.badge_outlined),
          label: const Text('Immigration MyGCC +60 3-8000 8000'),
        ),
      ],
    );
  }
}

class CountryGoldReferencePage extends StatelessWidget {
  const CountryGoldReferencePage({super.key, required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final profile = _countryHubProfileFor(language);
    final resource = _countryResourceProfileFor(language);
    return CountryHubScaffold(
      language: language,
      title: _localizedGoldTitle(language),
      children: [
        _BanglaSection(
          icon: Icons.workspace_premium_outlined,
          title: resource.goldReferenceName,
          body: 'Open the source inside this app to check the current published local-market reference. Store prices, purity, taxes, and service charges can differ. This is not buying or selling advice.',
          color: const Color(0xFF9B5B12),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => openWebsiteInApp(
            context,
            title: resource.goldReferenceName,
            url: resource.goldReferenceUrl,
            copy: appCopies[language]!,
          ),
          icon: const Icon(Icons.open_in_new_rounded),
          label: Text(profile.openOfficialLabel),
        ),
      ],
    );
  }
}

class BanglaPriorityHubPage extends StatelessWidget {
  const BanglaPriorityHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: _AppBar(
          title: 'বাংলা সহায়তা কেন্দ্র',
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppPalette.ink,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: Color(0xFFBEE4D7),
                    size: 28,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'প্রয়োজনীয় কাজ সহজে করুন',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'বাংলাদেশি কর্মীদের জন্য পরিষ্কার নির্দেশনা, দরকারি মালাই ভাষা ও সরকারি সহায়তার লিংক। এখানে কোনো বিজ্ঞাপন আপনার কাজের মাঝে দেখানো হবে না।',
                    style: TextStyle(
                      color: Color(0xFFD4E9E2),
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _BanglaHubCard(
              number: '01',
              icon: Icons.assignment_turned_in_outlined,
              title: 'সরকারি কাজের আগে যা লাগবে',
              subtitle: 'ভিসা, FOMEMA ও EPF খোলার আগে ছোট চেকলিস্ট দেখুন',
              color: const Color(0xFF0E5C57),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const BanglaServiceGuidePage(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _BanglaHubCard(
              number: '02',
              icon: Icons.record_voice_over_outlined,
              title: 'কাজের দরকারি মালাই ভাষা',
              subtitle: 'ক্লিনিক, দোকান, যাতায়াত, কাজ ও জরুরি কথাবার্তা',
              color: const Color(0xFF9B5B12),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const BanglaPhrasebookPage(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _BanglaHubCard(
              number: '03',
              icon: Icons.workspace_premium_outlined,
              title: 'সোনার রেফারেন্স রেট',
              subtitle: '২৪ ক্যারেট সোনার আনুমানিক রেট RM ও BDT-তে দেখুন',
              color: const Color(0xFF9B5B12),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const BanglaGoldReferencePage(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _BanglaHubCard(
              number: '04',
              icon: Icons.account_balance_outlined,
              title: 'বাংলাদেশি সহায়তা',
              subtitle:
                  'হাই কমিশন, কনস্যুলার ও পাসপোর্ট সেন্টারের অফিসিয়াল তথ্য',
              color: const Color(0xFF7C2349),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const BanglaSupportDirectoryPage(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _BanglaHubCard(
              number: '05',
              icon: Icons.support_agent_outlined,
              title: 'কাজের সমস্যা বা অভিযোগ',
              subtitle: 'সমস্যার কাগজপত্র গুছিয়ে সরকারি JTK সহায়তা নিন',
              color: const Color(0xFF314A7E),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const BanglaWorkerSupportPage(),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'মনে রাখবেন: এই পেজটি সহজ ভাষার সহায়তা। চূড়ান্ত তথ্যের জন্য সব সময় অফিসিয়াল ওয়েবসাইট বা সংশ্লিষ্ট কর্তৃপক্ষের সঙ্গে নিশ্চিত করুন।',
              style: TextStyle(
                color: AppPalette.muted,
                fontSize: 11.5,
                height: 1.45,
              ),
            ),
          ],
        ),
        bottomNavigationBar: _CompactCreditBar(
          copy: appCopies[AppLanguage.bangla]!,
          onOpenProfile: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  CreatorProfilePage(copy: appCopies[AppLanguage.bangla]!),
            ),
          ),
        ),
      ),
    );
  }
}

class _LocalizedPriorityEntry extends StatelessWidget {
  const _LocalizedPriorityEntry({
    required this.profile,
    required this.onPressed,
  });

  final CountryHubProfile profile;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4EEE5),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE3D4BF)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFB66B1C),
                child: Icon(Icons.star_outline_rounded, color: Colors.white),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.hubTitle,
                      style: const TextStyle(
                        color: AppPalette.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      profile.hubSubtitle,
                      style: const TextStyle(
                        color: AppPalette.muted,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: Color(0xFF8B5317)),
            ],
          ),
        ),
      ),
    );
  }
}

// Reference-informed monochrome utility row: supports semantic light and dark contrast.
class _BanglaHubCard extends StatelessWidget {
  const _BanglaHubCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final String number;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppPalette.outline),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 17, color: color),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: AppPalette.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppPalette.muted,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppPalette.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _BanglaHubScaffold extends StatelessWidget {
  const _BanglaHubScaffold({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _AppBar(
        title: title,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        children: children,
      ),
      bottomNavigationBar: _CompactCreditBar(
        copy: appCopies[AppLanguage.bangla]!,
        onOpenProfile: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                CreatorProfilePage(copy: appCopies[AppLanguage.bangla]!),
          ),
        ),
      ),
    );
  }
}

class _BanglaSection extends StatelessWidget {
  const _BanglaSection({
    required this.icon,
    required this.title,
    required this.body,
    this.color = AppPalette.evergreen,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        border: Border.all(color: AppPalette.outline),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppPalette.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppPalette.muted,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BanglaServiceGuidePage extends StatelessWidget {
  const BanglaServiceGuidePage({super.key});

  void _open(BuildContext context, String url) {
    openWebsiteInApp(
      context,
      title: 'অফিসিয়াল সেবা',
      url: url,
      copy: appCopies[AppLanguage.bangla]!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _BanglaHubScaffold(
      title: 'সরকারি কাজের আগে',
      children: [
        const Text(
          'সঠিক ওয়েবসাইটে যাওয়ার আগে কয়েক মিনিট প্রস্তুতি নিন। নিচের তথ্য সহজ গাইড—চূড়ান্ত নিয়ম অফিসিয়াল সাইটে দেখে নিন।',
          style: TextStyle(
            color: AppPalette.muted,
            fontSize: 12.5,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),
        const _BanglaSection(
          icon: Icons.badge_outlined,
          title: 'ভিসা বা পাস চেক',
          body: 'আপনার পাসপোর্ট নম্বর ও দেশ নির্বাচন করার তথ্য প্রস্তুত রাখুন। নিজের তথ্য শুধু অফিসিয়াল Immigration পোর্টালে দিন।',
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () => _open(
            context,
            'https://eservices.imi.gov.my/myimms/VPAStsInq?MAD_DOC_NO=&MAD_DOC_CTRY_CD=BGD&search=CARIAN&lang=en',
          ),
          icon: const Icon(Icons.open_in_new_rounded),
          label: const Text('অফিসিয়াল ভিসা চেক খুলুন'),
        ),
        const SizedBox(height: 18),
        const _BanglaSection(
          icon: Icons.health_and_safety_outlined,
          title: 'FOMEMA মেডিকেল স্ট্যাটাস',
          body: 'ক্লিনিক বা নিয়োগকর্তার দেওয়া রেফারেন্স তথ্য কাছে রাখুন। মেডিকেল ফলাফল বা করণীয় নিয়ে সন্দেহ হলে শুধু নিবন্ধিত ক্লিনিক বা FOMEMA-এর সঙ্গে নিশ্চিত করুন।',
          color: Color(0xFFB4232A),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () => _open(
            context,
            'https://eservices.imi.gov.my/myimms/FomemaStatus',
          ),
          icon: const Icon(Icons.open_in_new_rounded),
          label: const Text('অফিসিয়াল FOMEMA চেক খুলুন'),
        ),
        const SizedBox(height: 18),
        const _BanglaSection(
          icon: Icons.savings_outlined,
          title: 'EPF / KWSP তথ্য',
          body: 'বৈধ পাসপোর্ট ও কাজের পাস থাকলে আপনার EPF অবস্থা নিয়োগকর্তা ও EPF অফিসিয়াল উৎস থেকে নিশ্চিত করুন। অবদান, নিবন্ধন বা উত্তোলনের নিয়ম পরিবর্তিত হতে পারে।',
          color: Color(0xFF314A7E),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () => _open(context, 'https://www.kwsp.gov.my/ms/'),
          icon: const Icon(Icons.open_in_new_rounded),
          label: const Text('অফিসিয়াল EPF / KWSP খুলুন'),
        ),
      ],
    );
  }
}

class BanglaGoldReferencePage extends StatefulWidget {
  const BanglaGoldReferencePage({super.key});

  @override
  State<BanglaGoldReferencePage> createState() =>
      _BanglaGoldReferencePageState();
}

class _BanglaGoldReferencePageState extends State<BanglaGoldReferencePage> {
  static final _smsDeenUri = Uri.parse('https://smsdeenjewels.com.my/');
  String? _ratePerGram;
  String? _rateDate;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSmsDeenRate();
  }

  Future<void> _loadSmsDeenRate() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final client = HttpClient();
    try {
      final request = await client
          .getUrl(_smsDeenUri)
          .timeout(const Duration(seconds: 12));
      final response = await request.close().timeout(
        const Duration(seconds: 12),
      );
      final body = await utf8.decoder.bind(response).join();
      final plainText = body.replaceAll(RegExp(r'<[^>]*>'), ' ');
      final match = RegExp(
        r'916\s+Gold\s+Rate\s+as\s+on\s*([0-9A-Za-z ]+)\s*:\s*RM\s*([0-9]+(?:\.[0-9]+)?)\s*/\s*gm',
        caseSensitive: false,
      ).firstMatch(plainText);
      if (response.statusCode != 200 || match == null) {
        throw const HttpException('SMS Deen 916 rate is unavailable.');
      }
      if (mounted) {
        setState(() {
          _rateDate = match.group(1)?.trim();
          _ratePerGram = match.group(2);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'রেট এখন পাওয়া যাচ্ছে না। কিছুক্ষণ পরে রিফ্রেশ করুন।';
          _isLoading = false;
        });
      }
    } finally {
      client.close(force: true);
    }
  }

  void _openSmsDeen(BuildContext context) {
    openWebsiteInApp(
      context,
      title: 'SMS Deen 916 Gold Rate',
      url: _smsDeenUri.toString(),
      copy: appCopies[AppLanguage.bangla]!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _BanglaHubScaffold(
      title: 'সোনার রেফারেন্স রেট',
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7A4C11), Color(0xFFC58A24)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                color: Colors.white,
                size: 30,
              ),
              SizedBox(height: 12),
              Text(
                'SMS Deen ৯১৬ সোনার রেট',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'SMS Deen Jewellers-এর ওয়েবসাইটে প্রকাশিত ৯১৬ সোনার প্রতি গ্রাম রেফারেন্স।',
                style: TextStyle(
                  color: Color(0xFFFFECCE),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          _BanglaSection(
            icon: Icons.cloud_off_outlined,
            title: 'রেট লোড করা যায়নি',
            body: _error!,
            color: const Color(0xFFB4232A),
          )
        else ...[
          _GoldReferenceTile(
            label: 'SMS Deen 916 Gold Rate',
            value: 'RM ${_ratePerGram!} / গ্রাম',
            subtitle: '${_rateDate ?? 'আজকের'} প্রকাশিত রেট · ৯১৬ সোনা',
          ),
        ],
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _loadSmsDeenRate,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('SMS Deen রেট রিফ্রেশ করুন'),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () => _openSmsDeen(context),
          icon: const Icon(Icons.open_in_new_rounded),
          label: const Text('SMS Deen ওয়েবসাইটে রেট দেখুন'),
        ),
        const SizedBox(height: 18),
        const _BanglaSection(
          icon: Icons.info_outline_rounded,
          title: 'রেট ব্যবহারের আগে জানুন',
          body: 'এটি SMS Deen Jewellers-এর ওয়েবসাইটে প্রকাশিত ৯১৬ সোনার রেফারেন্স। ডিজাইন, মজুরি, কর, স্টক, কেনা-বেচার স্প্রেড ও দোকানের নিজস্ব চার্জে আপনার চূড়ান্ত দাম আলাদা হতে পারে। এটি কেনা বা বিক্রির পরামর্শ নয়।',
          color: Color(0xFF9B5B12),
        ),
        const SizedBox(height: 14),
        const Text(
          'Source: SMS Deen Jewellers official website · 916 Gold Rate header. রেট বা তারিখ না মিললে অফিসিয়াল ওয়েবসাইটে যাচাই করুন।',
          style: TextStyle(
            color: AppPalette.muted,
            fontSize: 10.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _GoldReferenceTile extends StatelessWidget {
  const _GoldReferenceTile({
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBD7B0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7A4C11),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: AppPalette.ink,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppPalette.muted,
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class BanglaPhrasebookPage extends StatefulWidget {
  const BanglaPhrasebookPage({super.key});

  @override
  State<BanglaPhrasebookPage> createState() => _BanglaPhrasebookPageState();
}

class _BanglaPhrasebookPageState extends State<BanglaPhrasebookPage> {
  late final Future<_MalayLearningLibrary> _library =
      _MalayLearningLibrary.load();
  final TextEditingController _searchController = TextEditingController();
  _LearningLibraryMode _mode = _LearningLibraryMode.sentences;
  String _selectedCategory = 'সব বিভাগ';
  String _query = '';
  int _visibleLimit = 40;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectMode(_LearningLibraryMode mode) {
    setState(() {
      _mode = mode;
      _selectedCategory = 'সব বিভাগ';
      _visibleLimit = 40;
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _visibleLimit = 40;
    });
  }

  void _updateQuery(String value) {
    setState(() {
      _query = value.trim().toLowerCase();
      _visibleLimit = 40;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_MalayLearningLibrary>(
      future: _library,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _BanglaHubScaffold(
            title: 'দরকারি মালাই ভাষা',
            children: const [
              _BanglaSection(
                icon: Icons.error_outline_rounded,
                title: 'লাইব্রেরি খোলা যায়নি',
                body: 'ইন্টারনেট ছাড়াই লাইব্রেরি কাজ করার কথা। দয়া করে অ্যাপটি আবার খুলুন।',
                color: AppPalette.hibiscus,
              ),
            ],
          );
        }
        if (!snapshot.hasData) {
          return _BanglaHubScaffold(
            title: 'দরকারি মালাই ভাষা',
            children: const [
              Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        }
        return _buildLibrary(snapshot.data!);
      },
    );
  }

  Widget _buildLibrary(_MalayLearningLibrary library) {
    final scheme = Theme.of(context).colorScheme;
    final isSentenceMode = _mode == _LearningLibraryMode.sentences;
    final categories = isSentenceMode
        ? <String>['সব বিভাগ', ...library.sentenceCategories]
        : const <String>['সব বিভাগ'];
    final allItems = isSentenceMode
        ? library.sentences.where((item) {
            final matchesCategory =
                _selectedCategory == 'সব বিভাগ' ||
                item.category == _selectedCategory;
            return matchesCategory && item.matches(_query);
          }).toList()
        : library.words.where((item) => item.matches(_query)).toList();
    final visibleItems = allItems.take(_visibleLimit).toList();

    return _BanglaHubScaffold(
      title: 'দরকারি মালাই ভাষা',
      children: [
        CivicHeroPanel(
          accent: AppPalette.saffron,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeroStatusPill(label: 'বাংলা · মালাই লার্নিং লাইব্রেরি'),
              const SizedBox(height: 14),
              const Text(
                'কথা বলুন,\nকাজ সহজ করুন',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '৫৯৫টি দরকারি বাক্য এবং ১,২০০টি নিয়মিত ব্যবহার করা মালাই শব্দ—সবকিছু অফলাইনে আপনার সঙ্গে।',
                style: TextStyle(
                  color: Color(0xFFD4E9E2),
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _LibraryModeButton(
                label: 'বাক্য',
                count: '${library.sentences.length}',
                icon: Icons.chat_bubble_outline_rounded,
                selected: isSentenceMode,
                onTap: () => _selectMode(_LearningLibraryMode.sentences),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _LibraryModeButton(
                label: 'শব্দ',
                count: '${library.words.length}',
                icon: Icons.menu_book_outlined,
                selected: !isSentenceMode,
                onTap: () => _selectMode(_LearningLibraryMode.words),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _searchController,
          onChanged: _updateQuery,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: isSentenceMode
                ? 'মালাই বাক্য বা বাংলা অর্থ খুঁজুন'
                : 'মালাই শব্দ বা উচ্চারণ খুঁজুন',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _updateQuery('');
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
            filled: true,
            fillColor: scheme.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: scheme.onSurface.withValues(alpha: 0.18),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: scheme.onSurface.withValues(alpha: 0.18),
              ),
            ),
          ),
        ),
        if (isSentenceMode) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in categories)
                ChoiceChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (_) => _selectCategory(category),
                  selectedColor: scheme.primary,
                  side: BorderSide(
                    color: _selectedCategory == category
                        ? scheme.primary
                        : scheme.onSurface.withValues(alpha: 0.20),
                  ),
                  labelStyle: TextStyle(
                    color: _selectedCategory == category
                        ? scheme.onPrimary
                        : scheme.onSurface,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 18),
        CivicSectionLabel(
          label: isSentenceMode ? 'দরকারি বাক্য' : 'নিয়মিত ব্যবহার করা শব্দ',
          trailing: _CountPill(label: '${allItems.length} ফলাফল'),
        ),
        const SizedBox(height: 12),
        if (visibleItems.isEmpty)
          const _BanglaSection(
            icon: Icons.search_off_rounded,
            title: 'কিছু পাওয়া যায়নি',
            body: 'অন্য শব্দ লিখে আবার খুঁজুন।',
            color: AppPalette.saffron,
          )
        else ...[
          for (final item in visibleItems) ...[
            isSentenceMode
                ? _SentenceLearningCard(sentence: item as _MalaySentence)
                : _WordLearningCard(word: item as _MalayWord),
            const SizedBox(height: 10),
          ],
          if (allItems.length > visibleItems.length)
            OutlinedButton.icon(
              onPressed: () => setState(() => _visibleLimit += 40),
              icon: const Icon(Icons.expand_more_rounded),
              label: Text(
                'আরও ${allItems.length - visibleItems.length}টি দেখুন',
              ),
            ),
        ],
      ],
    );
  }
}

enum _LearningLibraryMode { sentences, words }

class _MalayLearningLibrary {
  const _MalayLearningLibrary({required this.sentences, required this.words});

  final List<_MalaySentence> sentences;
  final List<_MalayWord> words;

  List<String> get sentenceCategories =>
      sentences.map((item) => item.category).toSet().toList()..sort();

  static Future<_MalayLearningLibrary> load() async {
    final raw = await rootBundle.loadString(
      'assets/data/malay_learning_library.json',
    );
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return _MalayLearningLibrary(
      sentences: (data['sentences'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(_MalaySentence.fromJson)
          .toList(growable: false),
      words: (data['words'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(_MalayWord.fromJson)
          .toList(growable: false),
    );
  }
}

class _MalaySentence {
  const _MalaySentence({
    required this.category,
    required this.malay,
    required this.pronunciation,
    required this.meaning,
  });

  final String category;
  final String malay;
  final String pronunciation;
  final String meaning;

  factory _MalaySentence.fromJson(Map<String, dynamic> json) => _MalaySentence(
    category: json['category'] as String,
    malay: json['malay'] as String,
    pronunciation: json['pronunciation'] as String,
    meaning: json['meaning'] as String,
  );

  bool matches(String query) =>
      query.isEmpty ||
      '$category $malay $pronunciation $meaning'.toLowerCase().contains(query);
}

class _MalayWord {
  const _MalayWord({
    required this.category,
    required this.malay,
    required this.pronunciation,
    required this.meaning,
    required this.wordType,
  });

  final String category;
  final String malay;
  final String pronunciation;
  final String meaning;
  final String wordType;

  factory _MalayWord.fromJson(Map<String, dynamic> json) => _MalayWord(
    category: json['category'] as String,
    malay: json['malay'] as String,
    pronunciation: json['pronunciation'] as String,
    meaning: json['meaning'] as String,
    wordType: json['wordType'] as String,
  );

  bool matches(String query) =>
      query.isEmpty ||
      '$malay $pronunciation $meaning $wordType'.toLowerCase().contains(query);
}

class _LibraryModeButton extends StatelessWidget {
  const _LibraryModeButton({
    required this.label,
    required this.count,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String count;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CivicPressable(
      radius: 19,
      color: selected ? scheme.primary : scheme.surface,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: selected ? scheme.onPrimary : scheme.primary),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? scheme.onPrimary : scheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              count,
              style: TextStyle(
                color: selected
                    ? scheme.onPrimary.withValues(alpha: 0.8)
                    : scheme.onSurface.withValues(alpha: 0.66),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SentenceLearningCard extends StatelessWidget {
  const _SentenceLearningCard({required this.sentence});

  final _MalaySentence sentence;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LearningCategoryLabel(label: sentence.category),
          const SizedBox(height: 8),
          Text(
            sentence.malay,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'উচ্চারণ: ${sentence.pronunciation}',
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.68),
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'অর্থ: ${sentence.meaning}',
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.68),
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _WordLearningCard extends StatelessWidget {
  const _WordLearningCard({required this.word});

  final _MalayWord word;

  Future<void> _openTranslation(BuildContext context) async {
    final uri = Uri.https('translate.google.com', '/', {
      'sl': 'ms',
      'tl': 'bn',
      'text': word.malay,
      'op': 'translate',
    });
    openWebsiteInApp(
      context,
      title: 'Google Translate',
      url: uri.toString(),
      copy: appCopies[AppLanguage.bangla]!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label:
          '${word.malay}; উচ্চারণ ${word.pronunciation}; Google Translate খুলুন',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openTranslation(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: scheme.onSurface.withValues(alpha: 0.14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.translate_rounded,
                    color: scheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              word.malay,
                              style: TextStyle(
                                color: scheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          _LearningCategoryLabel(label: word.wordType),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'উচ্চারণ: ${word.pronunciation}',
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.68),
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ট্যাপ করুন: Google Translate-এ বাংলা অর্থ ও ভয়েস শুনুন',
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 17,
                  color: scheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LearningCategoryLabel extends StatelessWidget {
  const _LearningCategoryLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: scheme.primary,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class BanglaSupportDirectoryPage extends StatelessWidget {
  const BanglaSupportDirectoryPage({super.key});

  Future<void> _launch(BuildContext context, Uri uri) async {
    if (uri.scheme == 'https' || uri.scheme == 'http') {
      openWebsiteInApp(
        context,
        title: 'বাংলাদেশি সহায়তা',
        url: uri.toString(),
        copy: appCopies[AppLanguage.bangla]!,
      );
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('লিংকটি খোলা যায়নি। পরে আবার চেষ্টা করুন।'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BanglaHubScaffold(
      title: 'বাংলাদেশি সহায়তা',
      children: [
        const _BanglaSection(
          icon: Icons.account_balance_outlined,
          title: 'বাংলাদেশ হাই কমিশন, কুয়ালালামপুর',
          body: 'অফিসিয়াল কনস্যুলার, পাসপোর্ট ও যোগাযোগ তথ্যের জন্য হাই কমিশনের নিজস্ব ওয়েবসাইট ব্যবহার করুন। যাওয়ার আগে অফিস সময় ও প্রয়োজনীয় কাগজপত্র নিশ্চিত করুন।',
          color: Color(0xFF7C2349),
        ),
        const SizedBox(height: 12),
        _ContactButton(
          icon: Icons.phone_outlined,
          title: 'কনস্যুলার সার্ভিস',
          subtitle: '+60 3-2604 0949 · অফিসিয়াল নম্বর',
          onPressed: () => _launch(context, Uri.parse('tel:+60326040949')),
        ),
        const SizedBox(height: 10),
        _ContactButton(
          icon: Icons.phone_in_talk_outlined,
          title: 'পাসপোর্ট সার্ভিস সেন্টার',
          subtitle: '+60 10-430 3020 · অফিসিয়াল নম্বর',
          onPressed: () => _launch(context, Uri.parse('tel:+60104303020')),
        ),
        const SizedBox(height: 10),
        _ContactButton(
          icon: Icons.public_rounded,
          title: 'হাই কমিশনের অফিসিয়াল ওয়েবসাইট',
          subtitle: 'ঠিকানা, কনস্যুলার ও পাসপোর্ট তথ্য দেখুন',
          onPressed: () =>
              _launch(context, Uri.parse('https://www.bdhckl.gov.bd/contact/')),
        ),
        const SizedBox(height: 18),
        const _BanglaSection(
          icon: Icons.emergency_rounded,
          title: 'মালয়েশিয়া জরুরি সহায়তা',
          body: 'পুলিশ, অ্যাম্বুলেন্স, ফায়ার বা তাৎক্ষণিক বিপদে শুধু ৯৯৯-এ কল করুন। এটি Malaysia Emergency Response Services (MERS) নম্বর এবং PDRM-সহ জরুরি সংস্থার জন্য ব্যবহৃত হয়।',
          color: Color(0xFFB4232A),
        ),
        const SizedBox(height: 12),
        _ContactButton(
          icon: Icons.local_police_rounded,
          title: 'PDRM পুলিশ ও জরুরি সেবা',
          subtitle: '৯৯৯ · জরুরি অবস্থায় সঙ্গে সঙ্গে কল করুন',
          onPressed: () => _launch(context, Uri.parse('tel:999')),
        ),
        const SizedBox(height: 10),
        _ContactButton(
          icon: Icons.info_outline_rounded,
          title: 'MERS 999 সাধারণ জিজ্ঞাসা',
          subtitle: '+60 3-2240 7593 · জরুরি নয় এমন তথ্যের জন্য',
          onPressed: () => _launch(context, Uri.parse('tel:+60322407593')),
        ),
        const SizedBox(height: 10),
        _ContactButton(
          icon: Icons.badge_outlined,
          title: 'মালয়েশিয়া Immigration / MyGCC',
          subtitle: '+60 3-8000 8000 · ইমিগ্রেশন অফিসিয়াল যোগাযোগ',
          onPressed: () => _launch(context, Uri.parse('tel:+60380008000')),
        ),
        const SizedBox(height: 10),
        _ContactButton(
          icon: Icons.language_rounded,
          title: 'Immigration অফিসিয়াল ওয়েবসাইট',
          subtitle: 'যোগাযোগ ও অফিসিয়াল তথ্য অ্যাপের ভেতর দেখুন',
          onPressed: () => _launch(
            context,
            Uri.parse('https://www.imi.gov.my/index.php/en/contact-us/'),
          ),
        ),
        const SizedBox(height: 18),
        const _BanglaSection(
          icon: Icons.account_balance_rounded,
          title: 'প্রবাসী কল্যাণ ব্যাংক',
          body: 'প্রবাসী কল্যাণ ব্যাংকের ঋণ, সঞ্চয় ও সেবা-সংক্রান্ত অফিসিয়াল তথ্যের জন্য শুধু ব্যাংকের নিজস্ব ওয়েবসাইট ও যাচাইকৃত যোগাযোগ মাধ্যম ব্যবহার করুন। যোগ্যতা বা ঋণ নেওয়ার সিদ্ধান্তের জন্য সরাসরি ব্যাংকের সঙ্গে কথা বলুন।',
          color: Color(0xFF1B5E52),
        ),
        const SizedBox(height: 12),
        _ContactButton(
          icon: Icons.support_agent_rounded,
          title: 'প্রবাসী কল্যাণ ব্যাংক হটলাইন',
          subtitle: '১৬২৩৮ · বাংলাদেশ থেকে অফিসিয়াল হটলাইন',
          onPressed: () => _launch(context, Uri.parse('tel:16238')),
        ),
        const SizedBox(height: 10),
        _ContactButton(
          icon: Icons.phone_in_talk_outlined,
          title: 'প্রধান কার্যালয় হেল্প ডেস্ক',
          subtitle: '+880 9677-787878 · অফিসিয়াল সাপোর্ট নম্বর',
          onPressed: () => _launch(context, Uri.parse('tel:+8809677787878')),
        ),
        const SizedBox(height: 10),
        _ContactButton(
          icon: Icons.language_rounded,
          title: 'প্রবাসী কল্যাণ ব্যাংকের ওয়েবসাইট',
          subtitle: 'সেবা, শাখা ও অফিসিয়াল বিজ্ঞপ্তি দেখুন',
          onPressed: () => _launch(context, Uri.parse('https://pkb.gov.bd/')),
        ),
        const SizedBox(height: 10),
        _ContactButton(
          icon: Icons.facebook_rounded,
          title: 'প্রবাসী কল্যাণ ব্যাংকের Facebook পেজ',
          subtitle: '@pkb.gov.bd · অফিসিয়াল আপডেট দেখুন',
          onPressed: () => _launch(
            context,
            Uri.parse('https://www.facebook.com/pkb.gov.bd/'),
          ),
        ),
        const SizedBox(height: 10),
        _ContactButton(
          icon: Icons.email_outlined,
          title: 'প্রবাসী কল্যাণ ব্যাংক ইমেইল',
          subtitle: 'info@pkb.gov.bd',
          onPressed: () =>
              _launch(context, Uri.parse('mailto:info@pkb.gov.bd')),
        ),
        const SizedBox(height: 18),
        const _BanglaSection(
          icon: Icons.info_outline_rounded,
          title: 'যাওয়ার আগে প্রস্তুতি',
          body: 'পাসপোর্ট, আবেদন বা রসিদের কপি, ফোন নম্বর এবং দরকারি প্রমাণপত্র সঙ্গে রাখুন। কোনো দালালকে পাসপোর্ট বা টাকা দেওয়ার আগে অফিসিয়াল সেবার সঙ্গে নিশ্চিত করুন।',
          color: Color(0xFF9B5B12),
        ),
      ],
    );
  }
}

class BanglaWorkerSupportPage extends StatelessWidget {
  const BanglaWorkerSupportPage({super.key});

  void _open(BuildContext context) {
    openWebsiteInApp(
      context,
      title: 'JTK অভিযোগ সহায়তা',
      url: 'https://www.malaysia.gov.my/en/digital-services/eaduan-jtksm',
      copy: appCopies[AppLanguage.bangla]!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _BanglaHubScaffold(
      title: 'কাজের সমস্যা বা অভিযোগ',
      children: [
        const Text(
          'বেতন, চুক্তি বা কাজ-সম্পর্কিত সমস্যা হলে শান্তভাবে কাগজপত্র গুছিয়ে রাখুন। এই পেজ আইনগত সিদ্ধান্ত দেয় না; এটি অফিসিয়াল JTK সহায়তার দিকে নিয়ে যায়।',
          style: TextStyle(
            color: AppPalette.muted,
            fontSize: 12.5,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),
        const _BanglaSection(
          icon: Icons.folder_copy_outlined,
          title: 'যা প্রস্তুত রাখবেন',
          body: 'আপনার নাম ও যোগাযোগ, নিয়োগকর্তা বা কোম্পানির তথ্য, সমস্যার সংক্ষিপ্ত বিবরণ, চাকরির অফার বা চুক্তি এবং সর্বশেষ বেতন স্লিপ বা সহায়ক কাগজের কপি।',
          color: Color(0xFF314A7E),
        ),
        const SizedBox(height: 12),
        const _BanglaSection(
          icon: Icons.account_balance_outlined,
          title: 'অফিসিয়াল JTK পথ',
          body: 'নিকটস্থ JTK অফিস, সরকারি অভিযোগ চ্যানেল বা Working for Workers পথ ব্যবহার করুন। জরুরি বিপদে স্থানীয় জরুরি পরিষেবার সঙ্গে যোগাযোগ করুন।',
          color: Color(0xFF7C2349),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () => _open(context),
          icon: const Icon(Icons.open_in_new_rounded),
          label: const Text('সরকারি JTK অভিযোগ পেজ খুলুন'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => launchUrl(
            Uri(scheme: 'mailto', path: 'jtksm@mohr.gov.my'),
            mode: LaunchMode.externalApplication,
          ),
          icon: const Icon(Icons.email_outlined),
          label: const Text('JTK ইমেইল খুলুন'),
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppPalette.outline),
        boxShadow: [
          BoxShadow(
            color: AppPalette.ink.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppPalette.evergreen.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppPalette.evergreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppPalette.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppPalette.muted,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CivicPressable(
      radius: 18,
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppPalette.evergreen.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: AppPalette.evergreen, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppPalette.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppPalette.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_outward_rounded,
              size: 18,
              color: AppPalette.evergreen,
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarFeatureCard extends StatelessWidget {
  const _CalendarFeatureCard({required this.copy, required this.onPressed});

  final AppCopy copy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CivicPressable(
      radius: 24,
      color: AppPalette.civicBlue,
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: Colors.white,
                size: 27,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Malaysia Public Holidays · 2026',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Calendar and holiday details',
                    style: TextStyle(color: Color(0xFFD6EAF6), fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_outward_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class HolidayEntry {
  const HolidayEntry(this.month, this.day, this.name, this.detail);

  final int month;
  final int day;
  final String name;
  final String detail;
}

class CalendarMonthTheme {
  const CalendarMonthTheme({
    required this.state,
    required this.motif,
    required this.icon,
    required this.primary,
    required this.wash,
    required this.backgroundAsset,
  });

  final String state;
  final String motif;
  final IconData icon;
  final Color primary;
  final Color wash;
  final String backgroundAsset;
}

const calendarMonthThemes = <CalendarMonthTheme>[
  CalendarMonthTheme(
    state: 'Riverfront heritage',
    motif: 'Malaysia cultural photo theme',
    icon: Icons.waves_rounded,
    primary: Color(0xFF365D7A),
    wash: Color(0xFFE8F0F5),
    backgroundAsset: 'assets/images/calendar/january_riverfront.jpeg',
  ),
  CalendarMonthTheme(
    state: 'Floral traditions',
    motif: 'Malaysia cultural photo theme',
    icon: Icons.light_rounded,
    primary: Color(0xFFA84D34),
    wash: Color(0xFFFFEEE8),
    backgroundAsset: 'assets/images/calendar/february_floral_culture.jpeg',
  ),
  CalendarMonthTheme(
    state: 'Malay festive attire',
    motif: 'Malaysia cultural photo theme',
    icon: Icons.auto_awesome_rounded,
    primary: Color(0xFF704A8B),
    wash: Color(0xFFF3EAF8),
    backgroundAsset: 'assets/images/calendar/march_malay_attire.jpeg',
  ),
  CalendarMonthTheme(
    state: 'Batik craft',
    motif: 'Malaysia cultural photo theme',
    icon: Icons.sailing_rounded,
    primary: Color(0xFF226B6D),
    wash: Color(0xFFE5F3F2),
    backgroundAsset: 'assets/images/calendar/april_batik.jpeg',
  ),
  CalendarMonthTheme(
    state: 'Heritage architecture',
    motif: 'Malaysia cultural photo theme',
    icon: Icons.agriculture_rounded,
    primary: Color(0xFF966825),
    wash: Color(0xFFFAF0D9),
    backgroundAsset: 'assets/images/calendar/may_heritage_architecture.jpeg',
  ),
  CalendarMonthTheme(
    state: 'Rainforest life',
    motif: 'Malaysia cultural photo theme',
    icon: Icons.forest_rounded,
    primary: Color(0xFF2F6B48),
    wash: Color(0xFFE5F2E9),
    backgroundAsset: 'assets/images/calendar/june_rainforest.jpeg',
  ),
  CalendarMonthTheme(
    state: 'Paddy landscape',
    motif: 'Malaysia cultural photo theme',
    icon: Icons.grass_rounded,
    primary: Color(0xFF547A2C),
    wash: Color(0xFFEEF5DE),
    backgroundAsset: 'assets/images/calendar/july_rice_terraces.jpeg',
  ),
  CalendarMonthTheme(
    state: 'Malaysia Day colours',
    motif: 'Malaysia cultural photo theme',
    icon: Icons.account_balance_rounded,
    primary: Color(0xFF9E4139),
    wash: Color(0xFFF9E8E5),
    backgroundAsset: 'assets/images/calendar/august_malaysia_flags.jpeg',
  ),
  CalendarMonthTheme(
    state: 'National landmarks',
    motif: 'Malaysia cultural photo theme',
    icon: Icons.water_rounded,
    primary: Color(0xFF176A8C),
    wash: Color(0xFFE3F2F8),
    backgroundAsset: 'assets/images/calendar/september_putrajaya.jpeg',
  ),
  CalendarMonthTheme(
    state: 'River journey',
    motif: 'Malaysia cultural photo theme',
    icon: Icons.park_rounded,
    primary: Color(0xFF3D754A),
    wash: Color(0xFFE6F1E7),
    backgroundAsset: 'assets/images/calendar/october_river.jpeg',
  ),
  CalendarMonthTheme(
    state: 'Market traditions',
    motif: 'Malaysia cultural photo theme',
    icon: Icons.roofing_rounded,
    primary: Color(0xFF8A4E2D),
    wash: Color(0xFFF7E9DF),
    backgroundAsset: 'assets/images/calendar/november_market_culture.jpeg',
  ),
  CalendarMonthTheme(
    state: 'Festival attire',
    motif: 'Malaysia cultural photo theme',
    icon: Icons.location_city_rounded,
    primary: Color(0xFF465F9B),
    wash: Color(0xFFE8ECF8),
    backgroundAsset: 'assets/images/calendar/december_traditional_attire.jpeg',
  ),
];

const holidays2026 = <HolidayEntry>[
  HolidayEntry(
    2,
    17,
    'Chinese New Year',
    'Federal/nationwide reference; some state observances may differ.',
  ),
  HolidayEntry(
    2,
    18,
    'Second Day of Chinese New Year',
    'Federal/nationwide reference; some state observances may differ.',
  ),
  HolidayEntry(
    3,
    21,
    'Hari Raya Aidilfitri',
    'Date may be subject to official religious announcement.',
  ),
  HolidayEntry(5, 1, 'Labour Day', 'National public holiday.'),
  HolidayEntry(
    5,
    27,
    'Hari Raya Haji',
    'Date may be subject to official religious announcement.',
  ),
  HolidayEntry(
    5,
    31,
    'Wesak Day',
    'Nationwide public holiday; replacement days can differ by state.',
  ),
  HolidayEntry(
    6,
    1,
    'The Yang di-Pertuan Agong’s Birthday',
    'Federal public holiday.',
  ),
  HolidayEntry(
    6,
    17,
    'Awal Muharram',
    'Federal/nationwide reference; date may be subject to official announcement.',
  ),
  HolidayEntry(
    8,
    25,
    'The Prophet Muhammad’s Birthday',
    'Public holiday listed on the official Malaysia government calendar.',
  ),
  HolidayEntry(8, 31, 'Malaysia’s National Day', 'Federal public holiday.'),
  HolidayEntry(9, 16, 'Malaysia Day', 'Federal public holiday.'),
  HolidayEntry(
    11,
    8,
    'Diwali',
    'Public holiday; state observances may differ.',
  ),
  HolidayEntry(12, 25, 'Christmas Day', 'Public holiday.'),
];

class HolidayCalendarPage extends StatelessWidget {
  const HolidayCalendarPage({super.key, required this.language});

  final AppLanguage language;

  AppCopy get _copy => appCopies[language]!;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _copy.direction,
      child: Scaffold(
        appBar: _AppBar(
          title: 'Malaysia Holidays 2026',
          leading: IconButton(
            tooltip: _copy.backToServices,
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        bottomNavigationBar: _CompactCreditBar(
          copy: _copy,
          onOpenProfile: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CreatorProfilePage(copy: _copy),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB21F2D), Color(0xFF6F1723)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Row(
                children: [
                  Text('🇲🇾', style: TextStyle(fontSize: 34)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Malaysia public holidays · 2026',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Twelve cultural photo calendar themes',
                          style: TextStyle(
                            color: Color(0xFFFFDFD7),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Red dates are federal or nationwide holiday references. State holidays and replacement days can differ, so confirm leave arrangements with your employer or an official authority.',
              style: TextStyle(
                color: Color(0xFF657773),
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            for (var month = 1; month <= 12; month++) ...[
              _MonthCalendar(
                month: month,
                theme: calendarMonthThemes[month - 1],
              ),
              const SizedBox(height: 14),
            ],
            const SizedBox(height: 6),
            const Text(
              'Holiday details',
              style: TextStyle(
                color: Color(0xFF163A38),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            for (final holiday in holidays2026)
              _HolidayDetailTile(holiday: holiday),
          ],
        ),
      ),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({required this.month, required this.theme});

  final int month;
  final CalendarMonthTheme theme;

  @override
  Widget build(BuildContext context) {
    const monthNames = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const weekdayNames = <String>['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final firstWeekday = DateTime(2026, month, 1).weekday % 7;
    final daysInMonth = DateTime(2026, month + 1, 0).day;
    final holidayDays = <int>{
      for (final item in holidays2026.where((item) => item.month == month))
        item.day,
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.wash,
        image: DecorationImage(
          image: AssetImage(theme.backgroundAsset),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.48),
            BlendMode.darken,
          ),
        ),
        border: Border.all(color: theme.primary.withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: Icon(theme.icon, color: Colors.white, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      monthNames[month - 1],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${theme.state} · ${theme.motif}',
                      style: const TextStyle(
                        color: Color(0xFFE6F4F1),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.circle, color: Color(0xFFFF5263), size: 10),
              const SizedBox(width: 4),
              const Text(
                'Holiday',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, index) {
              if (index < 7) {
                return Center(
                  child: Text(
                    weekdayNames[index],
                    style: const TextStyle(
                      color: Color(0xFFE9F5F2),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
              }
              final day = index - 7 - firstWeekday + 1;
              if (day < 1 || day > daysInMonth) return const SizedBox.shrink();
              final isHoliday = holidayDays.contains(day);
              return Center(
                child: Container(
                  width: 25,
                  height: 25,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isHoliday
                        ? const Color(0xFFBF2632)
                        : Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: isHoliday ? Colors.white : const Color(0xFF41534F),
                      fontSize: 10,
                      fontWeight: isHoliday ? FontWeight.w900 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HolidayDetailTile extends StatelessWidget {
  const _HolidayDetailTile({required this.holiday});

  final HolidayEntry holiday;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F3),
        border: Border.all(color: const Color(0xFFF1D3CE)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 7),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFBD2833),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${holiday.day}/${holiday.month}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holiday.name,
                  style: const TextStyle(
                    color: Color(0xFF74252D),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  holiday.detail,
                  style: const TextStyle(
                    color: Color(0xFF61736F),
                    fontSize: 10.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatusWebViewPage extends StatefulWidget {
  const StatusWebViewPage({
    super.key,
    required this.title,
    required this.url,
    required this.copy,
  });

  final String title;
  final String url;
  final AppCopy copy;

  @override
  State<StatusWebViewPage> createState() => _StatusWebViewPageState();
}

const _fimMobileChromeUserAgent =
    'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/125.0.0.0 Mobile Safari/537.36';
const _responsiveWebViewScript = """
(function () {
  var viewport = document.querySelector('meta[name="viewport"]');
  if (!viewport) {
    viewport = document.createElement('meta');
    viewport.name = 'viewport';
    document.head.appendChild(viewport);
  }
  viewport.content = 'width=device-width, initial-scale=1, maximum-scale=5';
  document.documentElement.style.webkitTextSizeAdjust = '100%';
})();
""";

class _StatusWebViewPageState extends State<StatusWebViewPage>
    with SingleTickerProviderStateMixin {
  late final WebViewController _controller;
  late final AnimationController _loadingMotion;
  int _loadingProgress = 0;
  bool _showLoading = true;
  bool _loadFailed = false;
  Timer? _loadTimeout;
  Timer? _progressTimeout;

  @override
  void initState() {
    super.initState();
    _loadingMotion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(_fimMobileChromeUserAgent)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            _armLoadTimeout();
            _armProgressTimeout();
            setState(() {
              _loadingProgress = 0;
              _loadFailed = false;
              _showLoading = true;
            });
          },
          onProgress: (progress) {
            if (!mounted) return;
            setState(() {
              _loadingProgress = progress;
              _showLoading = !_loadFailed && progress < 100;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            _controller.runJavaScript(_responsiveWebViewScript);
            _completeLoading();
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame != false) _failLoading();
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null || uri.scheme == 'http' || uri.scheme == 'https') {
              return NavigationDecision.navigate;
            }
            launchUrl(uri, mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;
          },
        ),
      );
    _armLoadTimeout();
    _armProgressTimeout();
    _controller.loadRequest(Uri.parse(widget.url));
  }

  void _armLoadTimeout() {
    _loadTimeout?.cancel();
    _loadTimeout = Timer(
      widget.url.contains('cims.cidb.gov.my')
          ? const Duration(seconds: 30)
          : const Duration(seconds: 12),
      () {
        if (mounted && _showLoading) _failLoading();
      },
    );
  }

  void _armProgressTimeout() {
    _progressTimeout?.cancel();
    _progressTimeout = Timer(const Duration(seconds: 6), () {
      if (!mounted) return;
      setState(() => _showLoading = false);
    });
  }

  void _completeLoading() {
    _loadTimeout?.cancel();
    _progressTimeout?.cancel();
    if (!mounted) return;
    setState(() {
      _loadingProgress = 100;
      _loadFailed = false;
      _showLoading = false;
    });
  }

  void _failLoading() {
    _loadTimeout?.cancel();
    _progressTimeout?.cancel();
    if (!mounted) return;
    setState(() {
      _loadFailed = true;
      _showLoading = false;
    });
  }

  void _retryLoading() {
    if (!mounted) return;
    setState(() {
      _loadFailed = false;
      _loadingProgress = 0;
      _showLoading = true;
    });
    _armLoadTimeout();
    _armProgressTimeout();
    _controller.reload();
  }

  Future<void> _openOutsideApp() async {
    await launchUrl(
      Uri.parse(widget.url),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _printOrSaveResult() async {
    try {
      final raw = await _controller.runJavaScriptReturningResult(
        'document.body ? document.body.innerText : ""',
      );
      final visibleText = raw.toString().replaceAll(r'\n', '\n').trim();
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Header(level: 0, text: widget.title),
            pw.Paragraph(
              text: visibleText.isEmpty
                  ? 'No readable result text was found.'
                  : visibleText,
            ),
            pw.SizedBox(height: 16),
            pw.Paragraph(text: 'Source: ${widget.url}'),
            pw.Paragraph(text: 'Generated by FIM - Foreigner in Malaysia.'),
          ],
        ),
      );
      final bytes = await pdf.save();
      final directory = await getApplicationDocumentsDirectory();
      final safeName = widget.title.toLowerCase().replaceAll(
        RegExp(r'[^a-z0-9]+'),
        '_',
      );
      final file = File('${directory.path}/${safeName}_result.pdf');
      await file.writeAsBytes(bytes, flush: true);
      await Printing.sharePdf(bytes: bytes, filename: '${safeName}_result.pdf');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved and ready to print: ${file.path}')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The result could not be prepared for printing.'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _loadTimeout?.cancel();
    _progressTimeout?.cancel();
    _loadingMotion.dispose();
    super.dispose();
  }

  Future<void> _handleBackNavigation() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: widget.copy.direction,
      child: PopScope<void>(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _handleBackNavigation();
        },
        child: Scaffold(
          appBar: _AppBar(
            title: widget.title,
            leading: IconButton(
              tooltip: widget.copy.backToServices,
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          bottomNavigationBar: _CompactCreditBar(
            copy: widget.copy,
            onOpenProfile: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CreatorProfilePage(copy: widget.copy),
              ),
            ),
          ),
          body: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _showLoading
                    ? LinearProgressIndicator(
                        key: const ValueKey('loading'),
                        minHeight: 3,
                        value: _loadingProgress > 0
                            ? _loadingProgress / 100
                            : null,
                        backgroundColor: const Color(0xFFE5E7EB),
                      )
                    : const SizedBox(key: ValueKey('loaded'), height: 3),
              ),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    WebViewWidget(controller: _controller),
                    if (_loadFailed)
                      Positioned.fill(
                        child: _WebViewFailurePanel(
                          isBangla: widget.copy.languageName == 'বাংলা',
                          onRetry: _retryLoading,
                          onOpenOutsideApp: _openOutsideApp,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.small(
                heroTag: 'print-result',
                tooltip: 'Print or save result',
                onPressed: _printOrSaveResult,
                child: const Icon(Icons.print_outlined),
              ),
              const SizedBox(height: 10),
              FloatingActionButton.small(
                heroTag: 'reload-page',
                tooltip: widget.copy.reload,
                onPressed: () => _controller.reload(),
                child: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebViewFailurePanel extends StatelessWidget {
  const _WebViewFailurePanel({
    required this.isBangla,
    required this.onRetry,
    required this.onOpenOutsideApp,
  });

  final bool isBangla;
  final VoidCallback onRetry;
  final VoidCallback onOpenOutsideApp;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final title = isBangla
        ? 'পেজটি এখনো খোলা যায়নি'
        : 'This page is taking too long';
    final body = isBangla
        ? 'অফিসিয়াল সেবাটি এই মুহূর্তে ধীর বা সাময়িকভাবে অনুপলব্ধ। আবার চেষ্টা করুন অথবা প্রয়োজনে ফোনের ব্রাউজারে খুলুন।'
        : 'The official service may be slow or temporarily unavailable. Try again, or open it in your device browser if needed.';
    return ColoredBox(
      color: scheme.surface,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.wifi_tethering_error_rounded,
                      color: scheme.primary,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.68),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(isBangla ? 'আবার চেষ্টা' : 'Try again'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onOpenOutsideApp,
                          icon: const Icon(Icons.open_in_new_rounded),
                          label: Text(
                            isBangla ? 'ব্রাউজারে খুলুন' : 'Open outside',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
