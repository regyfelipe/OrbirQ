import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  int _questoesRespondidas = 0;
  int _provasRealizadas = 0;
  int _horasEstudadas = 0;
  double _aproveitamento = 0.0;
  List<ActivityItem> _actividadesRecentes = [];
  List<ExamItem> _proximasAvaliacoes = [];
  List<ConcursoItem> _concursosInscritos = [];

  int get questoesRespondidas => _questoesRespondidas;
  int get provasRealizadas => _provasRealizadas;
  int get horasEstudadas => _horasEstudadas;
  double get aproveitamento => _aproveitamento;
  List<ActivityItem> get actividadesRecentes => _actividadesRecentes;
  List<ExamItem> get proximasAvaliacoes => _proximasAvaliacoes;
  List<ConcursoItem> get concursosInscritos => _concursosInscritos;

  void incrementQuestoesRespondidas() {
    _questoesRespondidas++;
    notifyListeners();
  }

  void incrementProvasRealizadas() {
    _provasRealizadas++;
    notifyListeners();
  }

  void addAtividade(ActivityItem atividade) {
    _actividadesRecentes.insert(0, atividade);
    if (_actividadesRecentes.length > 10) {
      _actividadesRecentes.removeLast();
    }
    notifyListeners();
  }

  void addAvaliacao(ExamItem avaliacao) {
    _proximasAvaliacoes.add(avaliacao);
    _proximasAvaliacoes.sort((a, b) => a.data.compareTo(b.data));
    notifyListeners();
  }

  void removeAvaliacao(String id) {
    _proximasAvaliacoes.removeWhere((avaliacao) => avaliacao.id == id);
    notifyListeners();
  }

  void loadInitialData() {
    _questoesRespondidas = 1275;
    _provasRealizadas = 18;
    _horasEstudadas = 156;
    _aproveitamento = 78.5;

    _actividadesRecentes = [
      ActivityItem(
        id: '1',
        titulo: 'Simulado Completo - Tribunal Regional Federal',
        subtitulo: 'Realizado há 2 dias',
        pontuacao: 85,
        tipo: AtividadeTipo.simuladoConcurso,
        materia: 'Direito Constitucional',
        tempoGasto: const Duration(hours: 5),
      ),
      ActivityItem(
        id: '2',
        titulo: 'Questões Comentadas - Direito Administrativo',
        subtitulo: 'Realizado há 3 dias',
        pontuacao: 92,
        tipo: AtividadeTipo.questoesConcurso,
        materia: 'Direito Administrativo',
        tempoGasto: const Duration(minutes: 45),
      ),
      ActivityItem(
        id: '3',
        titulo: 'Revisão de Edital - MPU',
        subtitulo: 'Realizado há 4 dias',
        pontuacao: 100,
        tipo: AtividadeTipo.revisaoEdital,
        materia: 'Análise de Edital',
        tempoGasto: const Duration(hours: 2),
      ),
    ];

    _proximasAvaliacoes = [
      ExamItem(
        id: '1',
        titulo: 'Simulado Nacional - TRF',
        data: DateTime(2024, 4, 15, 14, 0),
        materias: [
          'Direito Constitucional',
          'Direito Administrativo',
          'Direito Civil',
          'Português',
          'Raciocínio Lógico'
        ],
        duracao: const Duration(hours: 5),
        banca: 'CESPE',
        numeroQuestoes: 120,
        tipoProva: TipoProva.objetiva,
      ),
      ExamItem(
        id: '2',
        titulo: 'Prova Discursiva - MPU',
        data: DateTime(2024, 5, 20, 8, 0),
        materias: ['Direito Constitucional', 'Direito Administrativo'],
        duracao: const Duration(hours: 4),
        banca: 'FGV',
        numeroQuestoes: 2,
        tipoProva: TipoProva.discursiva,
      ),
    ];

    _concursosInscritos = [
      ConcursoItem(
        id: '1',
        titulo: 'Concurso TRF - Analista Judiciário',
        dataProva: DateTime(2024, 4, 15),
        banca: 'CESPE',
        salario: 12000.0,
        vagas: 50,
        status: StatusConcurso.inscrito,
        fases: [
          FaseConcurso(
            titulo: 'Prova Objetiva',
            data: DateTime(2024, 4, 15),
            status: StatusFase.aguardando,
          ),
          FaseConcurso(
            titulo: 'Prova Discursiva',
            data: DateTime(2024, 5, 20),
            status: StatusFase.aguardando,
          ),
        ],
      ),
      ConcursoItem(
        id: '2',
        titulo: 'Concurso MPU - Analista',
        dataProva: DateTime(2024, 6, 10),
        banca: 'FGV',
        salario: 13500.0,
        vagas: 30,
        status: StatusConcurso.inscrito,
        fases: [
          FaseConcurso(
            titulo: 'Prova Objetiva',
            data: DateTime(2024, 6, 10),
            status: StatusFase.aguardando,
          ),
        ],
      ),
    ];

    notifyListeners();
  }
}

class ActivityItem {
  final String id;
  final String titulo;
  final String subtitulo;
  final int pontuacao;
  final AtividadeTipo tipo;
  final String materia;
  final Duration tempoGasto;

  ActivityItem({
    required this.id,
    required this.titulo,
    required this.subtitulo,
    required this.pontuacao,
    required this.tipo,
    this.materia = '',
    this.tempoGasto = const Duration(minutes: 0),
  });
}

enum AtividadeTipo {
  simuladoConcurso,
  questoesConcurso,
  revisaoEdital,
  videoAula,
  resumo,
  lista,
  prova,
}

enum TipoProva { objetiva, discursiva, oral, pratica, titulos }

class ExamItem {
  final String id;
  final String titulo;
  final DateTime data;
  final List<String> materias;
  final Duration duracao;
  final String banca;
  final int numeroQuestoes;
  final TipoProva tipoProva;

  ExamItem({
    required this.id,
    required this.titulo,
    required this.data,
    required this.materias,
    required this.duracao,
    this.banca = '',
    this.numeroQuestoes = 0,
    this.tipoProva = TipoProva.objetiva,
  });
}

enum StatusConcurso {
  inscrito,
  aprovado,
  reprovado,
  aguardandoResultado,
  convocado
}

enum StatusFase { aguardando, concluido, aprovado, reprovado }

class ConcursoItem {
  final String id;
  final String titulo;
  final DateTime dataProva;
  final String banca;
  final double salario;
  final int vagas;
  final StatusConcurso status;
  final List<FaseConcurso> fases;

  ConcursoItem({
    required this.id,
    required this.titulo,
    required this.dataProva,
    required this.banca,
    required this.salario,
    required this.vagas,
    required this.status,
    required this.fases,
  });
}

class FaseConcurso {
  final String titulo;
  final DateTime data;
  final StatusFase status;

  FaseConcurso({
    required this.titulo,
    required this.data,
    required this.status,
  });
}
