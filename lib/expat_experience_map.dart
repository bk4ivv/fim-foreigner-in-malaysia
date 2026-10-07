import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

const _experienceEmail = 'hire.borhankabir@hotmail.com';

enum ExperienceCategory { all, work, stay, travel, safety, food }

class ExpatExperienceMapPage extends StatefulWidget {
  const ExpatExperienceMapPage({super.key, this.isBangla = false});
  final bool isBangla;

  @override
  State<ExpatExperienceMapPage> createState() => _ExpatExperienceMapPageState();
}

class _ExpatExperienceMapPageState extends State<ExpatExperienceMapPage> {
  ExperienceCategory _category = ExperienceCategory.all;
  final _picker = ImagePicker();
  XFile? _selectedPhoto;

  bool get _bn => widget.isBangla;

  List<_ExperiencePin> get _visiblePins => _samplePins
      .where(
        (pin) =>
            _category == ExperienceCategory.all || pin.category == _category,
      )
      .toList(growable: false);

  Future<void> _choosePhoto() async {
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 82,
    );
    if (photo != null && mounted) setState(() => _selectedPhoto = photo);
  }

  Future<void> _openPostForm() async {
    final title = TextEditingController();
    final area = TextEditingController();
    final details = TextEditingController();
    var category = ExperienceCategory.travel;
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) => StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              MediaQuery.viewInsetsOf(context).bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _bn ? 'অভিজ্ঞতা শেয়ার করুন' : 'Share an experience',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _bn
                        ? 'শুধু এলাকা লিখুন। বাসা বা কর্মস্থলের exact location দেবেন না।'
                        : 'Share the area only. Never publish an exact home or workplace location.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface
                          .withValues(alpha: .68),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: title,
                    decoration: InputDecoration(
                      labelText: _bn ? 'শিরোনাম' : 'Title',
                      prefixIcon: const Icon(Icons.title_rounded),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: area,
                    decoration: InputDecoration(
                      labelText: _bn ? 'এলাকা / শহর' : 'Area / city',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ExperienceCategory>(
                    initialValue: category,
                    decoration: InputDecoration(
                      labelText: _bn ? 'বিষয়' : 'Category',
                      border: const OutlineInputBorder(),
                    ),
                    items: ExperienceCategory.values
                        .where((item) => item != ExperienceCategory.all)
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(_categoryLabel(item)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setSheetState(() => category = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: details,
                    maxLines: 6,
                    maxLength: 1800,
                    decoration: InputDecoration(
                      labelText: _bn ? 'আপনার অভিজ্ঞতা' : 'Your experience',
                      alignLabelWithHint: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 76),
                        child: Icon(Icons.notes_rounded),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await _choosePhoto();
                      if (mounted) setSheetState(() {});
                    },
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(
                      _selectedPhoto == null
                          ? (_bn ? 'ছবি যোগ করুন' : 'Add a photo')
                          : (_bn ? 'ছবি নির্বাচিত' : 'Photo selected'),
                    ),
                  ),
                  if (_selectedPhoto != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _selectedPhoto!.name,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        if (area.text.trim().isEmpty ||
                            details.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _bn
                                    ? 'এলাকা এবং অভিজ্ঞতা লিখুন।'
                                    : 'Please enter an area and experience.',
                              ),
                            ),
                          );
                          return;
                        }
                        final body =
                            'FIM Expat Experience Map submission\n\n'
                            'Title: ${title.text.trim().isEmpty ? 'Untitled' : title.text.trim()}\n'
                            'Area: ${area.text.trim()}\n'
                            'Category: ${_categoryLabel(category)}\n'
                            'Photo selected: ${_selectedPhoto == null ? 'No' : _selectedPhoto!.name}\n\n'
                            '${details.text.trim()}\n\n'
                            'Safety note: Please moderate this submission before publishing.';
                        final uri = Uri(
                          scheme: 'mailto',
                          path: _experienceEmail,
                          queryParameters: {
                            'subject':
                                '[FIM Experience Map] ${area.text.trim()}',
                            'body': body,
                          },
                        );
                        final opened = await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                        if (!context.mounted || !sheetContext.mounted) return;
                        Navigator.of(sheetContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              opened
                                  ? (_bn
                                        ? 'ইমেইলে পোস্ট প্রস্তুত হয়েছে।'
                                        : 'Submission prepared in your email app.')
                                  : (_bn
                                        ? 'ইমেইল অ্যাপ খোলা যায়নি।'
                                        : 'No email app could be opened.'),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.send_rounded),
                      label: Text(
                        _bn ? 'পর্যালোচনার জন্য পাঠান' : 'Send for review',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } finally {
      title.dispose();
      area.dispose();
      details.dispose();
    }
  }

  String _categoryLabel(ExperienceCategory category) {
    if (_bn) {
      return {
            ExperienceCategory.work: 'কাজ',
            ExperienceCategory.stay: 'থাকা',
            ExperienceCategory.travel: 'ভ্রমণ',
            ExperienceCategory.safety: 'নিরাপত্তা',
            ExperienceCategory.food: 'খাবার',
          }[category] ??
          'সব';
    }
    return {
      ExperienceCategory.all: 'All',
      ExperienceCategory.work: 'Work',
      ExperienceCategory.stay: 'Stay',
      ExperienceCategory.travel: 'Travel',
      ExperienceCategory.safety: 'Safety',
      ExperienceCategory.food: 'Food',
    }[category]!;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_bn ? 'অভিজ্ঞতার মানচিত্র' : 'Expat Experience Map'),
        actions: [
          IconButton(
            tooltip: _bn ? 'অভিজ্ঞতা শেয়ার করুন' : 'Share experience',
            onPressed: _openPostForm,
            icon: const Icon(Icons.add_location_alt_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          _MapHero(isBangla: _bn),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ExperienceCategory.values
                .map(
                  (category) => ChoiceChip(
                    label: Text(_categoryLabel(category)),
                    selected: _category == category,
                    onSelected: (_) => setState(() => _category = category),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          Text(
            _bn ? 'এলাকার অভিজ্ঞতা' : 'Community experiences',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          for (final pin in _visiblePins)
            _ExperienceCard(pin: pin, isBangla: _bn),
          const SizedBox(height: 10),
          Card(
            color: scheme.surface,
            child: ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: Text(
                _bn ? 'নিরাপত্তা ও moderation' : 'Safety and moderation',
              ),
              subtitle: Text(
                _bn
                    ? 'পোস্ট প্রকাশের আগে পর্যালোচনা করা হবে। পাসপোর্ট, OTP বা exact address দেবেন না।'
                    : 'Submissions are reviewed before publishing. Never share passports, OTPs, or exact addresses.',
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openPostForm,
        icon: const Icon(Icons.add_location_alt_outlined),
        label: Text(_bn ? 'পোস্ট করুন' : 'Share experience'),
      ),
    );
  }
}

class _MapHero extends StatelessWidget {
  const _MapHero({required this.isBangla});
  final bool isBangla;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF06104E), Color(0xFF124B9B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _MapGridPainter())),
          const Positioned(
            left: 25,
            top: 22,
            child: Icon(Icons.explore_outlined, color: Colors.white, size: 30),
          ),
          Positioned(
            left: 25,
            top: 64,
            right: 24,
            child: Text(
              isBangla
                  ? 'প্রবাসীদের দেখা Malaysia'
                  : 'Malaysia through expat eyes',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Positioned(
            left: 25,
            bottom: 24,
            right: 25,
            child: Text(
              isBangla ? 'ঘোরা, থাকা, কাজ ও নিরাপত্তার বাস্তব অভিজ্ঞতা' : 'Real experiences about travel, work, stays, food and safety',
              style: const TextStyle(color: Color(0xFFD7E5FF), height: 1.35),
            ),
          ),
          const _MapPin(left: 72, top: 122, label: 'KL'),
          const _MapPin(left: 188, top: 103, label: 'IPOH'),
          const _MapPin(left: 262, top: 150, label: 'JB'),
          const _MapPin(left: 128, top: 176, label: 'MELAKA'),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.left, required this.top, required this.label});
  final double left;
  final double top;
  final String label;
  @override
  Widget build(BuildContext context) => Positioned(
    left: left,
    top: top,
    child: Column(
      children: [
        const Icon(Icons.location_on, color: Color(0xFFFFCC00), size: 28),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: .10)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 34) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y < size.height; y += 34) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final route = Paint()
      ..color = const Color(0xFF7CB8FF).withValues(alpha: .35)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(40, 185), Offset(size.width - 35, 88), route);
    canvas.drawLine(Offset(92, 95), Offset(size.width - 75, 188), route);
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) => false;
}

