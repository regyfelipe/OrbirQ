import 'package:flutter/material.dart';

import '../../themes/colors.dart';

class FilterCard extends StatelessWidget {
  final String title;
  final bool isSelected;

  const FilterCard({
    Key? key,
    required this.title,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            isSelected ? AppColors.primaryLight.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppColors.primaryLight : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryLight : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isSelected ? AppColors.primaryLight : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
