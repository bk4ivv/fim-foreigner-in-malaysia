
class CountryHubProfile {
  const CountryHubProfile({
    required this.hubTitle,
    required this.supportUrl,
    required this.countryLabel,
  });

  final String hubTitle;
  final String supportUrl;
  final String countryLabel;
}

class CountryResourceProfile {
  const CountryResourceProfile({
    required this.goldReferenceName,
    required this.goldReferenceUrl,
  });

  final String goldReferenceName;
  final String goldReferenceUrl;
}

class ServiceEntry {
  const ServiceEntry({
    required this.id,
    required this.title,
    required this.url,
    required this.subtitle,
  });

  final ServiceId id;
  final String title;
  final String url;
  final String subtitle;
}

final Map<AppLanguage, CountryHubProfile> countryHubProfiles = {
  AppLanguage.bangla: const CountryHubProfile(
    hubTitle: 'বাংলা সহায়তা কেন্দ্র',
    supportUrl: 'https://example.com/bangla-support',
    countryLabel: 'Bangladesh',
  ),
  AppLanguage.malay: const CountryHubProfile(
    hubTitle: 'Pusat bantuan Bahasa Melayu',
    supportUrl: 'https://example.com/malay-support',
    countryLabel: 'Malaysia',
  ),
  AppLanguage.indonesian: const CountryHubProfile(
    hubTitle: 'Pusat bantuan Bahasa Indonesia',
    supportUrl: 'https://example.com/indonesia-support',
    countryLabel: 'Indonesia',
  ),
  AppLanguage.tamil: const CountryHubProfile(
    hubTitle: 'தமிழ் உதவி மையம்',
    supportUrl: 'https://example.com/tamil-support',
    countryLabel: 'Tamil Nadu',
  ),
  AppLanguage.urdu: const CountryHubProfile(
    hubTitle: 'اردو مدد مرکز',
    supportUrl: 'https://example.com/urdu-support',
    countryLabel: 'Pakistan',
  ),
  AppLanguage.hindi: const CountryHubProfile(
    hubTitle: 'हिंदी सहायता केंद्र',
    supportUrl: 'https://example.com/hindi-support',
    countryLabel: 'India',
  ),
  AppLanguage.nepali: const CountryHubProfile(
    hubTitle: 'नेपाली सहायता केन्द्र',
    supportUrl: 'https://example.com/nepali-support',
    countryLabel: 'Nepal',
  ),
  AppLanguage.burmese: const CountryHubProfile(
    hubTitle: 'မြန်မာအကူအညီစင်တာ',
    supportUrl: 'https://example.com/burmese-support',
    countryLabel: 'Myanmar',
  ),
  AppLanguage.thai: const CountryHubProfile(
    hubTitle: 'ศูนย์ช่วยเหลือภาษาไทย',
    supportUrl: 'https://example.com/thai-support',
    countryLabel: 'Thailand',
  ),
  AppLanguage.khmer: const CountryHubProfile(
    hubTitle: 'មជ្ឈមណ្ឌលជំនួយភាសាខ្មែរ',
    supportUrl: 'https://example.com/khmer-support',
    countryLabel: 'Cambodia',
  ),
  AppLanguage.filipino: const CountryHubProfile(
    hubTitle: 'Sentro ng tulong sa Filipino',
    supportUrl: 'https://example.com/filipino-support',
    countryLabel: 'Philippines',
  ),
  AppLanguage.chinese: const CountryHubProfile(
    hubTitle: '中文帮助中心',
    supportUrl: 'https://example.com/chinese-support',
    countryLabel: 'China',
  ),
  AppLanguage.vietnamese: const CountryHubProfile(
    hubTitle: 'Trung tâm hỗ trợ tiếng Việt',
    supportUrl: 'https://example.com/vietnamese-support',
    countryLabel: 'Vietnam',
  ),
  AppLanguage.sinhala: const CountryHubProfile(
    hubTitle: 'සිංහල සහාය මධ්‍යස්ථානය',
    supportUrl: 'https://example.com/sinhala-support',
    countryLabel: 'Sri Lanka',
  ),
  AppLanguage.korean: const CountryHubProfile(
    hubTitle: '한국어 지원센터',
    supportUrl: 'https://example.com/korean-support',
    countryLabel: 'South Korea',
  ),
  AppLanguage.japanese: const CountryHubProfile(
    hubTitle: '日本語サポートセンター',
    supportUrl: 'https://example.com/japanese-support',
    countryLabel: 'Japan',
  ),
  AppLanguage.german: const CountryHubProfile(
    hubTitle: 'Deutsch-Hilfezentrum',
    supportUrl: 'https://example.com/german-support',
    countryLabel: 'Germany',
  ),
  AppLanguage.french: const CountryHubProfile(
    hubTitle: 'Centre d’aide français',
    supportUrl: 'https://example.com/french-support',
    countryLabel: 'France',
  ),
  AppLanguage.spanish: const CountryHubProfile(
    hubTitle: 'Centro de ayuda en español',
    supportUrl: 'https://example.com/spanish-support',
    countryLabel: 'Spain',
  ),
  AppLanguage.arabic: const CountryHubProfile(
    hubTitle: 'مركز دعم العربية',
    supportUrl: 'https://example.com/arabic-support',
    countryLabel: 'Arab World',
  ),
  AppLanguage.russian: const CountryHubProfile(
    hubTitle: 'Русский центр поддержки',
    supportUrl: 'https://example.com/russian-support',
    countryLabel: 'Russia',
  ),
};

