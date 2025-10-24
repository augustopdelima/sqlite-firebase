import 'package:flutter/material.dart';
import '../model/cidade.dart';
import '../repository/cidade_repository.dart';

// DTO (Data Transfer Object) para expor dados formatados à View
// A View NÃO deve acessar o Model diretamente
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

// ViewModel que expõe dados e ações para as Views (usa ChangeNotifier para MVVM reativo)
class CidadeViewModel extends ChangeNotifier {
  // Repositório de dados (injeção simples via construtor)
 final CidadeRepositoryAdapter _repository = CidadeRepositoryAdapter();

  List<Cidade> _cidades = [];
  String _ultimoFiltro = '';

  // Lista pública de DTOs que a View irá observar
  List<CidadeDTO> get cidades =>
      _cidades.map((c) => CidadeDTO.fromModel(c)).toList();

  CidadeViewModel() {
    loadCidades();
  }

  /
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
