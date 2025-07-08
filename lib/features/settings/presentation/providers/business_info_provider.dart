import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';

// Business info model
class BusinessInfo {
  final String? businessName;
  final String? address;
  final String? phone;
  final String? email;
  final String? gstNumber;
  final String? panNumber;

  BusinessInfo({
    this.businessName,
    this.address,
    this.phone,
    this.email,
    this.gstNumber,
    this.panNumber,
  });
}

// Provider for business info
final businessInfoProvider = FutureProvider<BusinessInfo?>((ref) async {
  try {
    Box box;
    if (Hive.isBoxOpen(AppConstants.businessInfoBox)) {
      box = Hive.box(AppConstants.businessInfoBox);
    } else {
      box = await Hive.openBox(AppConstants.businessInfoBox);
    }
    
    return BusinessInfo(
      businessName: box.get('businessName'),
      address: box.get('address'),
      phone: box.get('phone'),
      email: box.get('email'),
      gstNumber: box.get('gstin'),
      panNumber: box.get('pan'),
    );
  } catch (e) {
    return null;
  }
});