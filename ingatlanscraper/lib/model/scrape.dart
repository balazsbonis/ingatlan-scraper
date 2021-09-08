import 'package:conduit/conduit.dart';

class Scrape extends ManagedObject<_Scrape> implements _Scrape {
  Map<String, dynamic> toJson() =>
      {'id': id, 'settlementId': settlementId, 'created': created.toString()};
}

class _Scrape {
  @primaryKey
  int id;

  @Column()
  int settlementId;

  @Column()
  DateTime created;

  @Column(nullable: true)
  String raw;
}