class _ExperiencePin {
  const _ExperiencePin({
    required this.area,
    required this.title,
    required this.summary,
    required this.category,
    required this.icon,
    required this.color,
  });
  final String area;
  final String title;
  final String summary;
  final ExperienceCategory category;
  final IconData icon;
  final Color color;
}

const _samplePins = <_ExperiencePin>[
  _ExperiencePin(
    area: 'Kuala Lumpur',
    title: 'City services and transport',
    summary: 'Good access to clinics, public transport, food and official services. Check the exact area before renting.',
    category: ExperienceCategory.travel,
    icon: Icons.location_city_rounded,
    color: Color(0xFF2C5AA0),
  ),
  _ExperiencePin(
    area: 'Johor Bahru',
    title: 'Border-city living',
    summary: 'Useful for people travelling between Malaysia and Singapore. Compare transport and accommodation costs.',
    category: ExperienceCategory.stay,
    icon: Icons.home_work_outlined,
    color: Color(0xFF9B5B2E),
  ),
  _ExperiencePin(
    area: 'Penang',
    title: 'Food and heritage routes',
    summary: 'Popular for food, culture and short visits. Save emergency and transport information before exploring.',
    category: ExperienceCategory.food,
    icon: Icons.restaurant_outlined,
    color: Color(0xFFB74B3C),
  ),
  _ExperiencePin(
    area: 'Melaka',
    title: 'Weekend travel experience',
    summary: 'A practical short-trip destination with heritage sites and family attractions.',
    category: ExperienceCategory.travel,
    icon: Icons.park_outlined,
    color: Color(0xFF277A5D),
  ),
  _ExperiencePin(
    area: 'Ipoh',
    title: 'Work and accommodation notes',
    summary: 'Community members can share verified area-level notes about work, rooms and daily services.',
    category: ExperienceCategory.work,
    icon: Icons.work_outline,
    color: Color(0xFF8A6E2F),
  ),
];

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({required this.pin, required this.isBangla});
  final _ExperiencePin pin;
  final bool isBangla;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      contentPadding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
      leading: CircleAvatar(
        backgroundColor: pin.color.withValues(alpha: .14),
        child: Icon(pin.icon, color: pin.color),
      ),
      title: Text(
        pin.title,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text('${pin.area}\n${pin.summary}'),
      ),
      isThreeLine: true,
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
          child: Text(
            isBangla
                ? 'এই অভিজ্ঞতা area-level community information। প্রকাশের আগে যাচাই করুন।'
                : 'This is area-level community information. Verify important details before acting.',
            style: const TextStyle(height: 1.5),
          ),
        ),
      ),
    ),
  );
}