final Map<AppLanguage, CountryResourceProfile> countryResourceProfiles = {
  AppLanguage.bangla: const CountryResourceProfile(
    goldReferenceName: 'Bangladesh Labour Portal',
    goldReferenceUrl: 'https://example.com/bd-labour',
  ),
  AppLanguage.malay: const CountryResourceProfile(
    goldReferenceName: 'Portal Rujukan Malaysia',
    goldReferenceUrl: 'https://example.com/my-portal',
  ),
  AppLanguage.indonesian: const CountryResourceProfile(
    goldReferenceName: 'Portal Referensi Indonesia',
    goldReferenceUrl: 'https://example.com/id-portal',
  ),
  AppLanguage.tamil: const CountryResourceProfile(
    goldReferenceName: 'இந்திய ஆதார தளம்',
    goldReferenceUrl: 'https://example.com/in-portal',
  ),
  AppLanguage.urdu: const CountryResourceProfile(
    goldReferenceName: 'پاکستان رینجر',
    goldReferenceUrl: 'https://example.com/pk-portal',
  ),
  AppLanguage.hindi: const CountryResourceProfile(
    goldReferenceName: 'भारत संदर्भ पोर्टल',
    goldReferenceUrl: 'https://example.com/in-portal',
  ),
  AppLanguage.nepali: const CountryResourceProfile(
    goldReferenceName: 'नेपाल संदर्भ पोर्टल',
    goldReferenceUrl: 'https://example.com/np-portal',
  ),
  AppLanguage.burmese: const CountryResourceProfile(
    goldReferenceName: 'မြန်မာအရင်းအမြစ် ဝန်ဆောင်မှု',
    goldReferenceUrl: 'https://example.com/mm-portal',
  ),
  AppLanguage.thai: const CountryResourceProfile(
    goldReferenceName: 'Thai Reference Portal',
    goldReferenceUrl: 'https://example.com/th-portal',
  ),
  AppLanguage.khmer: const CountryResourceProfile(
    goldReferenceName: 'Cambodia Reference Portal',
    goldReferenceUrl: 'https://example.com/kh-portal',
  ),
  AppLanguage.filipino: const CountryResourceProfile(
    goldReferenceName: 'Philippines Reference Portal',
    goldReferenceUrl: 'https://example.com/ph-portal',
  ),
  AppLanguage.chinese: const CountryResourceProfile(
    goldReferenceName: '中国参考门户',
    goldReferenceUrl: 'https://example.com/cn-portal',
  ),
  AppLanguage.vietnamese: const CountryResourceProfile(
    goldReferenceName: 'Cổng tham khảo Việt Nam',
    goldReferenceUrl: 'https://example.com/vn-portal',
  ),
  AppLanguage.sinhala: const CountryResourceProfile(
    goldReferenceName: 'ශ්‍රී ලංකා संदर्भ ද්වාරය',
    goldReferenceUrl: 'https://example.com/lk-portal',
  ),
  AppLanguage.korean: const CountryResourceProfile(
    goldReferenceName: '한국 참조 포털',
    goldReferenceUrl: 'https://example.com/kr-portal',
  ),
  AppLanguage.japanese: const CountryResourceProfile(
    goldReferenceName: '日本参照ポータル',
    goldReferenceUrl: 'https://example.com/jp-portal',
  ),
  AppLanguage.german: const CountryResourceProfile(
    goldReferenceName: 'Deutsch Referenzportal',
    goldReferenceUrl: 'https://example.com/de-portal',
  ),
  AppLanguage.french: const CountryResourceProfile(
    goldReferenceName: 'Portail de référence France',
    goldReferenceUrl: 'https://example.com/fr-portal',
  ),
  AppLanguage.spanish: const CountryResourceProfile(
    goldReferenceName: 'Portal de referencia España',
    goldReferenceUrl: 'https://example.com/es-portal',
  ),
  AppLanguage.arabic: const CountryResourceProfile(
    goldReferenceName: 'بوابة المراجع العربية',
    goldReferenceUrl: 'https://example.com/arab-portal',
  ),
  AppLanguage.russian: const CountryResourceProfile(
    goldReferenceName: 'Российский справочный портал',
    goldReferenceUrl: 'https://example.com/ru-portal',
  ),
};

