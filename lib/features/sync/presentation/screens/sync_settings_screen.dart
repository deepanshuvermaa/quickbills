import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SyncSettingsScreen extends ConsumerStatefulWidget {
  const SyncSettingsScreen({super.key});

  @override
  ConsumerState<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends ConsumerState<SyncSettingsScreen> {
  bool _autoSyncEnabled = true;
  String _syncInterval = '15';
  bool _syncOnWifiOnly = true;
  bool _syncInBackground = false;
  
  final DateTime _lastSyncTime = DateTime.now().subtract(const Duration(minutes: 30));
  bool _isSyncing = false;
  
  final List<Map<String, dynamic>> _syncHistory = [
    {
      'time': DateTime.now().subtract(const Duration(minutes: 30)),
      'status': 'success',
      'uploaded': 25,
      'downloaded': 10,
    },
    {
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'success',
      'uploaded': 45,
      'downloaded': 20,
    },
    {
      'time': DateTime.now().subtract(const Duration(hours: 5)),
      'status': 'failed',
      'error': 'Network connection lost',
    },
    {
      'time': DateTime.now().subtract(const Duration(hours: 8)),
      'status': 'success',
      'uploaded': 30,
      'downloaded': 15,
    },
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Settings'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sync Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sync Status',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Last synced: ${_getLastSyncText()}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      _isSyncing
                          ? const CircularProgressIndicator()
                          : Icon(
                              Icons.cloud_done,
                              color: Colors.green[600],
                              size: 32,
                            ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSyncing ? null : _syncNow,
                      icon: Icon(_isSyncing ? Icons.sync : Icons.sync),
                      label: Text(_isSyncing ? 'Syncing...' : 'Sync Now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Auto Sync Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Auto Sync',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: _autoSyncEnabled,
                        onChanged: (value) {
                          setState(() {
                            _autoSyncEnabled = value;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_autoSyncEnabled) ...[
                    const SizedBox(height: 16),
                    const Text('Sync Interval'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _syncInterval,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: '5', child: Text('Every 5 minutes')),
                        DropdownMenuItem(value: '15', child: Text('Every 15 minutes')),
                        DropdownMenuItem(value: '30', child: Text('Every 30 minutes')),
                        DropdownMenuItem(value: '60', child: Text('Every hour')),
                        DropdownMenuItem(value: '360', child: Text('Every 6 hours')),
                        DropdownMenuItem(value: '1440', child: Text('Once a day')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _syncInterval = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Wi-Fi Only'),
                      subtitle: const Text('Sync only when connected to Wi-Fi'),
                      value: _syncOnWifiOnly,
                      onChanged: (value) {
                        setState(() {
                          _syncOnWifiOnly = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    SwitchListTile(
                      title: const Text('Background Sync'),
                      subtitle: const Text('Sync data in the background'),
                      value: _syncInBackground,
                      onChanged: (value) {
                        setState(() {
                          _syncInBackground = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Data to Sync
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data to Sync',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSyncDataItem('Products & Inventory', true, Icons.inventory_2),
                  _buildSyncDataItem('Customers', true, Icons.people),
                  _buildSyncDataItem('Sales & Bills', true, Icons.receipt),
                  _buildSyncDataItem('Expenses', true, Icons.money_off),
                  _buildSyncDataItem('Reports', true, Icons.analytics),
                  _buildSyncDataItem('Settings', true, Icons.settings),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Sync History
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sync History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: _clearHistory,
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._syncHistory.map((sync) => _buildSyncHistoryItem(sync)).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Advanced Options
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Advanced Options',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.cloud_off),
                    title: const Text('Reset Sync'),
                    subtitle: const Text('Clear local sync data and start fresh'),
                    onTap: _resetSync,
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: const Icon(Icons.compress),
                    title: const Text('Compress Data'),
                    subtitle: const Text('Reduce bandwidth usage during sync'),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {},
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSyncDataItem(String title, bool enabled, IconData icon) {
    return CheckboxListTile(
      title: Text(title),
      secondary: Icon(icon),
      value: enabled,
      onChanged: (value) {
        // TODO: Handle individual sync settings
      },
      contentPadding: EdgeInsets.zero,
    );
  }
  
  Widget _buildSyncHistoryItem(Map<String, dynamic> sync) {
    final bool isSuccess = sync['status'] == 'success';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isSuccess 
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            child: Icon(
              isSuccess ? Icons.check : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(sync['time']),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  isSuccess
                      ? '↑ ${sync['uploaded']} uploaded, ↓ ${sync['downloaded']} downloaded'
                      : sync['error'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getLastSyncText() {
    final difference = DateTime.now().difference(_lastSyncTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
  
  Future<void> _syncNow() async {
    setState(() {
      _isSyncing = true;
    });
    
    // Simulate sync process
    await Future.delayed(const Duration(seconds: 3));
    
    setState(() {
      _isSyncing = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sync completed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sync settings saved'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }
  
  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Sync History'),
        content: const Text('Are you sure you want to clear all sync history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sync history cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
  
  void _resetSync() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Sync'),
        content: const Text(
          'This will clear all local sync data and force a full sync on next connection. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sync data reset')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}