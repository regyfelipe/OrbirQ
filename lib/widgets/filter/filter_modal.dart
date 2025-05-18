import 'package:flutter/material.dart';
import 'package:orbirq/screens/questions/filtered_questions_screen.dart';

import '../../themes/colors.dart';
import '../../services/questoes_service.dart';

class FilterModal extends StatefulWidget {
  final String filterName;
  final List<String> currentSelections;

  const FilterModal({
    Key? key,
    required this.filterName,
    required this.currentSelections,
  }) : super(key: key);

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  final Map<String, bool> _selectedItems = {};
  final _questoesService = QuestoesService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFilterOptions();
  }

  Future<void> _loadFilterOptions() async {
    setState(() => _isLoading = true);

    try {
      final questoes = await _questoesService.carregarQuestoes();
      final Set<String> options = <String>{};

      // Get unique values based on filter type
      switch (widget.filterName) {
        case 'Disciplina':
          options.addAll(questoes.map((q) => q.disciplina));
          break;
        case 'Assunto':
          options.addAll(questoes.map((q) => q.assunto));
          break;
        case 'Banca':
          options.addAll(
              questoes.where((q) => q.banca != null).map((q) => q.banca!));
          break;
        case 'Órgão':
          options.addAll(
              questoes.where((q) => q.orgao != null).map((q) => q.orgao!));
          break;
        case 'Ano':
          options
              .addAll(questoes.where((q) => q.ano != null).map((q) => q.ano!));
          break;
        case 'Autor':
          options.addAll(
              questoes.where((q) => q.autor != null).map((q) => q.autor!));
          break;
        case 'Tipo':
          options.addAll(['Inéditas', 'Públicas']);
          break;
      }

      setState(() {
        _selectedItems.clear();
        for (var option in options) {
          _selectedItems[option] = widget.currentSelections.contains(option);
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar opções de filtro: $e');
      setState(() => _isLoading = false);
    }
  }

  void _toggleItem(String title, bool? value) {
    setState(() {
      _selectedItems[title] = value ?? false;
    });
  }

  void _limparFiltros() {
    setState(() {
      for (var key in _selectedItems.keys) {
        _selectedItems[key] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selectedItems.entries.where((e) => e.value).length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.filterName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: _limparFiltros,
                child: const Text(
                  'Limpar filtro',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Busque por assunto',
              hintStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          else if (_selectedItems.isEmpty)
            const Center(
              child: Text(
                'Nenhuma opção disponível',
                style: TextStyle(color: Colors.white),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: _selectedItems.keys.map((title) {
                        return CheckboxListTile(
                          value: _selectedItems[title],
                          onChanged: (value) => _toggleItem(title, value),
                          title: Text(
                            title,
                            style: const TextStyle(color: Colors.white),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: Colors.white,
                          checkColor: AppColors.primaryLight,
                          side: const BorderSide(color: Colors.white),
                        );
                      }).toList(),
                    ),
                  ),
                  if (selectedCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selecionados ($selectedCount):',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _selectedItems.entries
                                .where((e) => e.value)
                                .map((e) => Chip(
                                      backgroundColor:
                                          Colors.white.withOpacity(0.2),
                                      label: Text(
                                        e.key,
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                      deleteIcon: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      onDeleted: () =>
                                          _toggleItem(e.key, false),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: selectedCount > 0
                    ? () {
                        final selecionados = _selectedItems.entries
                            .where((e) => e.value)
                            .map((e) => e.key)
                            .toList();
                        Navigator.pop(context, {
                          'tipo': widget.filterName,
                          'valores': selecionados,
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryLight,
                  disabledBackgroundColor: Colors.grey,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Selecionar ${selectedCount > 0 ? '($selectedCount)' : ''}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<Map<String, dynamic>?> showFilterModal(
  BuildContext context,
  String filterName,
  List<String> currentSelections,
) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    backgroundColor: AppColors.primaryLight,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => FilterModal(
        filterName: filterName,
        currentSelections: currentSelections,
      ),
    ),
  );
}
