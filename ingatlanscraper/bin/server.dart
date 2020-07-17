// gcloud builds submit --tag gcr.io/ingatlan-scraper-dart/scraper
// gcloud beta run deploy --image gcr.io/ingatlan-scraper-dart/scraper

import 'dart:io';

import 'package:ingatlan_scraper_dart/ingatlan_scraper_dart.dart';

Future main() async {
  // Find port to listen on from environment variable.
  var port = int.tryParse(Platform.environment['PORT'] ?? '8080');

  final app = Application<CloudRunAppChannel>()
    ..options.port = port;

  await app.start();

  print("Application started on port: ${app.options.port}.");
}

class IngatlanScraperConfig extends Configuration{
  IngatlanScraperConfig(String path) : super.fromFile(File(path));

  DatabaseConfiguration database;
}