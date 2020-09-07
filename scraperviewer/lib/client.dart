import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:scraperviewer/models/settlement.dart';

class ScraperClient {
  Future<List<Settlement>> fetchSettlements() async {
    var client = Client();
    var settlementResults =
        await client.get("https://scraper-densponx3q-ez.a.run.app/settlement");
    if (settlementResults.statusCode != 200) {
      // wait a sec and retry. The Cloud run has to start up
      sleep(new Duration(seconds: 1));
      settlementResults = await client
          .get("https://scraper-densponx3q-ez.a.run.app/settlement");
    }
    if (settlementResults.statusCode == 200){
      final parsed = json.decode(settlementResults.body).cast<Map<String, dynamic>>();

      return parsed.map<Settlement>((json) => Settlement.fromJson(json)).toList();
    }
    else {
      return null;
    }
  }
}
