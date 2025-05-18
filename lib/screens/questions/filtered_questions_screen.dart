import 'package:flutter/material.dart';
import '../../services/questoes_service.dart';
import '../../models/questao.dart';
import '../../themes/colors.dart';
import 'question_page.dart';

class FilteredQuestionsScreen extends StatefulWidget {
  final String filterType;
  final List<String> selectedValues;

  const FilteredQuestionsScreen({
    Key? key,
    required this.filterType,
    required this.selectedValues,
  }) : super(key: key);

  @override
  State<FilteredQuestionsScreen> createState() => _FilteredQuestionsScreenState();
}

class _FilteredQuestionsScreenState extends State<FilteredQuestionsScreen> {
  final _questoesService = QuestoesService();
  int _currentQuestionIndex = 0;
  List<Questao> _questoes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFilteredQuestions();
  }

  Future<void> _loadFilteredQuestions() async {
    setState(() => _isLoading = true);
    try {
      final allQuestions = await _questoesService.carregarQuestoes();
      
      setState(() {
        _questoes = allQuestions.where((questao) {
          switch (widget.filterType) {
            case 'Disciplina':
              return widget.selectedValues.contains(questao.disciplina);
            case 'Assunto':
              return widget.selectedValues.contains(questao.assunto);
            case 'Banca':
              return questao.banca != null && widget.selectedValues.contains(questao.banca);
            case 'Órgão':
              return questao.orgao != null && widget.selectedValues.contains(questao.orgao);
            case 'Ano':
              return questao.ano != null && widget.selectedValues.contains(questao.ano);
            case 'Autor':
              return questao.autor != null && widget.selectedValues.contains(questao.autor);
            default:
              return false;
          }
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar questões filtradas: $e');
      setState(() => _isLoading = false);
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questoes.length - 1) {
      setState(() => _currentQuestionIndex++);
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questoes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryLight,
          title: const Text('Questões Filtradas'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('Nenhuma questão encontrada com os filtros selecionados'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      
      body: QuestionPage(
        questaoId: _questoes[_currentQuestionIndex].id,
        onNext: _currentQuestionIndex < _questoes.length - 1 ? _nextQuestion : null,
        onPrevious: _currentQuestionIndex > 0 ? _previousQuestion : null,
        filteredIds: _questoes.map((q) => q.id).toList(),
      ),
    );
  }
}