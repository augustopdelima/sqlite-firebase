class Cidade {
  int? id;
  String nome;

  Cidade({this.id, required this.nome});

  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome};
  }

  factory Cidade.fromMap(Map<String, dynamic> map) {
    return Cidade(id: map['id'], nome: map['nome']);
  }
}
