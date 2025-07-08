import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/services/backup_service.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _isBackingUp = false;
  bool _isRestoring = false;
  BackupSchedule? _schedule;
  List<BackupInfo> _backupHistory = [];
  
  @override
  void initState() {
    super.initState();
    _loadBackupInfo();
  }
  
  Future<void> _loadBackupInfo() async {
    final schedule = await BackupService.getBackupSchedule();
    final history = await BackupService.getBackupHistory();
    
    setState(() {
      _schedule = schedule;
      _backupHistory = history;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Manual Backup Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.backup, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Manual Backup',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create a backup of all your data including products, customers, bills, and settings.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isBackingUp ? null : _createBackup,
                        icon: _isBackingUp
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.cloud_upload),
                        label: Text(_isBackingUp ? 'Creating Backup...' : 'Create Backup Now'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Restore Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.restore, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text(
                          'Restore from Backup',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Restore your data from a previous backup file. This will replace all current data.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isRestoring ? null : _restoreBackup,
                        icon: _isRestoring
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.folder_open),
                        label: Text(_isRestoring ? 'Restoring...' : 'Select Backup File'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Auto Backup Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.schedule, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text(
                          'Automatic Backup',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Enable Auto Backup'),
                      subtitle: Text(
                        _schedule?.enabled ?? false
                            ? 'Backing up ${_schedule!.frequency}'
                            : 'Automatic backups are disabled',
                      ),
                      value: _schedule?.enabled ?? false,
                      onChanged: (value) => _toggleAutoBackup(value),
                    ),
                    if (_schedule?.enabled ?? false) ...[
                      const Divider(),
                      ListTile(
                        title: const Text('Frequency'),
                        trailing: DropdownButton<String>(
                          value: _schedule!.frequency,
                          onChanged: (value) => _updateSchedule(frequency: value),
                          items: const [
                            DropdownMenuItem(value: 'daily', child: Text('Daily')),
                            DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                            DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                          ],
                        ),
                      ),
                      ListTile(
                        title: const Text('Backup Time'),
                        trailing: TextButton(
                          onPressed: _selectBackupTime,
                          child: Text(
                            '${_schedule!.hour.toString().padLeft(2, '0')}:00',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Backup History
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Backup History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_backupHistory.isNotEmpty)
                  TextButton(
                    onPressed: _clearHistory,
                    child: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_backupHistory.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'No backup history',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._backupHistory.map((backup) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: backup.isAutomatic
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    child: Icon(
                      backup.isAutomatic ? Icons.schedule : Icons.backup,
                      color: backup.isAutomatic ? Colors.blue : Colors.green,
                    ),
                  ),
                  title: Text(backup.fileName),
                  subtitle: Text(
                    '${DateFormat('MMM dd, yyyy • hh:mm a').format(backup.createdAt)} • ${_formatFileSize(backup.size)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => _shareBackup(backup),
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }
  
  Future<void> _createBackup() async {
    setState(() => _isBackingUp = true);
    
    final result = await BackupService.createBackup(
      businessName: 'QuickBills', // Get from settings
    );
    
    setState(() => _isBackingUp = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
      
      if (result.success) {
        await BackupService.addToBackupHistory(BackupInfo(
          createdAt: DateTime.now(),
          fileName: result.filePath!.split('/').last,
          size: result.size!,
          isAutomatic: false,
        ));
        _loadBackupInfo();
      }
    }
  }
  
  Future<void> _restoreBackup() async {
    // Show warning dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup'),
        content: const Text(
          'This will replace all your current data with the backup data. This action cannot be undone.\n\nDo you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() => _isRestoring = true);
    
    final result = await BackupService.restoreBackup();
    
    setState(() => _isRestoring = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
      
      if (result.success) {
        // Restart app or refresh all data
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Restore Complete'),
            content: Text('Successfully restored ${result.itemsRestored} items. Please restart the app for changes to take effect.'),
            actions: [
              FilledButton(
                onPressed: () {
                  // Navigate to home and clear stack
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
  
  void _toggleAutoBackup(bool enabled) async {
    final schedule = _schedule ?? BackupSchedule(
      enabled: enabled,
      frequency: 'daily',
      hour: 2,
    );
    
    await BackupService.setBackupSchedule(
      schedule.copyWith(enabled: enabled),
    );
    
    _loadBackupInfo();
  }
  
  void _updateSchedule({String? frequency}) async {
    if (_schedule == null) return;
    
    await BackupService.setBackupSchedule(
      BackupSchedule(
        enabled: _schedule!.enabled,
        frequency: frequency ?? _schedule!.frequency,
        hour: _schedule!.hour,
      ),
    );
    
    _loadBackupInfo();
  }
  
  Future<void> _selectBackupTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _schedule?.hour ?? 2, minute: 0),
    );
    
    if (time != null && _schedule != null) {
      await BackupService.setBackupSchedule(
        BackupSchedule(
          enabled: _schedule!.enabled,
          frequency: _schedule!.frequency,
          hour: time.hour,
        ),
      );
      
      _loadBackupInfo();
    }
  }
  
  void _shareBackup(BackupInfo backup) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }
  
  void _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear backup history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      // Clear history
      setState(() => _backupHistory.clear());
    }
  }
  
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

extension on BackupSchedule {
  BackupSchedule copyWith({bool? enabled}) {
    return BackupSchedule(
      enabled: enabled ?? this.enabled,
      frequency: frequency,
      hour: hour,
    );
  }
}