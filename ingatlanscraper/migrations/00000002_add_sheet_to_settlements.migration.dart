import 'dart:async';
import 'package:conduit/conduit.dart';

class Migration2 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("_Settlement", SchemaColumn("sheet", ManagedPropertyType.string, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    