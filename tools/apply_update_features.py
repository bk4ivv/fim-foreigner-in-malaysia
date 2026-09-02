from pathlib import Path

path = Path('/home/ubuntu/expat_status_checker/lib/main.dart')
source = path.read_text()

source = source.replace(
    "import 'package:flutter/material.dart';\n",
    "import 'package:flutter/material.dart';\nimport 'package:path_provider/path_provider.dart';\nimport 'package:pdf/widgets.dart' as pw;\nimport 'package:printing/printing.dart';\n",
    1,
)

trips_start = source.index('class TripsPage extends StatelessWidget {')
tools_start = source.index('class ToolsPage extends StatelessWidget {', trips_start)
trips_block = r'''enum _TripMode { bus, plane, ferry, train }

class _TripProvider {
  const _TripProvider({required this.name, required this.url, required this.note});

  final String name;
  final String url;
  final String note;
}

const _tripProviders = <_TripMode, List<_TripProvider>>{
  _TripMode.bus: [
    _TripProvider(
      name: 'redBus Malaysia',
      url: 'https://www.redbus.my/',
      note: 'Compare routes, operators, seats, and online bus tickets.',
    ),
    _TripProvider(
      name: 'BusOnlineTicket',
      url: 'https://www.busonlineticket.com/',
      note: 'Bus booking across Malaysia and Singapore.',
    ),
    _TripProvider(
      name: 'Easybook',
      url: 'https://www.easybook.com/en-my/bus',
      note: 'Bus schedules and online reservations in Malaysia.',
    ),
  ],
  _TripMode.plane: [
    _TripProvider(
      name: 'Malaysia Airlines',
      url: 'https://www.malaysiaairlines.com/my/en/home.html',
      note: 'Official Malaysia Airlines booking and manage-booking site.',
    ),
    _TripProvider(
      name: 'AirAsia',
      url: 'https://www.airasia.com/',
      note: 'Official AirAsia booking and flight search.',
    ),
    _TripProvider(
      name: 'Google Flights',
      url: 'https://www.google.com/travel/flights',
      note: 'Compare flight schedules and fares before booking.',
    ),
  ],
  _TripMode.ferry: [
    _TripProvider(
      name: 'BusOnlineTicket Ferry',
      url: 'https://www.busonlineticket.com/booking/ferry-tickets.aspx',
      note: 'Ferry tickets for Langkawi, Tioman, Redang, Batam, Bintan, and more.',
    ),
    _TripProvider(
      name: 'Easybook Ferry',
      url: 'https://www.easybook.com/en-my/ferry',
      note: 'Online ferry booking for Malaysia routes.',
    ),
    _TripProvider(
      name: 'Malaysia Ferry',
      url: 'https://www.malaysiaferry.com/',
      note: 'Ferry route and ticket search.',
    ),
  ],
  _TripMode.train: [
    _TripProvider(
      name: 'KTMB',
      url: 'https://www.ktmb.com.my/',
      note: 'Official KTM Berhad passenger information and ticket access.',
    ),
    _TripProvider(
      name: 'BusOnlineTicket Train',
      url: 'https://www.busonlineticket.com/',
      note: 'Online bus and selected train ticket search.',
    ),
  ],
};

String _tripModeTitle(AppLanguage language, _TripMode mode) {
  if (language == AppLanguage.bangla) {
    return switch (mode) {
      _TripMode.bus => 'বাস',
      _TripMode.plane => 'বিমান',
      _TripMode.ferry => 'ফেরি',
      _TripMode.train => 'ট্রেন',
    };
  }
  return switch (mode) {
    _TripMode.bus => 'Bus',
    _TripMode.plane => 'Plane',
    _TripMode.ferry => 'Ferry',
    _TripMode.train => 'Train',
  };
}

IconData _tripModeIcon(_TripMode mode) => switch (mode) {
  _TripMode.bus => Icons.directions_bus_outlined,
  _TripMode.plane => Icons.flight_outlined,
  _TripMode.ferry => Icons.directions_boat_outlined,
  _TripMode.train => Icons.train_outlined,
};

class TripsPage extends StatelessWidget {
  const TripsPage({super.key, required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final copy = appCopies[language]!;
    final modes = _TripMode.values;
    return Directionality(
      textDirection: copy.direction,
      child: Scaffold(
        appBar: _AppBar(
          title: language == AppLanguage.bangla ? 'ভ্রমণ' : 'Trips',
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            CivicHeroPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.travel_explore_rounded, color: Colors.white, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    language == AppLanguage.bangla
                        ? 'যাতায়াতের ধরন বেছে নিন'
                        : 'Choose your way to travel',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    language == AppLanguage.bangla
                        ? 'বাস, বিমান, ফেরি বা ট্রেন বেছে নিয়ে টিকিট খোঁজার সাইট দেখুন।'
                        : 'Choose bus, plane, ferry, or train to see suitable ticket sites.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.74), height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            for (final mode in modes) ...[
              _HelpActionCard(
                icon: _tripModeIcon(mode),
                title: _tripModeTitle(language, mode),
                subtitle: language == AppLanguage.bangla
                    ? 'টিকিট বুকিং সাইট দেখুন'
                    : 'Find ticket-booking websites',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => TripProvidersPage(language: language, mode: mode),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class TripProvidersPage extends StatelessWidget {
  const TripProvidersPage({super.key, required this.language, required this.mode});

  final AppLanguage language;
  final _TripMode mode;

  @override
  Widget build(BuildContext context) {
    final copy = appCopies[language]!;
    final providers = _tripProviders[mode]!;
    final modeTitle = _tripModeTitle(language, mode);
    return Directionality(
      textDirection: copy.direction,
      child: Scaffold(
        appBar: _AppBar(
          title: language == AppLanguage.bangla ? '$modeTitle টিকিট' : '$modeTitle tickets',
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            _BanglaSection(
              icon: _tripModeIcon(mode),
              title: language == AppLanguage.bangla
                  ? '$modeTitle টিকিট খুঁজুন'
                  : 'Find $modeTitle tickets',
              body: language == AppLanguage.bangla
                  ? 'সাইটের নাম, রুট, মূল্য ও নিয়ম নিজে যাচাই করে তারপর বুক করুন।'
                  : 'Compare the route, fare, operator, and booking rules before paying.',
              color: AppPalette.flagRed,
            ),
            const SizedBox(height: 14),
            for (final provider in providers) ...[
              _HelpActionCard(
                icon: Icons.confirmation_number_outlined,
                title: provider.name,
                subtitle: provider.note,
                onTap: () => openWebsiteInApp(
                  context,
                  title: provider.name,
                  url: provider.url,
                  copy: copy,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

'''
source = source[:trips_start] + trips_block + source[tools_start:]

