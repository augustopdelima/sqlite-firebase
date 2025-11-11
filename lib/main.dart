import 'package:exdb/firebase_options.dart';
import 'package:exdb/repository/adapter/cidade_adapter.dart';
import './viewmodel/auth_viewmodel.dart';
import 'package:exdb/view/lista_cliente.dart';
import 'package:exdb/view/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'repository/adapter/cliente_adapter.dart';
import 'services/settings.dart';
import 'viewmodel/cliente_viewmodel.dart';
import 'viewmodel/cidade_viewmodel.dart';
import 'db/db_helper.dart';
import 'package:firebase_core/firebase_core.dart';

// Ponto de entrada da aplicação
Future<void> main() async {
  // Garante que plugins nativos estejam inicializados antes de usar path_provider/sqflite
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // (Opcional) Inicializa o banco explicitamente para evitar atrasos na primeira operação
  await DatabaseHelper.instance.database;

  final settings = SettingsPreferences();

  final clienteRepo = await ClienteRepositoryAdapter.create(settings);

  final clienteVM = ClienteViewModel.withRepository(clienteRepo);

  final cidadeRepo = await CidadeRepositoryAdapter.create(settings);

  final cidadeVM = CidadeViewModel.withRepository(cidadeRepo);

  // Executa o app dentro de um Provider que injeta o ViewModel (MVVM)
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => settings),
        ChangeNotifierProvider(create: (_) => clienteVM),
        ChangeNotifierProvider(create: (_) => cidadeVM),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

// Widget raiz da aplicação
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de Clientes (MVVM + SQLite)',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthViewModel>(context);

    if (auth.isLoggedIn) {
      return const ListaClientesPage();
    } else {
      return const LoginPage();
    }
  }
}
