import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/certification_store.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/certification_scope.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp(apiClient: ApiClient()));
}

class MyApp extends StatefulWidget {
  const MyApp({required this.apiClient, super.key});

  final ApiClient apiClient;

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
    // MultiProvider menyisipkan objek yang sering dipakai (API client dan
    // state autentikasi) ke widget tree sehingga bisa diambil di layar mana
    // pun lewat context.read atau context.watch.
    return MultiProvider(
      providers: [
        Provider.value(value: widget.apiClient),
        ChangeNotifierProvider(create: (_) => AuthState(widget.apiClient)),
      ],
      child: CertificationScope(
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
      ),
    );
  }
}
