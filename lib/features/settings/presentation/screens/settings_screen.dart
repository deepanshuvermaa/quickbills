import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Business Settings
          _buildSectionHeader('Business'),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Business Information'),
            subtitle: const Text('Name, address, contact details'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToBusinessInfo(context),
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Invoice Settings'),
            subtitle: const Text('Invoice format, numbering, terms'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToInvoiceSettings(context),
          ),
          ListTile(
            leading: const Icon(Icons.calculate),
            title: const Text('Tax Configuration'),
            subtitle: const Text('GST rates, tax settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToTaxSettings(context),
          ),
          
          // Hardware Settings
          _buildSectionHeader('Hardware'),
          ListTile(
            leading: const Icon(Icons.print),
            title: const Text('Printer Settings'),
            subtitle: const Text('Configure thermal printer'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/printer'),
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('Scanner Settings'),
            subtitle: const Text('Barcode scanner configuration'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToScannerSettings(context),
          ),
          
          // Data Management
          _buildSectionHeader('Data Management'),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup & Restore'),
            subtitle: const Text('Backup your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/backup-restore'),
          ),
          ListTile(
            leading: const Icon(Icons.import_export),
            title: const Text('Import/Export'),
            subtitle: const Text('Import or export data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToImportExport(context),
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Sync Settings'),
            subtitle: const Text('Cloud sync configuration'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToSyncSettings(context),
          ),
          
          // App Preferences
          _buildSectionHeader('App Preferences'),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('English'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.currency_rupee),
            title: const Text('Currency'),
            subtitle: const Text('Indian Rupee (₹)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCurrencyDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('App notifications settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToNotifications(context),
          ),
          Consumer(
            builder: (context, ref, _) {
              final themeMode = ref.watch(themeModeProvider);
              String themeName;
              switch (themeMode) {
                case ThemeMode.dark:
                  themeName = 'Dark';
                  break;
                case ThemeMode.system:
                  themeName = 'System Default';
                  break;
                default:
                  themeName = 'Light';
              }
              return ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Theme'),
                subtitle: Text(themeName),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeDialog(context, ref),
              );
            },
          ),
          
          // Security
          _buildSectionHeader('Security'),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('App Lock'),
            subtitle: const Text('PIN/Password protection'),
            trailing: Switch(
              value: false,
              onChanged: (value) => _toggleAppLock(context, value),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Biometric Authentication'),
            subtitle: const Text('Use fingerprint to unlock'),
            trailing: Switch(
              value: false,
              onChanged: (value) => _toggleBiometric(context, value),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Auto Logout'),
            subtitle: const Text('After 15 minutes of inactivity'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAutoLogoutDialog(context),
          ),
          
          // About
          _buildSectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About QuickBills'),
            subtitle: const Text('Version 1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToTerms(context),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToPrivacy(context),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToHelp(context),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }
  
  void _navigateToBusinessInfo(BuildContext context) {
    context.push('/settings/business');
  }
  
  void _navigateToInvoiceSettings(BuildContext context) {
    context.push('/settings/invoice');
  }
  
  void _navigateToTaxSettings(BuildContext context) {
    context.push('/settings/tax');
  }
  
  void _navigateToScannerSettings(BuildContext context) {
    context.push('/settings/scanner');
  }
  
  void _navigateToImportExport(BuildContext context) {
    context.push('/settings/import-export');
  }
  
  void _navigateToSyncSettings(BuildContext context) {
    context.push('/settings/sync');
  }
  
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: const Text('English'),
                value: 'en',
                groupValue: 'en',
                onChanged: (value) => Navigator.pop(context),
              ),
              RadioListTile(
                title: const Text('हिन्दी'),
                value: 'hi',
                groupValue: 'en',
                onChanged: (value) => Navigator.pop(context),
              ),
              RadioListTile(
                title: const Text('తెలుగు'),
                value: 'te',
                groupValue: 'en',
                onChanged: (value) => Navigator.pop(context),
              ),
              RadioListTile(
                title: const Text('தமிழ்'),
                value: 'ta',
                groupValue: 'en',
                onChanged: (value) => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showCurrencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: const Text('Indian Rupee (₹)'),
                value: 'INR',
                groupValue: 'INR',
                onChanged: (value) => Navigator.pop(context),
              ),
              RadioListTile(
                title: const Text('US Dollar (\$)'),
                value: 'USD',
                groupValue: 'INR',
                onChanged: (value) => Navigator.pop(context),
              ),
              RadioListTile(
                title: const Text('Euro (€)'),
                value: 'EUR',
                groupValue: 'INR',
                onChanged: (value) => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _navigateToNotifications(BuildContext context) {
    context.push('/settings/notifications');
  }
  
  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.read(themeModeProvider);
    ThemeMode selectedMode = currentThemeMode;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Theme'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Light'),
                  value: ThemeMode.light,
                  groupValue: selectedMode,
                  onChanged: (value) {
                    setState(() => selectedMode = value!);
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark'),
                  value: ThemeMode.dark,
                  groupValue: selectedMode,
                  onChanged: (value) {
                    setState(() => selectedMode = value!);
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('System Default'),
                  value: ThemeMode.system,
                  groupValue: selectedMode,
                  onChanged: (value) {
                    setState(() => selectedMode = value!);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(themeModeProvider.notifier).setThemeMode(selectedMode);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _toggleAppLock(BuildContext context, bool value) {
    if (value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('App lock feature coming soon')),
      );
    }
  }
  
  void _toggleBiometric(BuildContext context, bool value) {
    if (value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric authentication coming soon')),
      );
    }
  }
  
  void _showAutoLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto Logout Timer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: const Text('5 minutes'),
                value: 5,
                groupValue: 15,
                onChanged: (value) => Navigator.pop(context),
              ),
              RadioListTile(
                title: const Text('15 minutes'),
                value: 15,
                groupValue: 15,
                onChanged: (value) => Navigator.pop(context),
              ),
              RadioListTile(
                title: const Text('30 minutes'),
                value: 30,
                groupValue: 15,
                onChanged: (value) => Navigator.pop(context),
              ),
              RadioListTile(
                title: const Text('Never'),
                value: 0,
                groupValue: 15,
                onChanged: (value) => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'QuickBills',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.point_of_sale, size: 48),
      applicationLegalese: '© 2024 QuickBills. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'QuickBills is a comprehensive Point of Sale (POS) and billing application designed for small to medium businesses.',
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
  
  void _navigateToTerms(BuildContext context) {
    context.push('/settings/terms');
  }
  
  void _navigateToPrivacy(BuildContext context) {
    context.push('/settings/privacy');
  }
  
  void _navigateToHelp(BuildContext context) {
    context.push('/help');
  }
}