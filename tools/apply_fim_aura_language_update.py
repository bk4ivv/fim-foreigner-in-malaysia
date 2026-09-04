from pathlib import Path

PROJECT = Path('/home/ubuntu/expat_status_checker')
MAIN = PROJECT / 'lib/main.dart'
text = MAIN.read_text()

# Add the requested major language families to the existing country-first model.
text = text.replace(
    "  sinhala,\n}",
    "  sinhala,\n  korean,\n  japanese,\n  german,\n  french,\n  spanish,\n  arabic,\n  russian,\n}",
    1,
)
text = text.replace(
    "  'sinhala': AppLanguage.sinhala,\n};",
    "  'sinhala': AppLanguage.sinhala,\n  'korean': AppLanguage.korean,\n  '한국어': AppLanguage.korean,\n  'japanese': AppLanguage.japanese,\n  '日本語': AppLanguage.japanese,\n  'german': AppLanguage.german,\n  'deutsch': AppLanguage.german,\n  'french': AppLanguage.french,\n  'français': AppLanguage.french,\n  'spanish': AppLanguage.spanish,\n  'español': AppLanguage.spanish,\n  'arabic': AppLanguage.arabic,\n  'العربية': AppLanguage.arabic,\n  'russian': AppLanguage.russian,\n  'русский': AppLanguage.russian,\n};",
    1,
)

# Localized app-shell copy. These entries make the major language choices real app
# modes instead of silently routing to English.
app_copy_marker = "\n};\n\nclass FirstUseCopy"
app_copy_insert = """
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
    creatorCredit: '말레이시아에서 근무하는 외국인 근로자 Khandaker Md Borhan Kabir (@bk4ivv)가 제작했습니다.',
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
    creatorCredit: 'マレーシアで働く外国人労働者 Khandaker Md Borhan Kabir (@bk4ivv) が制作しました。',
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
    languagePageSubtitle: 'Beginnen Sie mit der Sprache, die für Sie am bequemsten ist.',
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
    languagePageSubtitle: 'Commencez avec la langue qui vous convient le mieux.',
    chooseLanguage: 'Langues pour les travailleurs',
    servicePageTitle: 'Vérifications officielles, simplifiées',
    servicePageSubtitle: 'Choisissez le service dont vous avez besoin. La page officielle de Malaisie s’ouvre dans l’application.',
    visaTitle: 'Statut du visa',
    visaDescription: 'Vérifiez la demande de visa et le statut de l’immigration.',
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
    adSubtitle: 'Место для будущего партнёра или полезной информации для работников.',
    creditTitle: 'Создано с заботой о работниках',
    creatorCredit: 'Создано Khandaker Md Borhan Kabir (@bk4ivv), иностранным работником и оператором металлообрабатывающего ЧПУ в Малайзии.',
    contact: 'Связаться по электронной почте',
    backToLanguages: 'Изменить язык',
    backToServices: 'Вернуться к услугам',
    reload: 'Перезагрузить страницу',
    contactTitle: 'Контакт по электронной почте',
  ),
"""
if app_copy_marker not in text:
    raise SystemExit('AppCopy insertion marker not found')
text = text.replace(app_copy_marker, app_copy_insert + app_copy_marker, 1)

first_use_marker = "\n};\n\nclass LanguageVisual"
first_use_insert = """
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
"""
if first_use_marker not in text:
    raise SystemExit('FirstUse insertion marker not found')
text = text.replace(first_use_marker, first_use_insert + first_use_marker, 1)

visual_marker = "\n};\n\nfinal ValueNotifier<ThemeMode>"
visual_insert = """
  AppLanguage.korean: LanguageVisual(
    accent: Color(0xFF3A6EA5),
    wash: Color(0xFFE7F0F9),
    motif: Icons.waves_rounded,
  ),
  AppLanguage.japanese: LanguageVisual(
    accent: Color(0xFFB23A48),
    wash: Color(0xFFF9E7EA),
    motif: Icons.flower_outlined,
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
"""
if visual_marker not in text:
    raise SystemExit('LanguageVisual insertion marker not found')
text = text.replace(visual_marker, visual_insert + visual_marker, 1)

