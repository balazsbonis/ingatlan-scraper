import 'package:gsheets/gsheets.dart';
import 'package:stats/stats.dart';
import 'listing.dart';
import 'repository.dart';

Spreadsheet ss;

Future saveToGSheets(String settlement, double median) async {
  if (ss == null) {
    const _credentials = r'''
    
    ''';
    const _spreadSheetId = '1XBov7Ca3kzOKHj-SVUaPcwbJQ3nwLCVWeGyhF1evHx4';
    final gsheets = GSheets(_credentials);
    ss = await gsheets.spreadsheet(_spreadSheetId);
  }
  try {
    var sheet = ss.worksheetByTitle('Median');
    var currentDate =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
    var dateColumn = await sheet.values.column(1);
    var row = dateColumn.indexOf(currentDate) + 1;
    if (row == 0) {
      row = dateColumn.length + 1;
      await sheet.values.insertValue(currentDate, column: 1, row: row);
    }

    var settlementRow = await sheet.values.row(1);
    var column = settlementRow.indexOf(settlement) + 1;
    if (column == 0){
      column = settlementRow.length +1;
      await sheet.values.insertValue(settlement, column: column, row: 1);
    }
    print("Inserting $median to $column-$row.");
    await sheet.values.insertValue(median, column: column, row: row);

  } catch (e) {
    print(e);
  }
}

void main() async {
  try {
    var repo = new Repository();
    await repo.init();
    var settlements = await repo.getSettlements();
    Stopwatch stopwatch = new Stopwatch();
    stopwatch.start();
    for (int i = 0; i < settlements.length; i++) {
      print("Starting ${settlements[i]['Name']}");
      var scrapeResult = await Listing.scrape(
          'https://ingatlan.com/lista/elado+haz+', settlements[i]['Name']);
      var data =
          scrapeResult.where((x) => x.settlement == settlements[i]['Name']);
      var scrapeId = await repo.insertScrape(settlements[i]['Id'], data);
      var sizeAdjustedPrices = data.select((x) => x.sizeAdjustedPrice());
      final stats = Stats.fromData(sizeAdjustedPrices.toList());
      print("Stats - $stats");
      await repo.insertStats(scrapeId, {
        'meanPrice': stats.average,
        'medianPrice': stats.median,
        'distributionPrice': stats.standardDeviation,
        'meanDwellingSize': scrapeResult.select((arg1) => arg1.dwellingSize).average(),
        'meanPlotSize': scrapeResult.select((arg1) => arg1.plotSize).average()
      });
      await saveToGSheets(settlements[i]['Name'], stats.median * 1000000);
    }
    stopwatch.stop();
    print("Execution took ${stopwatch.elapsed}");
  } catch (e) {
    print(e);
  }
}
