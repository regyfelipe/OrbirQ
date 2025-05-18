import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../models/user_type.dart';
import '../screens/questions/filter_questions_screen.dart';
import '../services/auth_service.dart';
import '../themes/colors.dart';
import '../screens/home/home_page.dart';
import '../screens/exams/exams_page.dart';
import '../screens/simulated/simulated_page.dart';
import '../screens/group/group_page.dart';
import '../screens/folder/folder_page.dart';
import '../screens/create/create_question_page.dart';

class NavigationPage extends StatefulWidget {
  final UserType userType;

  const NavigationPage({
    Key? key,
    required this.userType,
  }) : super(key: key);

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;
  late final List<NavigationItem> _pages;

  @override
  void initState() {
    super.initState();
    _pages = _getNavigationItems();
  }

  List<NavigationItem> _getNavigationItems() {
    final List<NavigationItem> items = [
      NavigationItem(
        icon: HugeIcons.strokeRoundedHome01,
        selectedIcon: HugeIcons.strokeRoundedHome01,
        label: 'Home',
        screen: const HomePage(),
      ),
      NavigationItem(
        icon: HugeIcons.strokeRoundedBookBookmark01,
        selectedIcon: HugeIcons.strokeRoundedBookBookmark01,
        label: 'Questões',
        screen: FilterQuestionsScreen(),
      ),
      NavigationItem(
        icon: HugeIcons.strokeRoundedDocumentCode,
        selectedIcon: HugeIcons.strokeRoundedDocumentCode,
        label: 'Provas',
        screen: const ExamsPage(),
      ),
      NavigationItem(
        icon: HugeIcons.strokeRoundedTimer01,
        selectedIcon: HugeIcons.strokeRoundedTimer01,
        label: 'Simulados',
        screen: const SimulatedPage(),
      ),
      NavigationItem(
        icon: HugeIcons.strokeRoundedUserGroup,
        selectedIcon: HugeIcons.strokeRoundedUserGroup,
        label: 'Grupo',
        screen: const GroupPage(),
      ),
      NavigationItem(
        icon: HugeIcons.strokeRoundedFavouriteCircle,
        selectedIcon: HugeIcons.strokeRoundedFavouriteCircle,
        label: 'Pasta',
        screen: const FolderPage(),
      ),
    ];

    if (widget.userType == UserType.professor) {
      items.insert(
        4,
        NavigationItem(
          icon: HugeIcons.strokeRoundedFolder01,
          selectedIcon: HugeIcons.strokeRoundedFolder01,
          label: 'Criar',
          screen: const CreateQuestionPage(),
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _pages[_selectedIndex].screen,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            labelTextStyle: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                );
              }
              return TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              );
            }),
            iconTheme: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return IconThemeData(
                  color: AppColors.primary,
                  size: 24,
                );
              }
              return IconThemeData(
                color: AppColors.textSecondary,
                size: 24,
              );
            }),
            backgroundColor: AppColors.surface,
            elevation: 8,
            height: 65,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            indicatorColor: AppColors.primary.withOpacity(0.1),
            surfaceTintColor: Colors.transparent,
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: _pages.map((item) {
            return NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Widget screen;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.screen,
  });
}
