import 'dart:io';

import 'package:gsheets/gsheets.dart';

class GSheetHelper {
  Spreadsheet ss;

  Future init() async {
    if (ss == null) {
      final _credFile = new File('.\\agglomeracio-gsheet.cred');
      final _credentials = _credFile.readAsStringSync();
      const _spreadSheetId = '1XBov7Ca3kzOKHj-SVUaPcwbJQ3nwLCVWeGyhF1evHx4';
      final gsheets = GSheets(_credentials);
      ss = await gsheets.spreadsheet(_spreadSheetId);
    }
  }

  Future saveMedian(String settlement, double median) async {
    try {
      await init();
      var sheet = ss.worksheetByTitle('Median');
      sheet ??= await ss.addWorksheet('Median');
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
      if (column == 0) {
        column = settlementRow.length + 1;
        await sheet.values.insertValue(settlement, column: column, row: 1);
      }
      print("   > Inserting $median to $column-$row.");
      await sheet.values.insertValue(median, column: column, row: row);
    } catch (e) {
      print(e);
    }
  }

  Future saveToplist(List<Map<String, Object>> toplist) async {
    try {
      await init();
      var sheet = ss.worksheetByTitle('Toplist');
      sheet ??= await ss.addWorksheet('Toplist');
      for (int i = 0; i < toplist.length; i++) {
        var record = toplist[i];
        await sheet.values.insertRow(i + 2, [
          record['Name'],
          record['MedianPrice'],
          record['MeanDwellingSize']
        ]);
      }
    } catch (e) {
      print(e);
    }
  }
}
