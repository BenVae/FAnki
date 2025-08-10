import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:authentication_repository/authentication_repository.dart';
import '../../login/cubit/login_cubit.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _packageInfo = info;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = RepositoryProvider.of<AuthenticationRepository>(context);
    final userEmail = authRepo.currentUser.email ?? 'Not logged in';

    return Container(
      color: Colors.grey.shade50,
      child: SafeArea(
        child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.settings,
                        size: 32,
                        color: Colors.blue.shade600,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        SizedBox(width: 8),
                        Text(
                          userEmail,
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Settings sections
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account section
                  _SettingsSection(
                    title: 'Account',
                    children: [
                      _SettingsTile(
                        icon: Icons.logout,
                        title: 'Logout',
                        subtitle: 'Sign out of your account',
                        onTap: () => _showLogoutDialog(context),
                        iconColor: Colors.red,
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // App section
                  _SettingsSection(
                    title: 'Application',
                    children: [
                      _SettingsTile(
                        icon: Icons.info_outline,
                        title: 'About',
                        subtitle:
                            'Version ${_packageInfo?.version ?? '1.0.0'} (${_packageInfo?.buildNumber ?? '1'})',
                        onTap: () => _showAboutDialog(context),
                      ),
                      _SettingsTile(
                        icon: Icons.article_outlined,
                        title: 'Licenses',
                        subtitle: 'View open source licenses',
                        onTap: () => _showLicensesPage(context),
                      ),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'View privacy policy',
                        onTap: () => _showPrivacyPolicy(context),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Study settings section
                  _SettingsSection(
                    title: 'Study Settings',
                    children: [
                      _SettingsTile(
                        icon: Icons.timer_outlined,
                        title: 'Study Reminders',
                        subtitle: 'Configure daily study reminders',
                        trailing: Switch(
                          value: false,
                          onChanged: (value) {
                            // TODO: Implement reminders
                          },
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Mode',
                        subtitle: 'Toggle dark theme',
                        trailing: Switch(
                          value: false,
                          onChanged: (value) {
                            // TODO: Implement dark mode
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Support section
                  _SettingsSection(
                    title: 'Support',
                    children: [
                      _SettingsTile(
                        icon: Icons.help_outline,
                        title: 'Help & FAQ',
                        subtitle: 'Get help using the app',
                        onTap: () => _showHelp(context),
                      ),
                      _SettingsTile(
                        icon: Icons.bug_report_outlined,
                        title: 'Report Issue',
                        subtitle: 'Report a bug or request a feature',
                        onTap: () => _reportIssue(context),
                      ),
                      _SettingsTile(
                        icon: Icons.mail_outline,
                        title: 'Contact Us',
                        subtitle: 'Send us an email',
                        onTap: () => _contactSupport(context),
                      ),
                    ],
                  ),

                  SizedBox(height: 40),

                  // Footer
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'FAnki',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'A Flutter-based Anki Clone',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '© 2024 FAnki Team',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<LoginCubit>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'FAnki',
      applicationVersion: _packageInfo?.version ?? '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.school,
          size: 36,
          color: Colors.blue.shade600,
        ),
      ),
      children: [
        SizedBox(height: 16),
        Text(
          'FAnki is a Flutter-based flashcard application inspired by Anki, '
          'featuring AI-powered card generation, spaced repetition learning, '
          'and hierarchical deck organization.',
        ),
        SizedBox(height: 16),
        Text(
          'Built with Flutter and Firebase.',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _showLicensesPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LicensePage(
          applicationName: 'FAnki',
          applicationVersion: _packageInfo?.version ?? '1.0.0',
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Privacy policy coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Help documentation coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _reportIssue(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Issue reporting coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _contactSupport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contact: support@fanki.app'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.blue).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 24,
                color: iconColor ?? Colors.blue.shade600,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }
}
