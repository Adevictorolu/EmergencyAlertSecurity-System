import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dualert/providers/theme_provider.dart';
import 'package:dualert/features/auth/services/auth_service.dart';
import 'package:dualert/core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authService = context.read<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Appearance'),
          Card(
            child: ListTile(
              leading: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: AppColors.primaryBlue,
              ),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
                activeColor: AppColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Account'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email, color: AppColors.primaryBlue),
                  title: const Text('Verify Email / Resend'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to verification screen if needed
                    Navigator.pushNamed(context, '/verification');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: AppColors.error),
                  ),
                  onTap: () async {
                    await authService.signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/signin', (route) => false);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('About'),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline, color: AppColors.primaryBlue),
              title: Text('About DUalert'),
              subtitle: Text('Version 1.0.0\nDeveloper: Ademola Victor Oluokun\nFinal Year Project'),
              isThreeLine: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
