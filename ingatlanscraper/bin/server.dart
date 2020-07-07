// gcloud builds submit --tag gcr.io/ingatlan-scraper-dart/helloworld
// gcloud beta run deploy --image gcr.io/ingatlan-scraper-dart/helloworld

import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

import 'cloudsqlrepository.dart';

final repository = new CloudSqlRepository();

Future main() async {
  await repository.init();
  // Find port to listen on from environment variable.
  var port = int.tryParse(Platform.environment['PORT'] ?? '8080');

  Future<Response> handler(Request request) async =>
      await handleRequest(request);

  // Serve handler on given port.
  var server = await serve(
    Pipeline().addMiddleware(logRequests()).addHandler(handler),
    InternetAddress.anyIPv4,
    port,
  );
  print('Serving at http://${server.address.host}:${server.port}');
}

Future<Response> handleRequest(Request request) async {
  try {
    if (request.method == 'GET') {
      return await handleGet(request);
    } else {
      // ···
    }
  } catch (e) {
    print('Exception in handleRequest: $e');
    return Response.internalServerError(body: 'Error: $e');
  }
  print('Request handled.');

  return Response.ok('OK');
}

Future<Response> handleGet(Request request) async {
  if (request.url.queryParameters.length == 0) {
    return Response.ok('Hello there!');
  } else if (request.url.queryParameters.containsKey('ping')) {
    var ping = request.url.queryParameters['ping'];
    return Response.ok('Ping: $ping');
  } else if (request.url.queryParameters.containsKey('settlement')){
    var settlementName = request.url.queryParameters['settlement'];
    var test = await repository.existsSettlement(settlementName);
    return Response.ok(test.toString());
  } else if (request.url.queryParameters.containsKey('stats')) {
    var settlementName = request.url.queryParameters['stats'];
    var stats = await repository.getStatsForSettlement(settlementName);
    if (stats != null) {
      var body = json.encode(stats);
      return Response.ok(body);
    } else {
      return Response.notFound('Unknown settlement');
    }
  } else {
    return Response.forbidden('Unkonwn query');
  }
}
