import 'package:flutter/material.dart';

class ExcludeButton extends StatelessWidget {
  final String title;

  const ExcludeButton({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF789DBC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Text(title, style: const TextStyle(fontSize: 14)),
    );
  }
}
