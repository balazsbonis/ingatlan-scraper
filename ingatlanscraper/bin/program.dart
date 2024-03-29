import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

Future main() async {
  var stopwatch = Stopwatch();
  stopwatch.start();
  var client = Client();
  var settlementResults = await client
          .get("https://scraper-densponx3q-ez.a.run.app/settlement");
  if (settlementResults.body == ""){
    // wait a sec and retry. The Cloud run has to start up
    sleep(new Duration(seconds: 1));
    settlementResults = await client
          .get("https://scraper-densponx3q-ez.a.run.app/settlement");
  }
  var settlements = json.decode(settlementResults.body);
  var enabledOnes = (settlements as List<dynamic>).where((element) => element['enabled']).toList();
  print("Found ${enabledOnes.length} settlements");
  for (var e in enabledOnes){
    print("Starting ${e['name']}(${e['county']}) @ ${e['id']}");
    var scrapeResult = await client.post('https://scraper-densponx3q-ez.a.run.app/scrape/${e['id']}');
    var scrape = json.decode(scrapeResult.body);
    print("  ${scrape['Stats']}");
  }
  stopwatch.stop();
  print("Execution took ${stopwatch.elapsed.toString()}");
}