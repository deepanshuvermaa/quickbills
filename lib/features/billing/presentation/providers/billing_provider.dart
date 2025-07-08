import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/bill_model.dart';

final billsProvider = StreamProvider<List<BillModel>>((ref) async* {
  Box<BillModel> box;
  
  if (Hive.isBoxOpen(AppConstants.billsBox)) {
    box = Hive.box<BillModel>(AppConstants.billsBox);
  } else {
    box = await Hive.openBox<BillModel>(AppConstants.billsBox);
  }
  
  // Initial data
  yield box.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  
  // Listen to changes
  await for (final event in box.watch()) {
    yield box.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
});

final draftBillsProvider = Provider<AsyncValue<List<BillModel>>>((ref) {
  final billsAsync = ref.watch(billsProvider);
  
  return billsAsync.whenData((bills) {
    return bills.where((bill) => bill.status == BillStatus.draft).toList();
  });
});

final completedBillsProvider = Provider<AsyncValue<List<BillModel>>>((ref) {
  final billsAsync = ref.watch(billsProvider);
  
  return billsAsync.whenData((bills) {
    return bills.where((bill) => bill.status == BillStatus.completed).toList();
  });
});

final billingServiceProvider = Provider((ref) => BillingService());

class BillingService {
  Box<BillModel>? _billsBox;
  
  Future<Box<BillModel>> _getBox() async {
    if (_billsBox != null && _billsBox!.isOpen) {
      return _billsBox!;
    }
    
    if (Hive.isBoxOpen(AppConstants.billsBox)) {
      _billsBox = Hive.box<BillModel>(AppConstants.billsBox);
    } else {
      _billsBox = await Hive.openBox<BillModel>(AppConstants.billsBox);
    }
    
    return _billsBox!;
  }
  
  Future<void> saveBill(BillModel bill) async {
    final box = await _getBox();
    await box.put(bill.id, bill);
  }
  
  Future<void> updateBill(BillModel bill) async {
    final box = await _getBox();
    await box.put(bill.id, bill.copyWith(updatedAt: DateTime.now()));
  }
  
  Future<void> deleteBill(String billId) async {
    final box = await _getBox();
    await box.delete(billId);
  }
  
  Future<BillModel?> getBill(String billId) async {
    final box = await _getBox();
    return box.get(billId);
  }
  
  Future<List<BillModel>> searchBills(String query) async {
    final box = await _getBox();
    final bills = box.values.toList();
    
    return bills.where((bill) {
      return bill.invoiceNumber.toLowerCase().contains(query.toLowerCase()) ||
          (bill.customerName?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
          bill.items.any((item) => item.productName.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }
  
  Future<List<BillModel>> getBillsByDateRange(DateTime start, DateTime end) async {
    final box = await _getBox();
    final bills = box.values.toList();
    
    return bills.where((bill) {
      return bill.createdAt.isAfter(start) && bill.createdAt.isBefore(end);
    }).toList();
  }
  
  Future<double> getTotalSales({DateTime? start, DateTime? end}) async {
    final box = await _getBox();
    var bills = box.values.where((bill) => bill.status == BillStatus.completed);
    
    if (start != null && end != null) {
      bills = bills.where((bill) => 
        bill.createdAt.isAfter(start) && bill.createdAt.isBefore(end)
      );
    }
    
    return bills.fold<double>(0.0, (sum, bill) => sum + bill.total);
  }
}

// Provider for customer bills
final customerBillsProvider = FutureProvider.family<List<BillModel>, String>((ref, customerId) async {
  final service = ref.read(billingServiceProvider);
  final box = await service._getBox();
  final bills = box.values.where((bill) => bill.customerId == customerId).toList();
  bills.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return bills;
});