import 'package:gsheets/gsheets.dart';
import 'package:stats/stats.dart';
import 'listing.dart';
 
/*
database:
Settlements<id, name>
Scrape<id, settlementid, createddate, raw>
Stats<id, scrapeid, meanprice, medianprice, distributionprice, meansize, 

Index: Scrape_createddate
*/

Spreadsheet ss;

Future saveToGSheets(String settlement, List<double> values) async {
  if (ss == null) {
    const _credentials = r'''
     
    ''';
    const _spreadSheetId = '1XBov7Ca3kzOKHj-SVUaPcwbJQ3nwLCVWeGyhF1evHx4';
    final gsheets = GSheets(_credentials);
    ss = await gsheets.spreadsheet(_spreadSheetId);
  }
  try {
    var sheet = ss.worksheetByTitle('Scraper-$settlement');
    if (sheet == null) {
      sheet ??= await ss.addWorksheet('Scraper-$settlement');
      await sheet.values.insertValue('Dátum', column: 1, row: 1);
      await sheet.values.insertValue('Átlag', column: 2, row: 1);
      await sheet.values.insertValue('Medián', column: 3, row: 1);
      await sheet.values.insertValue('Szórás', column: 4, row: 1);
      await sheet.values.insertValue('Különbség (átlag)', column: 5, row: 1);
      await sheet.values.insertValue('Különbség (medián)', column: 6, row: 1);
    }
    var currentDate =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
    print(await sheet.values.column(1));
    var dateColumn = await sheet.values.column(1);
    var row = dateColumn.indexOf(currentDate) + 1;
    if (row == 0) {
      row = dateColumn.length + 1;
      await sheet.values.insertValue(currentDate, column: 1, row: row);
    }
    for (int i = 0; i < values.length; i++) {
      await sheet.values.insertValue(values[i], column: i + 2, row: row);
    }
    if (row > 2) {
      await sheet.values.insertValue("=B$row-B${row - 1}",
          column: values.length + 2, row: row);
      await sheet.values.insertValue("=C$row-C${row - 1}",
          column: values.length + 3, row: row);
    }
  } catch (e) {
    print(e);
  }
}

void main() async {
  var settlements = [
    'veroce',
    'kismaros',
    'nagymaros',
    'zebegeny',
    'szokolya',
    'szodliget',
    'iii-ker',
    'x-ker',
    'xv-ker',
    'xvi-ker',
    'xvii-ker',
    'xx-ker',
    'god',
    'balatonfoldvar',
    'encs',
    'urom',
    'alsonemedi',
    // 'szentendre',
    'dunakeszi',
    'szod',
    'vac',
    // 'telki'
  ];
  Stopwatch stopwatch = new Stopwatch();
  stopwatch.start();
  for (int i = 0; i < settlements.length; i++) {
    var scrapeResult = await Listing.scrape(
        'https://ingatlan.com/lista/elado+haz+', settlements[i]);
    var data = scrapeResult.where((x) => x.settlement == settlements[i]);
    var sizeAdjustedPrices = data.select((x) => x.sizeAdjustedPrice());
    final stats = Stats.fromData(sizeAdjustedPrices.toList());
    await saveToGSheets(settlements[i], [
      stats.average * 1000000,
      stats.median * 1000000,
      stats.standardDeviation * 1000000
    ]);
  }
  stopwatch.stop();
  print("Execution took ${stopwatch.elapsed}");
}
