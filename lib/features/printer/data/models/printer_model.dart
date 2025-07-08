class PrinterModel {
  final String name;
  final String address;
  final bool isConnected;
  
  PrinterModel({
    required this.name,
    required this.address,
    this.isConnected = false,
  });
  
  PrinterModel copyWith({
    String? name,
    String? address,
    bool? isConnected,
  }) {
    return PrinterModel(
      name: name ?? this.name,
      address: address ?? this.address,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}