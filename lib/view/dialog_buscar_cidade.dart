import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/cidade_viewmodel.dart';
import 'cadastro_cidade.dart';

class DialogBuscaCidade extends StatefulWidget {
  const DialogBuscaCidade({super.key});

  @override
  State<DialogBuscaCidade> createState() => _DialogBuscaCidadeState();
}

class _DialogBuscaCidadeState extends State<DialogBuscaCidade> {
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
    // Aqui listen: true → diálogo será reconstruído quando cidades mudarem
    final vm = Provider.of<CidadeViewModel>(context);

    final cidadesFiltradas = vm.cidades
        .map((c) => c.nome)
        .where((nome) => nome.toLowerCase().contains(_filtro.toLowerCase()))
        .toList();

    return AlertDialog(
      title: const Text('Buscar Cidade'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _buscaController,
            decoration: const InputDecoration(
              labelText: 'Digite o nome da cidade',
              suffixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() => _filtro = value);
            },
          ),
          TextButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CadastroCidadePage(),
                ),
              );
              // Como listen:true, ao salvar uma cidade e chamar notifyListeners(),
              // este diálogo será atualizado automaticamente.
            },
            child: const Text('Adicionar cidade'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
