import 'package:flutter_test/flutter_test.dart';
import 'package:expat_status_checker/fim_help_assistant.dart';

void main() {
  test('answers how to change the app language from the manual', () {
    final answer = findFimManualAnswer('How do I change the language?');

    expect(answer.title, 'Change language');
    expect(answer.body, contains('language'));
  });

  test('answers Trips questions with practical navigation steps', () {
    final answer = findFimManualAnswer('Where can I find bus and train tickets?');

    expect(answer.title, 'Trips');
    expect(answer.body, contains('Trips'));
  });

  test('uses a safe fallback when the manual has no matching answer', () {
    final answer = findFimManualAnswer('Can I definitely get a visa tomorrow?');

    expect(answer.title, 'I can help you use FIM');
    expect(answer.body, contains('official source'));
  });

  test('returns Bangla manual answers when Bangla is selected', () {
    final answer = findFimManualAnswer(
      'ভাষা কীভাবে পরিবর্তন করব?',
      language: 'Bangla',
    );

    expect(answer.title, 'ভাষা পরিবর্তন');
    expect(answer.body, contains('ভাষা'));
  });
}
