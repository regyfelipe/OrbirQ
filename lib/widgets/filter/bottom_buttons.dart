import 'package:flutter/material.dart';
import '../../screens/questions/question_page.dart';
import '../../screens/questions/filtered_questions_screen.dart';
import '../../themes/Colors.dart';

class BottomButtons extends StatelessWidget {
  final Map<String, List<String>> selectedFilters;

  const BottomButtons({
    Key? key, 
    required this.selectedFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                if (selectedFilters.isEmpty) {
                  // If no filters selected, show all questions
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QuestionPage()),
                  );
                } else {
                  // Show filtered questions
                  final firstFilter = selectedFilters.entries.first;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FilteredQuestionsScreen(
                        filterType: firstFilter.key,
                        selectedValues: firstFilter.value,
                      ),
                    ),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryLight, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Ver questões',
                style: TextStyle(color: AppColors.primaryLight, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Add save filter functionality here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.primaryLight, width: 2),
                ),
              ),
              child: const Text(
                'Salvar Filtro',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
