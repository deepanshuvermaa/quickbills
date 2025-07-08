import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  // Notification preferences
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _smsNotificationsEnabled = false;
  
  // Notification types
  bool _lowStockAlerts = true;
  bool _salesAlerts = true;
  bool _paymentReminders = true;
  bool _dailySummary = true;
  bool _weeklyReports = false;
  bool _monthlyReports = true;
  bool _customerBirthdays = true;
  bool _newCustomerAlerts = true;
  bool _expenseAlerts = true;
  bool _backupReminders = true;
  
  String _quietHoursStart = '22:00';
  String _quietHoursEnd = '07:00';
  bool _quietHoursEnabled = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Notification Channels
          _buildSectionHeader('Notification Channels'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive notifications on this device'),
                  secondary: const Icon(Icons.notifications),
                  value: _pushNotificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _pushNotificationsEnabled = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive notifications via email'),
                  secondary: const Icon(Icons.email),
                  value: _emailNotificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _emailNotificationsEnabled = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('SMS Notifications'),
                  subtitle: const Text('Receive notifications via SMS'),
                  secondary: const Icon(Icons.sms),
                  value: _smsNotificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _smsNotificationsEnabled = value;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Inventory Alerts
          _buildSectionHeader('Inventory Alerts'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Low Stock Alerts'),
                  subtitle: const Text('Get notified when items are running low'),
                  value: _lowStockAlerts,
                  onChanged: (value) {
                    setState(() {
                      _lowStockAlerts = value;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Sales & Payment
          _buildSectionHeader('Sales & Payment'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Sales Alerts'),
                  subtitle: const Text('New sales and high-value transactions'),
                  value: _salesAlerts,
                  onChanged: (value) {
                    setState(() {
                      _salesAlerts = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Payment Reminders'),
                  subtitle: const Text('Remind customers about pending payments'),
                  value: _paymentReminders,
                  onChanged: (value) {
                    setState(() {
                      _paymentReminders = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Expense Alerts'),
                  subtitle: const Text('Unusual or high expenses'),
                  value: _expenseAlerts,
                  onChanged: (value) {
                    setState(() {
                      _expenseAlerts = value;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Reports & Summaries
          _buildSectionHeader('Reports & Summaries'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Daily Summary'),
                  subtitle: const Text('Receive daily sales summary at 9 PM'),
                  value: _dailySummary,
                  onChanged: (value) {
                    setState(() {
                      _dailySummary = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Weekly Reports'),
                  subtitle: const Text('Receive weekly business reports'),
                  value: _weeklyReports,
                  onChanged: (value) {
                    setState(() {
                      _weeklyReports = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Monthly Reports'),
                  subtitle: const Text('Receive monthly business reports'),
                  value: _monthlyReports,
                  onChanged: (value) {
                    setState(() {
                      _monthlyReports = value;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Customer Related
          _buildSectionHeader('Customer Related'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Customer Birthdays'),
                  subtitle: const Text('Remind about customer birthdays'),
                  value: _customerBirthdays,
                  onChanged: (value) {
                    setState(() {
                      _customerBirthdays = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('New Customer Alerts'),
                  subtitle: const Text('Get notified about new registrations'),
                  value: _newCustomerAlerts,
                  onChanged: (value) {
                    setState(() {
                      _newCustomerAlerts = value;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // System
          _buildSectionHeader('System'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Backup Reminders'),
                  subtitle: const Text('Remind to backup data regularly'),
                  value: _backupReminders,
                  onChanged: (value) {
                    setState(() {
                      _backupReminders = value;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Quiet Hours
          _buildSectionHeader('Quiet Hours'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable Quiet Hours'),
                  subtitle: const Text('Pause non-urgent notifications'),
                  value: _quietHoursEnabled,
                  onChanged: (value) {
                    setState(() {
                      _quietHoursEnabled = value;
                    });
                  },
                ),
                if (_quietHoursEnabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Quiet Hours'),
                    subtitle: Text('$_quietHoursStart - $_quietHoursEnd'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _selectQuietHours,
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Test Notification
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _sendTestNotification,
              icon: const Icon(Icons.notifications_active),
              label: const Text('Send Test Notification'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
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
  
  void _selectQuietHours() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Quiet Hours'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(_quietHoursStart),
              onTap: () async {
                final TimeOfDay? time = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 22, minute: 0),
                );
                if (time != null) {
                  setState(() {
                    _quietHoursStart = time.format(context);
                  });
                }
              },
            ),
            ListTile(
              title: const Text('End Time'),
              subtitle: Text(_quietHoursEnd),
              onTap: () async {
                final TimeOfDay? time = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 7, minute: 0),
                );
                if (time != null) {
                  setState(() {
                    _quietHoursEnd = time.format(context);
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
  
  void _sendTestNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test notification sent!'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void _saveSettings() {
    // TODO: Save notification settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings saved'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }
}