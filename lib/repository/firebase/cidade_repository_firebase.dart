import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/cidade.dart';
import '../interfaces/cidade.dart';

class CidadeRepositoryFirebase implements ICidadeRepository {
  final CollectionReference _collection = FirebaseFirestore.instance.collection(
    'cidades',
  );

  @override
  Future<int> inserir(Cidade cidade) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    cidade.id = id;
    await _collection.doc(id.toString()).set(cidade.toMap());
    return 1;
  }

  @override
  Future<int> atualizar(Cidade cidade) async {
    if (cidade.id == null) return 0;
    await _collection.doc(cidade.id.toString()).update(cidade.toMap());
    return 1;
  }

  @override
  Future<int> excluir(int id) async {
    await _collection.doc(id.toString()).delete();
    return 1;
  }

  @override
  Future<List<Cidade>> buscar({String filtro = ''}) async {
    QuerySnapshot snapshot;
    if (filtro.isEmpty) {
      snapshot = await _collection.get();
    } else {
      snapshot = await _collection
          .where('nome', isGreaterThanOrEqualTo: filtro)
          .where('nome', isLessThanOrEqualTo: filtro + '\uf8ff')
          .get();
    }

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Cidade.fromMap(data)..id = int.tryParse(doc.id);
    }).toList();
  }
}
