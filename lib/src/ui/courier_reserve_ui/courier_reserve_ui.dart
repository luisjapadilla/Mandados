import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:mandados/src/ui/courier_reserve_ui/form_window.dart';
import 'package:mandados/src/ui/menu_ui/menu_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReserveCUI extends StatefulWidget {
  @override
  _ReserveCState createState() => _ReserveCState();
}

class _ReserveCState extends State<ReserveCUI> with MenuUI {

  bool isCollapsed = true;
  double screenWidth, screenHeight;
  String name;
  final Duration duration = const Duration(milliseconds: 300);
  @override
  void initState() {
    getname();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;
    return WillPopScope(
      onWillPop: (){
        Navigator.of(context).pushReplacementNamed("/dashboard");
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: <Widget>[
            ClipPath(
              clipper: linemenu(),
              child: Container(
                color: Theme.of(context).primaryColor,
              ),
            ),
            menu(context,name),
            main_map(context),
          ],
        ),
      ),
    );
  }

  Widget main_map(context) {
    return AnimatedPositioned(
      duration: duration,
      top: isCollapsed ? 0 : 0.2 * screenHeight,
      bottom: isCollapsed ? 0 : 0.2 * screenWidth,
      left: isCollapsed ? 0 : 0.6 * screenWidth,
      right: isCollapsed ? 0 : -0.4 * screenWidth,
      child: Material(
        animationDuration: const Duration(milliseconds: 2000),
        borderRadius: BorderRadius.all(Radius.circular(40)),
        elevation: 8,
        color: Colors.white,
        child: Container(
          padding:
          const EdgeInsets.only(left: 2, right: 2, top: 35, bottom: 25),
          child: Stack(
            children: <Widget>[
              Map(),
              InkWell(
                child: Icon(isCollapsed ? Icons.menu : Icons.close,
                    size: isCollapsed ? 40 : 50, color: Colors.black),
                onTap: () {
                  setState(() {
                    FocusScope.of(context).requestFocus(FocusNode());
                    isCollapsed = !isCollapsed;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future getname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    name = prefs.getString('name');
  }
}

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  GoogleMapController mapController;
  final LatLng fromPoint = LatLng(4.624335, -74.063644);
  LatLng _pickPoint;
  String _pickText = "";
  String picklat, picklong;
  int _Deliverycost;
  String _mapStyle;
  GoogleMapController _mapController;
  double screenWidth, screenHeight;
  GoogleMapsPlaces _places =
  GoogleMapsPlaces(apiKey: "AIzaSyD5kGvzZZprCsYSfiXfHVSkKE8Nhs4uGWY");
  final Duration duration = const Duration(milliseconds: 300);
  Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _pickController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pickController.addListener(() {
      print(_pickController.text);
      _pickController.text = _pickText;
    });
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  final homeScaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
         GoogleMap(
            initialCameraPosition: CameraPosition(
              target: fromPoint,
              zoom: 12,
            ),
            onMapCreated: _onMapCreated,
            markers: _CreateMarkers(),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
        Positioned(
          top: 50.0,
          right: 15.0,
          left: 15.0,
          child: Container(
            height: 50.0,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey,
                    offset: Offset(1.0, 5.0),
                    blurRadius: 10,
                    spreadRadius: 3)
              ],
            ),
            child: TextField(
              onTap: () async {
                Prediction p = await PlacesAutocomplete.show(
                    context: context,
                    apiKey: "AIzaSyD5kGvzZZprCsYSfiXfHVSkKE8Nhs4uGWY",
                    language: "es",
                    mode: Mode.overlay,
                    hint: "Lugar de Recogida",
                    components: [Component(Component.country, "co")]);
                if (p != null) {
                  PlacesDetailsResponse detail =
                  await _places.getDetailsByPlaceId(p.placeId);
                  final lat = detail.result.geometry.location.lat;
                  final lng = detail.result.geometry.location.lng;
                  print(lat);
                  print(lng);
                  setState(() {
                    _pickText = p.description;
                    _pickController.text = p.description;
                    _pickPoint = LatLng(lat, lng);
                    picklat = lat.toString();
                    picklong = lng.toString();
                    _CreateMarkers();
                  });
                }
              },
              controller: _pickController,
              cursorColor: Colors.black,
              textInputAction: TextInputAction.go,
              decoration: InputDecoration(
                icon: Container(
                  margin: EdgeInsets.only(left: 20, top: 5),
                  width: 10,
                  height: 10,
                  child: Icon(
                    Icons.timer,
                    color: Colors.black,
                  ),
                ),
                labelText: 'Lugar del servicio',
                hintText: "Lugar del servicio",
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
              ),
            ),
          ),
        ),
        _pickPoint != null ?Positioned(
          bottom: 20.0,
          right: 15.0,
          left: 15.0,
          child: RaisedButton(
            child: Text("Siguiente"),
            shape:  RoundedRectangleBorder(borderRadius:BorderRadius.circular(22.0) ),
            elevation: 18.0,
            color: Colors.black,
            textColor: Theme.of(context).accentColor,
            padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
            splashColor: Theme.of(context).primaryColor,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  formWindow alertDialogWindow =
                  new formWindow(_pickPoint,_pickText, picklat, picklong);
                  return alertDialogWindow;
                },
              );
            },
          ),
        ) : Text(
          ""
        )
      ],
    );
  }

  Set<Marker> _CreateMarkers() {
    if (_pickPoint != null) {
      var tmp = Set<Marker>();
      tmp.add(
        Marker(
          markerId: MarkerId("inicio"),
          position: _pickPoint,
        ),
      );
      _mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _pickPoint, zoom: 12),
      ));
      return tmp;
    }
  }


  Future _onMapCreated(GoogleMapController controller) async {
    _mapController = await controller;
//    _mapController.setMapStyle('[{"featureType":"administrative","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"landscape","elementType":"all","stylers":[{"visibility":"simplified"}]},{"featureType":"poi","elementType":"all","stylers":[{"visibility":"simplified"}]},{"featureType":"road","elementType":"labels","stylers":[{"visibility":"simplified"}]},{"featureType":"road.highway","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"visibility":"on"}]},{"featureType":"road.local","elementType":"all","stylers":[{"visibility":"on"}]},{"featureType":"transit","elementType":"all","stylers":[{"visibility":"simplified"}]},{"featureType":"transit.line","elementType":"geometry","stylers":[{"color":"#3f518c"}]},{"featureType":"water","elementType":"all","stylers":[{"visibility":"simplified"},{"color":"#84afa3"},{"lightness":52}]},{"featureType":"water","elementType":"geometry.fill","stylers":[{"saturation":"-55"},{"color":"#33bae4"}]}],');
    getLocation();
  }
  void getLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng myposition = LatLng(position.latitude , position.longitude);
    _mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: myposition, zoom: 15),
    ));
  }
}
class linemenu extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // TODO: implement getClip
    var path = Path();
    path.lineTo(0, 250);
    path.lineTo(500, 0);
    path.lineTo(size.width - 500, size.height - 500);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}