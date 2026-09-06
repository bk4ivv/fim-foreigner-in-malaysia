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

  if (normalized.contains('language') ||
      normalized.contains('ভাষা') ||
      normalized.contains('idioma')) {
    return isBangla
        ? const FimManualAnswer(
            title: 'ভাষা পরিবর্তন',
            body: 'হোম স্ক্রিনের ভাষা নির্বাচন অপশন খুলে আপনার পছন্দের ভাষা বেছে নিন। FIM আবার খুললে আপনার ভাষা ব্যবহার করবে।',
          )
        : const FimManualAnswer(
            title: 'Change language',
            body: 'Open the language option from the FIM home screen and choose your preferred language. FIM will use that language across the app.',
          );
  }

  if (normalized.contains('trip') ||
      normalized.contains('bus') ||
      normalized.contains('train') ||
      normalized.contains('plane') ||
      normalized.contains('flight') ||
      normalized.contains('ferry') ||
      normalized.contains('ট্রেন') ||
      normalized.contains('বাস')) {
    return isBangla
        ? const FimManualAnswer(
            title: 'ভ্রমণ',
            body: 'হোম স্ক্রিন থেকে Trips খুলুন। বাস, বিমান, ফেরি বা ট্রেন বেছে নিলে FIM টিকিট খোঁজার উপযুক্ত সাইট দেখাবে।',
          )
        : const FimManualAnswer(
            title: 'Trips',
            body: 'Open Trips from the home screen. Choose Bus, Plane, Ferry, or Train to see suitable ticket-booking websites.',
          );
  }

  if (normalized.contains('learn') ||
      normalized.contains('malay') ||
      normalized.contains('শেখা')) {
    return isBangla
        ? const FimManualAnswer(
            title: 'শেখা',
            body: 'নেভিগেশন থেকে Learn খুলুন। সেখানে মালয় ভাষা, দরকারি বাক্য এবং সংস্কৃতি-সম্পর্কিত শেখার বিষয়বস্তু পাবেন।',
          )
        : const FimManualAnswer(
            title: 'Learn',
            body: 'Open Learn from the navigation bar to find Malay language practice, useful phrases, and Malaysian culture content.',
          );
  }

  if (normalized.contains('privacy') ||
      normalized.contains('data') ||
      normalized.contains('গোপনীয়তা')) {
    return isBangla
        ? const FimManualAnswer(
            title: 'গোপনীয়তা',
            body: 'Help & info খুলে Privacy policy নির্বাচন করুন। সেখানে ডেটা, ক্যামেরা এবং বাহ্যিক সেবা সম্পর্কে তথ্য পাবেন।',
          )
        : const FimManualAnswer(
            title: 'Privacy',
            body: 'Open Help & info and choose Privacy policy to read about data, camera access, and external services.',
          );
  }

  return isBangla
      ? const FimManualAnswer(
          title: 'FIM সহায়তা',
          body: 'আমি FIM অ্যাপ ব্যবহার করতে সাহায্য করতে পারি। ভাষা পরিবর্তন, Trips, Learn, Privacy বা Help & info সম্পর্কে জিজ্ঞাসা করুন। সরকারি নিয়মের জন্য অ্যাপের official source দেখুন।',
        )
      : const FimManualAnswer(
          title: 'I can help you use FIM',
          body: 'Ask me about changing language, Trips, Learn, Privacy, or Help & info. For government rules or decisions, always check the official source shown in FIM.',
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
    final title = _isBangla ? 'FIM সহায়তা সহকারী' : 'FIM Help Assistant';
    final hint = _isBangla ? 'আপনার প্রশ্ন লিখুন' : 'Ask how to use FIM';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
            color: scheme.primaryContainer,
            child: Text(
              _isBangla
                  ? 'এটি FIM-এর অফলাইন ব্যবহার নির্দেশিকা। সরকারি সিদ্ধান্তের জন্য official source দেখুন।'
                  : 'This offline guide explains how to use FIM. For government decisions, check the official source shown in the app.',
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
                        hintText: hint,
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
        ? <String>['ভাষা কীভাবে পরিবর্তন করব?', 'Trips কোথায়?', 'Learn কীভাবে ব্যবহার করব?']
        : <String>['How do I change the language?', 'Where can I find Trips?', 'How do I use Learn?'];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Icon(Icons.support_agent_rounded, size: 56, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        Text(
          isBangla ? 'কীভাবে সাহায্য করব?' : 'How can I help?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
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
