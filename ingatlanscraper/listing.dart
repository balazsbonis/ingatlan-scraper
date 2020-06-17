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
    id = int.parse(element.attributes['data-id']);
    var priceOnPage = element.querySelector('.price__container');
    var dwellingSizeOnPage = element.querySelector('.listing__data--area-size');
    var plotSizeOnPage = element.querySelector('.listing__data--plot-size');
    price = double.parse(
        priceOnPage.text.replaceAll('M Ft', '').replaceAll(' ', '').trim());
    dwellingSize = double.parse(dwellingSizeOnPage.text
        .replaceAll('m² terület', '')
        .replaceAll(' ', '')
        .trim());
    plotSize = double.parse(plotSizeOnPage.text
        .replaceAll('m² telek', '')
        .replaceAll(' ', '')
        .trim());
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
      sleep(new Duration(milliseconds: 1000 + random.nextInt(500)));
      var response = await client
          .get("$startLink$settlement?page=${pageCounter.toString()}");
      var document = parse(response.body);
      var listings = document.querySelectorAll('.listing');
      if (listings.length == 0) break;
      for (var listing in listings) {
        allListings.add(new Listing(settlement, listing));
      }
      pageCounter++;
    }
    return allListings;
    // print(settlement);
    // print('Average price (M): ' +
    //     allListings.select((x) => x.price).average().toString());
    // print('Average size adjusted price (M): ' +
    //     allListings.select((x) => x.sizeAdjustedPrice()).average().toString());
    //print(allListings);
  }
}
