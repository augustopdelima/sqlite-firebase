import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/cliente.dart';
import '../interfaces/cliente.dart';

class ClienteRepositoryFirebase implements IClienteRepository {
  final _collection = FirebaseFirestore.instance.collection('clientes');

  @override
  Future<int> inserir(Cliente cliente) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    cliente.codigo = id;

    await _collection.doc(id.toString()).set(cliente.toMap());
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
    QuerySnapshot query;

    if (filtro.isEmpty) {
      query = await _collection.get();
    } else {
      query = await _collection
          .where('nome', isGreaterThanOrEqualTo: filtro)
          .where('nome', isLessThanOrEqualTo: '$filtro\uf8ff')
          .get();
    }

    return query.docs.map((d) {
      final data = d.data() as Map<String, dynamic>;
      return Cliente.fromMap({...data, 'codigo': int.tryParse(d.id) ?? 0});
    }).toList();
  }
}
