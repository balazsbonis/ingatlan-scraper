// gcloud builds submit --tag gcr.io/ingatlan-scraper-dart/scraper
// gcloud beta run deploy --image gcr.io/ingatlan-scraper-dart/scraper
// curl -Method Post "https://scraper-densponx3q-ez.a.run.app" -Body '{"settlements": [1,2,3,4] }' -Headers @{'Content-Type' = 'application/json'}

import 'dart:io';

import 'package:ingatlan_scraper_dart/ingatlan_scraper_dart.dart';

Future main() async {
  // Find port to listen on from environment variable.
  var port = int.tryParse(Platform.environment['PORT'] ?? '8080');
  final app = Application<CloudRunAppChannel>()..options.port = port;

  await app.start();

  print("Application started on port: ${app.options.port}.");
}
