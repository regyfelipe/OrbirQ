import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/Colors.dart';
import '../../widgets/questao/optionTile.dart';
import '../../providers/home_provider.dart';
import '../../models/questao.dart';
import '../../services/questoes_service.dart';

class QuestionPage extends StatefulWidget {
  final String? questaoId;

  const QuestionPage({super.key, this.questaoId});

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  int? _selectedOptionIndex;
  bool _showAnswer = false;
  bool _showExplanation = false;
  bool _isBookmarked = false;
  bool _expandedTextoApoio = false;
  final int _totalTime = 300; 
  int _timeRemaining = 300;
  bool _timerActive = false;

  Questao? _questaoAtual;
  final _questoesService = QuestoesService();

  final List<String> _mensagensMotivacionais = [
    "Excelente! Continue assim que você vai longe! 🌟",
    "Impressionante! Você está dominando o assunto! 🎯",
    "Que orgulho! Seu esforço está valendo a pena! 🏆",
    "Sensacional! Você está no caminho certo! ⭐",
    "Incrível! Sua dedicação está dando resultados! 🌈",
    "Parabéns! Você está cada vez mais preparado! 🚀",
    "Fantástico! Continue brilhando assim! ✨",
    "Show! Você está arrasando nos estudos! 💫",
    "Espetacular! Seu conhecimento está sólido! 🎊",
    "Perfeito! Você é exemplo de dedicação! 🌟"
  ];

  final List<String> _mensagensConstrutivas = [
    "Não desanime! Erros são parte do aprendizado. 🌱",
    "Continue tentando! Cada erro te deixa mais forte. 💪",
    "Persista! O caminho do sucesso passa pela superação. 🎯",
    "Mantenha o foco! Você está progredindo a cada tentativa. 🚀",
    "Não desista! Você está mais perto do acerto. 💫",
    "Cabeça erguida! Aprender com os erros é sabedoria. 🌟",
    "Força! Cada desafio te torna mais preparado. 🎊",
    "Ânimo! O erro de hoje é o acerto de amanhã. ✨",
    "Coragem! Você está no caminho do aprendizado. 🌈",
    "Confiança! Errar faz parte do processo. 💡"
  ];

  @override
  void initState() {
    super.initState();
    _carregarQuestao();
  }

  Future<void> _carregarQuestao() async {
    if (widget.questaoId != null) {
      _questaoAtual = await _questoesService.getQuestaoPorId(widget.questaoId!);
    } else {
      final questoes = await _questoesService.carregarQuestoes();
      if (questoes.isNotEmpty) {
        _questaoAtual = questoes[0];
      }
    }
    setState(() {});
  }

  void _startTimer() {
    setState(() {
      _timerActive = true;
      _timeRemaining = _totalTime;
    });
    Future.delayed(const Duration(seconds: 1), _updateTimer);
  }

