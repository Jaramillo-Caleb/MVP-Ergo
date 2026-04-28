import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:ergo_desktop/core/theme/app_colors.dart';
import 'package:ergo_desktop/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:ergo_desktop/features/pomodoro/presentation/pages/pomodoro_page.dart';
import 'package:ergo_desktop/features/settings/presentation/pages/settings_page.dart';
import 'package:ergo_desktop/features/tasks/presentation/pages/tasks_page.dart';
import 'package:ergo_desktop/features/profile/data/services/profile_service.dart';
import 'package:ergo_desktop/core/database/app_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late final ProfileService _profileService;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _profileService = GetIt.instance<ProfileService>();
    _profileService.addListener(_onProfileChanged);
    _profileService.getProfile();

    _pages = [
      DashboardPage(
        onNavigateToIndex: (idx) => setState(() => _selectedIndex = idx),
      ),
      const TasksPage(),
      const PomodoroPage(),
      _buildGenericPage("Reportes y Estadísticas"),
      _buildGenericPage("Página en Construcción"),
      const SettingsPage(),
    ];
  }

  @override
  void dispose() {
    _profileService.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = _profileService.profile;
    final userName = user?.fullName.split(' ')[0] ?? "Usuario";

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            color: AppColors.sidebarBackground,
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildProfileSection(user, userName),
                const SizedBox(height: 40),
                _buildMenuItem(0, "Inicio", Icons.home_filled),
                _buildMenuItem(1, "Tareas", Icons.task_alt),
                _buildMenuItem(2, "Pomodoro", Icons.timer_outlined),
                _buildMenuItem(3, "Estadísticas", Icons.bar_chart),
                _buildMenuItem(4, "Ayuda", Icons.help_outline),
                const Spacer(),
                _buildMenuItem(5, "Configuración", Icons.settings_outlined),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericPage(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.construction, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain),
          ),
          const SizedBox(height: 10),
          const Text("Esta sección se implementará próximamente."),
        ],
      ),
    );
  }

  Widget _buildProfileSection(User? user, String userName) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[800],
          backgroundImage:
              user?.photo != null ? MemoryImage(user!.photo!) : null,
          child: user?.photo == null
              ? const Icon(Icons.person, size: 40, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          userName,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildMenuItem(int index, String label, IconData icon) {
    bool isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _selectedIndex = index);
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
