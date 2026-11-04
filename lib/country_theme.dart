import 'package:flutter/material.dart';

enum FimCalendarSystem { gregorian, bangla, hijri }

class CountryThemeProfile {
  const CountryThemeProfile({
    required this.code,
    required this.countryName,
    required this.localName,
    required this.accent,
    required this.secondary,
    required this.wash,
    required this.pattern,
    required this.motif,
    required this.defaultCalendar,
    required this.calendars,
    required this.welcome,
    required this.utilityLine,
  });

  final String code;
  final String countryName;
  final String localName;
  final Color accent;
  final Color secondary;
  final Color wash;
  final String pattern;
  final IconData motif;
  final FimCalendarSystem defaultCalendar;
  final List<FimCalendarSystem> calendars;
  final String welcome;
  final String utilityLine;
}

const countryThemeProfiles = <String, CountryThemeProfile>{
  'MY': CountryThemeProfile(
    code: 'MY', countryName: 'Malaysia', localName: 'Malaysia',
    accent: Color(0xFF010066), secondary: Color(0xFFCC0001),
    wash: Color(0xFFE8EFFB), pattern: 'songket',
    motif: Icons.auto_awesome_mosaic_rounded,
    defaultCalendar: FimCalendarSystem.gregorian,
    calendars: [FimCalendarSystem.gregorian, FimCalendarSystem.hijri],
    welcome: 'Malaysia-first utilities, with your country close to home.',
    utilityLine: 'Malaysia services stay at the centre of FIM.',
  ),
  'BD': CountryThemeProfile(
    code: 'BD', countryName: 'Bangladesh', localName: 'বাংলাদেশ',
    accent: Color(0xFF006A4E), secondary: Color(0xFFF42A41),
    wash: Color(0xFFE2F4EC), pattern: 'alpana',
    motif: Icons.diamond_outlined,
    defaultCalendar: FimCalendarSystem.bangla,
    calendars: [FimCalendarSystem.gregorian, FimCalendarSystem.bangla, FimCalendarSystem.hijri],
    welcome: 'আপনার দেশ, ভাষা ও Malaysia-র দরকারি তথ্য একসাথে।',
    utilityLine: 'বাংলা সহায়তা ও Malaysia-র official worker utilities.',
  ),
  'IN': CountryThemeProfile(
    code: 'IN', countryName: 'India', localName: 'भारत',
    accent: Color(0xFFFF9933), secondary: Color(0xFF138808),
    wash: Color(0xFFFFEEE2), pattern: 'rangoli',
    motif: Icons.local_fire_department_outlined,
    defaultCalendar: FimCalendarSystem.gregorian,
    calendars: [FimCalendarSystem.gregorian, FimCalendarSystem.hijri],
    welcome: 'Your India layer, while FIM keeps Malaysia tasks simple.',
    utilityLine: 'India-aware language routes with Malaysia-first services.',
  ),
  'PK': CountryThemeProfile(
    code: 'PK', countryName: 'Pakistan', localName: 'پاکستان',
    accent: Color(0xFF01411C), secondary: Color(0xFFFFFFFF),
    wash: Color(0xFFE4F5EE), pattern: 'jaali',
    motif: Icons.change_history_rounded,
    defaultCalendar: FimCalendarSystem.hijri,
    calendars: [FimCalendarSystem.gregorian, FimCalendarSystem.hijri],
    welcome: 'Your Pakistan layer, with trusted Malaysia worker routes.',
    utilityLine: 'Urdu-friendly content and Malaysia official utilities.',
  ),
};

CountryThemeProfile countryThemeFor(String? code) =>
    countryThemeProfiles[(code ?? 'MY').toUpperCase()] ?? countryThemeProfiles['MY']!;

String calendarName(FimCalendarSystem system) => switch (system) {
  FimCalendarSystem.gregorian => 'Gregorian',
  FimCalendarSystem.bangla => 'Bangla / বাংলা',
  FimCalendarSystem.hijri => 'Hijri / হিজরি',
};

String calendarShortDate(DateTime date, FimCalendarSystem system) {
  switch (system) {
    case FimCalendarSystem.gregorian:
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    case FimCalendarSystem.bangla:
      final year = date.month > 4 || (date.month == 4 && date.day >= 14)
          ? date.year - 593
          : date.year - 594;
      return '${date.day} ${_banglaMonths[date.month - 1]} $year';
    case FimCalendarSystem.hijri:
      final jd = _julianDay(date);
      final l = jd - 1948440 + 10632;
      final n = ((l - 1) / 10631).floor();
      final l2 = l - 10631 * n + 354;
      final j = (((10985 - l2) / 5316).floor()) *
          ((50 * l2 / 17719).floor()) +
          ((l2 / 5670).floor()) * ((43 * l2 / 15238).floor());
      final l3 = l2 - ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
          ((j / 16).floor()) * ((15238 * j) / 43).floor() + 29;
      final month = ((24 * l3) / 709).floor();
      final day = l3 - ((709 * month) / 24).floor();
      final year = 30 * n + j - 30;
      return '$day ${_hijriMonths[month - 1]} $year AH';
  }
}

const _banglaMonths = <String>['বৈশাখ', 'জ্যৈষ্ঠ', 'আষাঢ়', 'শ্রাবণ', 'ভাদ্র', 'আশ্বিন', 'কার্তিক', 'অগ্রহায়ণ', 'পৌষ', 'মাঘ', 'ফাল্গুন', 'চৈত্র'];
const _hijriMonths = <String>['Muharram', 'Safar', 'Rabi I', 'Rabi II', 'Jumada I', 'Jumada II', 'Rajab', 'Sha’ban', 'Ramadan', 'Shawwal', 'Dhu al-Qadah', 'Dhu al-Hijjah'];

int _julianDay(DateTime date) {
  final a = ((14 - date.month) / 12).floor();
  final y = date.year + 4800 - a;
  final m = date.month + 12 * a - 3;
  return date.day + ((153 * m + 2) / 5).floor() + 365 * y +
      (y / 4).floor() - (y / 100).floor() + (y / 400).floor() - 32045;
}
