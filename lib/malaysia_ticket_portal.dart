import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MalaysiaPortalLink {
  const MalaysiaPortalLink({
    required this.name,
    required this.description,
    required this.url,
    this.logoAsset,
  });

  final String name;
  final String description;
  final String url;
  final String? logoAsset;
}

const _movieLinks = <MalaysiaPortalLink>[
  MalaysiaPortalLink(
    name: 'GSC Cinemas',
    description: 'Malaysia movie showtimes and official tickets.',
    url: 'https://www.gsc.com.my/movies/now-showing',
    logoAsset: 'assets/images/official-portals/gsc.png',
  ),
  MalaysiaPortalLink(
    name: 'TGV Cinemas',
    description: 'Malaysia movie listings, showtimes, and tickets.',
    url: 'https://www.tgv.com.my/movies',
    logoAsset: 'assets/images/official-portals/tgv.png',
  ),
];

const _attractionLinks = <MalaysiaPortalLink>[
  MalaysiaPortalLink(
    name: 'Ticket2U',
    description: 'Malaysia events, theme parks, and attraction tickets.',
    url: 'https://www.ticket2u.com.my/event/list',
  ),
  MalaysiaPortalLink(
    name: 'Klook Malaysia',
    description: 'Attractions, activities, tours, and experiences.',
    url: 'https://www.klook.com/en-MY/attractions/malaysia/g19/',
    logoAsset: 'assets/images/official-portals/klook.ico',
  ),
  MalaysiaPortalLink(
    name: 'Traveloka Activities',
    description: 'Malaysia attraction tickets and local experiences.',
    url: 'https://www.traveloka.com/en-my/activities',
    logoAsset: 'assets/images/official-portals/traveloka.png',
  ),
  MalaysiaPortalLink(
    name: 'KKday Malaysia',
    description: 'Tours, amusement parks, and Malaysia experiences.',
    url: 'https://www.kkday.com/en/category/my-malaysia/experiences/list',
  ),
];

const _eventLinks = <MalaysiaPortalLink>[
  MalaysiaPortalLink(
    name: 'DBKL Programme Calendar',
    description: 'Kuala Lumpur City Hall programmes and official events.',
    url: 'https://www.dbkl.gov.my/en/news-events',
    logoAsset: 'assets/images/official-portals/dbkl.png',
  ),
  MalaysiaPortalLink(
    name: 'Eventbrite Kuala Lumpur',
    description: 'Local workshops, talks, concerts, and community events.',
    url: 'https://www.eventbrite.com/d/malaysia--kuala-lumpur/events/',
    logoAsset: 'assets/images/official-portals/eventbrite.png',
  ),
  MalaysiaPortalLink(
    name: 'Time Out Kuala Lumpur',
    description: 'Current things to do, food, nightlife, and city events.',
    url: 'https://www.timeout.com/kuala-lumpur/things-to-do',
    logoAsset: 'assets/images/official-portals/timeout.png',
  ),
  MalaysiaPortalLink(
    name: 'Visit Kuala Lumpur',
    description: 'Kuala Lumpur attractions and local city discovery.',
    url: 'https://visitkualalumpur.com/what-to-do/',
    logoAsset: 'assets/images/official-portals/visitkl.jpg',
  ),
  MalaysiaPortalLink(
    name: 'Tourism Malaysia Events',
    description: 'Malaysia tourism events and destination information.',
    url: 'https://www.malaysia.travel/events',
  ),
];

class MalaysiaTicketPortalPage extends StatelessWidget {
  const MalaysiaTicketPortalPage({super.key, required this.isBangla});

  final bool isBangla;

  Future<void> _open(BuildContext context, MalaysiaPortalLink link) async {
    final opened = await launchUrl(
      Uri.parse(link.url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBangla
                ? 'ওয়েবসাইট খোলা যায়নি।'
                : 'The official website could not be opened.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isBangla ? 'টিকিট ও ইভেন্ট' : 'Tickets & events'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        children: [
          _PortalHero(isBangla: isBangla),
          const SizedBox(height: 22),
          _PortalSection(
            title: isBangla ? 'সিনেমা টিকিট' : 'Movie tickets',
            subtitle: isBangla
                ? 'অফিসিয়াল সিনেমা সাইটে শো-টাইম ও টিকিট দেখুন।'
                : 'Check showtimes and continue to the official cinema ticket site.',
            links: _movieLinks,
            onOpen: _open,
          ),
          const SizedBox(height: 22),
          _PortalSection(
            title: isBangla ? 'আকর্ষণ ও ভ্রমণ' : 'Attractions & activities',
            subtitle: isBangla
                ? 'মালয়েশিয়ার পার্ক, ট্যুর ও আকর্ষণের টিকিট খুঁজুন।'
                : 'Find Malaysia attraction, theme-park, tour, and activity tickets.',
            links: _attractionLinks,
            onOpen: _open,
          ),
          const SizedBox(height: 22),
          _PortalSection(
            title: isBangla
                ? 'কুয়ালালামপুরের বর্তমান ইভেন্ট'
                : 'Current KL & Malaysia events',
            subtitle: isBangla
                ? 'তারিখ, স্থান ও টিকিটের availability অফিসিয়াল সাইটে যাচাই করুন।'
                : 'Discover current events around Kuala Lumpur and Malaysia; dates and availability change.',
            links: _eventLinks,
            onOpen: _open,
          ),
          const SizedBox(height: 18),
          Text(
            isBangla
                ? 'FIM টিকিট বিক্রি বা পেমেন্ট করে না। প্রতিটি বাটন সংশ্লিষ্ট অফিসিয়াল ওয়েবসাইটে নিয়ে যাবে।'
                : 'FIM does not sell tickets or process payments. Each button opens the relevant official website.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.64),
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _PortalHero extends StatelessWidget {
  const _PortalHero({required this.isBangla});
  final bool isBangla;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF010066), Color(0xFF123B86)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.confirmation_number_outlined,
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(height: 12),
          Text(
            isBangla
                ? 'টিকিট ও স্থানীয় ইভেন্ট এক জায়গায়'
                : 'Tickets and local events in one place',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isBangla
                ? 'সিনেমা, আকর্ষণ, কুয়ালালামপুর ও মালয়েশিয়ার বর্তমান ইভেন্ট খুঁজে নিন।'
                : 'Find movies, attractions, Kuala Lumpur listings, and current Malaysia events.',
            style: const TextStyle(
              color: Color(0xFFD8E8FF),
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _PortalSection extends StatelessWidget {
  const _PortalSection({
    required this.title,
    required this.subtitle,
    required this.links,
    required this.onOpen,
  });
  final String title;
  final String subtitle;
  final List<MalaysiaPortalLink> links;
  final Future<void> Function(BuildContext, MalaysiaPortalLink) onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface
                .withValues(alpha: 0.66),
            fontSize: 12,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 11),
        for (final link in links) ...[
          _PortalLinkCard(link: link, onTap: () => onOpen(context, link)),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _PortalLinkCard extends StatelessWidget {
  const _PortalLinkCard({required this.link, required this.onTap});
  final MalaysiaPortalLink link;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.7)),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 48,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: scheme.onSurface.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: link.logoAsset == null
                    ? Icon(Icons.public_rounded, color: scheme.primary)
                    : Image.asset(link.logoAsset!, fit: BoxFit.contain),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      link.name,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      link.description,
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.66),
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new_rounded, color: scheme.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
