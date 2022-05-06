import 'package:ingatlan_scraper_dart/ingatlan_scraper_dart.dart';
import 'package:ingatlan_scraper_dart/model/scrape.dart';
import 'package:ingatlan_scraper_dart/model/stat.dart';

class StatController extends ResourceController {
  final ManagedContext context;

  StatController(this.context);

  @Operation.get()
  Future<Response> getAllStats() async {
    final qry = Query<Stat>(context);
    final entities = await qry.fetch();
    return Response.ok(entities);
  }

  @Operation.get('settlementId')
  Future<Response> getStatsForSettlementAndDate(
      @Bind.path('settlementId') int settlementId,
      @Bind.query('date') DateTime date) async {
    final dateStart = DateTime(date.year, date.month, date.day);
    final dateEnd = dateStart.add(Duration(days: 1));
    final qry = Query<Scrape>(context)
      ..where((h) => h.settlementId).equalTo(settlementId)
      ..where((h) => h.created).between(dateStart, dateEnd);
    final scrape = await qry.fetchOne();
    if (scrape == null) {
      return Response.notFound();
    }
    final statsQry = Query<Stat>(context)
      ..where((h) => h.scrapeId).equalTo(scrape.id);
    final stats = await statsQry.fetch();
    if (stats == null) {
      return Response.notFound();
    }
    return Response.ok(stats);
  }
}
