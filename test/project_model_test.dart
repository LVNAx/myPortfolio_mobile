import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/models/project.dart';

// Contoh respons nyata dari ProjectSerializer pada backend Django.
const Map<String, dynamic> apiPayload = {
  'id': '7f0c1d3e-1111-4222-8333-444455556666',
  'title': 'Website Portofolio',
  'role': 'Full-stack developer',
  'category': 'web',
  'category_display': 'Web Development',
  'description': 'Website portofolio pribadi.',
  'highlights': 'Memakai Django\nMemakai DRF',
  'highlight_list': ['Memakai Django', 'Memakai DRF'],
  'tech_stack': 'Django, HTML, CSS',
  'thumbnail_url': '/static/img/portfolio.png',
  'live_url': 'https://example.com',
  'github_url': 'https://github.com/example/repo',
  'started_at': '2026-01-10',
  'ended_at': null,
  'is_ongoing': true,
  'star_count': 3,
  'is_starred': false,
  'starred_by_names': ['a', 'b', 'c'],
};

void main() {
  group('Project.fromJson', () {
    test('memetakan kunci snake_case ke properti camelCase', () {
      final project = Project.fromJson(apiPayload);

      expect(project.id, '7f0c1d3e-1111-4222-8333-444455556666');
      expect(project.title, 'Website Portofolio');
      expect(project.role, 'Full-stack developer');
      expect(project.category, 'web');
      expect(project.categoryDisplay, 'Web Development');
      expect(project.techStack, 'Django, HTML, CSS');
      expect(project.thumbnailUrl, '/static/img/portfolio.png');
      expect(project.liveUrl, 'https://example.com');
      expect(project.githubUrl, 'https://github.com/example/repo');
      expect(project.startedAt, '2026-01-10');
      expect(project.endedAt, isNull);
      expect(project.isOngoing, isTrue);
    });

    test('field opsional yang hilang atau null memakai nilai bawaan', () {
      final project = Project.fromJson({
        'title': 'Minimal',
        'role': 'Dev',
        'category': 'course',
        'description': 'Deskripsi',
        'tech_stack': 'Dart',
        'started_at': '2026-02-01',
        'live_url': null,
      });

      expect(project.id, isNull);
      expect(project.liveUrl, '');
      expect(project.githubUrl, '');
      expect(project.highlights, '');
      expect(project.thumbnailUrl, '');
      expect(project.categoryDisplay, '');
    });

    test('abaikan field read-only yang tidak dipakai klien', () {
      expect(() => Project.fromJson(apiPayload), returnsNormally);
    });
  });

  group('Project.toJson', () {
    test('tidak mengirim id dan field read-only milik server', () {
      final json = Project.fromJson(apiPayload).toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('category_display'), isFalse);
      expect(json.containsKey('thumbnail_url'), isFalse);
    });

    test('memakai kunci snake_case sesuai API', () {
      final json = Project.fromJson(apiPayload).toJson();

      expect(json['tech_stack'], 'Django, HTML, CSS');
      expect(json['live_url'], 'https://example.com');
      expect(json['github_url'], 'https://github.com/example/repo');
      expect(json['started_at'], '2026-01-10');
    });

    test('ended_at dihilangkan saat proyek masih berjalan', () {
      final ongoing = Project.fromJson(apiPayload).toJson();
      expect(ongoing.containsKey('ended_at'), isFalse);

      final finished = Project.fromJson({
        ...apiPayload,
        'ended_at': '2026-03-01',
      }).toJson();
      expect(finished['ended_at'], '2026-03-01');
    });
  });

  group('Project turunan', () {
    test('techList memangkas spasi dan membuang elemen kosong', () {
      const project = Project(
        title: 't',
        role: 'r',
        category: 'web',
        description: 'd',
        techStack: ' Flutter , Django,, ',
        startedAt: '2026-01-01',
      );
      expect(project.techList, ['Flutter', 'Django']);
    });

    test('highlightList memecah per baris dan membuang baris kosong', () {
      const project = Project(
        title: 't',
        role: 'r',
        category: 'web',
        description: 'd',
        techStack: 'x',
        startedAt: '2026-01-01',
        highlights: 'Satu\n\n  Dua  \n',
      );
      expect(project.highlightList, ['Satu', 'Dua']);
    });
  });
}
