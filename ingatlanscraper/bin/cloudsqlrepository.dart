import 'package:postgres/postgres.dart';
import 'package:queries/collections.dart';

import 'listing.dart';
import 'repository.dart';

class CloudSqlRepository implements ARepository {
  PostgreSQLConnection connection;

  @override
  Future init() async {
    connection = new PostgreSQLConnection(
);
    await connection.open();
  }

  @override
  Future<bool> existsSettlement(String settlement) async {
    if (connection.isClosed) connection.open();
    var qry = await connection.query(
        'SELECT "Enabled" FROM public."Settlements" WHERE "Name" = @aValue',
        substitutionValues: {'aValue': settlement});
    if (qry.length == 1) {
      var enabled = qry.first[0];
      return enabled.toString().toLowerCase() == 'true';
    }
    return false;
  }

  @override
  Future<List<Map<String, Object>>> getSettlements() async {
    if (connection.isClosed) connection.open();
    var qry = await connection.mappedResultsQuery(
        'SELECT "Id", "Name" FROM public."Settlements" WHERE "Enabled" = true');
    var result = new List<Map<String, Object>>();
    for (final row in qry) {
      result.add(row['Settlements']);
    }
    return result;
  }

  @override
  Future<Map<String, Object>> getStatsForSettlement(
      String settlementName) async {
    if (connection.isClosed) connection.open();
    var qry = await connection.mappedResultsQuery(
        'SELECT "Name", "MedianPrice", "MeanPrice", "DeviationPrice", "MeanDwellingSize", "MeanPlotSize", "ListingCount" FROM public."Latest"' +
            'WHERE "Name" = @aValue',
        substitutionValues: {'aValue': settlementName});
    return qry.first[null];
  }

  @override
  Future<List<Map<String, Object>>> getToplist({String date}) {
    // TODO: implement getToplist
    throw UnimplementedError();
  }

  @override
  Future<int> insertScrape(int id, IEnumerable<Listing> scrape) {
    // TODO: implement insertScrape
    throw UnimplementedError();
  }

  @override
  Future insertStats(int scrapeId, Map<String, double> stats) {
    // TODO: implement insertStats
    throw UnimplementedError();
  }
}
