import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/certification_store.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/widgets/certification_scope.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Dimiliki oleh State agar tetap ada selama aplikasi berjalan.
  final _certificationStore = CertificationStore();

  @override
  void dispose() {
    _certificationStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CertificationScope(
      store: _certificationStore,
      child: MaterialApp(
        title: 'MyPortfolio',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            secondary: Colors.amber[700],
          ),
          useMaterial3: true,
        ),
        home: MyHomePage(),
      ),
    );
  }
}
