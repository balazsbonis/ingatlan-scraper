import 'package:aqueduct/aqueduct.dart';

class Stat extends ManagedObject<_Stat> implements _Stat {
  Map<String, dynamic> toJson() => {
        'id': id,
        'scrapeId': scrapeId,
        'meanPrice': meanPrice,
        'medianPrice': medianPrice,
        'distributionPrice': distributionPrice,
        'meanDwellingSize': meanDwellingSize,
        'meanPlotSize': meanPlotSize,
        'listingCount': listingCount
      };
}

class _Stat {
  @primaryKey
  int id;

  @Column()
  int scrapeId;

  @Column(nullable: true)
  double meanPrice;

  @Column(nullable: true)
  double medianPrice;

  @Column(nullable: true)
  double distributionPrice;

  @Column(nullable: true)
  double meanDwellingSize;

  @Column(nullable: true)
  double meanPlotSize;

  @Column(nullable: true)
  int listingCount;
}
