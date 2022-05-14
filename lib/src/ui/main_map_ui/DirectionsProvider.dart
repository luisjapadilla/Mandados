import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:google_maps_webservice/directions.dart';

class DirectionProvider extends ChangeNotifier {
  GoogleMapsDirections directionsApi =
  GoogleMapsDirections(apiKey: "AIzaSyD5kGvzZZprCsYSfiXfHVSkKE8Nhs4uGWY");

  Set<maps.Polyline> _route = Set();
  Set<maps.Polyline> get currentRoute => _route;

  String _price;
  String get currentPrice => _price;

  findDirections(maps.LatLng from, maps.LatLng to) async {
    if(from == null && to == null){
      _price = null;
      _route.clear();
      notifyListeners();
    }else{
      var origin = Location(from.latitude, from.longitude);
      var destination = Location(to.latitude, to.longitude);
    var result = await directionsApi.directionsWithLocation(
      origin,
      destination,
      travelMode: TravelMode.driving,
      departureTime: DateTime.now(),
      trafficModel: TrafficModel.bestGuess
    );

    Set<maps.Polyline> newRoute = Set();

    if (result.isOkay) {
      var route = result.routes[0];
      var leg = route.legs[0];
      var dis = leg.durationInTraffic.value;
      dis = dis/60;
      var km = leg.distance.value;
      km = km/1000;
      var price = (km*620)+((dis-km)*440);
      int roundprice = price.round();
      roundprice = (((roundprice+99)/100).round()*100).round();
      List<maps.LatLng> points = [];

      leg.steps.forEach((step) {
        points.add(maps.LatLng(step.startLocation.lat, step.startLocation.lng));
        points.add(maps.LatLng(step.endLocation.lat, step.endLocation.lng));
      });

      var line = maps.Polyline(
        points: points,
        polylineId: maps.PolylineId("mejor ruta"),
        color: Color(0xFFFF8A00),
        width: 6,
      );
      newRoute.add(line);
      print("aqui");
      print(dis);
      print(km);
      print(price);
      print(roundprice);

      _route = newRoute;
      _price =  roundprice.toString();
      notifyListeners();
    } else {
      print("ERRROR !!! ${result.status}");
    }
    }
  }
  clearmap(){
    _route.clear();
    notifyListeners();
}
}