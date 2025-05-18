import 'package:flutter/material.dart';
import '../../themes/colors.dart';
import '../../widgets/filter/filter_card.dart';
import '../../widgets/filter/bottom_buttons.dart';
import '../../utils/actions_section.dart';
import '../../widgets/filter/filter_modal.dart';
import '../../services/questoes_service.dart';

class FilterQuestionsScreen extends StatefulWidget {
  const FilterQuestionsScreen({Key? key}) : super(key: key);

  @override
  State<FilterQuestionsScreen> createState() => _FilterQuestionsScreenState();
}

class _FilterQuestionsScreenState extends State<FilterQuestionsScreen> {
  final _questoesService = QuestoesService();
  List<String> availableFilters = [];
  Map<String, List<String>> selectedFilters = {};

  @override
  void initState() {
    super.initState();
    _loadAvailableFilters();
  }

  Future<void> _loadAvailableFilters() async {
    final filters = await _questoesService.getAvailableFilters();
    setState(() {
      availableFilters = filters;
    });
  }

  void _removeFilter(String filterType, String value) {
    setState(() {
      selectedFilters[filterType]?.remove(value);
      if (selectedFilters[filterType]?.isEmpty ?? false) {
        selectedFilters.remove(filterType);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
        title: const Text(
          'Questões',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: FutureBuilder<int>(
                future: _questoesService.getTotalQuestoes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text(
                      '...',
                      style: TextStyle(fontSize: 14, color: Colors.white54),
                    );
                  }

                  final total = snapshot.data ?? 0;
                  return Text(
                    '$total questões',
                    style: const TextStyle(fontSize: 14, color: Colors.white54),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Combine filtros e comece a resolver questões ou crie um novo caderno.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            if (selectedFilters.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.filter_list, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Filtros selecionados',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              selectedFilters.clear();
                            });
                          },
                          child: const Text('Limpar todos'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var filterType in selectedFilters.keys)
                          for (var value in selectedFilters[filterType] ?? [])
                            Chip(
                              label: Text(
                                '$filterType: $value',
                                style: const TextStyle(fontSize: 12),
                              ),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () => _removeFilter(filterType, value),
                              backgroundColor:
                                  AppColors.primaryLight.withOpacity(0.1),
                              side: BorderSide(
                                color: AppColors.primaryLight.withOpacity(0.2),
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            Expanded(
              child: availableFilters.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      itemCount: availableFilters.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 3.5,
                      ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _showFilterModal(
                              context, availableFilters[index]),
                          child: FilterCard(title: availableFilters[index]),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            buildActionsSection(),
            BottomButtons(selectedFilters: selectedFilters),
          ],
        ),
      ),
    );
  }

  void _showFilterModal(BuildContext context, String filterName) {
    final currentSelections = selectedFilters[filterName] ?? [];

    showFilterModal(
      context,
      filterName,
      currentSelections,
    ).then((result) {
      if (result != null) {
        setState(() {
          if (result['valores'].isNotEmpty) {
            selectedFilters[result['tipo']] = result['valores'];
          } else {
            selectedFilters.remove(result['tipo']);
          }
        });
      }
    });
  }
}
