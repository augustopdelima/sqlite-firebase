import '../model/cidade.dart';
import '../db/db_helper.dart';
import 'interfaces/cidade.dart';

class CidadeRepository implements ICidadeRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<int> inserir(Cidade cidade) async {
    final db = await _dbHelper.database;
    return await db.insert('cidades', cidade.toMap());
  }

  @override
  Future<int> atualizar(Cidade cidade) async {
    final db = await _dbHelper.database;
    return await db.update(
      'cidades',
      cidade.toMap(),
      where: 'id = ?',
      whereArgs: [cidade.id],
    );
  }

  @override
  Future<int> excluir(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('cidades', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Cidade>> buscar({String filtro = ''}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = filtro.isEmpty
        ? await db.query('cidades', orderBy: 'nome')
        : await db.query(
            'cidades',
            where: 'nome LIKE ?',
            whereArgs: ['%$filtro%'],
            orderBy: 'nome',
          );
    return maps.map((m) => Cidade.fromMap(m)).toList();
  }
}
