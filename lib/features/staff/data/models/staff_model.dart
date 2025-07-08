import 'package:hive/hive.dart';

part 'staff_model.g.dart';

@HiveType(typeId: 11)
class StaffModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String email;
  
  @HiveField(3)
  final String phone;
  
  @HiveField(4)
  final String role;
  
  @HiveField(5)
  final String password;
  
  @HiveField(6)
  final bool isActive;
  
  @HiveField(7)
  final DateTime joinDate;
  
  @HiveField(8)
  final double? monthlySalary;
  
  @HiveField(9)
  final double? commissionRate;
  
  @HiveField(10)
  final List<String> permissions;
  
  @HiveField(11)
  final String? profileImage;
  
  @HiveField(12)
  final Map<String, dynamic>? activityLog;
  
  @HiveField(13)
  final DateTime? lastLogin;
  
  StaffModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.password,
    this.isActive = true,
    required this.joinDate,
    this.monthlySalary,
    this.commissionRate,
    required this.permissions,
    this.profileImage,
    this.activityLog,
    this.lastLogin,
  });
  
  factory StaffModel.create({
    required String name,
    required String email,
    required String phone,
    required String role,
    required String password,
    double? monthlySalary,
    double? commissionRate,
    List<String>? permissions,
  }) {
    return StaffModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phone: phone,
      role: role,
      password: password,
      joinDate: DateTime.now(),
      monthlySalary: monthlySalary,
      commissionRate: commissionRate,
      permissions: permissions ?? StaffRole.getDefaultPermissions(role),
    );
  }
  
  double calculateCommission(double salesAmount) {
    if (commissionRate == null || commissionRate == 0) return 0;
    return salesAmount * (commissionRate! / 100);
  }
  
  bool hasPermission(String permission) {
    return permissions.contains(permission) || role == StaffRole.admin;
  }
  
  StaffModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? password,
    bool? isActive,
    double? monthlySalary,
    double? commissionRate,
    List<String>? permissions,
    String? profileImage,
    DateTime? lastLogin,
  }) {
    return StaffModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      password: password ?? this.password,
      isActive: isActive ?? this.isActive,
      joinDate: joinDate,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      commissionRate: commissionRate ?? this.commissionRate,
      permissions: permissions ?? this.permissions,
      profileImage: profileImage ?? this.profileImage,
      activityLog: activityLog,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

class StaffRole {
  static const String admin = 'Admin';
  static const String manager = 'Manager';
  static const String cashier = 'Cashier';
  static const String viewer = 'Viewer';
  
  static List<String> get all => [admin, manager, cashier, viewer];
  
  static List<String> getDefaultPermissions(String role) {
    switch (role) {
      case admin:
        return StaffPermission.all;
      case manager:
        return [
          StaffPermission.billing,
          StaffPermission.inventory,
          StaffPermission.customers,
          StaffPermission.reports,
          StaffPermission.expenses,
          StaffPermission.quotations,
        ];
      case cashier:
        return [
          StaffPermission.billing,
          StaffPermission.customers,
        ];
      case viewer:
        return [
          StaffPermission.viewReports,
        ];
      default:
        return [];
    }
  }
}

class StaffPermission {
  static const String billing = 'billing';
  static const String inventory = 'inventory';
  static const String customers = 'customers';
  static const String reports = 'reports';
  static const String expenses = 'expenses';
  static const String quotations = 'quotations';
  static const String staff = 'staff';
  static const String settings = 'settings';
  static const String backup = 'backup';
  static const String viewReports = 'view_reports';
  
  static List<String> get all => [
    billing,
    inventory,
    customers,
    reports,
    expenses,
    quotations,
    staff,
    settings,
    backup,
    viewReports,
  ];
  
  static String getDisplayName(String permission) {
    switch (permission) {
      case billing:
        return 'Billing & Sales';
      case inventory:
        return 'Inventory Management';
      case customers:
        return 'Customer Management';
      case reports:
        return 'Full Reports Access';
      case expenses:
        return 'Expense Management';
      case quotations:
        return 'Quotations';
      case staff:
        return 'Staff Management';
      case settings:
        return 'Settings';
      case backup:
        return 'Backup & Restore';
      case viewReports:
        return 'View Reports Only';
      default:
        return permission;
    }
  }
}