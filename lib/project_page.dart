import 'package:flutter/material.dart';

// Data satu proyek pada daftar proyek.
class _Project {
  final String title;
  final String description;
  final IconData icon;

  const _Project(this.title, this.description, this.icon);
}

// Halaman tujuan tombol "Lihat Proyek": menampilkan daftar proyek.
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
        // foregroundColor juga mewarnai tombol kembali pada AppBar.
        foregroundColor: Colors.white,
      ),
      body: Center(
        // Membatasi lebar konten agar tetap nyaman dibaca di layar lebar.
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

// Halaman tujuan tombol "Tambah Proyek": tampilan formulir.
// Penyimpanan data belum dibuat, jadi tombol Simpan hanya menampilkan SnackBar.
class AddProjectPage extends StatelessWidget {
  const AddProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Proyek',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Nama Proyek',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              const TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Fitur menyimpan proyek akan dibuat di tugas berikutnya.',
                        ),
                      ),
                    );
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
