import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group_message.dart';
import 'dart:async';

class GroupMessageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _channel;
  final _messagesController = StreamController<List<GroupMessage>>.broadcast();
  List<GroupMessage> _currentMessages = [];

  Stream<List<GroupMessage>> getGroupMessages(String groupId) {
    _channel = _supabase.channel(
      'group_messages:$groupId',
      opts: const RealtimeChannelConfig(
        key: 'id',
        ack: true,
      ),
    );

    _channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'group_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'group_id',
            value: groupId,
          ),
          callback: (payload) async {
            print('Mudança detectada: $payload'); 
            await _refreshMessages(groupId);
          },
        )
        .subscribe();

    _refreshMessages(groupId);

    return _messagesController.stream;
  }

  Future<void> _refreshMessages(String groupId) async {
    try {
      final response = await _supabase
          .from('group_messages')
          .select()
          .eq('group_id', groupId)
          .order('created_at', ascending: true);

      _currentMessages = response
          .map((row) => GroupMessage(
                id: row['id'],
                groupId: row['group_id'],
                userId: row['user_id'],
                senderName: row['sender_name'] ?? 'Usuário',
                content: row['content'],
                attachmentUrl: row['attachment_url'],
                createdAt: DateTime.parse(row['created_at']),
              ))
          .toList();
      _currentMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      if (!_messagesController.isClosed) {
        _messagesController.add(_currentMessages);
      }
    } catch (e) {
      print('Erro ao atualizar mensagens: $e');
    }
  }

  Future<void> sendMessage({
    required String groupId,
    required String content,
    String? attachmentUrl,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    try {
      print('Enviando mensagem para o grupo $groupId'); 

      final profile =
          await _supabase.from('profiles').select().eq('id', user.id).single();

      final timestamp = DateTime.now().toUtc().toIso8601String();

      await _supabase.from('group_messages').insert({
        'group_id': groupId,
        'user_id': user.id,
        'sender_name': profile['name'],
        'content': content,
        'attachment_url': attachmentUrl,
        'created_at': timestamp,
      });

      print('Mensagem enviada com sucesso: $content'); 

      await _refreshMessages(groupId);
    } catch (e) {
      print('Erro ao enviar mensagem: $e'); 
      rethrow;
    }
  }

  Future<List<GroupMessage>> getOldMessages(String groupId,
      {int limit = 50}) async {
    try {
      print('Buscando mensagens antigas do grupo $groupId'); 

      final response = await _supabase
          .from('group_messages')
          .select()
          .eq('group_id', groupId)
          .order('created_at', ascending: true)
          .limit(limit);

      print('Encontradas ${response.length} mensagens antigas'); 
      return response
          .map((row) => GroupMessage(
                id: row['id'],
                groupId: row['group_id'],
                userId: row['user_id'],
                senderName: row['sender_name'] ?? 'Usuário',
                content: row['content'],
                attachmentUrl: row['attachment_url'],
                createdAt: DateTime.parse(row['created_at']),
              ))
          .toList()
          .cast<GroupMessage>();
    } catch (e) {
      print('Erro ao buscar mensagens antigas: $e'); 
      rethrow;
    }
  }

  void dispose() {
    _channel?.unsubscribe();
    _messagesController.close();
  }
}