# Add labels for the persistent three-destination navigation.
text = text.replace(
    "      AppLanguage.sinhala: ['මුල් පිටුව', 'ඉගෙනීම', 'උදව් සහ තොරතුරු'],\n    };",
    "      AppLanguage.sinhala: ['මුල් පිටුව', 'ඉගෙනීම', 'උදව් සහ තොරතුරු'],\n      AppLanguage.korean: ['홈', '학습', '도움말 및 정보'],\n      AppLanguage.japanese: ['ホーム', '学習', 'ヘルプと情報'],\n      AppLanguage.german: ['Start', 'Lernen', 'Hilfe & Info'],\n      AppLanguage.french: ['Accueil', 'Apprendre', 'Aide et infos'],\n      AppLanguage.spanish: ['Inicio', 'Aprender', 'Ayuda e información'],\n      AppLanguage.arabic: ['الرئيسية', 'تعلّم', 'المساعدة والمعلومات'],\n      AppLanguage.russian: ['Главная', 'Учёба', 'Помощь и информация'],\n    };",
    1,
)

# Add the requested airline and flight-search choices.
flight_marker = """  _TripMode.plane: [
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
      name: 'Google Flights',
      url: 'https://www.google.com/travel/flights',
      note: 'Compare flight schedules and fares before booking.',
    ),
  ],"""
flight_replacement = """  _TripMode.plane: [
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
  ],"""
if flight_marker not in text:
    raise SystemExit('flight block not found')
text = text.replace(flight_marker, flight_replacement, 1)

# Add explicit labels and Google Translate target codes for the new languages.
text = text.replace(
    "  AppLanguage.sinhala => 'රන් මිල යොමුව',\n  AppLanguage.english => 'Gold price reference',",
    "  AppLanguage.sinhala => 'රන් මිල යොමුව',\n  AppLanguage.korean => '금 가격 참고',\n  AppLanguage.japanese => '金価格の参考',\n  AppLanguage.german => 'Goldpreis-Referenz',\n  AppLanguage.french => 'Référence du prix de l’or',\n  AppLanguage.spanish => 'Referencia del precio del oro',\n  AppLanguage.arabic => 'مرجع سعر الذهب',\n  AppLanguage.russian => 'Справка о цене золота',\n  AppLanguage.english => 'Gold price reference',",
    1,
)
text = text.replace(
    "      AppLanguage.sinhala => 'රජයේ නිල ද්වාරය',\n      AppLanguage.english => 'Home-country government portal',",
    "      AppLanguage.sinhala => 'රජයේ නිල ද්වාරය',\n      AppLanguage.korean => '본국 정부 포털',\n      AppLanguage.japanese => '母国政府ポータル',\n      AppLanguage.german => 'Regierungsportal des Heimatlandes',\n      AppLanguage.french => 'Portail gouvernemental du pays d’origine',\n      AppLanguage.spanish => 'Portal gubernamental del país de origen',\n      AppLanguage.arabic => 'بوابة حكومة بلدك',\n      AppLanguage.russian => 'Правительственный портал страны',\n      AppLanguage.english => 'Home-country government portal',",
    1,
)
text = text.replace(
    "      AppLanguage.sinhala => 'නිල Facebook',\n      AppLanguage.english => 'Official Facebook',",
    "      AppLanguage.sinhala => 'නිල Facebook',\n      AppLanguage.korean => '공식 Facebook',\n      AppLanguage.japanese => '公式 Facebook',\n      AppLanguage.german => 'Offizielles Facebook',\n      AppLanguage.french => 'Facebook officiel',\n      AppLanguage.spanish => 'Facebook oficial',\n      AppLanguage.arabic => 'فيسبوك الرسمي',\n      AppLanguage.russian => 'Официальный Facebook',\n      AppLanguage.english => 'Official Facebook',",
    1,
)
text = text.replace(
    "  AppLanguage.sinhala => 'මැලේ වචන හෝ වාක්‍ය සොයන්න',\n  AppLanguage.english => 'Search Malay words or phrases',",
    "  AppLanguage.sinhala => 'මැලේ වචන හෝ වාක්‍ය සොයන්න',\n  AppLanguage.korean => '말레이어 단어 또는 문장 검색',\n  AppLanguage.japanese => 'マレー語の単語や文を検索',\n  AppLanguage.german => 'Malaiische Wörter oder Sätze suchen',\n  AppLanguage.french => 'Rechercher des mots ou phrases malais',\n  AppLanguage.spanish => 'Buscar palabras o frases en malayo',\n  AppLanguage.arabic => 'ابحث عن كلمات أو عبارات ملايوية',\n  AppLanguage.russian => 'Поиск малайских слов или фраз',\n  AppLanguage.english => 'Search Malay words or phrases',",
    1,
)
text = text.replace(
    "  AppLanguage.sinhala => 'ගැළපෙන කිසිවක් හමු නොවීය.',\n  AppLanguage.english => 'No matching Malay phrase found.',",
    "  AppLanguage.sinhala => 'ගැළපෙන කිසිවක් හමු නොවීය.',\n  AppLanguage.korean => '일치하는 말레이어 표현이 없습니다.',\n  AppLanguage.japanese => '一致するマレー語の表現が見つかりません。',\n  AppLanguage.german => 'Keine passende malaiische Phrase gefunden.',\n  AppLanguage.french => 'Aucune phrase malaise correspondante trouvée.',\n  AppLanguage.spanish => 'No se encontró ninguna frase en malayo.',\n  AppLanguage.arabic => 'لم يتم العثور على عبارة ملايوية مطابقة.',\n  AppLanguage.russian => 'Подходящая малайская фраза не найдена.',\n  AppLanguage.english => 'No matching Malay phrase found.',",
    1,
)
text = text.replace(
    "    case AppLanguage.sinhala:\n      return 'si';\n  }",
    "    case AppLanguage.sinhala:\n      return 'si';\n    case AppLanguage.korean:\n      return 'ko';\n    case AppLanguage.japanese:\n      return 'ja';\n    case AppLanguage.german:\n      return 'de';\n    case AppLanguage.french:\n      return 'fr';\n    case AppLanguage.spanish:\n      return 'es';\n    case AppLanguage.arabic:\n      return 'ar';\n    case AppLanguage.russian:\n      return 'ru';\n  }",
    1,
)

