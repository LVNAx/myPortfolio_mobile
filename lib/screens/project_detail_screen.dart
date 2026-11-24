import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:provider/provider.dart';

/// Detail sebuah proyek. Gambar hanya ditampilkan bila server mengirim URL-nya.
class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.project, super.key});

  final Project project;

  String get _category => project.categoryDisplay.isNotEmpty
      ? project.categoryDisplay
      : project.category;

  String get _period =>
      '${project.startedAt} - ${project.endedAt ?? 'Present'}';

  Widget _section(BuildContext context, String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final apiClient = context.read<ApiClient>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          project.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (project.thumbnailUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    apiClient.resolveUrl(project.thumbnailUrl),
                    height: 200,
                    fit: BoxFit.cover,
                    // Placeholder berukuran tetap saat gambar gagal dimuat.
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(
                          height: 200,
                          child: Center(
                            child: Icon(Icons.broken_image_outlined, size: 48),
                          ),
                        ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  project.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Text('${project.role} - $_category'),
              Text(_period),
              _section(context, 'Description', Text(project.description)),
              if (project.highlightList.isNotEmpty)
                _section(
                  context,
                  'Highlights',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final highlight in project.highlightList)
                        Text('• $highlight'),
                    ],
                  ),
                ),
              _section(
                context,
                'Tech Stack',
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final tech in project.techList)
                      Chip(label: Text(tech)),
                  ],
                ),
              ),
              if (project.liveUrl.isNotEmpty)
                _section(context, 'Live URL', SelectableText(project.liveUrl)),
              if (project.githubUrl.isNotEmpty)
                _section(context, 'GitHub', SelectableText(project.githubUrl)),
            ],
          ),
        ),
      ),
    );
  }
}