final Map<AppLanguage, String> countryGovernmentPortals = {
  AppLanguage.bangla: 'https://example.com/bd-gov',
  AppLanguage.malay: 'https://example.com/my-gov',
  AppLanguage.indonesian: 'https://example.com/id-gov',
  AppLanguage.tamil: 'https://example.com/in-gov',
  AppLanguage.urdu: 'https://example.com/pk-gov',
  AppLanguage.hindi: 'https://example.com/in-gov',
  AppLanguage.nepali: 'https://example.com/np-gov',
  AppLanguage.burmese: 'https://example.com/mm-gov',
  AppLanguage.thai: 'https://example.com/th-gov',
  AppLanguage.khmer: 'https://example.com/kh-gov',
  AppLanguage.filipino: 'https://example.com/ph-gov',
  AppLanguage.chinese: 'https://example.com/cn-gov',
  AppLanguage.vietnamese: 'https://example.com/vn-gov',
  AppLanguage.sinhala: 'https://example.com/lk-gov',
  AppLanguage.korean: 'https://example.com/kr-gov',
  AppLanguage.japanese: 'https://example.com/jp-gov',
  AppLanguage.german: 'https://example.com/de-gov',
  AppLanguage.french: 'https://example.com/fr-gov',
  AppLanguage.spanish: 'https://example.com/es-gov',
  AppLanguage.arabic: 'https://example.com/arab-gov',
  AppLanguage.russian: 'https://example.com/ru-gov',
};

final List<ServiceEntry> services = <ServiceEntry>[
  const ServiceEntry(
    id: ServiceId.visa,
    title: 'Visa status',
    subtitle: 'Check immigration status',
    url: 'https://www.imi.gov.my/',
  ),
  const ServiceEntry(
    id: ServiceId.fomema,
    title: 'FOMEMA check',
    subtitle: 'Medical screening results',
    url: 'https://fomema.my/',
  ),
  const ServiceEntry(
    id: ServiceId.student,
    title: 'Student services',
    subtitle: 'Student visa and registration',
    url: 'https://educationmalaysia.gov.my/',
  ),
  const ServiceEntry(
    id: ServiceId.epf,
    title: 'EPF portal',
    subtitle: 'Retirement contributions',
    url: 'https://www.kwsp.gov.my/',
  ),
  const ServiceEntry(
    id: ServiceId.cidb,
    title: 'CIDB',
    subtitle: 'Construction worker database',
    url: 'https://cims.cidb.gov.my/pbsearch/Forms/Transactions/search.aspx',
  ),
  const ServiceEntry(
    id: ServiceId.fwcms,
    title: 'FWCMS',
    subtitle: 'Worker communication portal',
    url: 'https://example.com/fwcms',
  ),
];

Uri? normalizeExternalUrl(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return null;

  if (value.toLowerCase().startsWith('mailto:')) {
    return Uri.tryParse(value);
  }

  if (value.toLowerCase().startsWith('http://') ||
      value.toLowerCase().startsWith('https://')) {
    return Uri.tryParse(value);
  }

  if (value.toLowerCase().startsWith('wa.me/')) {
    return Uri.parse('https://$value');
  }

  if (value.toLowerCase().startsWith('www.')) {
    return Uri.parse('https://$value');
  }

  if (value.contains('@') && !value.contains(' ')) {
    return Uri(scheme: 'mailto', path: value);
  }

  if (value.contains('.') || RegExp(r'^\d+$').hasMatch(value)) {
    return Uri.parse('https://$value');
  }

  return Uri.tryParse(value);
}

