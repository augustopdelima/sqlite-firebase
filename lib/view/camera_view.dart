import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../viewmodel/camera_viewmodel.dart';
import '../viewmodel/cliente_viewmodel.dart';
import 'dart:typed_data';

class CameraView extends StatefulWidget {
  final ClienteDTO clienteDTO;
  const CameraView({super.key, required this.clienteDTO});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final CameraViewModel _viewModel = CameraViewModel();
  final TextEditingController _rotuloController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    await _viewModel.inicializarCamera();
    setState(() {});
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _rotuloController.dispose();
    super.dispose();
  }

  Future<void> _tirarFoto() async {
    final caminho = await _viewModel.tirarFoto();
    if (caminho == null) return;

    final rotulo = await _mostrarDialogRotulo();
    if (rotulo.isEmpty) return;

    await _viewModel.salvarNoFirestore(
      caminhoFoto: caminho,
      rotulo: rotulo,
      clienteCodigo: widget.clienteDTO.codigo.toString(),
    );
  }

  Future<String> _mostrarDialogRotulo() async {
    _rotuloController.clear();
    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Adicionar rótulo"),
          content: TextField(
            controller: _rotuloController,
            decoration: const InputDecoration(hintText: "Digite uma descrição"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ""),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, _rotuloController.text),
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    ).then((value) => value ?? "");
  }

  @override
  Widget build(BuildContext context) {
    if (!_viewModel.inicializado) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Câmera - ${widget.clienteDTO.nome}'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: _viewModel.controller.value.aspectRatio,
            child: CameraPreview(_viewModel.controller),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text("Tirar Foto"),
            onPressed: _tirarFoto,
          ),
          const Divider(height: 32),
          Text(
            "Galeria de ${widget.clienteDTO.nome}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder(
              stream: _viewModel.getGaleriaStream(
                widget.clienteDTO.codigo.toString(),
              ),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("Nenhuma imagem salva ainda."),
                  );
                }

                // Corrigido: tipando corretamente os docs
                final docs = snapshot.data!.docs
                    .map<Map<String, dynamic>>(
                      (doc) => doc.data() as Map<String, dynamic>,
                    )
                    .toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index];
                    final rotulo = data['rotulo'] ?? 'Sem rótulo';
                    final Uint8List? imagemBytes = _viewModel.converterImagem(
                      data['imagem'],
                    );

                    if (imagemBytes == null) {
                      return const Center(
                        child: Text("Erro ao carregar imagem"),
                      );
                    }

                    return GridTile(
                      footer: Container(
                        color: Colors.black54,
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          rotulo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      child: Image.memory(imagemBytes, fit: BoxFit.cover),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
