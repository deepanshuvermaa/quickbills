import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/customer_model.dart';

final customersProvider = StreamProvider<List<CustomerModel>>((ref) async* {
  Box<CustomerModel> box;
  
  if (Hive.isBoxOpen(AppConstants.customersBox)) {
    box = Hive.box<CustomerModel>(AppConstants.customersBox);
  } else {
    box = await Hive.openBox<CustomerModel>(AppConstants.customersBox);
  }
  
  // Add mock data if empty
  if (box.isEmpty) {
    await _addMockCustomers(box);
  }
  
  // Initial data
  yield box.values.toList();
  
  // Listen to changes
  await for (final event in box.watch()) {
    yield box.values.toList();
  }
});

Future<void> _addMockCustomers(Box<CustomerModel> box) async {
  final mockCustomers = [
    CustomerModel(
      id: '1',
      name: 'Rajesh Kumar',
      email: 'rajesh.kumar@gmail.com',
      phone: '+919876543210',
      address: '123, MG Road, Bangalore - 560001',
      gstNumber: '29ABCDE1234F1Z5',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      totalPurchases: 125000,
      totalTransactions: 15,
    ),
    CustomerModel(
      id: '2',
      name: 'Priya Sharma',
      email: 'priya.sharma@yahoo.com',
      phone: '+919123456789',
      address: '456, Nehru Nagar, Delhi - 110001',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      totalPurchases: 85000,
      totalTransactions: 12,
    ),
    CustomerModel(
      id: '3',
      name: 'Tech Solutions Pvt Ltd',
      email: 'info@techsolutions.in',
      phone: '+918765432109',
      address: 'Plot 789, IT Park, Pune - 411001',
      gstNumber: '27AABCT1234D1Z5',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      totalPurchases: 450000,
      totalTransactions: 25,
    ),
    CustomerModel(
      id: '4',
      name: 'Amit Patel',
      email: 'amit.patel@gmail.com',
      phone: '+917654321098',
      address: '321, Gandhi Road, Ahmedabad - 380001',
      gstNumber: '24ABCDE5678G1H6',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      totalPurchases: 35000,
      totalTransactions: 5,
    ),
    CustomerModel(
      id: '5',
      name: 'Sunita Enterprises',
      phone: '+916543210987',
      address: '567, Market Street, Mumbai - 400001',
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      totalPurchases: 750000,
      totalTransactions: 45,
    ),
  ];
  
  for (var customer in mockCustomers) {
    await box.put(customer.id, customer);
  }
}

final customerServiceProvider = Provider((ref) => CustomerService());

class CustomerService {
  Box<CustomerModel>? _customersBox;
  
  Future<Box<CustomerModel>> _getBox() async {
    if (_customersBox != null && _customersBox!.isOpen) {
      return _customersBox!;
    }
    
    if (Hive.isBoxOpen(AppConstants.customersBox)) {
      _customersBox = Hive.box<CustomerModel>(AppConstants.customersBox);
    } else {
      _customersBox = await Hive.openBox<CustomerModel>(AppConstants.customersBox);
    }
    
    return _customersBox!;
  }
  
  Future<void> addCustomer(CustomerModel customer) async {
    final box = await _getBox();
    await box.put(customer.id, customer);
  }
  
  Future<void> updateCustomer(CustomerModel customer) async {
    final box = await _getBox();
    await box.put(customer.id, customer.copyWith(updatedAt: DateTime.now()));
  }
  
  Future<void> deleteCustomer(String customerId) async {
    final box = await _getBox();
    await box.delete(customerId);
  }
  
  Future<CustomerModel?> getCustomer(String customerId) async {
    final box = await _getBox();
    return box.get(customerId);
  }
  
  Future<List<CustomerModel>> searchCustomers(String query) async {
    final box = await _getBox();
    final customers = box.values.toList();
    return customers.where((customer) {
      return customer.name.toLowerCase().contains(query.toLowerCase()) ||
          (customer.phone?.contains(query) ?? false) ||
          (customer.email?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }
}

// Provider for individual customer
final customerProvider = FutureProvider.family<CustomerModel?, String>((ref, customerId) async {
  final service = ref.read(customerServiceProvider);
  return await service.getCustomer(customerId);
});