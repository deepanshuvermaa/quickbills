import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/models/quotation_model.dart';
import '../../../billing/presentation/screens/billing_screen.dart';

final quotationsProvider = StateNotifierProvider<QuotationsNotifier, AsyncValue<List<QuotationModel>>>((ref) {
  return QuotationsNotifier();
});

class QuotationsNotifier extends StateNotifier<AsyncValue<List<QuotationModel>>> {
  QuotationsNotifier() : super(const AsyncValue.loading()) {
    _loadQuotations();
  }
  
  Future<void> _loadQuotations() async {
    try {
      Box<QuotationModel> box;
      const boxName = 'quotations';
      
      if (Hive.isBoxOpen(boxName)) {
        box = Hive.box<QuotationModel>(boxName);
      } else {
        box = await Hive.openBox<QuotationModel>(boxName);
      }
      
      // Add mock data if empty
      if (box.isEmpty) {
        await _addMockQuotations(box);
      }
      
      final quotations = box.values.toList()
        ..sort((a, b) => b.createdDate.compareTo(a.createdDate));
      
      state = AsyncValue.data(quotations);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  Future<void> _addMockQuotations(Box<QuotationModel> box) async {
    final now = DateTime.now();
    
    // Create mock cart items
    final mockItems1 = [
      QuotationItem(
        productId: '1',
        productName: 'Laptop - Dell Inspiron 15',
        price: 45999.99,
        quantity: 2,
        total: 91999.98,
      ),
      QuotationItem(
        productId: '2',
        productName: 'Wireless Mouse',
        price: 1299.00,
        quantity: 2,
        total: 2598.00,
      ),
    ];
    
    final mockItems2 = [
      QuotationItem(
        productId: '3',
        productName: 'Office Chair',
        price: 8999.00,
        quantity: 5,
        total: 44995.00,
      ),
      QuotationItem(
        productId: '4',
        productName: 'Desk Lamp',
        price: 1599.00,
        quantity: 5,
        total: 7995.00,
      ),
    ];
    
    final mockQuotations = [
      QuotationModel.create(
        validityDate: now.add(const Duration(days: 30)),
        customerName: 'Tech Solutions Pvt Ltd',
        customerPhone: '+91 9876543210',
        customerEmail: 'info@techsolutions.com',
        items: mockItems1,
        subtotal: 94597.98,
        discount: 4597.98,
        tax: 16200.00,
        total: 106200.00,
        notes: 'Bulk order discount applied',
        terms: '1. Prices are valid for 30 days\n2. Delivery within 7 working days\n3. Payment: 50% advance, 50% on delivery',
        taxDetails: {
          'cgst': 9,
          'sgst': 9,
        },
      ).copyWith(status: 'sent'),
      
      QuotationModel.create(
        validityDate: now.add(const Duration(days: 15)),
        customerName: 'Startup Hub',
        customerPhone: '+91 9876543211',
        customerEmail: 'purchase@startuphub.com',
        items: mockItems2,
        subtotal: 52990.00,
        discount: 2990.00,
        tax: 9000.00,
        total: 59000.00,
        notes: 'Office furniture for new branch',
        taxDetails: {
          'cgst': 9,
          'sgst': 9,
        },
      ),
      
      // Expired quotation
      QuotationModel.create(
        validityDate: now.subtract(const Duration(days: 5)),
        customerName: 'ABC Corporation',
        customerPhone: '+91 9876543212',
        items: mockItems1,
        subtotal: 94597.98,
        discount: 0,
        tax: 17027.64,
        total: 111625.62,
        taxDetails: {
          'igst': 18,
        },
      ).copyWith(status: 'sent'),
      
      // Accepted quotation
      QuotationModel.create(
        validityDate: now.add(const Duration(days: 20)),
        customerName: 'XYZ Enterprises',
        customerPhone: '+91 9876543213',
        customerEmail: 'accounts@xyz.com',
        items: mockItems2,
        subtotal: 52990.00,
        discount: 0,
        tax: 9538.20,
        total: 62528.20,
        taxDetails: {
          'cgst': 9,
          'sgst': 9,
        },
      ).copyWith(
        status: 'accepted',
        convertedDate: now.subtract(const Duration(days: 2)),
        convertedBillId: 'BILL-001',
      ),
    ];
    
    for (final quotation in mockQuotations) {
      await box.put(quotation.id, quotation);
    }
  }
  
  Future<void> addQuotation(QuotationModel quotation) async {
    try {
      final box = Hive.box<QuotationModel>('quotations');
      await box.put(quotation.id, quotation);
      await _loadQuotations();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  Future<void> updateQuotation(QuotationModel quotation) async {
    try {
      final box = Hive.box<QuotationModel>('quotations');
      await box.put(quotation.id, quotation);
      await _loadQuotations();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  Future<void> deleteQuotation(String id) async {
    try {
      final box = Hive.box<QuotationModel>('quotations');
      await box.delete(id);
      await _loadQuotations();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  Future<void> duplicateQuotation(String id) async {
    try {
      final box = Hive.box<QuotationModel>('quotations');
      final original = box.get(id);
      if (original != null) {
        final duplicate = QuotationModel.create(
          validityDate: DateTime.now().add(const Duration(days: 30)),
          customerName: original.customerName,
          customerPhone: original.customerPhone,
          customerEmail: original.customerEmail,
          items: original.items,
          subtotal: original.subtotal,
          discount: original.discount,
          tax: original.tax,
          total: original.total,
          notes: original.notes,
          terms: original.terms,
          taxDetails: original.taxDetails,
        );
        await box.put(duplicate.id, duplicate);
        await _loadQuotations();
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  Future<void> convertToBill(String id) async {
    try {
      final box = Hive.box<QuotationModel>('quotations');
      final quotation = box.get(id);
      if (quotation != null) {
        // Update quotation status
        final updated = quotation.copyWith(
          status: 'accepted',
          convertedDate: DateTime.now(),
          convertedBillId: 'BILL-${DateTime.now().millisecondsSinceEpoch}',
        );
        await box.put(id, updated);
        
        // TODO: Actually create a bill from this quotation
        
        await _loadQuotations();
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  Future<void> updateStatus(String id, String status) async {
    try {
      final box = Hive.box<QuotationModel>('quotations');
      final quotation = box.get(id);
      if (quotation != null) {
        final updated = quotation.copyWith(status: status);
        await box.put(id, updated);
        await _loadQuotations();
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}