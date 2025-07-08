import 'package:hive/hive.dart';
import '../widgets/tax_settings_dialog.dart';

class TaxTypeAdapter extends TypeAdapter<TaxType> {
  @override
  final int typeId = 101; // Using a high number to avoid conflicts

  @override
  TaxType read(BinaryReader reader) {
    final index = reader.readByte();
    return TaxType.values[index];
  }

  @override
  void write(BinaryWriter writer, TaxType obj) {
    writer.writeByte(obj.index);
  }
}