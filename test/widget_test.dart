import 'package:flutter_test/flutter_test.dart';

import 'dart:convert';
import 'dart:io';

import 'package:expat_status_checker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

AppLanguage? _appLanguageForLabelForTest(String label) {
  final normalized = label.toLowerCase();
  if (normalized == 'bengali') return AppLanguage.bangla;
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
    expect(_appLanguageForLabelForTest('French'), isNull);
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

  testWidgets('Privacy is a dedicated destination', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: PrivacyPage(copy: appCopies[AppLanguage.english]!)),
    );

    expect(find.text('Privacy policy'), findsOneWidget);
    expect(find.text('Your privacy stays in your hands'), findsOneWidget);
  });
}
