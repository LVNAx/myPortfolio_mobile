import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

// Halaman formulir untuk menambah proyek.
// StatefulWidget dipakai karena halaman ini menyimpan data yang berubah
// (isian pengguna) dan harus menggambar ulang lewat setState().
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  // Kunci untuk mengakses state Form (validasi dan reset).
  final _formKey = GlobalKey<FormState>();

  // Variabel penampung isian dari tiap field.
  String _projectName = "";
  String _description = "";
  String _category = "Web Development"; // default
  String _technologies = "";
  String _projectLink = "";

  final List<String> _categories = [
    'Web Development',
    'Mobile Development',
    'Machine Learning',
    'Data Science',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Project Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      // Drawer yang sama dengan halaman utama, agar navigasi tetap tersedia.
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        // SingleChildScrollView: form bisa di-scroll bila layar tidak muat.
        child: SingleChildScrollView(
          // Center + ConstrainedBox membatasi lebar form di layar lebar.
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === Project Name ===
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: "Nama Proyek",
                        labelText: "Nama Proyek",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      // onChanged dijalankan tiap isi field berubah.
                      onChanged: (String? value) {
                        setState(() {
                          _projectName = value!;
                        });
                      },
                      // validator mengembalikan pesan error bila input tidak valid.
                      validator: (String? value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Nama proyek tidak boleh kosong!";
                        }
                        return null;
                      },
                    ),
                  ),

                  // === Description ===
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Deskripsi Proyek",
                        labelText: "Deskripsi Proyek",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          _description = value!;
                        });
                      },
                      validator: (String? value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Deskripsi proyek tidak boleh kosong!";
                        }
                        return null;
                      },
                    ),
                  ),

                  // === Category ===
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Kategori Proyek",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      // initialValue menggantikan properti value yang deprecated.
                      initialValue: _category,
                      items: _categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _category = newValue!;
                        });
                      },
                    ),
                  ),

                  // === Technologies ===
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: "Contoh: Flutter, Django, Figma",
                        labelText: "Teknologi yang Digunakan",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          _technologies = value!;
                        });
                      },
                    ),
                  ),

                  // === Project Link ===
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: "URL Proyek (opsional)",
                        labelText: "Tautan Proyek",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      onChanged: (String? value) {
                        setState(() {
                          _projectLink = value!;
                        });
                      },
                    ),
                  ),

                  // === Tombol Simpan ===
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            Colors.indigo,
                          ),
                        ),
                        onPressed: () {
                          // validate() menjalankan semua validator pada form.
                          if (_formKey.currentState!.validate()) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text(
                                    'Proyek berhasil ditambahkan!',
                                  ),
                                  // Menampilkan seluruh isian formulir.
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Nama Proyek: $_projectName'),
                                        Text('Deskripsi: $_description'),
                                        Text('Kategori: $_category'),
                                        Text('Teknologi: $_technologies'),
                                        Text('Tautan: $_projectLink'),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        // Menutup dialog, lalu mengosongkan form.
                                        Navigator.pop(context);
                                        _formKey.currentState!.reset();
                                        // reset() hanya mengosongkan tampilan field,
                                        // jadi variabel teks ikut dikosongkan agar
                                        // isian lama tidak muncul di dialog berikutnya.
                                        setState(() {
                                          _projectName = "";
                                          _description = "";
                                          _technologies = "";
                                          _projectLink = "";
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: const Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
