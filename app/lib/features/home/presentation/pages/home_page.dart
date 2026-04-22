import 'package:flutter/material.dart';

import 'package:ergo_desktop/core/theme/app_colors.dart';
import 'package:ergo_desktop/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:ergo_desktop/features/pomodoro/presentation/pages/pomodoro_page.dart';
import 'package:ergo_desktop/features/settings/presentation/pages/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final String _userName = "Usuario"; // Simplificado para versión local

  @override
  Widget build(BuildContext context) {
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
                _buildProfileSection(),
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
            child: _getContentForIndex(_selectedIndex),
          ),
        ],
      ),
    );
  }

  Widget _getContentForIndex(int index) {
    switch (index) {
      case 0:
        return DashboardPage(
          userName: _userName,
          onNavigateToIndex: (idx) => setState(() => _selectedIndex = idx),
        );
      case 1:
        return _buildGenericPage("Gestión de Tareas");
      case 2:
        return const PomodoroPage();
      case 3:
        return _buildGenericPage("Reportes y Estadísticas");
      case 5:
        return const SettingsPage();
      default:
        return _buildGenericPage("Página en Construcción");
    }
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

  Widget _buildProfileSection() {
    return Column(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: Colors.grey[800],
          child: const Icon(Icons.person, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          _userName,
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
