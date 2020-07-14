import 'package:stats/stats.dart';
import 'gsheets.dart';
import 'listing.dart';
import 'repository.dart';

class Scraper {
  final ARepository repo;
  final sheet = new GSheetHelper();

  Scraper(this.repo);

  void scrape({String settlementName}) async {
    try {
      await repo.init();
      var settlements = new List<Map<String, Object>>();
      if (settlementName == null) {
        settlements = await repo.getSettlements();
      }
      else {
        settlements.add(await repo.getSettlementByName(settlementName));
      }
      Stopwatch stopwatch = new Stopwatch();
      stopwatch.start();
      for (int i = 0; i < settlements.length; i++) {
        print("Starting ${settlements[i]['Name']}");
        var scrapeResult = await Listing.scrape(
            'https://ingatlan.com/lista/elado+haz+', settlements[i]['Name']);
        var data =
            scrapeResult.where((x) => x.settlement == settlements[i]['Name']);
        var scrapeId = await repo.insertScrape(settlements[i]['Id'], data);
        if (data.count() != 0) {
          var stats = Stats.fromData(
              data.select((x) => x.sizeAdjustedPrice()).toList());
          print("   > Stats $stats");
          await repo.insertStats(scrapeId, {
            'meanPrice': stats.average,
            'medianPrice': stats.median,
            'distributionPrice': stats.standardDeviation,
            'meanDwellingSize':
                scrapeResult.select((arg1) => arg1.dwellingSize).average(),
            'meanPlotSize':
                scrapeResult.select((arg1) => arg1.plotSize).average(),
            'listingCount': double.parse(stats.count.toString())
          });
          await sheet.saveMedian(
              settlements[i]['Name'], stats.median * 1000000);
        }
      }
      var toplist = await repo.getToplist();
      await sheet.saveToplist(toplist);
      stopwatch.stop();
      print("Execution took ${stopwatch.elapsed}");
    } catch (e) {
      print(e);
    }
  }
}