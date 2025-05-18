import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/questao.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class QuestoesService {
  final _supabase = Supabase.instance.client;

  Future<List<Questao>> carregarQuestoes() async {
    try {
      final user = _supabase.auth.currentUser;
      final response = await _supabase
          .from('questions')
          .select()
          .or('is_public.eq.true,professor_id.eq.${user?.id}')
          .order('created_at', ascending: false);

      return (response as List).map((json) => Questao.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao carregar questões: $e');
      return [];
    }
  }

  Future<Questao?> getQuestaoPorId(String id) async {
    try {
      final response =
          await _supabase.from('questions').select().eq('id', id).single();

      return Questao.fromJson(response);
    } catch (e) {
      print('Erro ao buscar questão por ID: $e');
      return null;
    }
  }

  Future<bool> salvarQuestao(Questao questao) async {
    try {
      String? imageUrl;
      if (questao.imagemPath != null) {
        final file = File(questao.imagemPath!);
        final fileExt = questao.imagemPath!.split('.').last;
        final fileName =
            '${questao.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final path = fileName;

        try {
          print('Iniciando upload da imagem...'); 
          await _supabase.storage.from('questoes').upload(path, file);
          print('Upload concluído. Gerando URL pública...'); 

          imageUrl = _supabase.storage.from('questoes').getPublicUrl(path);
          print('URL pública gerada: $imageUrl'); 
        } catch (e) {
          print('Erro no upload da imagem: $e');
        }
      }

      print('Salvando questão no banco com URL da imagem: $imageUrl');

      await _supabase.from('questions').insert({
        'id': questao.id,
        'professor_id': _supabase.auth.currentUser!.id,
        'disciplina': questao.disciplina,
        'assunto': questao.assunto,
        'pergunta': questao.pergunta,
        'alternativas': questao.alternativas,
        'resposta': questao.resposta,
        'explicacao': questao.explicacao,
        'banca': questao.banca,
        'ano': questao.ano,
        'imagem_url': imageUrl,
        'is_inedita': questao.isInedita,
        'autor': questao.autor,
        'texto_apoio': questao.textoApoio,
        'is_public': questao.isPublic,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Erro ao salvar questão: $e');
      return false;
    }
  }

  Future<List<Questao>> buscarQuestoes({bool apenasPublicas = false}) async {
    try {
      final user = _supabase.auth.currentUser;
      final query = _supabase.from('questions').select();

      if (apenasPublicas) {
        query.eq('is_public', true);
      } else if (user != null) {
        query.or('is_public.eq.true,professor_id.eq.${user.id}');
      } else {
        query.eq('is_public', true);
      }

      final data = await query;
      return data.map((json) => Questao.fromJson(json)).toList();
    } catch (e) {
      print('Erro ao buscar questões: $e');
      return [];
    }
  }

  String gerarNovoId() {
    return const Uuid().v4();
  }

  Future<int> getQuestaoNumero(String questaoId) async {
    try {
      final response = await _supabase
          .from('questions')
          .select('id')
          .order('created_at', ascending: true);

      final questoes = response as List;
      final index = questoes.indexWhere((q) => q['id'] == questaoId);
      return index + 1;
    } catch (e) {
      print('Erro ao buscar número da questão: $e');
      return 0;
    }
  }

  Future<int> getTotalQuestoes() async {
    try {
      final questoes = await carregarQuestoes();
      return questoes.length;
    } catch (e) {
      print('Erro ao obter total de questões: $e');
      return 0;
    }
  }

  Future<List<String>> getAvailableFilters() async {
    try {
      final questoes = await carregarQuestoes();
      final Map<String, Set<String>> filters = {
        'Disciplina': questoes.map((q) => q.disciplina).toSet(),
        'Assunto': questoes.map((q) => q.assunto).toSet(),
        'Banca': questoes.map((q) => q.banca ?? '').where((b) => b.isNotEmpty).toSet(),
        'Órgão': questoes.map((q) => q.orgao ?? '').where((o) => o.isNotEmpty).toSet(),
        'Ano': questoes.map((q) => q.ano ?? '').where((a) => a.isNotEmpty).toSet(),
        'Autor': questoes.map((q) => q.autor ?? '').where((a) => a.isNotEmpty).toSet(),
      };

      final List<String> availableFilters = [];
      
      filters.forEach((key, values) {
        if (values.isNotEmpty) {
          availableFilters.add(key);
        }
      });
      
      // Add static filters that don't depend on field values
      availableFilters.add('Tipo'); // Para filtrar questões inéditas/públicas
      
      return availableFilters;
    } catch (e) {
      print('Erro ao obter filtros disponíveis: $e');
      return [];
    }
  }
}
