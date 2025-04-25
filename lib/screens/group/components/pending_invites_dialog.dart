import 'package:flutter/material.dart';
import '../../../services/group_service.dart';
import '../../../themes/colors.dart';

class PendingInvitesDialog extends StatefulWidget {
  const PendingInvitesDialog({Key? key}) : super(key: key);

  @override
  State<PendingInvitesDialog> createState() => _PendingInvitesDialogState();
}

class _PendingInvitesDialogState extends State<PendingInvitesDialog> {
  final GroupService _groupService = GroupService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _invites = [];

  @override
  void initState() {
    super.initState();
    _loadInvites();
  }

  Future<void> _loadInvites() async {
    try {
      print('\n=== Iniciando carregamento de convites ===');
      setState(() => _isLoading = true);

      print('📥 Chamando getPendingInvites...');
      final invites = await _groupService.getPendingInvites();

      print('📊 Convites recebidos: ${invites.length}');
      if (invites.isNotEmpty) {
        print('\nℹ️ Primeiro convite da lista:');
        print(invites.first);
      }

      setState(() {
        _invites = invites;
        _isLoading = false;
      });
      print('✅ Lista de convites atualizada no estado');
    } catch (e, stackTrace) {
      print('\n❌ ERRO AO CARREGAR CONVITES');
      print('Erro: $e');
      print('Stack trace: $stackTrace');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleInvite(String inviteId, bool accept) async {
    try {
      setState(() => _isLoading = true);

      if (accept) {
        await _groupService.acceptInvite(inviteId);
      } else {
        await _groupService.declineInvite(inviteId);
      }

      await _loadInvites();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                accept ? 'Convite aceito com sucesso!' : 'Convite recusado'),
            backgroundColor: accept ? Colors.green : Colors.grey,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        if (e.toString().contains('grupo foi deletado')) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Grupo Indisponível'),
              content: const Text(
                'O grupo deste convite não existe mais. O convite foi automaticamente removido.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _loadInvites(); // Recarregar a lista de convites
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao processar convite: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Convites Pendentes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadInvites,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_invites.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Nenhum convite pendente',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _invites.length,
                  itemBuilder: (context, index) {
                    final invite = _invites[index];
                    final groupData = invite['groups'];
                    final bool isGroupAvailable = groupData != null;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          isGroupAvailable
                              ? groupData['name']
                              : 'Grupo Indisponível',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isGroupAvailable ? null : Colors.red,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isGroupAvailable)
                              const Text(
                                'Este grupo não está mais disponível ou foi removido. Você pode recusar este convite.',
                                style: TextStyle(color: Colors.red),
                              )
                            else ...[
                              Text(groupData['description'] ?? 'Sem descrição'),
                              const SizedBox(height: 4),
                              if (isGroupAvailable &&
                                  groupData['profiles'] != null)
                                Text(
                                  'Professor: ${groupData['profiles']['name']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isGroupAvailable)
                              IconButton(
                                icon: const Icon(Icons.check),
                                color: Colors.green,
                                onPressed: () =>
                                    _handleInvite(invite['id'], true),
                              ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              color: Colors.red,
                              onPressed: () =>
                                  _handleInvite(invite['id'], false),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
