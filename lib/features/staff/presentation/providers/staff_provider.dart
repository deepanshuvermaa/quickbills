import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/models/staff_model.dart';

final staffProvider = StateNotifierProvider<StaffNotifier, AsyncValue<List<StaffModel>>>((ref) {
  return StaffNotifier();
});

class StaffNotifier extends StateNotifier<AsyncValue<List<StaffModel>>> {
  StaffNotifier() : super(const AsyncValue.loading()) {
    _loadStaff();
  }
  
  Future<void> _loadStaff() async {
    try {
      Box<StaffModel> box;
      const boxName = 'staff';
      
      if (Hive.isBoxOpen(boxName)) {
        box = Hive.box<StaffModel>(boxName);
      } else {
        box = await Hive.openBox<StaffModel>(boxName);
      }
      
      // Add mock data if empty
      if (box.isEmpty) {
        await _addMockStaff(box);
      }
      
      final staff = box.values.toList();
      state = AsyncValue.data(staff);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  Future<void> _addMockStaff(Box<StaffModel> box) async {
    final mockStaff = [
      StaffModel.create(
        name: 'Admin User',
        email: 'admin@quickbills.com',
        phone: '+91 9876543210',
        role: StaffRole.admin,
        password: 'admin123',
        monthlySalary: 50000,
      ),
      StaffModel.create(
        name: 'Rajesh Kumar',
        email: 'rajesh@quickbills.com',
        phone: '+91 9876543211',
        role: StaffRole.manager,
        password: 'manager123',
        monthlySalary: 35000,
        commissionRate: 2.5,
      ),
      StaffModel.create(
        name: 'Priya Sharma',
        email: 'priya@quickbills.com',
        phone: '+91 9876543212',
        role: StaffRole.cashier,
        password: 'cashier123',
        monthlySalary: 20000,
        commissionRate: 1.5,
      ),
    ];
    
    for (final staff in mockStaff) {
      await box.put(staff.id, staff);
    }
  }
  
  Future<void> addStaff(StaffModel staff) async {
    try {
      final box = Hive.box<StaffModel>('staff');
      await box.put(staff.id, staff);
      await _loadStaff();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  Future<void> updateStaff(StaffModel staff) async {
    try {
      final box = Hive.box<StaffModel>('staff');
      await box.put(staff.id, staff);
      await _loadStaff();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  Future<void> deleteStaff(String id) async {
    try {
      final box = Hive.box<StaffModel>('staff');
      await box.delete(id);
      await _loadStaff();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  StaffModel? getStaffById(String id) {
    return state.maybeWhen(
      data: (staff) => staff.firstWhere((s) => s.id == id),
      orElse: () => null,
    );
  }
  
  List<StaffModel> getActiveStaff() {
    return state.maybeWhen(
      data: (staff) => staff.where((s) => s.isActive).toList(),
      orElse: () => [],
    );
  }
  
  bool authenticateStaff(String email, String password) {
    return state.maybeWhen(
      data: (staff) => staff.any((s) => s.email == email && s.password == password && s.isActive),
      orElse: () => false,
    );
  }
}