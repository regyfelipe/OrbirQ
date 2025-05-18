import 'storage_service.dart';

class UserPreferences {
  final String nome;
  final int idade;
  final bool darkMode;

  UserPreferences({
    required this.nome,
    required this.idade,
    required this.darkMode,
  });

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'idade': idade,
        'darkMode': darkMode,
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      UserPreferences(
        nome: json['nome'] as String,
        idade: json['idade'] as int,
        darkMode: json['darkMode'] as bool,
      );
}

void exemploDeUso() async {
  final storage = await StorageService.init();

  await storage.setValue('nome', 'João');
  await storage.setValue('idade', 25);
  await storage.setValue('darkMode', true);
  await storage.setValue('notas', ['A', 'B', 'C']);

  final userPrefs = UserPreferences(
    nome: 'Maria',
    idade: 30,
    darkMode: true,
  );
  await storage.setValue('userPrefs', userPrefs.toJson());

  final nome = storage.getValue<String>('nome');
  final idade = storage.getValue<int>('idade');
  final darkMode = storage.getValue<bool>('darkMode');
  final notas = storage.getValue<List<String>>('notas');

  final userPrefsJson = storage.getValue<Map<String, dynamic>>('userPrefs');
  if (userPrefsJson != null) {
    final userPrefsRecuperado = UserPreferences.fromJson(userPrefsJson);
    print(userPrefsRecuperado.nome); 
  }

  if (storage.hasKey('nome')) {
    print('Nome está armazenado');
  }

  await storage.removeValue('nome');

  final todasAsChaves = storage.getAllKeys();
  print('Chaves armazenadas: $todasAsChaves');

  await storage.clear();
}
