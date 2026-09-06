import 'package:flutter_test/flutter_test.dart';
import 'package:expat_status_checker/fim_help_assistant.dart';

void main() {
  test('answers the country support FAQ', () {
    final answer = findFimManualAnswer('How do I find country support?');

    expect(answer.title, 'Country support');
    expect(answer.body, contains('country'));
  });

  test('answers the About FIM FAQ', () {
    final answer = findFimManualAnswer('What is FIM about?');

    expect(answer.title, 'About FIM');
    expect(answer.body, contains('FIM'));
  });

  test('answers the privacy policy FAQ', () {
    final answer = findFimManualAnswer('Where can I read the privacy policy?');

    expect(answer.title, 'Privacy policy');
    expect(answer.body, contains('Privacy'));
  });

  test('does not answer questions outside the three FAQs', () {
    final answer = findFimManualAnswer('How do I change the language?');

    expect(answer.title, 'Choose one of the three FIM FAQs');
    expect(answer.body, contains('Country support'));
  });

  test('returns the three FAQs in Bangla when Bangla is selected', () {
    final answer = findFimManualAnswer(
      'গোপনীয়তা নীতি কোথায়?',
      language: 'Bangla',
    );

    expect(answer.title, 'গোপনীয়তা নীতি');
    expect(answer.body, contains('গোপনীয়তা'));
  });
}
