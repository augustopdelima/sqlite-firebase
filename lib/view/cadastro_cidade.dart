import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/cidade_viewmodel.dart';

class CadastroCidadePage extends StatefulWidget {
  final CidadeDTO? cidadeDTO;

  const CadastroCidadePage({super.key, this.cidadeDTO});

  @override
  State<CadastroCidadePage> createState() => _CadastroCidadePageState();
}

class _CadastroCidadePageState extends State<CadastroCidadePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.cidadeDTO?.nome ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = Provider.of<CidadeViewModel>(context, listen: false);

    try {
      if (widget.cidadeDTO == null) {
        await vm.adicionarCidade(nome: _nomeController.text.trim());
        _mostrarSnackBar('Cidade adicionada com sucesso!');
      } else {
        await vm.editarCidade(
          id: widget.cidadeDTO!.id!,
          nome: _nomeController.text.trim(),
        );
        _mostrarSnackBar('Cidade atualizada com sucesso!');
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      _mostrarSnackBar('Erro ao salvar cidade: $e');
    }
  }

  void _mostrarSnackBar(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cidadeDTO == null ? 'Nova Cidade' : 'Editar Cidade'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome da Cidade'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Informe o nome da cidade';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.save),
                label: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
