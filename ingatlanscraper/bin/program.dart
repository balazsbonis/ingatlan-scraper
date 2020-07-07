import 'dart:convert';

import 'cloudsqlrepository.dart';
import 'scraper.dart';

void main() async {

  var scraper = new Scraper();
  await scraper.scrape();
  
  // var repo = new CloudSqlRepository();
  // await repo.init();
//   var settlements = await repo.getSettlements();
//   for (var s in settlements) print(s['Name']);
  // var s = await repo.getStatsForSettlement('dabas');
  // var j = json.encode(s[0]);
  // print(s);
}
