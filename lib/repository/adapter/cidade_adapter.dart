import 'package:exdb/services/settings.dart';
import '../../model/cidade.dart';
import '../interfaces/cidade.dart';
import '../cidade_repository.dart';
import '../firebase/cidade_repository_firebase.dart';

class CidadeRepositoryAdapter implements ICidadeRepository {
  late ICidadeRepository _repo;
  final SettingsPreferences _settings;

  CidadeRepositoryAdapter._(this._settings) {
    _updateRepository(_settings.useFirebase);

    _settings.addListener(_onSettingsChanged);
  }

  static Future<CidadeRepositoryAdapter> create(
    SettingsPreferences settings,
  ) async {
    return CidadeRepositoryAdapter._(settings);
  }

  void _onSettingsChanged() {
    final useFirebase = _settings.useFirebase;

    _updateRepository(useFirebase);
  }

  void _updateRepository(bool useFirebase) {
    _repo = useFirebase ? CidadeRepositoryFirebase() : CidadeRepository();
  }

  void dispose() {
    _settings.removeListener(_onSettingsChanged);
  }

  @override
  Future<int> inserir(Cidade cidade) => _repo.inserir(cidade);

  @override
  Future<int> atualizar(Cidade cidade) => _repo.atualizar(cidade);

  @override
  Future<int> excluir(int id) => _repo.excluir(id);

  @override
  Future<List<Cidade>> buscar({String filtro = ''}) =>
      _repo.buscar(filtro: filtro);
}
