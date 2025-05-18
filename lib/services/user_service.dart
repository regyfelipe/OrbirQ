import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_type.dart';
import 'dart:developer' as developer;

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      print('=== BUSCANDO USUÁRIOS NO BANCO ===');

      final currentUser = await getCurrentUserProfile();
      if (currentUser == null) {
        print('Usuário atual não encontrado');
        return [];
      }

      final isTeacher = currentUser['user_type'] == 'professor';
      print('Usuário atual é professor? $isTeacher');

      final query = _supabase
          .from('profiles')
          .select('id, name, email, user_type')
          .neq('id', currentUser['id']); 
      if (isTeacher) {
        query.eq('user_type', 'aluno');
      } else {
        query.eq('user_type', 'professor');
      }

      final response = await query.order('name');
      print('Total de usuários encontrados: ${response.length}');
      print('Usuários: $response');

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      print('=== ERRO AO BUSCAR USUÁRIOS ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Erro ao buscar usuários: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final response =
          await _supabase.from('profiles').select().eq('id', userId).single();

      return response;
    } catch (e) {
      print('Erro ao buscar usuário $userId: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('Usuário não autenticado');
        return null;
      }

      print('Buscando perfil do usuário ${user.id}');

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        print('Perfil não encontrado, criando novo perfil...');
        final newProfile = {
          'id': user.id,
          'email': user.email,
          'name': user.email?.split('@')[0] ?? 'Usuário',
          'user_type': 'aluno'
        };

        await _supabase.from('profiles').insert(newProfile);
        return newProfile;
      }

      print('Perfil encontrado: $response');
      return response;
    } catch (e, stackTrace) {
      print('=== ERRO AO BUSCAR PERFIL ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<bool> isTeacher() async {
    try {
      final user = await getCurrentUserProfile();
      if (user == null) return false;
      return user['user_type'] == 'professor';
    } catch (e) {
      print('Erro ao verificar tipo de usuário: $e');
      return false;
    }
  }

  Future<void> updateUserType(UserType userType) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      print('Atualizando tipo de usuário para: ${userType.name}');
      await _supabase
          .from('profiles')
          .update({'user_type': userType.name}).eq('id', userId);
    } catch (e) {
      print('Erro ao atualizar tipo de usuário: $e');
      throw Exception('Erro ao atualizar tipo de usuário: $e');
    }
  }

  Future<void> setAsTeacher() async {
    await updateUserType(UserType.professor);
  }

  Future<void> setAsStudent() async {
    await updateUserType(UserType.aluno);
  }
}
