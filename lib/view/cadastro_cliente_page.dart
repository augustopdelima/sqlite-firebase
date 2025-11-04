import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/cliente_viewmodel.dart';
import './dialog_buscar_cidade.dart'; // importa o novo componente

class CadastroClientePage extends StatefulWidget {
  final ClienteDTO? clienteDTO;
  const CadastroClientePage({super.key, this.clienteDTO});

  @override
  State<CadastroClientePage> createState() => _CadastroClientePageState();
}

class _CadastroClientePageState extends State<CadastroClientePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _cpfController;
  late TextEditingController _nomeController;
  late TextEditingController _idadeController;
  late TextEditingController _dataNascimentoController;
  late TextEditingController _cidadeController;

  @override
  void initState() {
    super.initState();
    _cpfController = TextEditingController(text: widget.clienteDTO?.cpf ?? '');
    _nomeController = TextEditingController(
      text: widget.clienteDTO?.nome ?? '',
    );
    _idadeController = TextEditingController(
      text: widget.clienteDTO?.idade ?? '',
    );
    _dataNascimentoController = TextEditingController(
      text: widget.clienteDTO?.dataNascimento ?? '',
    );
    _cidadeController = TextEditingController(
      text: widget.clienteDTO?.cidadeNascimento ?? '',
    );
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _nomeController.dispose();
    _idadeController.dispose();
    _dataNascimentoController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = Provider.of<ClienteViewModel>(context, listen: false);

    if (widget.clienteDTO == null) {
      await vm.adicionarCliente(
        cpf: _cpfController.text.trim(),
        nome: _nomeController.text.trim(),
        idade: _idadeController.text.trim(),
        dataNascimento: _dataNascimentoController.text.trim(),
        cidadeNascimento: _cidadeController.text.trim(),
      );
    } else {
      await vm.editarCliente(
        codigo: widget.clienteDTO!.codigo!,
        cpf: _cpfController.text.trim(),
        nome: _nomeController.text.trim(),
        idade: _idadeController.text.trim(),
        dataNascimento: _dataNascimentoController.text.trim(),
        cidadeNascimento: _cidadeController.text.trim(),
      );
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _abrirBuscaCidadeModal() async {
    final cidadeSelecionada = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const BuscaCidadeModal(),
    );

    if (cidadeSelecionada != null && mounted) {
      setState(() {
        _cidadeController.text = cidadeSelecionada;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.clienteDTO == null ? 'Novo Cliente' : 'Editar Cliente',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _cpfController,
                decoration: const InputDecoration(labelText: 'CPF'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe o CPF' : null,
              ),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe o nome' : null,
              ),
              TextFormField(
                controller: _idadeController,
                decoration: const InputDecoration(labelText: 'Idade'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe a idade' : null,
              ),
              TextFormField(
                controller: _dataNascimentoController,
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento',
                ),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Informe a data de nascimento'
                    : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cidadeController,
                      decoration: const InputDecoration(
                        labelText: 'Cidade de Nascimento',
                      ),
                      enabled: false,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _abrirBuscaCidadeModal,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}
