import 'package:ingatlan_scraper_dart/ingatlan_scraper_dart.dart';
import 'package:ingatlan_scraper_dart/model/stat.dart';

class StatController extends ResourceController {
  final ManagedContext context;

  StatController(this.context);
  
  @Operation.get()
  Future<Response> getAllStats() async {
    final qry = Query<Stat>(context);
    final entities = await qry.fetch();
    return Response.ok(entities);
  }

}
