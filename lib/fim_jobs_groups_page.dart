import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FimJobsGroupsPage extends StatelessWidget {
  const FimJobsGroupsPage({super.key, required this.isBangla});

  final bool isBangla;

  static const _groups = <_JobsLink>[
    _JobsLink(
      title: 'FIM-JOBS🇲🇾',
      subtitle: 'Employer hiring and full-time opportunities',
      banglaSubtitle: 'নিয়োগকর্তার চাকরি ও ফুল-টাইম সুযোগ',
      url: 'https://www.facebook.com/share/g/1YPhM5ZtM4/',
      icon: Icons.work_outline_rounded,
      color: Color(0xFF1B5E20),
    ),
    _JobsLink(
      title: 'FIM-USERS♾️',
      subtitle: 'FIM support, feedback and Malaysia life discussion',
      banglaSubtitle: 'FIM সহায়তা, মতামত ও মালয়েশিয়া জীবন আলোচনা',
      url: 'https://www.facebook.com/share/g/1CRjKBP3Jh/',
      icon: Icons.groups_rounded,
      color: Color(0xFF1565C0),
    ),
    _JobsLink(
      title: 'Part Time Jobs Malaysia',
      subtitle: 'Temporary, weekend and part-time opportunities',
      banglaSubtitle: 'অস্থায়ী, weekend ও part-time কাজের সুযোগ',
      url: 'https://www.facebook.com/share/g/18Rxk6goVa/',
      icon: Icons.schedule_rounded,
      color: Color(0xFF8A4C99),
    ),
  ];

  static const _official = <_JobsLink>[
    _JobsLink(
      title: 'MYFutureJobs',
      subtitle: 'Malaysia public employment service',
      banglaSubtitle: 'মালয়েশিয়ার সরকারি চাকরি সেবা',
      url: 'https://myfuturejobs.gov.my/',
      icon: Icons.account_balance_outlined,
      color: Color(0xFF0D47A1),
    ),
    _JobsLink(
      title: 'Malaysia Immigration · Foreign Worker',
      subtitle: 'Official work-permit and immigration information',
      banglaSubtitle: 'সরকারি work-permit ও immigration তথ্য',
      url: 'https://www.imi.gov.my/index.php/en/main-services/foreign-worker/',
      icon: Icons.verified_user_outlined,
      color: Color(0xFF6D4C41),
    ),
  ];

  Future<void> _open(BuildContext context, String url) async {
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isBangla ? 'লিংক খোলা যায়নি' : 'Could not open this link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(isBangla ? 'FIM Jobs ও Groups' : 'FIM Jobs & Groups'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
        children: [
          _JobsHero(isBangla: isBangla),
          const SizedBox(height: 18),
          _SectionTitle(
            icon: Icons.groups_rounded,
            title: isBangla ? 'FIM community groups' : 'FIM community groups',
          ),
          const SizedBox(height: 10),
          for (final link in _groups) ...[
            _JobsLinkCard(
              link: link,
              isBangla: isBangla,
              onTap: () => _open(context, link.url),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 10),
          _SectionTitle(
            icon: Icons.verified_outlined,
            title: isBangla ? 'Official employment links' : 'Official employment links',
          ),
          const SizedBox(height: 10),
          for (final link in _official) ...[
            _JobsLinkCard(
              link: link,
              isBangla: isBangla,
              onTap: () => _open(context, link.url),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          Card(
            color: scheme.errorContainer.withValues(alpha: .72),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isBangla ? 'চাকরির নিরাপত্তা সতর্কতা' : 'Job safety reminder',
                          style: TextStyle(
                            color: scheme.onErrorContainer,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isBangla
                        ? 'কোনো advance payment, passport জমা, OTP, bank password বা guaranteed visa/job বিশ্বাস করবেন না। FIM recruiter, employer বা visa guarantor নয়। চুক্তি, payment, permit এবং legal compliance সবসময় employer ও worker-এর দায়িত্ব।'
                        : 'Never pay an advance fee or share your passport, OTP or bank password. FIM is not a recruiter, employer or visa guarantor. Contracts, payment, permits and legal compliance remain the responsibility of the employer and worker.',
                    style: TextStyle(
                      color: scheme.onErrorContainer,
                      height: 1.45,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isBangla
                ? 'FIM Jobs ভবিষ্যতে একটি connection marketplace হিসেবে ধাপে ধাপে তৈরি হবে। এখন এই page থেকে trusted groups ও official links দেখা যাবে।'
                : 'FIM Jobs will be developed step by step as a connection marketplace. For now, this page provides trusted groups and official links.',
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurface.withValues(alpha: .62), height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _JobsHero extends StatelessWidget {
  const _JobsHero({required this.isBangla});
  final bool isBangla;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF010066), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.work_history_rounded, color: Colors.white, size: 46),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBangla ? 'FIM Jobs' : 'FIM Jobs',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  isBangla
                      ? 'চাকরি খোঁজা ও নিয়োগকর্তার সঙ্গে সরাসরি যোগাযোগের জন্য নিরাপদ শুরু'
                      : 'A safer starting point for finding opportunities and contacting employers directly',
                  style: const TextStyle(color: Color(0xFFD7E5FF), height: 1.35, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
        ],
      );
}

class _JobsLinkCard extends StatelessWidget {
  const _JobsLinkCard({required this.link, required this.isBangla, required this.onTap});
  final _JobsLink link;
  final bool isBangla;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          leading: CircleAvatar(
            backgroundColor: link.color.withValues(alpha: .12),
            child: Icon(link.icon, color: link.color),
          ),
          title: Text(link.title, style: const TextStyle(fontWeight: FontWeight.w900)),
          subtitle: Text(isBangla ? link.banglaSubtitle : link.subtitle),
          trailing: const Icon(Icons.open_in_new_rounded),
          onTap: onTap,
        ),
      );
}

class _JobsLink {
  const _JobsLink({
    required this.title,
    required this.subtitle,
    required this.banglaSubtitle,
    required this.url,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String banglaSubtitle;
  final String url;
  final IconData icon;
  final Color color;
}
