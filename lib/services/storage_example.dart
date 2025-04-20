import 'storage_service.dart';

// Exemplo de uma classe de dados
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

// Exemplo de como usar o StorageService
void exemploDeUso() async {
  // Inicializar o serviço
  final storage = await StorageService.init();

  // Salvando valores simples
  await storage.setValue('nome', 'João');
  await storage.setValue('idade', 25);
  await storage.setValue('darkMode', true);
  await storage.setValue('notas', ['A', 'B', 'C']);

  // Salvando um objeto complexo
  final userPrefs = UserPreferences(
    nome: 'Maria',
    idade: 30,
    darkMode: true,
  );
  await storage.setValue('userPrefs', userPrefs.toJson());

  // Lendo valores
  final nome = storage.getValue<String>('nome');
  final idade = storage.getValue<int>('idade');
  final darkMode = storage.getValue<bool>('darkMode');
  final notas = storage.getValue<List<String>>('notas');

  // Lendo um objeto complexo
  final userPrefsJson = storage.getValue<Map<String, dynamic>>('userPrefs');
  if (userPrefsJson != null) {
    final userPrefsRecuperado = UserPreferences.fromJson(userPrefsJson);
    print(userPrefsRecuperado.nome); // Maria
  }

  // Verificando se uma chave existe
  if (storage.hasKey('nome')) {
    print('Nome está armazenado');
  }

  // Removendo um valor
  await storage.removeValue('nome');

  // Obtendo todas as chaves
  final todasAsChaves = storage.getAllKeys();
  print('Chaves armazenadas: $todasAsChaves');

  // Limpando todos os dados
  await storage.clear();
}
