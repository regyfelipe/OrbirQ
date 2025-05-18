import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/group.dart'
    hide GroupMessage; 
import '../../models/group_message.dart'; 
import '../../themes/colors.dart';
import '../../services/group_service.dart';
import '../../services/group_message_service.dart';
import 'components/group_message_item.dart';
import 'components/group_message_input.dart';
import 'components/group_members_list.dart';

class GroupChatPage extends StatefulWidget {
  final Group group;

  const GroupChatPage({
    Key? key,
    required this.group,
  }) : super(key: key);

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GroupService _groupService = GroupService();
  final GroupMessageService _messageService = GroupMessageService();
  final _supabase = Supabase.instance.client;
  bool _showMembers = false;
  bool _isUploading = false;
  bool _shouldScroll = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent) {
      _shouldScroll = false;
    }
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      _shouldScroll = true;
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients && _shouldScroll) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        title: InkWell(
          onTap: () async {
            final details =
                await _groupService.getGroupFullDetails(widget.group.id);
            if (mounted) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 4,
                        width: 40,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            // Cabeçalho com foto e nome do grupo
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: AppColors.primary,
                                  child: Text(
                                    widget.group.name
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.group.name,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (details['creator'] != null)
                                        Text(
                                          'Criado por ${details['creator']['name']}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      Text(
                                        'Criado em ${_formatDate(details['created_at'])}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Descrição do grupo
                            if (details['description'] != null &&
                                details['description'].toString().isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Descrição',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    details['description'],
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatistic(
                                  'Membros',
                                  details['members_count'].toString(),
                                  Icons.group,
                                ),
                                _buildStatistic(
                                  'Mensagens',
                                  details['messages_count'].toString(),
                                  Icons.message,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Membros do grupo',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (details['is_admin'])
                                  IconButton(
                                    icon: const Icon(Icons.person_add),
                                    onPressed: () {
                                      // Fechar o modal atual
                                      Navigator.pop(context);
                                      // Mostrar diálogo de convite
                                      _showInviteDialog();
                                    },
                                    tooltip: 'Convidar pessoas',
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...details['members']
                                .map<Widget>((member) => ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppColors.primary,
                                        child: Text(
                                          member.name
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                      title: Text(member.name),
                                      subtitle: Text(
                                        member.isAdmin
                                            ? 'Administrador'
                                            : 'Membro',
                                        style: TextStyle(
                                          color: member.isAdmin
                                              ? AppColors.primary
                                              : Colors.grey,
                                        ),
                                      ),
                                      trailing: Text(
                                        'Entrou em ${_formatDate(member.joinedAt.toString())}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.group.name),
              FutureBuilder<int>(
                future: _groupService.getGroupMembersCount(widget.group.id),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  return Text(
                    '$count membros',
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_showMembers ? Icons.group_off : Icons.group),
            onPressed: () {
              setState(() {
                _showMembers = !_showMembers;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showMembers)
            FutureBuilder<List<GroupMember>>(
              future: _groupService.getGroupMembers(widget.group.id),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GroupMembersList(members: snapshot.data!);
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                  ),
                ),
                StreamBuilder<List<GroupMessage>>(
                  stream: _messageService.getGroupMessages(widget.group.id),
                  builder:
                      (context, AsyncSnapshot<List<GroupMessage>> snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Erro: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final messages = snapshot.data!;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });

                    if (messages.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhuma mensagem ainda.\nSeja o primeiro a enviar!',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe =
                            message.userId == _supabase.auth.currentUser?.id;
                        return GroupMessageItem(
                          message: message,
                          isMe: isMe,
                        );
                      },
                    );
                  },
                ),
                if (_isUploading)
                  Container(
                    color: Colors.black45,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
          GroupMessageInput(
            controller: _messageController,
            onSendPressed: _handleSendMessage,
            onAttachPressed: _handleAttachFile,
          ),
        ],
      ),
    );
  }

  void _handleSendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      try {
        await _messageService.sendMessage(
          groupId: widget.group.id,
          content: _messageController.text,
        );
        _messageController.clear();
        _shouldScroll = true;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar mensagem: $e')),
        );
      }
    }
  }

  void _handleAttachFile() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Foto da Galeria'),
              onTap: () async {
                Navigator.pop(context);
                await _pickAndUploadImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar Foto'),
              onTap: () async {
                Navigator.pop(context);
                await _pickAndUploadImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Documento'),
              onTap: () async {
                Navigator.pop(context);
                await _pickAndUploadFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      setState(() => _isUploading = true);

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        final file = await pickedFile.readAsBytes();
        final fileExt = pickedFile.name.split('.').last;
        final fileName =
            'chat_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

        await _supabase.storage
            .from('chat_attachments')
            .uploadBinary(fileName, file);

        final fileUrl =
            _supabase.storage.from('chat_attachments').getPublicUrl(fileName);

        await _messageService.sendMessage(
          groupId: widget.group.id,
          content: '📎 Imagem',
          attachmentUrl: fileUrl,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar arquivo: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _pickAndUploadFile() async {
    try {
      setState(() => _isUploading = true);

      final result = await FilePicker.platform.pickFiles();

      if (result != null) {
        final file = result.files.single;
        final fileName =
            'chat_${DateTime.now().millisecondsSinceEpoch}_${file.name}';

        await _supabase.storage
            .from('chat_attachments')
            .uploadBinary(fileName, file.bytes!);

        final fileUrl =
            _supabase.storage.from('chat_attachments').getPublicUrl(fileName);

        await _messageService.sendMessage(
          groupId: widget.group.id,
          content: '📎 Arquivo: ${file.name}',
          attachmentUrl: fileUrl,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar arquivo: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  String _formatDate(String date) {
    final dt = DateTime.parse(date);
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Widget _buildStatistic(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Convidar para o grupo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Digite o email da pessoa que você deseja convidar para o grupo.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'exemplo@email.com',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Digite um email válido')),
                );
                return;
              }

              try {
                final success = await _groupService.inviteToGroup(
                  widget.group.id,
                  [email],
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Convite enviado com sucesso!'
                            : 'Erro ao enviar convite. Verifique se você tem permissão.',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao enviar convite: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Convidar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageService.dispose();
    super.dispose();
  }
}
