import 'package:flutter/material.dart';
import '../../themes/colors.dart';

class OptionTile extends StatelessWidget {
  final String optionText;
  final String optionLetter;
  final bool isSelected;
  final bool? isCorrect;
  final VoidCallback? onTap;
  final Color selectedColor;

  const OptionTile({
    Key? key,
    required this.optionText,
    required this.optionLetter,
    required this.isSelected,
    this.isCorrect,
    this.onTap,
    this.selectedColor = AppColors.primaryLight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color getBorderColor() {
      if (isCorrect == true) return Colors.green;
      if (isCorrect == false) return Colors.red;
      if (isSelected) return selectedColor;
      return Colors.grey[300]!;
    }

    Color getBackgroundColor() {
      if (isCorrect == true) return Colors.green.withOpacity(0.1);
      if (isCorrect == false) return Colors.red.withOpacity(0.1);
      if (isSelected) return selectedColor.withOpacity(0.1);
      return Colors.white;
    }

    Color getLetterColor() {
      if (isCorrect == true) return Colors.green;
      if (isCorrect == false) return Colors.red;
      if (isSelected) return selectedColor;
      return Colors.grey[600]!;
    }

    return Container(
      decoration: BoxDecoration(
        color: getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: getBorderColor(),
          width: isSelected || isCorrect != null ? 2 : 1,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: selectedColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
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
                        ? selectedColor.withOpacity(0.1)
                        : Colors.transparent,
                    border: Border.all(
                      color: getLetterColor(),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      optionLetter,
                      style: TextStyle(
                        color: getLetterColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    optionText,
                    style: TextStyle(
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
                if (isCorrect != null)
                  Icon(
                    isCorrect! ? Icons.check_circle : Icons.cancel,
                    color: isCorrect! ? Colors.green : Colors.red,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
