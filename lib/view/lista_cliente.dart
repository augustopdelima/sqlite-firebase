import 'dart:async'; // Importar para usar Timer

import 'package:exdb/components/shared_switch.dart';
import 'package:exdb/viewmodel/auth_viewmodel.dart';
import 'package:exdb/view/camera_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/cliente_viewmodel.dart';
import 'cadastro_cliente_page.dart';

// Tela que exibe a lista e o campo de pesquisa (View)
class ListaClientesPage extends StatefulWidget {
  const ListaClientesPage({super.key});

  @override
  State<ListaClientesPage> createState() => _ListaClientesPageState();
}

class _ListaClientesPageState extends State<ListaClientesPage> {
  final TextEditingController _searchController = TextEditingController();

  // 1. Variável para controlar o debounce (o atraso na pesquisa)
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // 2. Carrega a lista de clientes na inicialização, se estiver vazia.
    // Usamos addPostFrameCallback para garantir que o 'context' esteja disponível.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClienteViewModel>(context, listen: false).loadClientes('');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel(); // 3. Cancela o Timer no dispose
    super.dispose();
  }

  // 4. Nova função para a lógica de pesquisa com Debounce
  void _onSearchChanged(String query, ClienteViewModel vm) {
    // Cancela o timer anterior se ele existir
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Cria um novo timer para executar a pesquisa após 500ms
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await vm.loadClientes(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Observe que a ViewModel é acessada antes do build (no _onSearchChanged), mas
    // aqui ela é acessada para acionar a reconstrução quando os dados mudam.
    final vm = Provider.of<ClienteViewModel>(context);
    final auth = Provider.of<AuthViewModel>(context);

    final user = auth.user;
    final nome = user?.displayName ?? 'usuário';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes (MVVM + SQLite)'),
        actions: [
          // Botão adicionar cliente
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CadastroClientePage()),
              );
              // Recarrega a lista após o cadastro/edição
              await vm.loadClientes(_searchController.text);
            },
          ),
          // Botão sair (logout)
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await auth.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Saudação ao usuário logado (Não precisa de alteração)
          Container(
            width: double.infinity,
            color: Colors.blue.shade50,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Olá, $nome",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const PreferencesSwitch(), // Assumindo que é o seu widget
          // Campo de pesquisa
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Pesquisar por nome',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              // 5. Usa a função de Debounce aqui
              onChanged: (value) {
                _onSearchChanged(value, vm);
              },
            ),
          ),

          // Lista de clientes
          Expanded(
            child: vm.clientes.isEmpty
                ? const Center(child: Text('Nenhum cliente encontrado'))
                : ListView.builder(
                    itemCount: vm.clientes.length,
                    itemBuilder: (context, index) {
                      final dto = vm.clientes[index];
                      // ... (Restante do ListTile)
                      return ListTile(
                        title: Text(dto.nome),
                        subtitle: Text(dto.subtitulo),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CadastroClientePage(clienteDTO: dto),
                                  ),
                                );
                                await vm.loadClientes(_searchController.text);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.camera),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CameraView(clienteDTO: dto),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await vm.removerCliente(dto.codigo!);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
