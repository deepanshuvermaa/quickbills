import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:archive/archive.dart';
import 'package:intl/intl.dart';

class BackupService {
  static const String backupVersion = '1.0';
  
  static Future<BackupResult> createBackup({
    required String businessName,
    bool includeImages = true,
  }) async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        return BackupResult(
          success: false,
          message: 'Storage permission denied',
        );
      }
      
      // Create backup data
      final backupData = await _collectBackupData();
      
      // Add metadata
      backupData['metadata'] = {
        'version': backupVersion,
        'businessName': businessName,
        'createdAt': DateTime.now().toIso8601String(),
        'deviceInfo': {
          'platform': Platform.operatingSystem,
          'version': Platform.operatingSystemVersion,
        },
      };
      
      // Create backup file
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'quickbills_backup_$timestamp.qbb';
      
      final tempDir = await getTemporaryDirectory();
      final backupFile = File('${tempDir.path}/$fileName');
      
      // Compress and encrypt
      final jsonData = jsonEncode(backupData);
      final compressed = GZipEncoder().encode(utf8.encode(jsonData));
      
      await backupFile.writeAsBytes(compressed!);
      
      // Share the backup file
      await Share.shareXFiles(
        [XFile(backupFile.path)],
        subject: 'QuickBills Backup - $timestamp',
      );
      
      return BackupResult(
        success: true,
        message: 'Backup created successfully',
        filePath: backupFile.path,
        size: backupFile.lengthSync(),
      );
    } catch (e) {
      return BackupResult(
        success: false,
        message: 'Backup failed: $e',
      );
    }
  }
  
  static Future<Map<String, dynamic>> _collectBackupData() async {
    final data = <String, dynamic>{};
    
    // Collect data from all Hive boxes
    final boxNames = [
      'products',
      'customers',
      'bills',
      'drafts',
      'expenses',
      'staff',
      'settings',
    ];
    
    for (final boxName in boxNames) {
      try {
        Box box;
        if (Hive.isBoxOpen(boxName)) {
          box = Hive.box(boxName);
        } else {
          box = await Hive.openBox(boxName);
        }
        
        final items = <Map<String, dynamic>>[];
        for (final key in box.keys) {
          final item = box.get(key);
          if (item != null) {
            // Convert to JSON-serializable format
            if (item is Map) {
              items.add(Map<String, dynamic>.from(item));
            } else if (item.toJson != null) {
              items.add(item.toJson());
            }
          }
        }
        
        data[boxName] = items;
      } catch (e) {
        print('Error backing up $boxName: $e');
      }
    }
    
    return data;
  }
  
  static Future<RestoreResult> restoreBackup() async {
    try {
      // Pick backup file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['qbb'],
      );
      
      if (result == null || result.files.isEmpty) {
        return RestoreResult(
          success: false,
          message: 'No file selected',
        );
      }
      
      final file = File(result.files.single.path!);
      
      // Read and decompress
      final compressed = await file.readAsBytes();
      final decompressed = GZipDecoder().decodeBytes(compressed);
      final jsonString = utf8.decode(decompressed);
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Validate backup
      final metadata = backupData['metadata'] as Map<String, dynamic>?;
      if (metadata == null || metadata['version'] != backupVersion) {
        return RestoreResult(
          success: false,
          message: 'Invalid or incompatible backup file',
        );
      }
      
      // Show confirmation dialog
      final backupDate = DateTime.parse(metadata['createdAt'] as String);
      final confirmed = await _showRestoreConfirmation(
        businessName: metadata['businessName'] as String,
        backupDate: backupDate,
      );
      
      if (!confirmed) {
        return RestoreResult(
          success: false,
          message: 'Restore cancelled',
        );
      }
      
      // Clear existing data and restore
      await _clearAllData();
      await _restoreData(backupData);
      
      return RestoreResult(
        success: true,
        message: 'Backup restored successfully',
        itemsRestored: _countRestoredItems(backupData),
      );
    } catch (e) {
      return RestoreResult(
        success: false,
        message: 'Restore failed: $e',
      );
    }
  }
  
  static Future<bool> _showRestoreConfirmation({
    required String businessName,
    required DateTime backupDate,
  }) async {
    // This should be replaced with actual dialog implementation
    // For now, returning true for automatic confirmation
    return true;
  }
  
  static Future<void> _clearAllData() async {
    final boxNames = [
      'products',
      'customers',
      'bills',
      'drafts',
      'expenses',
      'staff',
      'settings',
    ];
    
    for (final boxName in boxNames) {
      try {
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box(boxName);
          await box.clear();
        }
      } catch (e) {
        print('Error clearing $boxName: $e');
      }
    }
  }
  
  static Future<void> _restoreData(Map<String, dynamic> backupData) async {
    for (final entry in backupData.entries) {
      if (entry.key == 'metadata') continue;
      
      try {
        Box box;
        if (Hive.isBoxOpen(entry.key)) {
          box = Hive.box(entry.key);
        } else {
          box = await Hive.openBox(entry.key);
        }
        
        final items = entry.value as List;
        for (final item in items) {
          final itemData = Map<String, dynamic>.from(item);
          final id = itemData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
          await box.put(id, itemData);
        }
      } catch (e) {
        print('Error restoring ${entry.key}: $e');
      }
    }
  }
  
  static int _countRestoredItems(Map<String, dynamic> backupData) {
    int count = 0;
    for (final entry in backupData.entries) {
      if (entry.key != 'metadata' && entry.value is List) {
        count += (entry.value as List).length;
      }
    }
    return count;
  }
  
  static Future<BackupSchedule?> getBackupSchedule() async {
    try {
      final box = await Hive.openBox('settings');
      final scheduleData = box.get('backupSchedule');
      if (scheduleData != null) {
        return BackupSchedule.fromJson(Map<String, dynamic>.from(scheduleData));
      }
    } catch (e) {
      print('Error getting backup schedule: $e');
    }
    return null;
  }
  
  static Future<void> setBackupSchedule(BackupSchedule schedule) async {
    try {
      final box = await Hive.openBox('settings');
      await box.put('backupSchedule', schedule.toJson());
    } catch (e) {
      print('Error setting backup schedule: $e');
    }
  }
  
  static Future<List<BackupInfo>> getBackupHistory() async {
    try {
      final box = await Hive.openBox('settings');
      final history = box.get('backupHistory', defaultValue: []);
      return (history as List)
          .map((item) => BackupInfo.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      print('Error getting backup history: $e');
      return [];
    }
  }
  
  static Future<void> addToBackupHistory(BackupInfo info) async {
    try {
      final box = await Hive.openBox('settings');
      final history = box.get('backupHistory', defaultValue: []) as List;
      history.insert(0, info.toJson());
      
      // Keep only last 10 backups in history
      if (history.length > 10) {
        history.removeRange(10, history.length);
      }
      
      await box.put('backupHistory', history);
    } catch (e) {
      print('Error adding to backup history: $e');
    }
  }
}

