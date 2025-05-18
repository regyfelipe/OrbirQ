import 'package:flutter/material.dart';
import '../../themes/colors.dart';

class FolderPage extends StatelessWidget {
  const FolderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pasta'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Página de Pasta em desenvolvimento'),
      ),
    );
  }
}
