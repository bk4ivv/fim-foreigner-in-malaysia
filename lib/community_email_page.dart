import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _communityEmail = 'hire.borhankabir@hotmail.com';

class CommunityEmailPage extends StatefulWidget {
  const CommunityEmailPage({super.key, required this.isBangla});

  final bool isBangla;

  @override
  State<CommunityEmailPage> createState() => _CommunityEmailPageState();
}

class _CommunityEmailPageState extends State<CommunityEmailPage> {
  final _title = TextEditingController();
  final _name = TextEditingController();
  final _message = TextEditingController();
  final _reportDetails = TextEditingController();
  var _mode = _CommunityMessageMode.post;

  bool get _isBangla => widget.isBangla;

  @override
  void dispose() {
    _title.dispose();
    _name.dispose();
    _message.dispose();
    _reportDetails.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final message = _mode == _CommunityMessageMode.post
        ? _message.text.trim()
        : _reportDetails.text.trim();
    if (message.isEmpty) {
      _showMessage(
        _isBangla
            ? 'আগে আপনার বার্তাটি লিখুন।'
            : 'Please write a message first.',
      );
      return;
    }

    final isPost = _mode == _CommunityMessageMode.post;
    final subject = isPost
        ? '[FIM Community Post] ${_title.text.trim().isEmpty ? 'New post' : _title.text.trim()}'
        : '[FIM Community Report] FIM user report';
    final body = isPost
        ? 'Community post submitted from FIM - Foreigner in Malaysia.\n\n'
              'Name: ${_name.text.trim().isEmpty ? 'Not provided' : _name.text.trim()}\n'
              'Title: ${_title.text.trim().isEmpty ? 'Untitled' : _title.text.trim()}\n\n'
              '$message'
        : 'Community report submitted from FIM - Foreigner in Malaysia.\n\n$message';
    final uri = Uri(
      scheme: 'mailto',
      path: _communityEmail,
      queryParameters: {'subject': subject, 'body': body},
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      _showMessage(
        _isBangla
            ? 'ইমেইল অ্যাপ খোলা যায়নি।'
            : 'No email app could be opened on this device.',
      );
    } else if (mounted) {
      _showMessage(
        isPost
            ? (_isBangla
                  ? 'আপনার কমিউনিটি পোস্ট ইমেইলে প্রস্তুত হয়েছে।'
                  : 'Your community post is ready in your email app.')
            : (_isBangla
                  ? 'আপনার রিপোর্ট ইমেইলে প্রস্তুত হয়েছে।'
                  : 'Your report is ready in your email app.'),
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isPost = _mode == _CommunityMessageMode.post;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF010066), Color(0xFF124B9B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.forum_outlined, color: Colors.white, size: 30),
                const SizedBox(height: 12),
                Text(
                  _isBangla ? 'কমিউনিটিতে কথা বলুন' : 'Community, together',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _isBangla
                      ? 'আপনার অভিজ্ঞতা, দরকারি তথ্য বা সমস্যা FIM কমিউনিটির সঙ্গে শেয়ার করুন।'
                      : 'Share useful experiences, questions, and updates with the FIM community.',
                  style: const TextStyle(
                    color: Color(0xFFD8E8FF),
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<_CommunityMessageMode>(
            segments: [
              ButtonSegment(
                value: _CommunityMessageMode.post,
                icon: const Icon(Icons.edit_note_rounded),
                label: Text(_isBangla ? 'পোস্ট' : 'Post'),
              ),
              ButtonSegment(
                value: _CommunityMessageMode.report,
                icon: const Icon(Icons.flag_outlined),
                label: Text(_isBangla ? 'রিপোর্ট' : 'Report'),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) =>
                setState(() => _mode = selection.first),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: scheme.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPost
                      ? (_isBangla
                            ? 'কমিউনিটি পোস্ট লিখুন'
                            : 'Write a community post')
                      : (_isBangla
                            ? 'কমিউনিটি রিপোর্ট লিখুন'
                            : 'Report a community issue'),
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 7),
                Text(
                  _isBangla
                      ? 'আপনার ডিভাইসের ইমেইল অ্যাপে বার্তাটি খুলবে এবং $_communityEmail ঠিকানায় পাঠানোর জন্য প্রস্তুত থাকবে।'
                      : 'Your email app will open with the message addressed to $_communityEmail.',
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.68),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                if (isPost) ...[
                  TextField(
                    controller: _title,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: _isBangla ? 'শিরোনাম' : 'Title',
                      prefixIcon: const Icon(Icons.title_rounded),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: _isBangla
                          ? 'আপনার নাম (ঐচ্ছিক)'
                          : 'Your name (optional)',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: isPost ? _message : _reportDetails,
                  maxLines: 7,
                  maxLength: 2000,
                  decoration: InputDecoration(
                    labelText: isPost
                        ? (_isBangla ? 'আপনার পোস্ট' : 'Your post')
                        : (_isBangla ? 'রিপোর্টের বিবরণ' : 'Report details'),
                    alignLabelWithHint: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 92),
                      child: Icon(Icons.notes_rounded),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _send,
                    icon: Icon(
                      isPost ? Icons.send_rounded : Icons.flag_outlined,
                    ),
                    label: Text(
                      isPost
                          ? (_isBangla
                                ? 'ইমেইলে পোস্ট পাঠান'
                                : 'Send post by email')
                          : (_isBangla
                                ? 'ইমেইলে রিপোর্ট পাঠান'
                                : 'Send report by email'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _isBangla
                ? 'নিরাপত্তা: কারও পাসওয়ার্ড, OTP, পাসপোর্ট নম্বর বা সংবেদনশীল নথি পোস্টে দেবেন না।'
                : 'Safety: never include passwords, OTPs, passport numbers, or sensitive documents in a post.',
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.64),
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

enum _CommunityMessageMode { post, report }
