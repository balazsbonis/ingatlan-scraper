import 'package:aqueduct/aqueduct.dart';

class Settlement extends ManagedObject<_Settlement> implements _Settlement {
  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'county': county, 'enabled': enabled, 'sheet': sheet};
}

class _Settlement {
  @primaryKey
  int id;

  @Column()
  String name;

  @Column(nullable: true)
  String county;

  @Column(nullable: true)
  bool enabled;

  @Column(nullable: true)
  String sheet;
}
