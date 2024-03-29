import 'package:ingatlan_scraper_dart/ingatlan_scraper_dart.dart';
import 'package:ingatlan_scraper_dart/model/settlement.dart';

class SettlementController extends ResourceController {
  final ManagedContext context;

  SettlementController(this.context);

  @Operation.get()
  Future<Response> getAllSettlements() async {
    final qry = Query<Settlement>(context)
      ..sortBy((x) => x.id, QuerySortOrder.ascending);
    final entities = await qry.fetch();
    return Response.ok(entities);
  }

  @Operation.get('id')
  Future<Response> getSettlementByID(@Bind.path('id') int id) async {
    final qry = Query<Settlement>(context)..where((h) => h.id).equalTo(id);

    final settlement = await qry.fetchOne();

    if (settlement == null) {
      return Response.notFound();
    }
    return Response.ok(settlement);
  }

  @Operation.post()
  Future<Response> createSettlement() async {
    final Map<String, dynamic> body = await request.body.decode();

    final qry = Query<Settlement>(context)
      ..values.name = body['name'] as String
      ..values.county = body['county'] as String
      ..values.enabled = body['enabled'] as bool
      ..values.sheet = body['sheet'] as String;
      
    return Response.ok(await qry.insert());
  }

  @Operation.put()
  Future<Response> updateSettlement() async {
    final Map<String, dynamic> body = await request.body.decode();
    final name = body['name'] as String;

    final qry = Query<Settlement>(context)
      ..where((h) => h.name).equalTo(name)
      ..values.county = body['county'] as String
      ..values.enabled = body['enabled'] as bool
      ..values.sheet = body['sheet'] as String;

    return Response.ok(await qry.updateOne());
  }
}
