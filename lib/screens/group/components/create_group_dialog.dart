import 'package:flutter/material.dart';
import '../../../services/group_service.dart';
import '../../../services/user_service.dart';
import '../../../themes/colors.dart';

class CreateGroupDialog extends StatefulWidget {
  final List<String> selectedUserIds;

  const CreateGroupDialog({
    Key? key,
    this.selectedUserIds = const [],
  }) : super(key: key);

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _emailController = TextEditingController();
  final _groupService = GroupService();
  final _userService = UserService();
  final List<String> _emailsConvidados = [];
  bool _isLoading = false;
  bool _isTeacher = false;

  @override
  void initState() {
    super.initState();
    _checkUserType();
    _loadSelectedUsers();
  }

  Future<void> _checkUserType() async {
    final isTeacher = await _userService.isTeacher();
    setState(() => _isTeacher = isTeacher);
  }

  Future<void> _loadSelectedUsers() async {
    if (widget.selectedUserIds.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      for (final userId in widget.selectedUserIds) {
        final user = await _userService.getUserById(userId);
        if (user != null) {
          _emailsConvidados.add(user['email']);
        }
      }
    } catch (e) {
      print('Erro ao carregar usuários selecionados: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _adicionarEmail() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty && email.contains('@')) {
      setState(() {
        _emailsConvidados.add(email);
        _emailController.clear();
      });
    }
  }

  void _removerEmail(String email) {
    setState(() {
      _emailsConvidados.remove(email);
    });
  }

  Future<void> _createGroup() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        setState(() => _isLoading = true);

        final isTeacher = await _userService.isTeacher();
        if (!isTeacher) {
          throw Exception('Apenas professores podem criar grupos');
        }

        final result = await _groupService.createGroup(
          name: _nomeController.text,
          description: _descricaoController.text,
          invitedEmails: _emailsConvidados,
        );

        if (result['success'] == true) {
          Navigator.of(context).pop(true);
        } else {
          throw Exception(result['message']);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar grupo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Criar Novo Grupo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Grupo',
                    hintText: 'Ex: Grupo de Estudos Direito Penal',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um nome para o grupo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    hintText: 'Descreva o objetivo do grupo',
                  ),
                  maxLines: 3,
                ),
                if (_isTeacher) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Convidar Alunos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email do aluno',
                            hintText: 'email@exemplo.com',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _adicionarEmail,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                if (_emailsConvidados.isNotEmpty) ...[
                  const Text(
                    'Alunos a serem convidados:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _emailsConvidados.map((email) {
                      return Chip(
                        label: Text(email),
                        onDeleted: () => _removerEmail(email),
                        backgroundColor:
                            AppColors.primaryLight.withOpacity(0.1),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createGroup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Criar Grupo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
