import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/quotation_model.dart';

final quotationsProvider = StreamProvider<List<QuotationModel>>((ref) async* {
  Box<QuotationModel> box;
  
  if (Hive.isBoxOpen(AppConstants.quotationsBox)) {
    box = Hive.box<QuotationModel>(AppConstants.quotationsBox);
  } else {
    box = await Hive.openBox<QuotationModel>(AppConstants.quotationsBox);
  }
  
  // Initial data
  yield box.values.toList()..sort((a, b) => b.createdDate.compareTo(a.createdDate));
  
  // Listen to changes
  await for (final event in box.watch()) {
    yield box.values.toList()..sort((a, b) => b.createdDate.compareTo(a.createdDate));
  }
});

final quotationServiceProvider = Provider((ref) => QuotationService());

class QuotationService {
  Box<QuotationModel>? _quotationsBox;
  
  Future<Box<QuotationModel>> _getBox() async {
    if (_quotationsBox != null && _quotationsBox!.isOpen) {
      return _quotationsBox!;
    }
    
    if (Hive.isBoxOpen(AppConstants.quotationsBox)) {
      _quotationsBox = Hive.box<QuotationModel>(AppConstants.quotationsBox);
    } else {
      _quotationsBox = await Hive.openBox<QuotationModel>(AppConstants.quotationsBox);
    }
    
    return _quotationsBox!;
  }
  
  Future<void> saveQuotation(QuotationModel quotation) async {
    final box = await _getBox();
    await box.put(quotation.id, quotation);
  }
  
  Future<void> updateQuotation(QuotationModel quotation) async {
    final box = await _getBox();
    await box.put(quotation.id, quotation);
  }
  
  Future<void> deleteQuotation(String quotationId) async {
    final box = await _getBox();
    await box.delete(quotationId);
  }
  
  Future<QuotationModel?> getQuotation(String quotationId) async {
    final box = await _getBox();
    return box.get(quotationId);
  }
  
  Future<void> convertToInvoice(String quotationId) async {
    final box = await _getBox();
    final quotation = box.get(quotationId);
    if (quotation != null) {
      final updatedQuotation = quotation.copyWith(
        status: 'accepted',
        convertedDate: DateTime.now(),
        convertedBillId: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      await box.put(quotationId, updatedQuotation);
    }
  }
  
  Future<List<QuotationModel>> searchQuotations(String query) async {
    final box = await _getBox();
    final quotations = box.values.toList();
    
    return quotations.where((quotation) {
      return quotation.quotationNumber.toLowerCase().contains(query.toLowerCase()) ||
          (quotation.customerName?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }
  
  Future<List<QuotationModel>> getQuotationsByStatus(String status) async {
    final box = await _getBox();
    return box.values.where((q) => q.status == status).toList();
  }
  
  Future<List<QuotationModel>> getExpiringQuotations(int days) async {
    final box = await _getBox();
    final futureDate = DateTime.now().add(Duration(days: days));
    return box.values.where((q) => 
      q.status == 'draft' && 
      q.validityDate.isBefore(futureDate) &&
      q.validityDate.isAfter(DateTime.now())
    ).toList();
  }
}