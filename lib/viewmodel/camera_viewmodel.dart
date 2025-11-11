import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;

class CameraViewModel {
  late CameraController controller;
  bool inicializado = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Inicializa a câmera do dispositivo
  Future<void> inicializarCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(cameras.first, ResolutionPreset.medium);
    await controller.initialize();
    inicializado = true;
  }

  /// Captura uma foto e retorna o caminho do arquivo
  Future<String?> tirarFoto() async {
    if (!controller.value.isInitialized) return null;
    final foto = await controller.takePicture();
    return foto.path;
  }

  /// Salva uma foto no Firestore em formato Base64 (com compressão)
  Future<void> salvarNoFirestore({
    required String caminhoFoto,
    required String rotulo,
    required String clienteCodigo,
    int larguraMax = 200,
    int qualidade = 40,
  }) async {
    try {
      final bytesOriginais = await File(caminhoFoto).readAsBytes();
      final imagem = img.decodeImage(bytesOriginais);
      if (imagem == null) throw Exception('Falha ao decodificar imagem.');

      // Redimensiona mantendo proporção
      final imagemReduzida = img.copyResize(imagem, width: larguraMax);

      // Compressão JPEG
      final bytesComprimidos = img.encodeJpg(
        imagemReduzida,
        quality: qualidade,
      );

      final imagemBase64 = base64Encode(bytesComprimidos);

      await _firestore.collection('galeria').add({
        'imagem': imagemBase64,
        'rotulo': rotulo,
        'clienteCodigo': clienteCodigo,
        'data': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erro ao salvar imagem: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getGaleriaStream(
    String clienteCodigo,
  ) {
    return _firestore
        .collection('galeria')
        .where('clienteCodigo', isEqualTo: clienteCodigo)
        .orderBy('data', descending: true)
        .snapshots();
  }

  Uint8List? converterImagem(String? imagemBase64) {
    if (imagemBase64 == null) return null;
    try {
      return base64Decode(imagemBase64);
    } catch (_) {
      return null;
    }
  }

  /// Libera recursos da câmera
  void dispose() {
    if (inicializado) controller.dispose();
  }
}
