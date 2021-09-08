import 'dart:convert';

import 'package:ingatlan_scraper_dart/ingatlan_scraper_dart.dart';
import 'package:ingatlan_scraper_dart/model/scrape.dart';
import 'package:ingatlan_scraper_dart/model/settlement.dart';
import 'package:ingatlan_scraper_dart/model/stat.dart';
import 'package:ingatlan_scraper_dart/service/gsheets.dart';
import 'package:ingatlan_scraper_dart/service/listing.dart';
import 'package:stats/stats.dart';

class ScrapeController extends ResourceController {
  ManagedContext context;
  ScraperConfiguration configuration;
  GSheetHelper gsheets;

  ScrapeController(this.context, this.configuration) {
    gsheets = new GSheetHelper(configuration);
  }

  @Operation.get()
  Future<Response> getAllScrapes() async {
    final qry = Query<Scrape>(context);
    final entities = await qry.fetch();
    return Response.ok(entities);
  }

  @Operation.get('settlementId')
  Future<Response> getScrapesBySettlementId(
      @Bind.path('settlementId') int settlementId) async {
    final qry = Query<Scrape>(context)
      ..where((h) => h.settlementId).equalTo(settlementId);

    final scrapes = await qry.fetch();

    if (scrapes == null) {
      return Response.notFound();
    }

    return Response.ok(scrapes);
  }

  @Operation.post('settlementId')
  Future<Response> createScrape(
      @Bind.path('settlementId') int settlementId) async {
    final settlement =
        await context.fetchObjectWithID<Settlement>(settlementId);

    if (settlement == null) {
      return Response.notFound();
    }

    var scrapeResult = await Listing.scrape(
        'https://ingatlan.com/lista/elado+haz+', settlement.name);

    if (scrapeResult.length == 0) {
      return Response.notFound();
    }

    final qry = Query<Scrape>(context)
      ..values.created = DateTime.now()
      ..values.settlementId = settlementId
      ..values.raw = jsonEncode(scrapeResult.items);
    final scrape = await qry.insert();

    final stats = Stats.fromData(
        scrapeResult.select((x) => x.sizeAdjustedPrice()).toList());

    final statsQry = Query<Stat>(context)
      ..values.scrapeId = scrape.id
      ..values.meanPrice = stats.average
      ..values.medianPrice = stats.median
      ..values.distributionPrice = stats.standardDeviation
      ..values.meanDwellingSize =
          scrapeResult.select((arg1) => arg1.dwellingSize).average()
      ..values.meanPlotSize =
          scrapeResult.select((arg1) => arg1.plotSize).average()
      ..values.listingCount = stats.count;

    final stat = await statsQry.insert();

    await gsheets.saveMedian(settlement.sheet, settlement.name, stats.median * 1000000);
    return Response.ok(
        {'Settlement': settlement, 'Scrape': scrape, 'Stats': stat});
  }
}
