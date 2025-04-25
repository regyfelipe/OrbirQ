import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../themes/colors.dart';
import '../../models/questao.dart';
import '../../services/questoes_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/disciplinas_constants.dart';

class CreateQuestionPage extends StatefulWidget {
  const CreateQuestionPage({Key? key}) : super(key: key);

  @override
  State<CreateQuestionPage> createState() => _CreateQuestionPageState();
}

class _CreateQuestionPageState extends State<CreateQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final TextEditingController _disciplinaController = TextEditingController();
  final TextEditingController _assuntoController = TextEditingController();
  final TextEditingController _perguntaController = TextEditingController();
  final List<TextEditingController> _alternativasControllers = [
    TextEditingController(), // A
    TextEditingController(), // B
  ];
  final TextEditingController _explicacaoController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();
  final TextEditingController _textoApoioController = TextEditingController();

  String? _selectedBanca;
  String? _selectedAno;
  bool _isInedita = false;
  bool _hasTextoApoio = false;
  bool _isPublic = false;
  String? _selectedResposta;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _bancas = ['CESPE', 'FGV', 'VUNESP', 'IBFC', 'FUNDATEC'];
  final List<String> _anos =
      List.generate(10, (index) => (DateTime.now().year - index).toString());

  List<String> _getSugestoesAssuntos(String disciplina) {
    return DisciplinasConstants.getAssuntos(disciplina);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _adicionarAlternativa() {
    if (_alternativasControllers.length < 5) {
      setState(() {
        _alternativasControllers.add(TextEditingController());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Criar Questão',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informações da Questão',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text(
                  'Questão Pública',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                subtitle: const Text(
                  'Se ativado, outros usuários poderão ver esta questão',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                value: _isPublic,
                onChanged: (bool value) {
                  setState(() {
                    _isPublic = value;
                  });
                },
                activeColor: AppColors.primaryLight,
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return DisciplinasConstants.getDisciplinas();
                        }
                        return DisciplinasConstants.getDisciplinas()
                            .where((String option) {
                          return option.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              );
                        });
                      },
                      onSelected: (String selection) {
                        _disciplinaController.text = selection;
                        _assuntoController.clear();
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onFieldSubmitted) {
                        _disciplinaController.text = controller.text;
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: 'Disciplina',
                            hintText: 'Digite ou selecione a disciplina',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        final sugestoes =
                            _getSugestoesAssuntos(_disciplinaController.text);
                        if (textEditingValue.text.isEmpty) {
                          return sugestoes;
                        }
                        return sugestoes.where((String option) {
                          return option.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              );
                        });
                      },
                      onSelected: (String selection) {
                        _assuntoController.text = selection;
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onFieldSubmitted) {
                        _assuntoController.text = controller.text;
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: 'Assunto',
                            hintText: 'Digite ou selecione o assunto',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      value: _selectedBanca,
                      items: _bancas,
                      label: 'Banca',
                      onChanged: (value) =>
                          setState(() => _selectedBanca = value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownField(
                      value: _selectedAno,
                      items: _anos,
                      label: 'Ano',
                      onChanged: (value) =>
                          setState(() => _selectedAno = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text(
                        'Questão Inédita',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      value: _isInedita,
                      onChanged: (bool? value) {
                        setState(() {
                          _isInedita = value ?? false;
                          if (!_isInedita) {
                            _autorController.clear();
                          }
                        });
                      },
                      activeColor: AppColors.primaryLight,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                ],
              ),
              if (_isInedita) ...[
                const SizedBox(height: 5),
                TextFormField(
                  controller: _autorController,
                  decoration: InputDecoration(
                    labelText: 'Autor da Questão',
                    hintText: 'Digite o nome do autor',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (_isInedita && (value == null || value.isEmpty)) {
                      return 'Por favor, informe o autor da questão';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text(
                        'Adicionar Texto de Apoio',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      value: _hasTextoApoio,
                      onChanged: (bool? value) {
                        setState(() {
                          _hasTextoApoio = value ?? false;
                          if (!_hasTextoApoio) {
                            _textoApoioController.clear();
                          }
                        });
                      },
                      activeColor: AppColors.primaryLight,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                ],
              ),
              if (_hasTextoApoio) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _textoApoioController,
                  decoration: InputDecoration(
                    labelText: 'Texto de Apoio',
                    hintText: 'Digite o texto de apoio aqui...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 4,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Adicionar Imagem'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryLight,
                      side: const BorderSide(color: AppColors.primaryLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              if (_selectedImage != null) ...[
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => setState(() => _selectedImage = null),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Pergunta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _perguntaController,
                decoration: InputDecoration(
                  hintText: 'Digite a pergunta aqui...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Alternativas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (_alternativasControllers.length < 5)
                    TextButton.icon(
                      onPressed: _adicionarAlternativa,
                      icon: const Icon(Icons.add),
                      label: const Text('Nova alternativa'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryLight,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ..._alternativasControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                final label = String.fromCharCode(65 + index); 
                return _buildAlternativaField(
                  controller: controller,
                  label: label,
                  isSelected: _selectedResposta == label,
                  onSelect: () => setState(() => _selectedResposta = label),
                  onDelete: index > 1
                      ? () {
                          setState(() {
                            _alternativasControllers.removeAt(index);
                            if (_selectedResposta == label) {
                              _selectedResposta = null;
                            }
                          });
                        }
                      : null,
                );
              }),
              const SizedBox(height: 24),
              const Text(
                'Explicação da resposta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _explicacaoController,
                decoration: InputDecoration(
                  hintText: 'Digite a explicação aqui...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Salvar questão',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required String label,
    required Function(String?) onChanged,
    bool required = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Este campo é obrigatório';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildAlternativaField({
    required TextEditingController controller,
    required String label,
    required bool isSelected,
    required VoidCallback onSelect,
    VoidCallback? onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primaryLight.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.primaryLight.withOpacity(0.1)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryLight
                          : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primaryLight
                            : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Digite a alternativa $label aqui...',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedResposta == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione a resposta correta'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final service = QuestoesService();

      final List<String> alternativas = _alternativasControllers
          .map((controller) => controller.text)
          .where((text) => text.isNotEmpty)
          .toList();

      final novaQuestao = Questao(
        id: service.gerarNovoId(),
        professorId: Supabase.instance.client.auth.currentUser!.id,
        disciplina: _disciplinaController.text,
        assunto: _assuntoController.text,
        pergunta: _perguntaController.text,
        alternativas: alternativas,
        resposta: _selectedResposta!,
        explicacao: _explicacaoController.text,
        banca: _selectedBanca,
        ano: _selectedAno,
        imagemPath: _selectedImage?.path,
        isInedita: _isInedita,
        autor: _isInedita ? _autorController.text : null,
        textoApoio: _hasTextoApoio ? _textoApoioController.text : null,
        isPublic: _isPublic,
      );

      try {
        final sucesso = await service.salvarQuestao(novaQuestao);
        if (sucesso && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Questão salva com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          _limparCampos();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao salvar a questão. Tente novamente.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar a questão: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _limparCampos() {
    _disciplinaController.clear();
    _assuntoController.clear();
    _perguntaController.clear();
    _explicacaoController.clear();
    _autorController.clear();
    _textoApoioController.clear();

    for (var controller in _alternativasControllers) {
      controller.dispose();
    }
    _alternativasControllers.clear();
    _alternativasControllers.addAll([
      TextEditingController(),
      TextEditingController(),
    ]);

    setState(() {
      _selectedBanca = null;
      _selectedAno = null;
      _selectedResposta = null;
      _selectedImage = null;
      _isInedita = false;
      _hasTextoApoio = false;
      _isPublic = false;
    });

    if (_formKey.currentState != null) {
      _formKey.currentState!.reset();
    }

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _disciplinaController.dispose();
    _assuntoController.dispose();
    _perguntaController.dispose();
    for (var controller in _alternativasControllers) {
      controller.dispose();
    }
    _explicacaoController.dispose();
    _autorController.dispose();
    _textoApoioController.dispose();
    super.dispose();
  }
}
