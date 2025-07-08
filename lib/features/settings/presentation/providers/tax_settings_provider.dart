import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Tax settings model
class TaxSettings {
  final bool isGSTEnabled;
  final double cgstRate;
  final double sgstRate;
  final double igstRate;
  final bool taxInclusivePricing;
  final String gstNumber;

  TaxSettings({
    required this.isGSTEnabled,
    required this.cgstRate,
    required this.sgstRate,
    required this.igstRate,
    required this.taxInclusivePricing,
    required this.gstNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'isGSTEnabled': isGSTEnabled,
      'cgstRate': cgstRate,
      'sgstRate': sgstRate,
      'igstRate': igstRate,
      'taxInclusivePricing': taxInclusivePricing,
      'gstNumber': gstNumber,
    };
  }

  factory TaxSettings.fromMap(Map<String, dynamic> map) {
    return TaxSettings(
      isGSTEnabled: map['isGSTEnabled'] ?? true,
      cgstRate: map['cgstRate'] ?? 9.0,
      sgstRate: map['sgstRate'] ?? 9.0,
      igstRate: map['igstRate'] ?? 18.0,
      taxInclusivePricing: map['taxInclusivePricing'] ?? false,
      gstNumber: map['gstNumber'] ?? '',
    );
  }

  factory TaxSettings.defaultSettings() {
    return TaxSettings(
      isGSTEnabled: true,
      cgstRate: 9.0,
      sgstRate: 9.0,
      igstRate: 18.0,
      taxInclusivePricing: false,
      gstNumber: '',
    );
  }
}

// Tax settings provider
final taxSettingsProvider = StateNotifierProvider<TaxSettingsNotifier, AsyncValue<TaxSettings>>((ref) {
  return TaxSettingsNotifier();
});

class TaxSettingsNotifier extends StateNotifier<AsyncValue<TaxSettings>> {
  static const String _boxName = 'settings';
  static const String _taxSettingsKey = 'taxSettings';
  
  TaxSettingsNotifier() : super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final box = await Hive.openBox(_boxName);
      final settingsMap = box.get(_taxSettingsKey);
      
      if (settingsMap != null) {
        state = AsyncValue.data(TaxSettings.fromMap(Map<String, dynamic>.from(settingsMap)));
      } else {
        state = AsyncValue.data(TaxSettings.defaultSettings());
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateSettings(TaxSettings settings) async {
    try {
      state = const AsyncValue.loading();
      
      final box = await Hive.openBox(_boxName);
      await box.put(_taxSettingsKey, settings.toMap());
      
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}