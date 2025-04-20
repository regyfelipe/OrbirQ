import 'package:flutter/material.dart';
import '../../themes/colors.dart';

class SimulatedPage extends StatelessWidget {
  const SimulatedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulados'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Página de Simulados em desenvolvimento'),
      ),
    );
  }
}
