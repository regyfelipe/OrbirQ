import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../themes/colors.dart';
import '../auth/login_screen.dart';
import '../../providers/home_provider.dart';
import 'package:hugeicons/hugeicons.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<HomeProvider>().loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final homeProvider = Provider.of<HomeProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OrbirQ'),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(HugeIcons.strokeRoundedNotification01),
            onPressed: () {
              _showNotificationsModal(context);
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, authService),
      body: RefreshIndicator(
        onRefresh: () async {
          homeProvider.loadInitialData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildStatisticsRow(context, homeProvider),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Atividades Recentes'),
                    const SizedBox(height: 16),
                    _buildActivitiesList(context, homeProvider),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, 'Próximas Avaliações'),
                    const SizedBox(height: 16),
                    _buildUpcomingExams(context, homeProvider),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExamModal(context),
        backgroundColor: AppColors.primaryLight,
        icon:
            const Icon(HugeIcons.strokeRoundedAssignments, color: Colors.white),
        label:
            const Text('Nova Avaliação', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthService authService) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              image: const DecorationImage(
                image: AssetImage('assets/images/drawer_bg.jpg'),
                fit: BoxFit.cover,
                opacity: 0.2,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                authService.userName?[0].toUpperCase() ?? 'U',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryLight,
                ),
              ),
            ),
            accountName: Text(authService.userName ?? 'Usuário'),
            accountEmail:
                Text(authService.currentUser?.email ?? 'usuario@email.com'),
          ),
          _buildDrawerItem(
            icon: HugeIcons.strokeRoundedHome01,
            title: 'Perfil',
            onTap: () => _navigateToProfile(context),
          ),
          _buildDrawerItem(
            icon: HugeIcons.strokeRoundedHome01,
            title: 'Configurações',
            onTap: () => _navigateToSettings(context),
          ),
          _buildDrawerItem(
            icon: HugeIcons.strokeRoundedHome01,
            title: 'Ajuda',
            onTap: () => _showHelpDialog(context),
          ),
          const Spacer(),
          Divider(color: AppColors.divider),
          _buildDrawerItem(
            icon: HugeIcons.strokeRoundedHome01,
            title: 'Sair',
            textColor: AppColors.error,
            iconColor: AppColors.error,
            onTap: () => _handleLogout(context, authService),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor)),
      onTap: onTap,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bem-vindo ao OrbirQ!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore suas atividades e progresso',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsRow(BuildContext context, HomeProvider homeProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Questões\nRespondidas',
            value: homeProvider.questoesRespondidas.toString(),
            icon: HugeIcons.strokeRoundedHome01,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Provas\nRealizadas',
            value: homeProvider.provasRealizadas.toString(),
            icon: HugeIcons.strokeRoundedHome01,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        TextButton(
          onPressed: () {
            // Navegar para a lista completa
          },
          child: const Text('Ver todos'),
        ),
      ],
    );
  }

  Widget _buildActivitiesList(BuildContext context, HomeProvider homeProvider) {
    return Column(
      children: homeProvider.actividadesRecentes.map((atividade) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildActivityCard(
            context,
            title: atividade.titulo,
            subtitle: atividade.subtitulo,
            score: '${atividade.pontuacao}%',
            icon: _getActivityIcon(atividade.tipo),
          ),
        );
      }).toList(),
    );
  }

  IconData _getActivityIcon(AtividadeTipo tipo) {
    switch (tipo) {
      case AtividadeTipo.simuladoConcurso:
        return HugeIcons.strokeRoundedHome01;
      case AtividadeTipo.questoesConcurso:
        return HugeIcons.strokeRoundedHome02;
      case AtividadeTipo.revisaoEdital:
        return HugeIcons.strokeRoundedHome03;
      case AtividadeTipo.videoAula:
        return HugeIcons.strokeRoundedHome01;
      case AtividadeTipo.resumo:
        return HugeIcons.strokeRoundedHome02;
      case AtividadeTipo.lista:
        return HugeIcons.strokeRoundedHome03;
      case AtividadeTipo.prova:
        return HugeIcons.strokeRoundedHome01;
    }
  }

  Widget _buildActivityCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String score,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            score,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingExams(BuildContext context, HomeProvider homeProvider) {
    return Column(
      children: homeProvider.proximasAvaliacoes.map((avaliacao) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildUpcomingExamCard(
            context,
            title: avaliacao.titulo,
            date: DateFormat('dd/MM/yyyy').format(avaliacao.data),
            time: DateFormat('HH:mm').format(avaliacao.data),
            subjects: avaliacao.materias,
            onDelete: () => homeProvider.removeAvaliacao(avaliacao.id),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUpcomingExamCard(
    BuildContext context, {
    required String title,
    required String date,
    required String time,
    required List<String> subjects,
    required VoidCallback onDelete,
  }) {
    return Dismissible(
      key: Key(title),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.divider),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(HugeIcons.strokeRoundedHome01, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Em breve',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    HugeIcons.strokeRoundedHome01,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    date,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    HugeIcons.strokeRoundedHome01,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    time,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: subjects
                    .map((subject) => Chip(
                          label: Text(
                            subject,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          side: BorderSide.none,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Notificações',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text('Nenhuma notificação no momento'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAddExamModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nova Avaliação',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                      ),
                      child: const Text('Adicionar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.pop(context);
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.pop(context);
  }

  void _showHelpDialog(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajuda'),
        content: const Text(
          'Este é o aplicativo OrbirQ, seu assistente de estudos.\n\n'
          'Aqui você pode:\n'
          '- Resolver questões\n'
          '- Fazer simulados\n'
          '- Acompanhar seu progresso\n'
          '- E muito mais!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(
      BuildContext context, AuthService authService) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Sair',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await authService.logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
