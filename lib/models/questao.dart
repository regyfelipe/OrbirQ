class Questao {
  final String id;
  final String professorId;
  final String disciplina;
  final String assunto;
  final String pergunta;
  final List<String> alternativas;
  final String resposta;
  final String? explicacao;
  final String? banca;
  final String? ano;
  final String? imagemPath;
  final bool isInedita;
  final String? autor;
  final String? textoApoio;
  final bool isPublic;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? orgao;

  Questao({
    required this.id,
    required this.professorId,
    required this.disciplina,
    required this.assunto,
    required this.pergunta,
    required this.alternativas,
    required this.resposta,
    this.explicacao,
    this.banca,
    this.ano,
    this.imagemPath,
    this.isInedita = false,
    this.autor,
    this.textoApoio,
    this.isPublic = false,
    this.createdAt,
    this.updatedAt,
    this.orgao,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professor_id': professorId,
      'disciplina': disciplina,
      'assunto': assunto,
      'pergunta': pergunta,
      'alternativas': alternativas,
      'resposta': resposta,
      'explicacao': explicacao,
      'banca': banca,
      'ano': ano,
      'imagem_url': imagemPath,
      'is_inedita': isInedita,
      'autor': autor,
      'texto_apoio': textoApoio,
      'is_public': isPublic,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'orgao': orgao,
    };
  }

  factory Questao.fromJson(Map<String, dynamic> json) {
    print('Dados da questão recebidos do banco: $json'); // Debug
    final imagemUrl = json['imagem_url'];
    print('URL da imagem recebida: $imagemUrl'); // Debug

    return Questao(
      id: json['id'],
      professorId: json['professor_id'],
      disciplina: json['disciplina'],
      assunto: json['assunto'],
      pergunta: json['pergunta'],
      alternativas: List<String>.from(json['alternativas']),
      resposta: json['resposta'],
      explicacao: json['explicacao'],
      banca: json['banca'],
      ano: json['ano'],
      imagemPath: imagemUrl,
      isInedita: json['is_inedita'] ?? false,
      autor: json['autor'],
      textoApoio: json['texto_apoio'],
      isPublic: json['is_public'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      orgao: json['orgao'],
    );
  }
}

class Opcao {
  final String id;
  final String texto;

  Opcao({
    required this.id,
    required this.texto,
  });

  factory Opcao.fromJson(Map<String, dynamic> json) {
    return Opcao(
      id: json['id'],
      texto: json['texto'],
    );
  }
}
