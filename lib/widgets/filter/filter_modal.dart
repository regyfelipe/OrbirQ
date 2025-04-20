import 'package:flutter/material.dart';

import '../../themes/colors.dart';

class FilterModal extends StatefulWidget {
  final String filterName;

  const FilterModal({Key? key, required this.filterName}) : super(key: key);

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  final Map<String, bool> _selectedItems = {
    'Língua Portuguesa (Português)': false,
    'Matemática': false,
    'Raciocínio Lógico': false,
    'Informática': false,
    'Direito Constitucional': false,
    'Direito Administrativo': false,
  };

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
                onPressed: () {
                  // Retorna os itens selecionados
                  final selecionados = _selectedItems.entries
                      .where((e) => e.value)
                      .map((e) => e.key)
                      .toList();
                  Navigator.pop(context, selecionados);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryLight,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Selecionar filtro',
                  style: TextStyle(
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

void showFilterModal(BuildContext context, String filterName) {
  showModalBottomSheet<List<String>>(
    context: context,
    backgroundColor: AppColors.primaryLight,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
    ),
    builder: (context) => FilterModal(filterName: filterName),
  ).then((selectedItems) {
    if (selectedItems != null) {
      // Aqui você pode usar os itens selecionados
      print('Itens selecionados: $selectedItems');
    }
  });
}