# New languages must not crash country support or gold pages when their full
# country-specific editorial profile is not yet available.
generic_profile_marker = "const countryHubProfiles = <AppLanguage, CountryHubProfile>{"
generic_profile = """const _genericCountryHubProfile = CountryHubProfile(
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

"""
if generic_profile_marker not in text:
    raise SystemExit('country profile marker not found')
text = text.replace(generic_profile_marker, generic_profile + generic_profile_marker, 1)
profile_end_marker = "\nconst countryResourceProfiles = <AppLanguage, CountryResourceProfile>{"
profile_helper = "\nCountryHubProfile _countryHubProfileFor(AppLanguage language) =>\n    countryHubProfiles[language] ?? _genericCountryHubProfile;\n"
if profile_end_marker not in text:
    raise SystemExit('country profile end marker not found')
text = text.replace(profile_end_marker, profile_helper + profile_end_marker, 1)

resource_marker = "const countryResourceProfiles = <AppLanguage, CountryResourceProfile>{"
resource_default = """const _genericCountryResourceProfile = CountryResourceProfile(
  goldReferenceUrl: 'https://www.goldprice.org/',
  goldReferenceName: 'International gold-price reference',
  officialSocialUrl: null,
);

"""
text = text.replace(resource_marker, resource_default + resource_marker, 1)
resource_end_marker = "\nconst countryGovernmentPortals = <AppLanguage, String>{"
resource_helper = """\nCountryResourceProfile _countryResourceProfileFor(AppLanguage language) =>
    countryResourceProfiles[language] ?? _genericCountryResourceProfile;
"""
if resource_end_marker not in text:
    raise SystemExit('resource end marker not found')
text = text.replace(resource_end_marker, resource_helper + resource_end_marker, 1)
portal_end_marker = "\nString _localizedGoldTitle(AppLanguage language)"
portal_helper = """\nconst _foreignMissionsDirectoryUrl =
    'https://www.kln.gov.my/web/guest/foreign-missions-in-malaysia';
String _countryGovernmentPortalFor(AppLanguage language) =>
    countryGovernmentPortals[language] ?? _foreignMissionsDirectoryUrl;
"""
if portal_end_marker not in text:
    raise SystemExit('portal end marker not found')
