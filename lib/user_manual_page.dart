import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UserManualPage extends StatelessWidget {
  const UserManualPage({super.key, required this.isBangla});

  final bool isBangla;

  Future<void> _openVideoSearch(BuildContext context) async {
    final opened = await launchUrl(
      Uri.parse(
        'https://www.youtube.com/results?search_query=FIM+Foreigner+in+Malaysia+user+manual',
      ),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBangla
                ? 'ভিডিও সাইট খোলা যায়নি।'
                : 'The video site could not be opened.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final steps = isBangla
        ? const [
            (
              '১',
              'দেশ বেছে নিন',
              'আপনার দেশের অফিসিয়াল সহায়তা ও ভাষার পথ দেখুন।',
            ),
            (
              '২',
              'ভাষা বেছে নিন',
              'আপনার জন্য সবচেয়ে স্বাচ্ছন্দ্যের ভাষায় FIM ব্যবহার করুন।',
            ),
            (
              '৩',
              'হোম সার্ভিস খুলুন',
              'Visa, FOMEMA, EPF, CIDB, টিকিট, ইভেন্ট ও অন্যান্য সার্ভিস সরাসরি খুলুন।',
            ),
            (
              '৪',
              'সহায়তা নিন',
              'Help & info এবং Community থেকে সহায়তা, রিপোর্ট বা পোস্ট পাঠান।',
            ),
          ]
        : const [
            (
              '1',
              'Choose your country',
              'See the support and language routes relevant to your country.',
            ),
            (
              '2',
              'Choose your language',
              'Use FIM in the language that feels most comfortable.',
            ),
            (
              '3',
              'Open Home services',
              'Open Visa, FOMEMA, EPF, CIDB, tickets, events, and other services directly.',
            ),
            (
              '4',
              'Get help',
              'Use Help & info and Community for guidance, reports, and community posts.',
            ),
          ];
    return Scaffold(
      appBar: AppBar(
        title: Text(isBangla ? 'ব্যবহার নির্দেশিকা' : 'User manual'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF010066), Color(0xFF0D5C74)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  isBangla ? 'FIM কীভাবে ব্যবহার করবেন' : 'How to use FIM',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isBangla ? 'প্রশ্নের ধাপ ছাড়াই সরাসরি নির্দেশিকা দেখুন।' : 'Open the guide directly without answering onboarding questions.',
                  style: const TextStyle(
                    color: Color(0xFFD8E8FF),
                    height: 1.45,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          for (final step in steps) ...[
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: scheme.outline.withValues(alpha: 0.72),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    child: Text(
                      step.$1,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.$2,
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step.$3,
                          style: TextStyle(
                            color: scheme.onSurface.withValues(alpha: 0.68),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _openVideoSearch(context),
            icon: const Icon(Icons.play_circle_outline_rounded),
            label: Text(
              isBangla
                  ? 'ব্যবহার নির্দেশিকা ভিডিও দেখুন'
                  : 'Watch the user manual video',
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}
