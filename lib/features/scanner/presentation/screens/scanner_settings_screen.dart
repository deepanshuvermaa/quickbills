import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/app_constants.dart';

class ScannerSettingsScreen extends ConsumerStatefulWidget {
  const ScannerSettingsScreen({super.key});

  @override
  ConsumerState<ScannerSettingsScreen> createState() => _ScannerSettingsScreenState();
}

class _ScannerSettingsScreenState extends ConsumerState<ScannerSettingsScreen> {
  late Box _settingsBox;
  bool _isLoading = true;
  
  // Scanner settings
  bool _autoScanEnabled = true;
  bool _flashEnabled = false;
  bool _beepSoundEnabled = true;
  bool _vibrateEnabled = true;
  String _scannerFormat = 'all';
  bool _continuousScanMode = false;
  double _scanDelay = 1.0;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    try {
      _settingsBox = await Hive.openBox(AppConstants.settingsBox);
      
      setState(() {
        _autoScanEnabled = _settingsBox.get('scanner_auto_scan', defaultValue: true);
        _flashEnabled = _settingsBox.get('scanner_flash', defaultValue: false);
        _beepSoundEnabled = _settingsBox.get('scanner_beep', defaultValue: true);
        _vibrateEnabled = _settingsBox.get('scanner_vibrate', defaultValue: true);
        _scannerFormat = _settingsBox.get('scanner_format', defaultValue: 'all');
        _continuousScanMode = _settingsBox.get('scanner_continuous', defaultValue: false);
        _scanDelay = _settingsBox.get('scanner_delay', defaultValue: 1.0);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _saveSettings() async {
    try {
      await _settingsBox.put('scanner_auto_scan', _autoScanEnabled);
      await _settingsBox.put('scanner_flash', _flashEnabled);
      await _settingsBox.put('scanner_beep', _beepSoundEnabled);
      await _settingsBox.put('scanner_vibrate', _vibrateEnabled);
      await _settingsBox.put('scanner_format', _scannerFormat);
      await _settingsBox.put('scanner_continuous', _continuousScanMode);
      await _settingsBox.put('scanner_delay', _scanDelay);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scanner settings saved'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner Settings'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Basic Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Basic Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Auto Scan'),
                    subtitle: const Text('Automatically start scanning when opened'),
                    value: _autoScanEnabled,
                    onChanged: (value) {
                      setState(() {
                        _autoScanEnabled = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Flash Light'),
                    subtitle: const Text('Enable flash for better scanning in low light'),
                    value: _flashEnabled,
                    onChanged: (value) {
                      setState(() {
                        _flashEnabled = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Beep Sound'),
                    subtitle: const Text('Play sound after successful scan'),
                    value: _beepSoundEnabled,
                    onChanged: (value) {
                      setState(() {
                        _beepSoundEnabled = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Vibration'),
                    subtitle: const Text('Vibrate after successful scan'),
                    value: _vibrateEnabled,
                    onChanged: (value) {
                      setState(() {
                        _vibrateEnabled = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Scan Format
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Barcode Format',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<String>(
                    title: const Text('All Formats'),
                    subtitle: const Text('Scan all supported barcode formats'),
                    value: 'all',
                    groupValue: _scannerFormat,
                    onChanged: (value) {
                      setState(() {
                        _scannerFormat = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Common Formats'),
                    subtitle: const Text('EAN-13, EAN-8, UPC-A, Code 128, QR Code'),
                    value: 'common',
                    groupValue: _scannerFormat,
                    onChanged: (value) {
                      setState(() {
                        _scannerFormat = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('QR Code Only'),
                    subtitle: const Text('Only scan QR codes'),
                    value: 'qr',
                    groupValue: _scannerFormat,
                    onChanged: (value) {
                      setState(() {
                        _scannerFormat = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('1D Barcodes Only'),
                    subtitle: const Text('Only scan linear barcodes'),
                    value: '1d',
                    groupValue: _scannerFormat,
                    onChanged: (value) {
                      setState(() {
                        _scannerFormat = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Advanced Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Advanced Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Continuous Scan Mode'),
                    subtitle: const Text('Keep scanning after each successful scan'),
                    value: _continuousScanMode,
                    onChanged: (value) {
                      setState(() {
                        _continuousScanMode = value;
                      });
                    },
                  ),
                  if (_continuousScanMode) ...[
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Scan Delay'),
                      subtitle: Text('${_scanDelay.toStringAsFixed(1)} seconds between scans'),
                    ),
                    Slider(
                      value: _scanDelay,
                      min: 0.5,
                      max: 5.0,
                      divisions: 9,
                      label: '${_scanDelay.toStringAsFixed(1)}s',
                      onChanged: (value) {
                        setState(() {
                          _scanDelay = value;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Test Scanner
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Scanner',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _testScanner,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Test Scanner'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _testScanner() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Test Scanner',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: MobileScanner(
                controller: MobileScannerController(
                  torchEnabled: _flashEnabled,
                  formats: _getScanFormats(),
                ),
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      Navigator.pop(context, barcode.rawValue);
                      break;
                    }
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Point the camera at a barcode to scan',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    
    if (result != null && mounted) {
      if (_beepSoundEnabled) {
        // TODO: Play beep sound
      }
      
      if (_vibrateEnabled) {
        // TODO: Trigger vibration
      }
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Scan Result'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Successfully scanned:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SelectableText(
                result,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your scanner settings are working correctly!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }
  
  List<BarcodeFormat> _getScanFormats() {
    switch (_scannerFormat) {
      case 'common':
        return [
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
          BarcodeFormat.upcA,
          BarcodeFormat.code128,
          BarcodeFormat.qrCode,
        ];
      case 'qr':
        return [BarcodeFormat.qrCode];
      case '1d':
        return [
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
          BarcodeFormat.upcA,
          BarcodeFormat.upcE,
          BarcodeFormat.code39,
          BarcodeFormat.code93,
          BarcodeFormat.code128,
          BarcodeFormat.codabar,
          BarcodeFormat.itf,
        ];
      default:
        return BarcodeFormat.values;
    }
  }
}