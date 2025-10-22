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
  final CidadeRepository _repository;

  // Lista interna de clientes (Model) - privada
  List<Cidade> _cidades = [];

  // Lista pública de DTOs que a View irá observar
  List<CidadeDTO> get cidades =>
      _cidades.map((c) => CidadeDTO.fromModel(c)).toList();

  // Último filtro usado (para manter a lista consistente ao voltar da tela de edição)
  String _ultimoFiltro = '';

  // Construtor recebe o repositório
  CidadeViewModel(this._repository) {
    // Ao construir o ViewModel, carregamos a lista inicial
    loadCidades();
  }

  // Carrega clientes do repositório com filtro opcional
  Future<void> loadCidades([String filtro = '']) async {
    // Guarda o filtro atual
    _ultimoFiltro = filtro;
    // Busca no repositório
    _cidades = await _repository.buscar(filtro: filtro);
    // Notifica listeners (Views que usam Provider/Consumer serão atualizadas)
    notifyListeners();
  }

  // Adiciona um cliente (recebe dados primitivos da View)
  Future<void> adicionarCidade({required String nome}) async {
    final cidade = Cidade(nome: nome);
    await _repository.inserir(cidade);
    // Recarrega a lista com o último filtro aplicado
    await loadCidades(_ultimoFiltro);
  }

  // Atualiza um cliente (recebe dados primitivos da View)
  Future<void> editarCidade({required int id, required String nome}) async {
    final cidade = Cidade(id: id, nome: nome);
    await _repository.atualizar(cidade);
    await loadCidades(_ultimoFiltro);
  }

  // Remove um cliente pelo código
  Future<void> removerCliente(int codigo) async {
    await _repository.excluir(codigo);
    await loadCidades(_ultimoFiltro);
  }
}
