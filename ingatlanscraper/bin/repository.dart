import 'dart:convert';
import 'dart:io';

import 'package:database/database.dart';
import 'package:database_adapter_postgre/database_adapter_postgre.dart';
import 'package:queries/collections.dart';

import 'listing.dart';

abstract class ARepository {
  Future init();

  Future<List<Map<String, Object>>> getSettlements();
  Future<bool> existsSettlement(String settlementName);
  Future<Map<String, Object>> getSettlementByName(String settlementName);
  Future<int> insertSettlement(String settlementName);

  Future<List<Map<String, Object>>> getToplist({String date});
  Future<int> insertScrape(int id, IEnumerable<Listing> scrape);

  Future<Map<String, Object>> getStatsForSettlement(String settlementName);
  Future insertStats(int scrapeId, Map<String, double> stats);
}

class Repository implements ARepository {
  Database _db;

  @override
  Future init() async {
    final configFile = json.decode(File('.\\database.cred').readAsStringSync());
    final config = Postgre(
      host: configFile['host'],
      port: int.parse(configFile['port']),
      user: configFile['username'],
      password: configFile['password'],
      databaseName: configFile['databaseName'],
    );

    _db = config.database();
  }

  @override
  Future<List<Map<String, Object>>> getSettlements() async {
    final settlements = await _db.sqlClient
        .table('Settlements')
        .whereColumn('Enabled', equals: true)
        .select(columnNames: ['Id', 'Name']).toMaps();
    return settlements;
  }

  @override
  Future<Map<String, Object>> getSettlementByName(String settlementName) async {
    final settlements = await _db.sqlClient
        .table('Settlements')
        .whereColumn('Name', equals: settlementName)
        .select(columnNames: ['Id', 'Name', 'County', 'Enabled']).toMaps();
    return settlements.length > 0 ? settlements.first : null;
  }

  @override
  Future<bool> existsSettlement(String settlementName) async {
    var settlement = await getSettlementByName(settlementName);
    return settlement != null;
  }

  @override
  Future<int> insertSettlement(String settlementName) async {
    final re = await _db.sqlClient
        .table('Settlements')
        .insert({'Name': settlementName, 'Enabled': false});
    if (re.affectedRows > 0) {
      var result = await _db.sqlClient
          .table('Settlements')
          .whereColumn('Name', equals: settlementName)
          .select(columnNames: ['Id']).toMaps();

      return result.last['Id'];
    }
    return 0;
  }

  @override
  Future<Map<String, Object>> getStatsForSettlement(
      String settlementName) async {
    final settlement = await _db.sqlClient
        .table('Settlements')
        .whereColumn('Name', equals: settlementName)
        .select(columnNames: ['Id']).toMaps();
    final settlementId = settlement[0]['Id'];
    final scrape = await _db.sqlClient
        .table('Scrapes')
        .whereColumn('SettlementId', equals: settlementId)
        .select(columnNames: ['Id']).toMaps();
    final scrapeId = scrape.last['Id'];
    final stat = await _db.sqlClient
        .table('Stats')
        .whereColumn('ScrapeId', equals: scrapeId)
        .select(columnNames: [
      'MeanPrice',
      'MedianPrice',
      'DistributionPrice',
      'MeanDwellingSize',
      'MeanPlotSize',
      'ListingCount'
    ]).toMaps();
    return stat.last;
  }

  @override
  Future<List<Map<String, Object>>> getToplist({String date}) async {
    var currentDate =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
    final toplist = await _db.sqlClient
        .table('Toplist')
        .whereColumn('Created', equals: currentDate)
        .ascending('MedianPrice')
        .select(
            columnNames: ['Name', 'MedianPrice', 'MeanDwellingSize']).toMaps();
    return toplist;
  }

  @override
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

  @override
  Future insertStats(int scrapeId, Map<String, double> stats) async {
    await _db.sqlClient.table('Stats').insert({
      'ScrapeId': scrapeId,
      'MeanPrice': stats['meanPrice'],
      'MedianPrice': stats['medianPrice'],
      'DistributionPrice': stats['distributionPrice'],
      'MeanDwellingSize': stats['meanDwellingSize'],
      'MeanPlotSize': stats['meanPlotSize'],
      'ListingCount': stats['listingCount']
    });
  }

}