text = text.replace(portal_end_marker, portal_helper + portal_end_marker, 1)

# Replace unsafe profile/resource lookups with the explicit fallbacks.
text = text.replace('countryHubProfiles[language]!', '_countryHubProfileFor(language)')
text = text.replace('countryHubProfiles[language];', '_countryHubProfileFor(language);')
text = text.replace('countryHubProfiles[language] ?? _englishLearningProfile', '_countryHubProfileFor(language)')
text = text.replace('countryResourceProfiles[language]!', '_countryResourceProfileFor(language)')
text = text.replace('countryGovernmentPortals[language]!', '_countryGovernmentPortalFor(language)')

# Give legacy CIDB CIMS pages a longer load window, a mobile Chrome identity,
# and a viewport hint so the ASP.NET/DevExpress form renders reliably in WebView.
text = text.replace(
    "          onPageFinished: (_) {\n            if (!mounted) return;\n            _completeLoading();\n          },",
    "          onPageFinished: (_) {\n            if (!mounted) return;\n            _controller.runJavaScript(_responsiveWebViewScript);\n            _completeLoading();\n          },",
    1,
)
text = text.replace(
    "      ..setJavaScriptMode(JavaScriptMode.unrestricted)\n      ..setBackgroundColor(Colors.white)",
    "      ..setJavaScriptMode(JavaScriptMode.unrestricted)\n      ..setUserAgent(_fimMobileChromeUserAgent)\n      ..setBackgroundColor(Colors.white)",
    1,
)
text = text.replace(
    "  void _armLoadTimeout() {\n    _loadTimeout?.cancel();\n    _loadTimeout = Timer(const Duration(seconds: 12), () {",
    "  void _armLoadTimeout() {\n    _loadTimeout?.cancel();\n    _loadTimeout = Timer(\n      widget.url.contains('cims.cidb.gov.my')\n          ? const Duration(seconds: 30)\n          : const Duration(seconds: 12),\n      () {",
    1,
)
text = text.replace(
    "      if (mounted && _showLoading) _failLoading();\n    });\n  }\n  void _armProgressTimeout() {\n    _progressTimeout?.cancel();\n    _progressTimeout = Timer(const Duration(seconds: 6), () {",
    "        if (mounted && _showLoading) _failLoading();\n      },\n    );\n  }\n  void _armProgressTimeout() {\n    _progressTimeout?.cancel();\n    _progressTimeout = Timer(\n      widget.url.contains('cims.cidb.gov.my')\n          ? const Duration(seconds: 18)\n          : const Duration(seconds: 6),\n      () {",
    1,
)
text = text.replace(
    "      if (!mounted) return;\n      setState(() => _showLoading = false);\n    });\n  }\n  void _completeLoading()",
    "        if (!mounted) return;\n        setState(() => _showLoading = false);\n      },\n    );\n  }\n  void _completeLoading()",
    1,
)
webview_marker = "class _StatusWebViewPageState extends State<StatusWebViewPage>"
webview_constants = '''const _fimMobileChromeUserAgent =
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

'''
if webview_marker not in text:
    raise SystemExit('webview marker not found')
text = text.replace(webview_marker, webview_constants + webview_marker, 1)

MAIN.write_text(text)

# Release WebViews need INTERNET permission. The debug manifest alone is not
# enough for the release variant; CIDB also references legacy HTTP subresources.
manifest = PROJECT / 'android/app/src/main/AndroidManifest.xml'
manifest_text = manifest.read_text()
manifest_text = manifest_text.replace(
    '<manifest xmlns:android="http://schemas.android.com/apk/res/android">',
    '<manifest xmlns:android="http://schemas.android.com/apk/res/android">\n    <uses-permission android:name="android.permission.INTERNET" />',
    1,
)
manifest_text = manifest_text.replace(
    '    <application\n',
    '    <application\n        android:usesCleartextTraffic="true"\n',
    1,
)
manifest.write_text(manifest_text)
print('Applied FIM aura, CIDB compatibility, flight providers, and major-language support update.')
