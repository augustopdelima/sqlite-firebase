import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/cidade_viewmodel.dart';
import 'cadastro_cidade.dart';

class BuscaCidadeModal extends StatefulWidget {
  const BuscaCidadeModal({super.key});

  @override
  State<BuscaCidadeModal> createState() => _BuscaCidadeModalState();
}

class _BuscaCidadeModalState extends State<BuscaCidadeModal> {
  late TextEditingController _buscaController;
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    _buscaController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CidadeViewModel>(context, listen: false).loadCidades('');
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CidadeViewModel>(context);
    final cidadesFiltradas = vm.cidades
        .map((c) => c.nome)
        .where((nome) => nome.toLowerCase().contains(_filtro.toLowerCase()))
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Text(
            'Buscar Cidade',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _buscaController,
            decoration: const InputDecoration(
              labelText: 'Digite o nome da cidade',
              suffixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => setState(() => _filtro = value),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CadastroCidadePage()),
              );
              vm.loadCidades('');
            },
            child: const Text('Adicionar cidade'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 250,
            child: ListView.builder(
              itemCount: cidadesFiltradas.length,
              itemBuilder: (context, index) {
                final cidade = cidadesFiltradas[index];
                return ListTile(
                  title: Text(cidade),
                  onTap: () => Navigator.pop(context, cidade),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
