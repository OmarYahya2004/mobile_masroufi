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
    final bgColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final inputFill =
        isDark ? AppColors.darkInputFill : AppColors.lightInputFill;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

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
      body: SingleChildScrollView(
        child: Column(
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
                    child: const Icon(
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
                    child: const CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primaryBlue,
                      child: Icon(
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

            const SizedBox(height: 32),

            // 1. Edit Name Row
            _buildSettingsRow(
              icon: Icons.person_outline,
              title: 'Edit Name',
              circleBg: inputFill,
              iconColor: textColor,
              textColor: textColor,
              trailing: Icon(Icons.chevron_right, color: textSecondary),
              onTap: () {
                // Edit Name logic will go here
              },
            ),

            // 2. Change Password Row
            _buildSettingsRow(
              icon: Icons.lock_outline,
              title: 'Change Password',
              circleBg: inputFill,
              iconColor: textColor,
              textColor: textColor,
              trailing: Icon(Icons.chevron_right, color: textSecondary),
              onTap: () {
                // Change Password logic will go here
              },
            ),

            // 3. Language Setting Row
            _buildSettingsRow(
              icon: Icons.language,
              title: 'Language',
              circleBg: inputFill,
              iconColor: textColor,
              textColor: textColor,
              trailing: Text(
                'English',
                style: TextStyle(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.bold,
                  fontFamily: appFont,
                ),
              ),
              onTap: () {
                // Language toggle logic will go here
              },
            ),

            // 4. Dark Mode Setting Row with Switch
            _buildSettingsRow(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              circleBg: inputFill,
              iconColor: textColor,
              textColor: textColor,
              trailing: Switch(
                value: isDark,
                activeColor: Colors.white,
                activeTrackColor: AppColors.primaryTeal,
                inactiveThumbColor: textSecondary,
                inactiveTrackColor: inputFill,
                onChanged: (_) {
                  MasroufiApp.of(context).toggleTheme();
                },
              ),
              onTap: () {
                MasroufiApp.of(context).toggleTheme();
              },
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Divider(),
            ),

            // 5. Log Out Setting Row
            _buildSettingsRow(
              icon: Icons.logout,
              title: 'Log Out',
              circleBg: inputFill,
              iconColor: AppColors.errorRed,
              textColor: AppColors.errorRed,
              onTap: () {
                // Firebase sign out logic
              },
            ),
          ],
        ),
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
    Widget? trailing,
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
      trailing: trailing,
      onTap: onTap,
    );
  }
}