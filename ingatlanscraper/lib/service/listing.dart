import 'dart:io';
import 'dart:math';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:queries/collections.dart';

class Listing {
  int id;
  double price;
  double dwellingSize;
  double plotSize;
  String settlement;

  Listing(this.settlement, Element element) {
    id = int.parse(element.attributes['data-listing-id']);
    var detailElement = element.querySelector('.row');
    var spans = detailElement.querySelectorAll('span');
    var priceOnPage = spans[0];
    var dwellingSizeOnPage = spans[4];
    var plotSizeOnPage = spans[6];
    price = double.parse(priceOnPage.text
        .replaceAll('M Ft', '')
        .replaceAll(' ', '')
        .replaceAll(',', '.')
        .trim());
    dwellingSize = double.parse(dwellingSizeOnPage.text
        .replaceAll('m2', '')
        .replaceAll(' ', '')
        .trim());
    plotSize = plotSizeOnPage != null
        ? double.parse(
            plotSizeOnPage.text.replaceAll('m2', '').replaceAll(' ', '').trim())
        : 0;
  }

  double sizeAdjustedPrice() => price / dwellingSize;

  @override
  String toString() {
    return "$price @ $dwellingSize m² = ${sizeAdjustedPrice()}";
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'price': price,
        'dwellingSize': dwellingSize,
        'plotSize': plotSize
      };

  static Future<Collection<Listing>> scrape(
      String startLink, String settlement) async {
    var allListings = new Collection<Listing>();
    var client = Client();
    var pageCounter = 1;

    while (true) {
      // random throttle
      Random random = new Random();
      sleep(new Duration(milliseconds: 500 + random.nextInt(500)));
      var response = await client
          .get("$startLink$settlement?page=${pageCounter.toString()}");
      var document = parse(response.body);
      var listings = document.querySelectorAll('.listing-card');
      if (listings.length == 0) break;
      for (var listing in listings) {
        try {
          allListings.add(new Listing(settlement, listing));
        } catch (e) {
          print("$e on ${pageCounter}.");
        }
      }
      pageCounter++;
    }
    return allListings;
  }
}