  void _updateTimer() {
    if (!_timerActive) return;

    if (_timeRemaining > 0) {
      setState(() {
        _timeRemaining--;
      });
      Future.delayed(const Duration(seconds: 1), _updateTimer);
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _checkAnswer() {
    if (_selectedOptionIndex == null || _questaoAtual == null) return;

    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    homeProvider.incrementQuestoesRespondidas();

    setState(() {
      _showAnswer = true;
      _timerActive = false;
    });

    homeProvider.addAtividade(
      ActivityItem(
        id: DateTime.now().toString(),
        titulo: 'Questão - ${_questaoAtual!.disciplina}',
        subtitulo: '${_questaoAtual!.banca} - ${_questaoAtual!.orgao}',
        pontuacao: _selectedOptionIndex! < _questaoAtual!.alternativas.length &&
                _questaoAtual!.alternativas[_selectedOptionIndex!] ==
                    _questaoAtual!.resposta
            ? 100
            : 0,
        tipo: AtividadeTipo.questoesConcurso,
        materia: _questaoAtual!.disciplina,
        tempoGasto: Duration(seconds: _totalTime - _timeRemaining),
      ),
    );
  }

  Future<void> _navegarParaQuestao(String direcao) async {
    final questoes = await _questoesService.carregarQuestoes();
    final indexAtual = questoes.indexWhere((q) => q.id == _questaoAtual!.id);

    if (direcao == 'anterior' && indexAtual > 0) {
      setState(() {
        _questaoAtual = questoes[indexAtual - 1];
        _resetQuestion();
      });
    } else if (direcao == 'proxima' && indexAtual < questoes.length - 1) {
      setState(() {
        _questaoAtual = questoes[indexAtual + 1];
        _resetQuestion();
      });
    }
  }

  void _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imagePath,
                fit: BoxFit.contain,
                headers: const {
                  'Cache-Control': 'no-cache',
                  'Access-Control-Allow-Origin': '*',
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.black54,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  print('Erro ao carregar imagem no diálogo: $error'); // Debug
                  print('Stack trace do diálogo: $stackTrace'); // Debug
                  return Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Imagem não disponível',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  String _getMensagemAleatoria(bool acertou) {
    final lista = acertou ? _mensagensMotivacionais : _mensagensConstrutivas;
    final random = DateTime.now().millisecondsSinceEpoch % lista.length;
    return lista[random];
  }

  @override
  Widget build(BuildContext context) {
    if (_questaoAtual == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.primaryLight,
        title: Row(
          children: [
            FutureBuilder<int>(
              future: _questoesService.getQuestaoNumero(_questaoAtual!.id),
              builder: (context, snapshot) {
                return Text(
                  'Questão ${snapshot.data ?? "..."}',
                  style: const TextStyle(color: Colors.white),
                );
              },
            ),
            const Spacer(),
            if (!_showAnswer && !_timerActive)
              TextButton(
                onPressed: _startTimer,
                child: const Text(
                  'Iniciar Timer',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            if (_timerActive)
              Text(
                _formatTime(_timeRemaining),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
            },
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildQuestionText(),
              const SizedBox(height: 20),
              _buildOptions(),
              if (_showAnswer) ...[
                const SizedBox(height: 20),
                _buildAnswerSection(),
              ],
              const SizedBox(height: 20),
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
      floatingActionButton: !_showAnswer
          ? FloatingActionButton.extended(
              onPressed: _selectedOptionIndex == null ? null : _checkAnswer,
              backgroundColor: AppColors.primaryLight,
              label:
                  const Text('Resolver', style: TextStyle(color: Colors.white)),
              icon: const Icon(Icons.check, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Primeira linha com Disciplina e Assunto
          IntrinsicHeight(
            child: Row(
              children: [
                // Disciplina
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Disciplina: ',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _questaoAtual!.disciplina,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Separador vertical
                VerticalDivider(
                  color: Colors.grey[300],
                  thickness: 1,
                  width: 32,
                ),
                // Assunto
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Assunto: ',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _questaoAtual!.assunto,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Segunda linha com Autor e Questão Inédita
          Row(
            children: [
              if (_questaoAtual!.autor != null) ...[
                Row(
                  children: [
                    Text(
                      'Autor: ',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _questaoAtual!.autor!,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              const Spacer(),
              if (_questaoAtual!.isInedita)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.new_releases_outlined,
                        size: 16,
                        color: Colors.green[700],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Questão Inédita',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (_questaoAtual!.banca != null ||
              _questaoAtual!.ano != null ||
              _questaoAtual!.orgao != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  if (_questaoAtual!.ano != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          _questaoAtual!.ano!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  if (_questaoAtual!.banca != null) ...[
                    if (_questaoAtual!.ano != null)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: 1,
                        height: 16,
                        color: Colors.grey[300],
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.school_outlined,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          _questaoAtual!.banca!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_questaoAtual!.orgao != null) ...[
                    if (_questaoAtual!.ano != null ||
                        _questaoAtual!.banca != null)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: 1,
                        height: 16,
                        color: Colors.grey[300],
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.business_outlined,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          _questaoAtual!.orgao!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_questaoAtual!.textoApoio != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _expandedTextoApoio = !_expandedTextoApoio;
                    });
                  },
                  child: Row(
                    children: [
                      const Text(
                        'Texto de Apoio',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _expandedTextoApoio
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
                if (_expandedTextoApoio) ...[
                  const SizedBox(height: 8),
                  Text(
                    _questaoAtual!.textoApoio!,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (_questaoAtual!.imagemPath != null) ...[
          GestureDetector(
            onTap: () {
              print('URL da imagem: ${_questaoAtual!.imagemPath}'); // Debug
              _showImageDialog(context, _questaoAtual!.imagemPath!);
            },
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _questaoAtual!.imagemPath!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      headers: const {
                        'Cache-Control': 'no-cache',
                        'Access-Control-Allow-Origin': '*',
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('Erro ao carregar imagem: $error'); // Debug
                        print('Stack trace: $stackTrace'); // Debug
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, color: Colors.grey),
                              SizedBox(width: 8),
                              Text(
                                'Imagem não disponível',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.zoom_in,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _questaoAtual!.pergunta,
            style:
                const TextStyle(fontSize: 16, color: Colors.black, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildOptions() {
    return Column(
      children: List.generate(_questaoAtual!.alternativas.length, (index) {
        final alternativa = _questaoAtual!.alternativas[index];
        final letraAlternativa = String.fromCharCode(65 + index); // A, B, C...
        final respostaCorreta = letraAlternativa == _questaoAtual!.resposta;

        // Só mostra se é correto/incorreto se for a alternativa selecionada ou a correta
        bool? isCorrect;
        if (_showAnswer) {
          if (index == _selectedOptionIndex) {
            // Se for a alternativa selecionada, mostra se está correta ou não
            isCorrect = respostaCorreta;
          } else if (respostaCorreta) {
            // Se for a alternativa correta (e não foi a selecionada), mostra como correta
            isCorrect = true;
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: OptionTile(
            optionText: alternativa,
            optionLetter: String.fromCharCode(65 + index),
            isSelected: _selectedOptionIndex == index,
            isCorrect: isCorrect,
            onTap: _showAnswer
                ? null
                : () {
                    setState(() {
                      if (_selectedOptionIndex == index) {
                        _selectedOptionIndex = null;
                      } else {
                        _selectedOptionIndex = index;
                      }
                    });
                  },
          ),
        );
      }),
    );
  }

  Widget _buildAnswerSection() {
    // Convertendo o índice selecionado para letra (A, B, C...)
    final letraSelecionada = String.fromCharCode(65 + _selectedOptionIndex!);
    final respostaCorreta = letraSelecionada == _questaoAtual!.resposta;
    final mensagem = _getMensagemAleatoria(respostaCorreta);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: respostaCorreta
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: respostaCorreta ? Colors.green : Colors.orange,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    respostaCorreta ? Icons.celebration : Icons.psychology,
                    color: respostaCorreta ? Colors.green : Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      mensagem,
                      style: TextStyle(
                        color: respostaCorreta ? Colors.green : Colors.orange,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: respostaCorreta
                        ? Colors.green.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      respostaCorreta ? Icons.check_circle : Icons.info,
                      color: respostaCorreta ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sua resposta: $letraSelecionada',
                            style: TextStyle(
                              color: respostaCorreta
                                  ? Colors.green
                                  : Colors.orange,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Resposta correta: ${_questaoAtual!.resposta}',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _showExplanation = !_showExplanation;
            });
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: respostaCorreta
                    ? Colors.green.withOpacity(0.3)
                    : Colors.orange.withOpacity(0.3),
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _showExplanation ? Icons.remove : Icons.add,
                color: respostaCorreta ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                'Ver explicação',
                style: TextStyle(
                  color: respostaCorreta ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ),
        if (_showExplanation)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: respostaCorreta
                    ? Colors.green.withOpacity(0.3)
                    : Colors.orange.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Explicação',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _questaoAtual!.explicacao ?? 'Explicação não disponível',
                  style: const TextStyle(
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: () => _navegarParaQuestao('anterior'),
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryLight),
          label: const Text(
            'Anterior',
            style: TextStyle(color: AppColors.primaryLight),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.list, color: AppColors.primaryLight),
          label: const Text(
            'Lista',
            style: TextStyle(color: AppColors.primaryLight),
          ),
        ),
        TextButton.icon(
          onPressed: () => _navegarParaQuestao('proxima'),
          icon: const Icon(Icons.arrow_forward, color: AppColors.primaryLight),
          label: const Text(
            'Próxima',
            style: TextStyle(color: AppColors.primaryLight),
          ),
        ),
      ],
    );
  }

  void _resetQuestion() {
    _selectedOptionIndex = null;
    _showAnswer = false;
    _showExplanation = false;
    _timerActive = false;
    _timeRemaining = _totalTime;
  }
}
