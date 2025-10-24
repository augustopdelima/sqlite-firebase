import '../../../model/cliente.dart';
import '../interfaces/cliente.dart';
import '../cliente_repository.dart';
import '../firebase/cliente_repository_firebase.dart';
import '../../../services/preferences.dart';

class ClienteRepositoryAdapter implements IClienteRepository {
  late final IClienteRepository _repo;

  ClienteRepositoryAdapter._(this._repo);

  static Future<ClienteRepositoryAdapter> create() async {
    final useFirebase = await PreferencesService.getUseFirebase();
    final repo = useFirebase
        ? ClienteRepositoryFirebase()
        : ClienteRepository();
    return ClienteRepositoryAdapter._(repo);
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
