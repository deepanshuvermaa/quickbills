import 'package:hive/hive.dart';

part 'usage_log_model.g.dart';

@HiveType(typeId: 1)
class UsageLogModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String action;
  
  @HiveField(2)
  final Map<String, dynamic>? details;
  
  @HiveField(3)
  final DateTime timestamp;
  
  @HiveField(4)
  final bool isSynced;
  
  @HiveField(5)
  final String? sessionId;
  
  UsageLogModel({
    required this.id,
    required this.action,
    this.details,
    required this.timestamp,
    this.isSynced = false,
    this.sessionId,
  });
  
  factory UsageLogModel.create({
    required String action,
    Map<String, dynamic>? details,
    String? sessionId,
  }) {
    return UsageLogModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      action: action,
      details: details,
      timestamp: DateTime.now(),
      sessionId: sessionId,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
      'sessionId': sessionId,
    };
  }
  
  UsageLogModel copyWith({
    String? id,
    String? action,
    Map<String, dynamic>? details,
    DateTime? timestamp,
    bool? isSynced,
    String? sessionId,
  }) {
    return UsageLogModel(
      id: id ?? this.id,
      action: action ?? this.action,
      details: details ?? this.details,
      timestamp: timestamp ?? this.timestamp,
      isSynced: isSynced ?? this.isSynced,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}