import 'package:flutter/material.dart';
import '../main.dart'; // Import to access MasroufiApp.of(context)

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryTextStyle = TextStyle(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 32),
          
          // Profile Picture + Camera Badge
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            'Omar Yahya',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Profile settings will go here in Phase 3',
            style: secondaryTextStyle,
          ),
          const SizedBox(height: 32),
          
          // Dark Mode Setting Row
          _buildSettingsRow(
            context: context,
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            onTap: () {
              MasroufiApp.of(context).toggleTheme();
            },
          ),
          
          // Log Out Setting Row
          _buildSettingsRow(
            context: context,
            icon: Icons.logout,
            title: 'Log Out',
            onTap: () {
              // Firebase sign out logic
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        radius: 20,
        child: Icon(icon, color: theme.colorScheme.onSurface, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: theme.colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
    );
  }
}