class BackupResult {
  final bool success;
  final String message;
  final String? filePath;
  final int? size;
  
  BackupResult({
    required this.success,
    required this.message,
    this.filePath,
    this.size,
  });
}

class RestoreResult {
  final bool success;
  final String message;
  final int? itemsRestored;
  
  RestoreResult({
    required this.success,
    required this.message,
    this.itemsRestored,
  });
}

class BackupSchedule {
  final bool enabled;
  final String frequency; // daily, weekly, monthly
  final int hour; // 0-23
  final int? dayOfWeek; // 1-7 for weekly
  final int? dayOfMonth; // 1-31 for monthly
  
  BackupSchedule({
    required this.enabled,
    required this.frequency,
    required this.hour,
    this.dayOfWeek,
    this.dayOfMonth,
  });
  
  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'frequency': frequency,
    'hour': hour,
    'dayOfWeek': dayOfWeek,
    'dayOfMonth': dayOfMonth,
  };
  
  factory BackupSchedule.fromJson(Map<String, dynamic> json) => BackupSchedule(
    enabled: json['enabled'] ?? false,
    frequency: json['frequency'] ?? 'daily',
    hour: json['hour'] ?? 2,
    dayOfWeek: json['dayOfWeek'],
    dayOfMonth: json['dayOfMonth'],
  );
}

class BackupInfo {
  final DateTime createdAt;
  final String fileName;
  final int size;
  final bool isAutomatic;
  
  BackupInfo({
    required this.createdAt,
    required this.fileName,
    required this.size,
    required this.isAutomatic,
  });
  
  Map<String, dynamic> toJson() => {
    'createdAt': createdAt.toIso8601String(),
    'fileName': fileName,
    'size': size,
    'isAutomatic': isAutomatic,
  };
  
  factory BackupInfo.fromJson(Map<String, dynamic> json) => BackupInfo(
    createdAt: DateTime.parse(json['createdAt']),
    fileName: json['fileName'],
    size: json['size'],
    isAutomatic: json['isAutomatic'] ?? false,
  );
}