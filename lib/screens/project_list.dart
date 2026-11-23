import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Data satu proyek pada daftar proyek.
class _Project {
  final String title;
  final String description;
  final IconData icon;

  const _Project(this.title, this.description, this.icon);
}

/// Halaman daftar proyek.
class ProjectListPage extends StatelessWidget {
  const ProjectListPage({super.key});

  static const List<_Project> _projects = [
    _Project(
      'Website Portofolio (Django)',
      'Website portofolio pribadi dengan Django, HTML, dan CSS.',
      Icons.language,
    ),
    _Project(
      'Aplikasi Mobile Portofolio (Flutter)',
      'Aplikasi mobile portofolio ini, dibangun bertahap tiap minggu.',
      Icons.phone_android,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lihat Proyek',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: _projects.map((project) {
              return Card(
                child: ListTile(
                  leading: Icon(project.icon),
                  title: Text(
                    project.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(project.description),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