old_fab = '''          floatingActionButton: FloatingActionButton.small(
            tooltip: widget.copy.reload,
            onPressed: () => _controller.reload(),
            child: const Icon(Icons.refresh_rounded),
          ),'''
new_fab = '''          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.small(
                heroTag: 'print-result',
                tooltip: 'Print or save result',
                onPressed: _printOrSaveResult,
                child: const Icon(Icons.print_outlined),
              ),
              const SizedBox(height: 10),
              FloatingActionButton.small(
                heroTag: 'reload-page',
                tooltip: widget.copy.reload,
                onPressed: () => _controller.reload(),
                child: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),'''
if old_fab not in source:
    raise SystemExit('WebView FAB block not found')
source = source.replace(old_fab, new_fab, 1)

anchor = '''  Future<void> _openOutsideApp() async {
    await launchUrl(
      Uri.parse(widget.url),
      mode: LaunchMode.externalApplication,
    );
  }
'''
method = r'''
  Future<void> _printOrSaveResult() async {
    try {
      final raw = await _controller.runJavaScriptReturningResult(
        'document.body ? document.body.innerText : ""',
      );
      final visibleText = raw.toString().replaceAll(r'\n', '\n').trim();
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Header(level: 0, text: widget.title),
            pw.Paragraph(
              text: visibleText.isEmpty ? 'No readable result text was found.' : visibleText,
            ),
            pw.SizedBox(height: 16),
            pw.Paragraph(text: 'Source: ${widget.url}'),
            pw.Paragraph(text: 'Generated by FIM - Foreigner in Malaysia.'),
          ],
        ),
      );
      final bytes = await pdf.save();
      final directory = await getApplicationDocumentsDirectory();
      final safeName = widget.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
      final file = File('${directory.path}/${safeName}_result.pdf');
      await file.writeAsBytes(bytes, flush: true);
      await Printing.sharePdf(bytes: bytes, filename: '${safeName}_result.pdf');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved and ready to print: ${file.path}')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The result could not be prepared for printing.')),
        );
      }
    }
  }
'''
if anchor not in source:
    raise SystemExit('WebView method anchor not found')
source = source.replace(anchor, anchor + method, 1)

path.write_text(source)
天天中彩票被 大发快三如何{
