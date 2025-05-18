import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../services/group_service.dart';
import '../../themes/colors.dart';
import '../../models/user_type.dart';
import 'components/group_list.dart';
import 'components/create_group_dialog.dart';
import 'components/pending_invites_dialog.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({Key? key}) : super(key: key);

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage>
    with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  final GroupService _groupService = GroupService();
  late TabController _tabController;
  bool _isGridView = true;
  bool _isLoading = true;
  bool _isTeacher = false;
  List<Map<String, dynamic>> _users = [];
  final Set<String> _selectedUsers = {};
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('=== CARREGANDO USUÁRIOS ===');

      final isTeacher = await _userService.isTeacher();
      print('Usuário atual é professor? $isTeacher');

      final users = await _userService.getUsers();
      print('Total de usuários encontrados: ${users.length}');

      setState(() {
        _users = users;
        _isTeacher = isTeacher;
        _isLoading = false;
      });

      print('=== CARREGAMENTO COMPLETO ===');
      print('Total de usuários filtrados: ${_filteredUsers.length}');
    } catch (e, stackTrace) {
      print('=== ERRO AO CARREGAR USUÁRIOS ===');
      print('Erro: $e');
      print('Stack trace: $stackTrace');

      setState(() {
        _isLoading = false;
      });

      // Mostrar mensagem de erro para o usuário
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar usuários: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    print('=== FILTRANDO USUÁRIOS ===');
    print('Total de usuários: ${_users.length}');
    print('É professor? $_isTeacher');

    return _users.where((user) {
      final userType = UserType.fromString(user['user_type']);
      print('Verificando usuário: ${user['name']} - Tipo: ${userType.name}');

      if (_isTeacher) {
        final shouldShow = userType == UserType.aluno;
        print('Professor vendo aluno? $shouldShow');
        return shouldShow;
      }

      if (!_isTeacher) {
        final shouldShow = userType == UserType.professor;
        print('Aluno vendo professor? $shouldShow');
        return shouldShow;
      }

      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        final name = user['name'].toString().toLowerCase();
        final email = user['email'].toString().toLowerCase();
        final query = _searchQuery!.toLowerCase();
        return name.contains(query) || email.contains(query);
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        title: Text(_isTeacher ? 'Meus Alunos' : 'Meus Professores'),
        actions: [
          if (!_isTeacher) 
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const PendingInvitesDialog(),
                ).then((_) {
                  setState(() {});
                });
              },
            ),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.5),
          tabs: const [
            Tab(text: 'USUÁRIOS'),
            Tab(text: 'GRUPOS'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMainContent(),
                const GroupList(),
              ],
            ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    if (_tabController.index == 1) {
      return FloatingActionButton.extended(
        onPressed: () => _showCreateGroupDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.group_add, color: Colors.white),
        label: const Text('Novo Grupo', style: TextStyle(color: Colors.white)),
      );
    }

    if (_selectedUsers.isNotEmpty && _isTeacher) {
      return FloatingActionButton.extended(
        onPressed: () => _showCreateGroupDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.group_add, color: Colors.white),
        label: const Text('Criar Grupo', style: TextStyle(color: Colors.white)),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: _isGridView ? _buildGridView() : _buildListView(),
        ),
        if (_selectedUsers.isNotEmpty) _buildBottomBar(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Pesquisar usuários...',
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        final isSelected = _selectedUsers.contains(user['id']);
        final userType = UserType.fromString(user['user_type']);

        return InkWell(
          onTap: () => _toggleUser(user['id']),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor:
                          isSelected ? AppColors.primary : AppColors.surface,
                      child: Text(
                        user['name'].toString().substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Positioned(
                        right: 0,
                        top: 0,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.green,
                          child:
                              Icon(Icons.check, color: Colors.white, size: 16),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  user['name'].toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  user['email'].toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: userType == UserType.professor
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    userType.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: userType == UserType.professor
                          ? AppColors.primary
                          : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        final isSelected = _selectedUsers.contains(user['id']);
        final userType = UserType.fromString(user['user_type']);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            onTap: () => _toggleUser(user['id']),
            contentPadding: const EdgeInsets.all(8),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor:
                  isSelected ? AppColors.primary : AppColors.surface,
              child: Text(
                user['name'].toString().substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
              ),
            ),
            title: Text(
              user['name'].toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(user['email'].toString()),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: userType == UserType.professor
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    userType.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: userType == UserType.professor
                          ? AppColors.primary
                          : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            trailing: isSelected
                ? const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.check, color: Colors.white, size: 16),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '${_selectedUsers.length} selecionados',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => setState(() => _selectedUsers.clear()),
            icon: Icon(Icons.clear, color: AppColors.error),
            label: Text(
              'Limpar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleUser(String id) {
    setState(() {
      if (_selectedUsers.contains(id)) {
        _selectedUsers.remove(id);
      } else {
        _selectedUsers.add(id);
      }
    });
  }

  void _showCreateGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateGroupDialog(),
    ).then((created) {
      if (created == true) {
        setState(() => _selectedUsers.clear());
        _loadUsers();
      }
    });
  }
}
