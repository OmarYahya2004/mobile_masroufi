import 'package:flutter/material.dart';
import '../main.dart'; // Import to access MasroufiApp.of(context)
import '../core/constants/colors.dart'; // Import your colors file

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  final String appFont = 'Poppins'; // Custom font consistency

  @override
  Widget build(BuildContext context) {
    // Theme setup
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final inputFill = isDark ? AppColors.darkInputFill : AppColors.lightInputFill;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final secondaryTextStyle = TextStyle(
      color: textSecondary,
      fontFamily: appFont,
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue, // Brand color for headers
            fontFamily: appFont,
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
                  backgroundColor: inputFill,
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: AppColors.primaryTeal, // Brand teal for default avatar
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: bgColor, // Creates a cutout effect
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primaryBlue,
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
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
              color: textColor,
              fontFamily: appFont,
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
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            circleBg: inputFill,
            iconColor: textColor,
            textColor: textColor,
            onTap: () {
              MasroufiApp.of(context).toggleTheme();
            },
          ),
          
          // Log Out Setting Row
          _buildSettingsRow(
            icon: Icons.logout,
            title: 'Log Out',
            circleBg: inputFill,
            iconColor: AppColors.errorRed, // Use error red to highlight destructive action
            textColor: AppColors.errorRed,
            onTap: () {
              // Firebase sign out logic
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    required Color circleBg,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: circleBg,
        radius: 20,
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: textColor,
          fontFamily: appFont,
        ),
      ),
      onTap: onTap,
    );
  }
}