import 'package:ingatlan_scraper_dart/controller/scrape_controller.dart';
import 'package:ingatlan_scraper_dart/controller/settlement_controller.dart';
import 'package:ingatlan_scraper_dart/controller/stat_controller.dart';

import 'ingatlan_scraper_dart.dart';

class CloudRunAppChannel extends ApplicationChannel {
  ManagedContext context;

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

    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    final persistentStore = PostgreSQLPersistentStore.fromConnectionInfo(
        "postgres", "Karthago36", "34.107.48.206", 5432, "ingatlanscraper");

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

    router.route("/settlement/[:id]").link(() => SettlementController(context));
    router.route("/scrape/[:settlementId]").link(() => ScrapeController(context));
    router.route("/stat/[:id]").link(() => StatController(context));

    return router;
  }
}
