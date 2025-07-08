import 'package:hive/hive.dart';
import '../widgets/discount_dialog.dart';

class DiscountTypeAdapter extends TypeAdapter<DiscountType> {
  @override
  final int typeId = 100; // Using a high number to avoid conflicts

  @override
  DiscountType read(BinaryReader reader) {
    final index = reader.readByte();
    return DiscountType.values[index];
  }

  @override
  void write(BinaryWriter writer, DiscountType obj) {
    writer.writeByte(obj.index);
  }
}