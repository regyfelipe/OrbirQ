import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/group.dart';
import '../../../themes/colors.dart';
import '../group_chat_page.dart';
import '../../../services/group_service.dart';
import '../../../services/user_service.dart';

class GroupList extends StatefulWidget {
  const GroupList({Key? key}) : super(key: key);

  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  final GroupService _groupService = GroupService();
  final UserService _userService = UserService();
  List<Group> grupos = [];
  bool isLoading = true;
  bool _isTeacher = false;

  @override
  void initState() {
    super.initState();
    _checkUserType();
    _loadGroups();
  }

  Future<void> _checkUserType() async {
    final isTeacher = await _userService.isTeacher();
    setState(() => _isTeacher = isTeacher);
  }

  Future<void> _loadGroups() async {
    try {
      final groups = await _groupService.getGroups();
      setState(() {
        grupos = groups;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar grupos: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showEditDialog(Group grupo) async {
    final nameController = TextEditingController(text: grupo.name);
    final descriptionController =
        TextEditingController(text: grupo.description);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Grupo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Grupo',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await _groupService.updateGroup(
                grupo.id,
                name: nameController.text,
                description: descriptionController.text,
              );
              if (mounted) {
                Navigator.of(context).pop(success);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result == true) {
      _loadGroups();
    }
  }

  Future<void> _showDeleteDialog(Group grupo) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Grupo'),
        content:
            Text('Tem certeza que deseja deletar o grupo "${grupo.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await _groupService.deleteGroup(grupo.id);
              if (mounted) {
                Navigator.of(context).pop(success);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (result == true) {
      _loadGroups();
    }
  }

  void _showGroupOptions(Group grupo) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Editar Grupo'),
            onTap: () {
              Navigator.pop(context);
              _showEditDialog(grupo);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red[700]),
            title: Text(
              'Deletar Grupo',
              style: TextStyle(color: Colors.red[700]),
            ),
            onTap: () {
              Navigator.pop(context);
              _showDeleteDialog(grupo);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (grupos.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum grupo encontrado',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGroups,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: grupos.length,
        itemBuilder: (context, index) {
          final grupo = grupos[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupChatPage(group: grupo),
                  ),
                );
              },
              onLongPress: _isTeacher ? () => _showGroupOptions(grupo) : null,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    grupo.name.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  grupo.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(grupo.description ?? 'Sem descrição'),
                    const SizedBox(height: 4),
                    FutureBuilder<int>(
                      future: _groupService.getGroupMembersCount(grupo.id),
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        return Text(
                          '$count membros',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
