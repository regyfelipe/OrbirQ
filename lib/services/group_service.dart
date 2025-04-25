import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import '../models/group.dart';

class GroupService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> createGroup({
    required String name,
    required String description,
    required List<String> invitedEmails,
  }) async {
    try {
      print('=== Iniciando criação do grupo ===');
      print('Nome: $name');
      print('Descrição: $description');
      print('Emails convidados: $invitedEmails');

      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('Erro: Usuário não está autenticado');
        return {
          'success': false,
          'message': 'Usuário não está autenticado',
          'data': null
        };
      }

      final userProfile = await _supabase
          .from('profiles')
          .select('user_type')
          .eq('id', user.id)
          .single();

      if (userProfile['user_type'] != 'professor') {
        print('Erro: Apenas professores podem criar grupos');
        return {
          'success': false,
          'message': 'Apenas professores podem criar grupos',
          'data': null
        };
      }

      print('Tentando inserir grupo na tabela groups...');
      final response = await _supabase
          .from('groups')
          .insert({
            'name': name,
            'description': description,
            'created_by': user.id,
          })
          .select()
          .single();

      print('Grupo criado com sucesso: ${response.toString()}');
      final groupId = response['id'];

      final membersToAdd = <Map<String, dynamic>>[];
      final invitesToCreate = <Map<String, dynamic>>[];

      for (final email in invitedEmails) {
        final existingUser = await _supabase
            .from('profiles')
            .select()
            .eq('email', email)
            .maybeSingle();

        if (existingUser != null) {
          membersToAdd.add({
            'group_id': groupId,
            'user_id': existingUser['id'],
          });
        } else {
          invitesToCreate.add({
            'group_id': groupId,
            'email': email,
            'created_by': user.id,
          });
        }
      }

      if (membersToAdd.isNotEmpty) {
        await _supabase.from('group_members').insert(membersToAdd);
      }

      if (invitesToCreate.isNotEmpty) {
        await _supabase.from('group_invites').insert(invitesToCreate);
      }

      print('Processo de criação do grupo concluído com sucesso');
      return {
        'success': true,
        'message': 'Grupo criado com sucesso!',
        'data': response
      };
    } catch (e, stackTrace) {
      print('=== ERRO AO CRIAR GRUPO ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Erro ao criar grupo: ${e.toString()}',
        'data': null
      };
    }
  }

  Future<List<Map<String, dynamic>>> getMyGroups() async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      final response = await _supabase
          .from('groups')
          .select('*, group_members!inner(*)')
          .eq('group_members.user_id', userId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Erro ao buscar grupos: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getGroupDetails(String groupId) async {
    try {
      final response = await _supabase
          .from('groups')
          .select('*, group_members(profiles(*))')
          .eq('id', groupId)
          .single();

      return response;
    } catch (e) {
      throw Exception('Erro ao buscar detalhes do grupo: ${e.toString()}');
    }
  }

  Future<void> acceptInvite(String inviteId) async {
    try {
      print('=== Aceitando convite $inviteId ===');

      final invite = await _supabase.from('group_invites').select('''
            *,
            groups!inner (
              id,
              name,
              description,
              created_at,
              profiles!groups_created_by_fkey (
                id,
                name,
                email
              )
            )
          ''').eq('id', inviteId).single();

      print('Convite encontrado: $invite');

      if (invite == null) {
        throw Exception('Convite não encontrado ou grupo não existe mais');
      }

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuário não está autenticado');
      }

      print('Adicionando usuário $userId ao grupo ${invite['group_id']}');

      await _supabase
          .from('group_invites')
          .update({'status': 'accepted'}).eq('id', inviteId);

      print('Status do convite atualizado para accepted');

      await _supabase.from('group_members').insert({
        'group_id': invite['group_id'],
        'user_id': userId,
        'joined_at': DateTime.now().toIso8601String(),
      });

      print('Usuário adicionado como membro com sucesso');
    } catch (e, stackTrace) {
      print('=== ERRO AO ACEITAR CONVITE ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');

      if (e.toString().contains('42501')) {
        throw Exception('Você não tem permissão para aceitar este convite');
      }

      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> declineInvite(String inviteId) async {
    try {
      await _supabase
          .from('group_invites')
          .update({'status': 'declined'}).eq('id', inviteId);
    } catch (e) {
      throw Exception('Erro ao recusar convite: ${e.toString()}');
    }
  }

  Future<List<Group>> getGroups() async {
    try {
      print('=== Buscando grupos ===');
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('Usuário não autenticado');
        return [];
      }

      print('Buscando tipo do usuário...');
      final userProfile = await _supabase
          .from('profiles')
          .select('user_type')
          .eq('id', user.id)
          .single();

      final isTeacher = userProfile['user_type'] == 'professor';
      print('É professor? $isTeacher');

      List response;
      if (isTeacher) {
        response = await _supabase
            .from('groups')
            .select('''
              *,
              profiles!groups_created_by_fkey(*),
              group_members(*)
            ''')
            .eq('created_by', user.id)
            .order('created_at', ascending: false);
      } else {
        response = await _supabase.from('group_members').select('''
              groups (
                *,
                profiles!groups_created_by_fkey(*)
              )
            ''').eq('user_id', user.id);

        response = response.map((item) => item['groups']).toList();
      }

      print('Grupos encontrados: ${response.length}');
      print('Resposta: $response');

      return response.map((group) => Group.fromJson(group)).toList();
    } catch (e, stackTrace) {
      print('=== ERRO AO BUSCAR GRUPOS ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<int> getGroupMembersCount(String groupId) async {
    try {
      print('=== Contando membros do grupo $groupId ===');

      final groupInfo = await _supabase
          .from('groups')
          .select('created_by')
          .eq('id', groupId)
          .single();

      final membersCount = await _supabase
          .from('group_members')
          .select()
          .eq('group_id', groupId);

      final totalCount =
          1 + (membersCount as List).length; 
      print('Total de membros encontrados: $totalCount');
      return totalCount;
    } catch (e, stackTrace) {
      print('=== ERRO AO CONTAR MEMBROS ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      return 0;
    }
  }

  Future<List<GroupMember>> getGroupMembers(String groupId) async {
    try {
      final adminInfo = await _supabase
          .from('profiles')
          .select('id, name')
          .eq('id', _supabase.auth.currentUser!.id)
          .single();

      final response = await _supabase
          .from('group_members')
          .select('*, profiles:user_id(*)')
          .eq('group_id', groupId)
          .neq('user_id', _supabase.auth.currentUser!.id);

      List<GroupMember> groupMembers = [];

      final professor = GroupMember(
        id: adminInfo['id'],
        name: adminInfo['name'],
        imageUrl: '',
        isAdmin: true,
        joinedAt: DateTime.now(),
      );
      groupMembers.add(professor);

      for (final member in response) {
        final profile = member['profiles'] as Map<String, dynamic>;
        groupMembers.add(GroupMember(
          id: profile['id'],
          name: profile['name'],
          imageUrl: profile['avatar_url'] ?? '',
          isAdmin: false,
          joinedAt: DateTime.parse(member['joined_at']),
        ));
      }

      return groupMembers;
    } catch (e) {
      print('Erro ao buscar membros do grupo: $e');
      throw Exception('Falha ao carregar membros do grupo');
    }
  }

  Future<List<GroupMessage>> getGroupMessages(String groupId) async {
    try {
      print('=== Buscando mensagens do grupo $groupId ===');

      final response = await _supabase
          .from('group_messages')
          .select('*, profiles:user_id(*)')
          .eq('group_id', groupId)
          .order('created_at');

      print('Mensagens encontradas: ${response.length}');

      return (response as List).map((msg) {
        final profile = msg['profiles'] as Map<String, dynamic>;
        return GroupMessage(
          id: msg['id'],
          senderId: msg['user_id'],
          senderName: profile['name'] ?? 'Usuário',
          content: msg['content'],
          timestamp: DateTime.parse(msg['created_at']),
          attachmentUrl: msg['attachment_url'],
        );
      }).toList();
    } catch (e, stackTrace) {
      print('=== ERRO AO BUSCAR MENSAGENS ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<bool> sendMessage(String groupId, String content,
      {String? attachmentUrl}) async {
    try {
      print('=== Enviando mensagem para o grupo $groupId ===');
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        print('Erro: Usuário não está autenticado');
        return false;
      }

      await _supabase.from('group_messages').insert({
        'group_id': groupId,
        'user_id': userId,
        'content': content,
        'attachment_url': attachmentUrl,
      });

      print('Mensagem enviada com sucesso');
      return true;
    } catch (e, stackTrace) {
      print('=== ERRO AO ENVIAR MENSAGEM ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  Stream<List<GroupMessage>> getGroupMessagesStream(String groupId) {
    return _supabase
        .from('group_messages')
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId)
        .order('created_at')
        .map((list) => list
            .map((msg) => GroupMessage(
                  id: msg['id'],
                  senderId: msg['user_id'],
                  senderName: msg['profiles']?['name'] ?? 'Usuário',
                  content: msg['content'],
                  timestamp: DateTime.parse(msg['created_at']),
                  attachmentUrl: msg['attachment_url'],
                ))
            .toList());
  }

  Future<bool> updateGroup(String groupId,
      {String? name, String? description}) async {
    try {
      print('=== Atualizando grupo $groupId ===');
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        print('Erro: Usuário não está autenticado');
        return false;
      }

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;

      await _supabase
          .from('groups')
          .update(updates)
          .eq('id', groupId)
          .eq('created_by', userId);

      print('Grupo atualizado com sucesso');
      return true;
    } catch (e, stackTrace) {
      print('=== ERRO AO ATUALIZAR GRUPO ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<bool> deleteGroup(String groupId) async {
    try {
      print('=== Deletando grupo $groupId ===');
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        print('Erro: Usuário não está autenticado');
        return false;
      }

      await _supabase
          .from('groups')
          .delete()
          .eq('id', groupId)
          .eq('created_by', userId);

      print('Grupo deletado com sucesso');
      return true;
    } catch (e, stackTrace) {
      print('=== ERRO AO DELETAR GRUPO ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getPendingInvites() async {
    try {
      print('\n=== Buscando convites pendentes ===');
      final user = _supabase.auth.currentUser;
      if (user == null || user.email == null) {
        print('❌ Usuário não autenticado ou sem email');
        return [];
      }

      final String userEmail = user.email!;
      print('📧 Buscando convites para: $userEmail');

      print('🔍 Buscando convites sem join...');
      final basicResponse = await _supabase
          .from('group_invites')
          .select()
          .eq('email', userEmail)
          .eq('status', 'pending');

      print('\n📋 Convites básicos encontrados: ${basicResponse.length}');
      if (basicResponse.isNotEmpty) {
        print('Primeiro convite:');
        print(basicResponse.first);
      }

      print('\n🔍 Buscando convites com join...');

      print('\n🔍 Verificando grupo ${basicResponse.first['group_id']}...');

      final response = await _supabase
          .from('group_invites')
          .select('*, groups(*)')
          .eq('email', userEmail)
          .eq('status', 'pending');

      print('\n📬 Resposta bruta:');
      print(response);

      print('\n📬 Convites encontrados: ${response.length}');
      if (response.isNotEmpty) {
        print('\n📋 Detalhes dos convites:');
        for (var invite in response) {
          print('''
📬 Detalhes do convite:
   - ID: ${invite['id']}
   - Email: ${invite['email']}
   - Status: ${invite['status']}
   - Group ID: ${invite['group_id']}
   - Groups data: ${invite['groups']}
            ''');
        }
      }

      if (response.isNotEmpty && response[0]['groups'] == null) {
        print('\n🔍 Tentando buscar grupo diretamente...');
        final groupId = response[0]['group_id'];
        try {
          final groupData = await _supabase
              .from('groups')
              .select('*, profiles:created_by(*)')
              .eq('id', groupId)
              .maybeSingle();  
              
          print('📋 Dados do grupo:');
          print(groupData);
          
          if (groupData != null) {
            response[0]['groups'] = groupData;
          } else {
            print('⚠️ Grupo não encontrado ou sem permissão de acesso');
            await _supabase
                .from('group_invites')
                .update({'status': 'invalid'})
                .eq('id', response[0]['id']);
            print('✅ Status do convite atualizado para invalid');
          }
        } catch (e) {
          print('❌ Erro ao buscar grupo: $e');
        }
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('\n❌ ERRO AO BUSCAR CONVITES');
      print('Detalhes do erro: $e');
      return [];
    }
  }

  Future<bool> isUserInGroup(String groupId) async {
    try {
      print('=== Verificando participação no grupo $groupId ===');
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        print('Usuário não está autenticado');
        return false;
      }

      final response = await _supabase
          .from('group_members')
          .select()
          .eq('group_id', groupId)
          .eq('user_id', userId)
          .maybeSingle();

      final isMember = response != null;
      print('Usuário ${isMember ? 'é' : 'não é'} membro do grupo');
      return isMember;
    } catch (e, stackTrace) {
      print('=== ERRO AO VERIFICAR PARTICIPAÇÃO NO GRUPO ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> checkPendingInvitesForUser() async {
    try {
      print('=== Verificando convites pendentes para o usuário ===');
      final user = _supabase.auth.currentUser;

      if (user == null || user.email == null) {
        print('Usuário não está autenticado ou sem email');
        return [];
      }

      final email = user.email!;
      print('Buscando convites para o email: $email');
      final response = await _supabase
          .from('group_invites')
          .select('*, groups(*), profiles!group_invites_created_by_fkey(*)')
          .eq('email', email)
          .filter('status', 'is', null)
          .order('created_at', ascending: false);

      print('Convites encontrados: ${(response as List).length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      print('=== ERRO AO VERIFICAR CONVITES PENDENTES ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<Map<String, dynamic>> getGroupMembershipStatus(String groupId) async {
    try {
      print('=== Verificando status no grupo $groupId ===');
      final user = _supabase.auth.currentUser;

      if (user == null || user.email == null) {
        print('Usuário não está autenticado ou sem email');
        return {
          'isMember': false,
          'hasInvite': false,
          'inviteStatus': null,
          'joinedAt': null
        };
      }

      final email = user.email!;

      final memberResponse = await _supabase
          .from('group_members')
          .select('joined_at')
          .eq('group_id', groupId)
          .eq('user_id', user.id)
          .maybeSingle();

      final inviteResponse = await _supabase
          .from('group_invites')
          .select('status, created_at')
          .eq('group_id', groupId)
          .eq('email', email)
          .maybeSingle();

      return {
        'isMember': memberResponse != null,
        'hasInvite': inviteResponse != null,
        'inviteStatus': inviteResponse?['status'],
        'joinedAt': memberResponse?['joined_at'],
      };
    } catch (e, stackTrace) {
      print('=== ERRO AO VERIFICAR STATUS NO GRUPO ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      return {
        'isMember': false,
        'hasInvite': false,
        'inviteStatus': null,
        'joinedAt': null
      };
    }
  }

  Future<Map<String, dynamic>> getGroupFullDetails(String groupId) async {
    try {
      print('=== Buscando detalhes completos do grupo $groupId ===');

      final groupInfo = await _supabase.from('groups').select('''
            *,
            profiles!groups_created_by_fkey (
              id,
              name,
              email,
              user_type
            )
          ''').eq('id', groupId).single();

      final members = await getGroupMembers(groupId);
      final messagesCount = await _supabase
          .from('group_messages')
          .select()
          .eq('group_id', groupId)
          .count();

      final currentUserId = _supabase.auth.currentUser?.id;
      final isAdmin = currentUserId == groupInfo['created_by'];

      return {
        'id': groupInfo['id'],
        'name': groupInfo['name'],
        'description': groupInfo['description'],
        'created_at': groupInfo['created_at'],
        'updated_at': groupInfo['updated_at'],
        'creator': {
          'id': groupInfo['profiles']['id'],
          'name': groupInfo['profiles']['name'],
          'email': groupInfo['profiles']['email'],
          'user_type': groupInfo['profiles']['user_type'],
        },
        'members': members,
        'members_count': members.length,
        'messages_count': messagesCount.count,
        'is_admin': isAdmin,
        'created_by': groupInfo['created_by'],
      };
    } catch (e, stackTrace) {
      print('=== ERRO AO BUSCAR DETALHES DO GRUPO ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<bool> inviteToGroup(String groupId, List<String> emails) async {
    try {
      print('\n=== Iniciando processo de envio de convites ===');
      print('Grupo ID: $groupId');
      print('Emails para convidar: ${emails.join(", ")}');

      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        print('❌ Erro: Usuário não está autenticado');
        throw Exception('Usuário não está autenticado');
      }

      final userProfile = await _supabase
          .from('profiles')
          .select('user_type')
          .eq('id', userId)
          .single();

      if (userProfile['user_type'] != 'professor') {
        print('❌ Erro: Apenas professores podem enviar convites');
        throw Exception('Apenas professores podem enviar convites');
      }

      final groupInfo = await _supabase
          .from('groups')
          .select('name, created_by')
          .eq('id', groupId)
          .single();

      if (groupInfo == null) {
        print('❌ Erro: Grupo não encontrado');
        throw Exception('Grupo não encontrado');
      }

      if (groupInfo['created_by'] != userId) {
        print('❌ Erro: Apenas o criador do grupo pode enviar convites');
        throw Exception('Apenas o criador do grupo pode enviar convites');
      }

      print('✓ Grupo encontrado: ${groupInfo['name']}');
      print('✓ Usuário é o criador do grupo');

      final existingUsers = await _supabase
          .from('profiles')
          .select('id, email')
          .filter('email', 'in', emails);

      final emailToId = Map.fromEntries(existingUsers.map(
          (user) => MapEntry(user['email'] as String, user['id'] as String)));

      final existingMembers = await _supabase
          .from('group_members')
          .select('user_id')
          .eq('group_id', groupId)
          .filter('user_id', 'in', emailToId.values.toList());

      final existingMemberIds =
          existingMembers.map((m) => m['user_id'] as String).toSet();
      final existingMemberEmails = emailToId.entries
          .where((entry) => existingMemberIds.contains(entry.value))
          .map((entry) => entry.key)
          .toSet();

      if (existingMemberEmails.isNotEmpty) {
        print('\n📝 Emails que já são membros:');
        for (var email in existingMemberEmails) {
          print('  • $email');
        }
      }

      final existingInvites = await _supabase
          .from('group_invites')
          .select('email')
          .eq('group_id', groupId)
          .eq('status', 'pending')
          .filter('email', 'in', emails);

      final pendingEmails =
          existingInvites.map((i) => i['email'] as String).toSet();

      if (pendingEmails.isNotEmpty) {
        print('\n📝 Emails com convites pendentes:');
        for (var email in pendingEmails) {
          print('  • $email');
        }
      }

      final emailsToInvite = emails
          .where((email) =>
              !existingMemberEmails.contains(email) &&
              !pendingEmails.contains(email))
          .toList();

      if (emailsToInvite.isEmpty) {
        print(
            '\n⚠️ Nenhum novo convite para enviar - todos os emails já são membros ou têm convites pendentes');
        return true;
      }

      print('\n📨 Enviando novos convites para:');
      for (var email in emailsToInvite) {
        print('  • $email');
      }

      final newInvites = emailsToInvite
          .map((email) => {
                'group_id': groupId,
                'email': email,
                'created_by': userId,
                'status': 'pending'
              })
          .toList();

      final insertedInvites =
          await _supabase.from('group_invites').insert(newInvites).select();

      print('\n✅ Convites inseridos no banco:');
      for (var invite in insertedInvites) {
        print('''
  • ID: ${invite['id']}
    - Email: ${invite['email']}
    - Status: ${invite['status']}
    - Created At: ${invite['created_at']}
        ''');
      }

      print('\n✅ Processo finalizado com sucesso!');
      print('Total de convites enviados: ${insertedInvites.length}');
      print('=== Fim do processo de envio de convites ===\n');

      return true;
    } catch (e) {
      print('\n❌ ERRO AO ENVIAR CONVITES');
      print('Detalhes do erro: $e');
      throw Exception('Erro ao enviar convites: ${e.toString()}');
    }
  }
}
