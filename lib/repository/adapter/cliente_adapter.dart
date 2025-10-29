import '../../../model/cliente.dart';
import '../../services/settings.dart';
import '../interfaces/cliente.dart';
import '../cliente_repository.dart';
import '../firebase/cliente_repository_firebase.dart';

class ClienteRepositoryAdapter implements IClienteRepository {
  late IClienteRepository _repo;
  final SettingsPreferences _settings;

  ClienteRepositoryAdapter._(this._settings) {
    _updateRepository(_settings.useFirebase);

    _settings.addListener(_onSettingsChanged);
  }

  static Future<ClienteRepositoryAdapter> create(
    SettingsPreferences settings,
  ) async {
    return ClienteRepositoryAdapter._(settings);
  }

  void _onSettingsChanged() {
    final useFirebase = _settings.useFirebase;

    _updateRepository(useFirebase);
  }

  void _updateRepository(bool useFirebase) {
    _repo = useFirebase ? ClienteRepositoryFirebase() : ClienteRepository();
  }

  void dispose() {
    _settings.removeListener(_onSettingsChanged);
  }

  @override
  Future<int> inserir(Cliente cliente) => _repo.inserir(cliente);

  @override
  Future<int> atualizar(Cliente cliente) => _repo.atualizar(cliente);

  @override
  Future<int> excluir(int codigo) => _repo.excluir(codigo);

  @override
  Future<List<Cliente>> buscar({String filtro = ''}) =>
      _repo.buscar(filtro: filtro);
}
