import 'package:ingatlan_scraper_dart/controller/scrape_controller.dart';
import 'package:ingatlan_scraper_dart/controller/settlement_controller.dart';
import 'package:ingatlan_scraper_dart/controller/stat_controller.dart';
import 'package:ingatlan_scraper_dart/service/gsheets.dart';

import 'ingatlan_scraper_dart.dart';

class CloudRunAppChannel extends ApplicationChannel {
  ManagedContext context;
  ScraperConfiguration config;

  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
    if (options.configurationFilePath == null) {
      // locally from VSCode
      options.configurationFilePath = './/config.yaml';
    }
    config = ScraperConfiguration(options.configurationFilePath);
    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    final persistentStore = PostgreSQLPersistentStore.fromConnectionInfo(
        config.database.username,
        config.database.password,
        config.database.host,
        config.database.port,
        config.database.databaseName);

    context = ManagedContext(dataModel, persistentStore);
  }

  /// Construct the request channel.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare].
  @override
  Controller get entryPoint {
    final router = Router();

    router.route("/settlement[/:id]").link(() => SettlementController(context));
    router
        .route("/scrape[/:settlementId]")
        .link(() => ScrapeController(context, config));
    router.route("/stat[/:id]").link(() => StatController(context));

    return router;
  }
}

class ScraperConfiguration extends Configuration {
  ScraperConfiguration(String path) : super.fromFile(File(path));

  DatabaseConfiguration database;
  String spreadSheetId;
  String spreadSheetToken;
}
