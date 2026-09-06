import 'package:flutter/material.dart';

class FimManualAnswer {
  const FimManualAnswer({required this.title, required this.body});

  final String title;
  final String body;
}

FimManualAnswer findFimManualAnswer(
  String question, {
  String language = 'English',
}) {
  final normalized = question.trim().toLowerCase();
  final isBangla = language.toLowerCase() == 'bangla';

  final isCountrySupport = normalized.contains('country') ||
      normalized.contains('support') ||
      normalized.contains('দেশ') ||
      normalized.contains('সহায়তা');
  final isAboutFim = normalized.contains('about') ||
      normalized.contains('what is fim') ||
      normalized.contains('fim সম্পর্কে');
  final isPrivacy = normalized.contains('privacy') ||
      normalized.contains('data') ||
      normalized.contains('গোপনীয়তা');

  if (isCountrySupport) {
    return isBangla
        ? const FimManualAnswer(
            title: 'দেশভিত্তিক সহায়তা',
            body: 'Help & info থেকে Country support খুলুন। আপনার ভাষা ও দেশের জন্য উপলব্ধ সরকারি, দূতাবাস এবং সহায়তা উৎসগুলো সেখানে দেখুন।',
          )
        : const FimManualAnswer(
            title: 'Country support',
            body: 'Open Country support from Help & info. You can find available official, embassy, and support sources for your language and country there.',
          );
  }

  if (isAboutFim) {
    return isBangla
        ? const FimManualAnswer(
            title: 'FIM সম্পর্কে',
            body: 'FIM হলো মালয়েশিয়ায় বসবাস ও কাজ করা বিদেশিদের জন্য একটি বিনামূল্যের সহায়ক অ্যাপ। এটি সরকারি সেবা, ভ্রমণ, শেখা এবং দরকারি তথ্য সহজে খুঁজে পেতে সাহায্য করে।',
          )
        : const FimManualAnswer(
            title: 'About FIM',
            body: 'FIM is a free helper app for foreigners living and working in Malaysia. It brings useful government services, travel, learning, and support information together.',
          );
  }

  if (isPrivacy) {
    return isBangla
        ? const FimManualAnswer(
            title: 'গোপনীয়তা নীতি',
            body: 'গোপনীয়তা নীতিতে FIM-এর ডেটা ব্যবহার, ক্যামেরা, বাহ্যিক সেবা এবং আপনার নিয়ন্ত্রণ সম্পর্কে তথ্য পড়ুন। সরকারি বা আইনি সিদ্ধান্তের জন্য official source দেখুন।',
          )
        : const FimManualAnswer(
            title: 'Privacy policy',
            body: 'Read the Privacy policy for information about FIM data use, camera access, external services, and your controls. For government or legal decisions, check the official source.',
          );
  }

  return isBangla
      ? const FimManualAnswer(
          title: 'তিনটি প্রশ্নের একটি বেছে নিন',
          body: 'আমি শুধু Country support, About FIM এবং Privacy policy—এই তিনটি প্রশ্নের উত্তর দিই।',
        )
      : const FimManualAnswer(
          title: 'Choose one of the three FIM FAQs',
          body: 'I answer only these three questions: Country support, About FIM, and Privacy policy.',
        );
}

class FimHelpAssistantPage extends StatefulWidget {
  const FimHelpAssistantPage({super.key, this.language = 'English'});

  final String language;

  @override
  State<FimHelpAssistantPage> createState() => _FimHelpAssistantPageState();
}

class _FimHelpAssistantPageState extends State<FimHelpAssistantPage> {
  final _controller = TextEditingController();
  final List<_FimChatMessage> _messages = [];

  bool get _isBangla => widget.language.toLowerCase() == 'bangla';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ask(String question) {
    final text = question.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() {
      _messages.add(_FimChatMessage(text: text, fromUser: true));
      final answer = findFimManualAnswer(text, language: widget.language);
      _messages.add(
        _FimChatMessage(
          text: '${answer.title}\n\n${answer.body}',
          fromUser: false,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isBangla ? 'FIM সহায়তা সহকারী' : 'FIM Help Assistant'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
            color: scheme.primaryContainer,
            child: Text(
              _isBangla
                  ? 'তিনটি FAQ থেকে একটি বেছে নিন।'
                  : 'Choose one of the three FIM FAQs.',
              style: TextStyle(color: scheme.onPrimaryContainer, height: 1.35),
            ),
          ),
          Expanded(
            child: _messages.isEmpty
                ? _SuggestedQuestions(
                    language: widget.language,
                    onAsk: _ask,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Align(
                        alignment: message.fromUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 340),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: message.fromUser
                                ? scheme.primary
                                : scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color: message.fromUser
                                  ? scheme.onPrimary
                                  : scheme.onSurface,
                              height: 1.4,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _ask,
                      decoration: InputDecoration(
                        hintText: _isBangla
                            ? 'তিনটি FAQ-এর একটি জিজ্ঞাসা করুন'
                            : 'Ask one of the three FAQs',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: _isBangla ? 'জিজ্ঞাসা করুন' : 'Ask',
                    onPressed: () => _ask(_controller.text),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FimChatMessage {
  const _FimChatMessage({required this.text, required this.fromUser});

  final String text;
  final bool fromUser;
}

class _SuggestedQuestions extends StatelessWidget {
  const _SuggestedQuestions({required this.language, required this.onAsk});

  final String language;
  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context) {
    final isBangla = language.toLowerCase() == 'bangla';
    final questions = isBangla
        ? <String>[
            'দেশভিত্তিক সহায়তা কোথায়?',
            'FIM সম্পর্কে বলুন',
            'গোপনীয়তা নীতি কোথায়?',
          ]
        : <String>[
            'Where is Country support?',
            'What is FIM about?',
            'Where is the Privacy policy?',
          ];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Icon(
          Icons.support_agent_rounded,
          size: 56,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Text(
          isBangla ? 'তিনটি FAQ থেকে বেছে নিন' : 'Choose a FIM FAQ',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 20),
        for (final question in questions) ...[
          OutlinedButton(
            onPressed: () => onAsk(question),
            child: Text(question),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