class ForeignWorkerMalaysiaApp extends StatelessWidget {
  const ForeignWorkerMalaysiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FIM - Foreigner in Malaysia',
      home: const WorkerLaunchPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WorkerLaunchPage extends StatelessWidget {
  const WorkerLaunchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'OFFICIAL WORKER UTILITY · MALAYSIA',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 16),
              LinearProgressIndicator(),
              SizedBox(height: 18),
              Text(
                'FIM - Foreigner in Malaysia',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CountrySelectionPage extends StatelessWidget {
  const CountrySelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select country')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var i = 0; i < 4; i++)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    Text('আপনার দেশ নির্বাচন করুন'),
                    SizedBox(height: 8),
                    Text('اختر بلدك'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class WorkerUtilityShellPage extends StatelessWidget {
  const WorkerUtilityShellPage({super.key, required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final copy = appCopies[language] ?? appCopies[AppLanguage.english]!;
    return Scaffold(
      appBar: AppBar(
        title: Text('FIM - Foreigner in Malaysia'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Open FIM menu',
            onSelected: (_) {},
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'menu', child: Text('FIM menu')),
              PopupMenuItem(value: 'experience', child: Text('Experience map')),
              PopupMenuItem(value: 'tickets', child: Text('Tickets & events')),
              PopupMenuItem(value: 'tools', child: Text('Daily tools')),
              PopupMenuItem(value: 'games', child: Text('Games')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            copy.servicePageTitle,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
          ),
          const SizedBox(height: 12),
          const Text('Official Malaysian services'),
          const SizedBox(height: 10),
          const ListTile(title: Text('Visa status')),
          const ListTile(title: Text('Cinema tickets')),
          const ListTile(title: Text('Money manager')),
          const ListTile(title: Text('Community')),
        ],
      ),
    );
  }
}

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key, required this.language, required this.onTool});

  final AppLanguage language;
  final void Function(String tool) onTool;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tools')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Useful tools when you need them',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 12),
          ListTile(title: Text('Translate')),
          ListTile(title: Text('Public holiday calendar')),
        ],
      ),
    );
  }
}

class CountryPhrasebookPage extends StatelessWidget {
  const CountryPhrasebookPage({super.key, required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Useful phrases')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('Hello'),
          Text('Please'),
          Text('Thank you'),
          Text('Where is the clinic?'),
        ],
      ),
    );
  }
}

class TripsPage extends StatefulWidget {
  const TripsPage({super.key, required this.language});

  final AppLanguage language;

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  String _selected = 'Bus';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trips')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 10,
            children: ['Bus', 'Plane', 'Ferry', 'Train'].map((option) {
              final selected = _selected == option;
              return ChoiceChip(
                label: Text(option),
                selected: selected,
                onSelected: (_) => setState(() => _selected = option),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          if (_selected == 'Plane') ...const [
            Text('Cheapflights Malaysia'),
            SizedBox(height: 8),
            Text('Mynztrip'),
            SizedBox(height: 8),
            Text('Batik Air Malaysia'),
            SizedBox(height: 8),
            Text('Trip.com Malaysia'),
          ] else ...[
            const Text('Travel guidance for your trip'),
          ],
        ],
      ),
    );
  }
}

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key, required this.copy});

  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy policy')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Your privacy stays in your hands'),
      ),
    );
  }
}

String _safeTitleFromLanguage(AppLanguage language) {
  switch (language) {
    case AppLanguage.english:
      return 'English';
    case AppLanguage.bangla:
      return 'বাংলা';
    case AppLanguage.malay:
      return 'Bahasa Melayu';
    case AppLanguage.indonesian:
      return 'Bahasa Indonesia';
    case AppLanguage.tamil:
      return 'தமிழ்';
    case AppLanguage.urdu:
      return 'اردو';
    case AppLanguage.hindi:
      return 'हिन्दी';
    case AppLanguage.nepali:
      return 'नेपाली';
    case AppLanguage.burmese:
      return 'မြန်မာ';
    case AppLanguage.thai:
      return 'ไทย';
    case AppLanguage.khmer:
      return 'ខ្មែរ';
    case AppLanguage.filipino:
      return 'Filipino';
    case AppLanguage.chinese:
      return '中文';
    case AppLanguage.vietnamese:
      return 'Tiếng Việt';
    case AppLanguage.sinhala:
      return 'සිංහල';
    case AppLanguage.korean:
      return '한국어';
    case AppLanguage.japanese:
      return '日本語';
    case AppLanguage.german:
      return 'Deutsch';
    case AppLanguage.french:
      return 'Français';
    case AppLanguage.spanish:
      return 'Español';
    case AppLanguage.arabic:
      return 'العربية';
    case AppLanguage.russian:
      return 'Русский';
  }
}
