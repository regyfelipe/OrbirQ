import 'package:flutter/material.dart';
import '../../themes/colors.dart';
import '../../widgets/filter/filter_card.dart';
import '../../widgets/filter/bottom_buttons.dart';
import '../../utils/actions_section.dart';
import '../../widgets/filter/filter_modal.dart';

class FilterQuestionsScreen extends StatelessWidget {
  final List<String> filters = [
    'Assunto',
    'Banca',
    'Cargo',
    'Ano',
    'Formação',
    'Órgão',
    'Área',
    'Dificuldade',
    'Escolaridade',
    'Região'
  ];

  FilterQuestionsScreen({Key? key}) : super(key: key);

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
              child: Text(
                '{} de questões',
                style: const TextStyle(fontSize: 14, color: Colors.white54),
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
            Expanded(
              child: GridView.builder(
                itemCount: filters.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3.5,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showFilterModal(context, filters[index]),
                    child: FilterCard(title: filters[index]),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            buildActionsSection(),
            const BottomButtons(),
          ],
        ),
      ),
    );
  }

  void _showFilterModal(BuildContext context, String filterName) {
    showFilterModal(context, filterName);
  }
}
