import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Invoice settings model
class InvoiceSettings {
  final bool autoGenerateInvoiceNumber;
  final bool showTaxBreakdown;
  final bool showPaymentTerms;
  final bool showNotes;
  final String invoicePrefix;
  final String defaultPaymentTerms;
  final String defaultCurrency;
  final double defaultTaxRate;
  final String? logoPath;
  final int? brandColor;
  final String footerText;
  final Map<String, String> bankDetails;
  final String termsConditions;
  final int nextInvoiceNumber;

  InvoiceSettings({
    required this.autoGenerateInvoiceNumber,
    required this.showTaxBreakdown,
    required this.showPaymentTerms,
    required this.showNotes,
    required this.invoicePrefix,
    required this.defaultPaymentTerms,
    required this.defaultCurrency,
    required this.defaultTaxRate,
    this.logoPath,
    this.brandColor,
    required this.footerText,
    required this.bankDetails,
    required this.termsConditions,
    required this.nextInvoiceNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'autoGenerateInvoiceNumber': autoGenerateInvoiceNumber,
      'showTaxBreakdown': showTaxBreakdown,
      'showPaymentTerms': showPaymentTerms,
      'showNotes': showNotes,
      'invoicePrefix': invoicePrefix,
      'defaultPaymentTerms': defaultPaymentTerms,
      'defaultCurrency': defaultCurrency,
      'defaultTaxRate': defaultTaxRate,
      'logoPath': logoPath,
      'brandColor': brandColor,
      'footerText': footerText,
      'bankDetails': bankDetails,
      'termsConditions': termsConditions,
      'nextInvoiceNumber': nextInvoiceNumber,
    };
  }

  factory InvoiceSettings.fromMap(Map<String, dynamic> map) {
    return InvoiceSettings(
      autoGenerateInvoiceNumber: map['autoGenerateInvoiceNumber'] ?? true,
      showTaxBreakdown: map['showTaxBreakdown'] ?? true,
      showPaymentTerms: map['showPaymentTerms'] ?? true,
      showNotes: map['showNotes'] ?? true,
      invoicePrefix: map['invoicePrefix'] ?? 'INV-',
      defaultPaymentTerms: map['defaultPaymentTerms'] ?? 'Net 30',
      defaultCurrency: map['defaultCurrency'] ?? 'INR',
      defaultTaxRate: map['defaultTaxRate'] ?? 18.0,
      logoPath: map['logoPath'],
      brandColor: map['brandColor'],
      footerText: map['footerText'] ?? 'Thank you for your business!',
      bankDetails: Map<String, String>.from(map['bankDetails'] ?? {}),
      termsConditions: map['termsConditions'] ?? '',
      nextInvoiceNumber: map['nextInvoiceNumber'] ?? 1,
    );
  }

  factory InvoiceSettings.defaultSettings() {
    return InvoiceSettings(
      autoGenerateInvoiceNumber: true,
      showTaxBreakdown: true,
      showPaymentTerms: true,
      showNotes: true,
      invoicePrefix: 'INV-',
      defaultPaymentTerms: 'Net 30',
      defaultCurrency: 'INR',
      defaultTaxRate: 18.0,
      footerText: 'Thank you for your business!',
      bankDetails: {},
      termsConditions: '',
      nextInvoiceNumber: 1,
    );
  }

  InvoiceSettings copyWith({
    bool? autoGenerateInvoiceNumber,
    bool? showTaxBreakdown,
    bool? showPaymentTerms,
    bool? showNotes,
    String? invoicePrefix,
    String? defaultPaymentTerms,
    String? defaultCurrency,
    double? defaultTaxRate,
    String? logoPath,
    int? brandColor,
    String? footerText,
    Map<String, String>? bankDetails,
    String? termsConditions,
    int? nextInvoiceNumber,
  }) {
    return InvoiceSettings(
      autoGenerateInvoiceNumber: autoGenerateInvoiceNumber ?? this.autoGenerateInvoiceNumber,
      showTaxBreakdown: showTaxBreakdown ?? this.showTaxBreakdown,
      showPaymentTerms: showPaymentTerms ?? this.showPaymentTerms,
      showNotes: showNotes ?? this.showNotes,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      defaultPaymentTerms: defaultPaymentTerms ?? this.defaultPaymentTerms,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      defaultTaxRate: defaultTaxRate ?? this.defaultTaxRate,
      logoPath: logoPath ?? this.logoPath,
      brandColor: brandColor ?? this.brandColor,
      footerText: footerText ?? this.footerText,
      bankDetails: bankDetails ?? this.bankDetails,
      termsConditions: termsConditions ?? this.termsConditions,
      nextInvoiceNumber: nextInvoiceNumber ?? this.nextInvoiceNumber,
    );
  }
}

// Invoice settings provider
final invoiceSettingsProvider = StateNotifierProvider<InvoiceSettingsNotifier, AsyncValue<InvoiceSettings>>((ref) {
  return InvoiceSettingsNotifier();
});

class InvoiceSettingsNotifier extends StateNotifier<AsyncValue<InvoiceSettings>> {
  static const String _boxName = 'settings';
  static const String _invoiceSettingsKey = 'invoiceSettings';
  
  InvoiceSettingsNotifier() : super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final box = await Hive.openBox(_boxName);
      final settingsMap = box.get(_invoiceSettingsKey);
      
      if (settingsMap != null) {
        state = AsyncValue.data(InvoiceSettings.fromMap(Map<String, dynamic>.from(settingsMap)));
      } else {
        state = AsyncValue.data(InvoiceSettings.defaultSettings());
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateSettings(InvoiceSettings settings) async {
    try {
      state = const AsyncValue.loading();
      
      final box = await Hive.openBox(_boxName);
      await box.put(_invoiceSettingsKey, settings.toMap());
      
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<int> getNextInvoiceNumber() async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      final nextNumber = currentSettings.nextInvoiceNumber;
      // Update the next number
      await updateSettings(currentSettings.copyWith(
        nextInvoiceNumber: nextNumber + 1,
      ));
      return nextNumber;
    }
    return 1;
  }
}