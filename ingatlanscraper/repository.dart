import 'dart:convert';

import 'package:database/database.dart';
import 'package:database_adapter_postgre/database_adapter_postgre.dart';
import 'package:queries/collections.dart';

import 'listing.dart';

class Repository {
  Database _db;

  Future init() async {
    final config = Postgre(
      host: 'localhost',
      port: 5432,
      user: 'postgres',
      password: 'Karthago36',
      databaseName: 'ingatlan-scraper',
    );

    _db = config.database();
  }

  Future<List<Map<String, Object>>> getSettlements() async {
    final settlements = _db.sqlClient
        .table('Settlements')
        .select(columnNames: ['Id', 'Name']).toMaps();
    return settlements;
  }

  Future<int> insertScrape(int id, IEnumerable<Listing> scrape) async {
    var now = DateTime.now();
    final re = await _db.sqlClient.table('Scrapes').insert({
      'SettlementId': id,
      'Created': now,
      'Raw': jsonEncode(scrape.toList())
    });
    if (re.affectedRows > 0) {
      var result = await _db.sqlClient
          .table('Scrapes')
          .whereColumn('Created', equals: now)
          .select(columnNames: ['Id', 'SettlementId']).toMaps();

      return result.where((x) => x['SettlementId'] == id).last['Id'];
    }
    return 0;
  }

  Future insertStats(int scrapeId, Map<String, double> stats) async{
    await _db.sqlClient.table('Stats')
      .insert({
        'ScrapeId': scrapeId,
        'MeanPrice': stats['meanPrice'],
        'MedianPrice': stats['medianPrice'],
        'DistributionPrice': stats['distributionPrice'],
        'MeanDwellingSize': stats['meanDwellingSize'],
        'MeanPlotSize': stats['meanPlotSize']
      });
  }
}
