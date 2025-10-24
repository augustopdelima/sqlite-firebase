import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/cliente.dart';
import '../interfaces/cliente.dart';

class ClienteRepositoryFirebase implements IClienteRepository {
  final _collection = FirebaseFirestore.instance.collection('clientes');

  @override
  Future<int> inserir(Cliente cliente) async {
    await _collection.add(cliente.toMap());
    return 1;
  }

  @override
  Future<int> atualizar(Cliente cliente) async {
    if (cliente.codigo == null) return 0;
    await _collection.doc(cliente.codigo.toString()).update(cliente.toMap());
    return 1;
  }

  @override
  Future<int> excluir(int codigo) async {
    await _collection.doc(codigo.toString()).delete();
    return 1;
  }

  @override
  Future<List<Cliente>> buscar({String filtro = ''}) async {
    final query = filtro.isEmpty
        ? await _collection.get()
        : await _collection.where('nome', isGreaterThanOrEqualTo: filtro).get();

    return query.docs
        .map((d) => Cliente.fromMap({...d.data(), 'codigo': d.id}))
        .toList();
  }
}
