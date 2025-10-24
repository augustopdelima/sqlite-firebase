import 'package:flutter/material.dart';
import '../model/cidade.dart';
import '../repository/adapter/cidade_adapter.dart';

class CidadeDTO {
  final int? id;
  final String nome;
  // Dado formatado para exibição

  CidadeDTO({required this.id, required this.nome});

  // Converte Model para DTO
  factory CidadeDTO.fromModel(Cidade cidade) {
    return CidadeDTO(id: cidade.id, nome: cidade.nome);
  }

  // Converte DTO para Model
  Cidade toModel() {
    return Cidade(id: id, nome: nome);
  }
}

class CidadeViewModel extends ChangeNotifier {
  final CidadeRepositoryAdapter _repository;

  List<Cidade> _cidades = [];
  String _ultimoFiltro = '';

  List<CidadeDTO> get cidades =>
      _cidades.map((c) => CidadeDTO.fromModel(c)).toList();

  CidadeViewModel.withRepository(this._repository) {
    loadCidades();
  }

  Future<void> loadCidades([String filtro = '']) async {
    _ultimoFiltro = filtro;
    _cidades = await _repository.buscar(filtro: filtro);
    notifyListeners();
  }

  Future<void> adicionarCidade({required String nome}) async {
    final cidade = Cidade(nome: nome);
    await _repository.inserir(cidade);
    await loadCidades(_ultimoFiltro);
  }

  Future<void> editarCidade({required int id, required String nome}) async {
    final cidade = Cidade(id: id, nome: nome);
    await _repository.atualizar(cidade);
    await loadCidades(_ultimoFiltro);
  }

  Future<void> removerCidade(int id) async {
    await _repository.excluir(id);
    await loadCidades(_ultimoFiltro);
  }
}
