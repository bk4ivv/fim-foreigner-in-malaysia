import 'package:flutter_test/flutter_test.dart';

import 'dart:convert';
import 'dart:io';

import 'package:expat_status_checker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

AppLanguage? _appLanguageForLabelForTest(String label) {
  final normalized = label.toLowerCase();
  if (normalized == 'bengali') return AppLanguage.bangla;
  if (normalized == 'french' || normalized == 'français') {
    return AppLanguage.french;
  }
  if (normalized == 'korean' || normalized == '한국어') {
    return AppLanguage.korean;
  }
  if (normalized == 'japanese' || normalized == '日本語') {
    return AppLanguage.japanese;
  }
  if (normalized == 'german' || normalized == 'deutsch') {
    return AppLanguage.german;
  }
  if (normalized == 'spanish' || normalized == 'español') {
    return AppLanguage.spanish;
  }
  if (normalized == 'arabic' || normalized == 'العربية') {
    return AppLanguage.arabic;
  }
  if (normalized == 'russian' || normalized == 'русский') {
    return AppLanguage.russian;
  }
  return null;
}

void main() {
  testWidgets('shows the FIM - Foreigner in Malaysia app title', (
    tester,
  ) async {
    await tester.pumpWidget(const ForeignWorkerMalaysiaApp());

    expect(find.text('FIM - Foreigner in Malaysia'), findsOneWidget);
  });

  testWidgets('completes the launch progress experience', (tester) async {
    await tester.pumpWidget(const ForeignWorkerMalaysiaApp());

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('OFFICIAL WORKER UTILITY · MALAYSIA'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    expect(find.byType(WorkerLaunchPage), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets(
    'provides one unified Help and Info destination without Community',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WorkerUtilityShellPage(language: AppLanguage.english),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Learn'), findsOneWidget);
      expect(find.text('Info'), findsNothing);
      expect(find.text('Credit'), findsNothing);
      expect(find.text('Help & info'), findsOneWidget);
      expect(find.text('Community'), findsNothing);
      expect(find.text('Account'), findsNothing);
      expect(find.text('Visa Status'), findsOneWidget);
    },
  );

  test(
    'creates a country-aware hub profile for every non-English language',
    () {
      for (final language in AppLanguage.values) {
        if (language == AppLanguage.english) {
          expect(countryHubProfiles.containsKey(language), isFalse);
        } else {
          final profile = countryHubProfiles[language];
          expect(profile, isNotNull);
          expect(profile!.hubTitle, isNotEmpty);
          expect(profile.supportUrl, startsWith('http'));
        }
      }
    },
  );

  test('creates a country resource profile for every non-English language', () {
    for (final language in AppLanguage.values) {
      if (language == AppLanguage.english) {
        expect(countryResourceProfiles.containsKey(language), isFalse);
      } else {
        final resource = countryResourceProfiles[language];
        expect(resource, isNotNull);
        expect(resource!.goldReferenceUrl, startsWith('https://'));
        expect(resource.goldReferenceName, isNotEmpty);
        expect(countryGovernmentPortals[language], startsWith('https://'));
      }
    }
  });

  test('maps country flags and Malaysia source-country status safely', () {
    const bangladesh = CountryOption(
      name: 'Bangladesh',
      code: 'BD',
      region: 'Asia',
      languages: ['Bengali', 'English'],
      currencyCode: 'BDT',
    );
    const france = CountryOption(
      name: 'France',
      code: 'FR',
      region: 'Europe',
      languages: ['French', 'English'],
      currencyCode: 'EUR',
    );

    expect(bangladesh.flag, '🇧🇩');
    expect(bangladesh.isMalaysiaWorkerSourceCountry, isTrue);
    expect(france.flag, '🇫🇷');
    expect(france.isMalaysiaWorkerSourceCountry, isFalse);
    expect(_appLanguageForLabelForTest('Bengali'), AppLanguage.bangla);
    expect(_appLanguageForLabelForTest('French'), AppLanguage.french);
    expect(_appLanguageForLabelForTest('한국어'), AppLanguage.korean);
    expect(_appLanguageForLabelForTest('日本語'), AppLanguage.japanese);
  });

  test(
    'bundles every country-selection dataset required by the loader',
    () async {
      final iso = await File('assets/data/iso_countries.json').readAsString();
      final languages = await File('assets/data/country_by_languages.json')
          .readAsString();
      final currencies = jsonDecode(
        await File('assets/data/country_currencies.json').readAsString(),
      ) as Map<String, dynamic>;

      expect(iso, contains('Bangladesh'));
      expect(languages, contains('Bangladesh'));
      expect(currencies['BD'], 'BDT');
    },
  );

  testWidgets('renders a separate secondary Tools page', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ToolsPage(language: AppLanguage.english, onTool: (_) {}),
      ),
    );

    expect(find.text('Useful tools when you need them'), findsOneWidget);
    expect(find.text('Translate'), findsOneWidget);
    expect(find.text('Public holiday calendar'), findsOneWidget);
  });

  test(
    'packages at least 500 sentences and 1000 regular-use Malay words',
    () async {
      final raw = await rootBundle.loadString(
        'assets/data/malay_learning_library.json',
      );
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final sentences = data['sentences'] as List<dynamic>;
      final words = data['words'] as List<dynamic>;

      expect(sentences.length, greaterThanOrEqualTo(500));
      expect(words.length, greaterThanOrEqualTo(1000));
      expect(words.map((item) => item['malay']).toSet().length, words.length);
    },
  );

  testWidgets('Trips starts with bus, plane, ferry, and train choices', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: TripsPage(language: AppLanguage.english)),
    );

    expect(find.text('Bus'), findsOneWidget);
    expect(find.text('Plane'), findsOneWidget);
    expect(find.text('Ferry'), findsOneWidget);
    expect(find.text('Train'), findsOneWidget);
  });

  testWidgets('Plane trips expose Malaysia-relevant booking choices', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: TripsPage(language: AppLanguage.english)),
    );

    await tester.tap(find.text('Plane'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 650));

    expect(find.text('Cheapflights Malaysia'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Mynztrip'),
      280,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Mynztrip'), findsOneWidget);
    expect(find.text('Batik Air Malaysia'), findsOneWidget);
    expect(find.text('Trip.com Malaysia'), findsOneWidget);
  });

  test('CIDB keeps the official CIMS URL for in-app WebView routing', () {
    final cidb = services.firstWhere((service) => service.id == ServiceId.cidb);
    expect(cidb.url, startsWith('https://cims.cidb.gov.my/'));
    expect(cidb.url, contains('/pbsearch/Forms/Transactions/search.aspx'));
  });

  test('major language modes have app, support, and resource coverage', () {
    const majorLanguages = <AppLanguage>[
      AppLanguage.korean,
      AppLanguage.japanese,
      AppLanguage.german,
      AppLanguage.french,
      AppLanguage.spanish,
      AppLanguage.arabic,
      AppLanguage.russian,
    ];

    for (final language in majorLanguages) {
      expect(appCopies[language]?.languageName, isNotEmpty);
      expect(firstUseCopies[language]?.continueLabel, isNotEmpty);
      expect(countryHubProfiles[language], isNotNull);
      expect(countryResourceProfiles[language], isNotNull);
      expect(countryGovernmentPortals[language], startsWith('https://'));
    }
  });

  testWidgets('Privacy is a dedicated destination', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: PrivacyPage(copy: appCopies[AppLanguage.english]!)),
    );

    expect(find.text('Privacy policy'), findsOneWidget);
    expect(find.text('Your privacy stays in your hands'), findsOneWidget);
  });
}
