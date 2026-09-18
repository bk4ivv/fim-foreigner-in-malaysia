import 'package:flutter_test/flutter_test.dart';
import 'package:expat_status_checker/community_portal.dart';

void main() {
  test('migrates a legacy avatar into the gallery as the first photo', () {
    expect(
      normalizeProfileGallery(
        const <dynamic>[],
        legacyAvatar: 'https://cdn.example/avatar.jpg',
      ),
      ['https://cdn.example/avatar.jpg'],
    );
  });

  test('deduplicates, trims, and caps profile gallery paths', () {
    final paths = normalizeProfileGallery([
      ' first ',
      'first',
      'second',
      '',
      'third',
      'fourth',
      'fifth',
      'sixth',
      'seventh',
    ]);

    expect(paths, ['first', 'second', 'third', 'fourth', 'fifth', 'sixth']);
    expect(paths, hasLength(maxProfileGalleryPhotos));
  });

  test('ignores malformed gallery values and blank legacy avatars', () {
    expect(
      normalizeProfileGallery([
        'https://one.example/photo.jpg',
        42,
        null,
        '   ',
      ], legacyAvatar: '  '),
      ['https://one.example/photo.jpg'],
    );
  });
}
