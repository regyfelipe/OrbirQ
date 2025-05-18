import 'package:flutter/material.dart';

class GridItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const GridItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: item['color'],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: InkWell(
        onTap: () {
          if (item.containsKey('onTap')) {
            item['onTap'](context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Você clicou em ${item['title']}')),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item['icon'], size: 50, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              item['title'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
