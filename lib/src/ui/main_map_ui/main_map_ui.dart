import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mandados/requests/QueryMutation.dart';
import 'package:mandados/src/ui/history_ui/data.dart';
import 'package:mandados/src/ui/history_ui/history_ui.dart';
import 'package:mandados/src/ui/main_map_ui/button_map.dart';
import 'package:mandados/states/app_state.dart';
import 'package:mandados/src/ui/menu_ui/menu_ui.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mandados/requests/google_maps_requests.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';
import 'DirectionsProvider.dart';

GoogleMapsPlaces _places =
    new GoogleMapsPlaces(apiKey: "AIzaSyD5kGvzZZprCsYSfiXfHVSkKE8Nhs4uGWY");

class MapMUI extends StatefulWidget {
  @override
  _MapMUIState createState() => _MapMUIState();
}

class _MapMUIState extends State<MapMUI> with MenuUI {
  bool isCollapsed = true;

  double screenWidth, screenHeight;
  final Duration duration = const Duration(milliseconds: 300);
  String name;

  @override
  void initState() {
    getName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;
    return WillPopScope(
      onWillPop: () {
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
            menu(context, name),
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
                    size: isCollapsed ? 40 : 60, color: Colors.black),
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

  Future getName() async {
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
  LatLng myposition;
  String mylat, mylong;
  LatLng _pickPoint;
  LatLng _dropPoint;
  String _droplong;
  String _droplat;
  String _picklong;
  String _picklat;
  int _cityCode = 547;
  int _stepcounter = 0;
  String _pickText = "";
  String _dropText = "";
  int _Deliverycost;
  String _mapStyle;
  Uint8List pickmarkerIcon;
  Uint8List dropmarkerIcon;
  GoogleMapController _mapController;
  double screenWidth, screenHeight;
  GoogleMapsPlaces _places =
      GoogleMapsPlaces(apiKey: "AIzaSyD5kGvzZZprCsYSfiXfHVSkKE8Nhs4uGWY");
  final Duration duration = const Duration(milliseconds: 300);
  Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _pickController = TextEditingController();
  final TextEditingController _note = TextEditingController();
  final TextEditingController _dropController = TextEditingController();
  QueryMutation addMutation = QueryMutation();
  double commentheight;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    commentheight = 75.0;
    _pickController.addListener(() {
      print(_pickController.text);
      _pickController.text = _pickText;
    });
    _dropController.addListener(() {
      print(_dropController.text);
      _dropController.text = _dropText;
    });
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          commentheight = 300.0;
        });
      } else {
        setState(() {
          commentheight = 75.0;
        });
      }
    });
  }

  final homeScaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final counter = Provider.of<DirectionProvider>(context, listen: false);
    final appState = Provider.of<AppState>(context);
    return Stack(
      children: <Widget>[
        Consumer<DirectionProvider>(builder:
            (BuildContext context, DirectionProvider api, Widget child) {
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: fromPoint,
              zoom: 6,
            ),
            onMapCreated: _onMapCreated,
            markers: _CreateMarkers(),
            polylines: api.currentRoute,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          );
        }),
        Positioned(
          top: 50.0,
          right: 15.0,
          left: 15.0,
          child: Container(
              height: 40.0,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.0),
                boxShadow: [
                  BoxShadow(
                      color: Color.fromRGBO(255, 255, 255, 2),
                      offset: Offset(1.0, 5.0),
                      blurRadius: 10,
                      spreadRadius: 3)
                ],
              ),
              child: UnicornOutlineButton(
                strokeWidth: 4,
                radius: 24,
                gradient: LinearGradient(
                    colors: [Colors.black, Theme.of(context).primaryColorDark]),
                child: Flexible(
                  child: Text(
                    _pickText == ""
                        ? "Seleccionar Direccion Recogida"
                        : _pickText,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(fontSize: 16, fontFamily: 'Ambit'),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlacePicker(
                          apiKey: "AIzaSyD5kGvzZZprCsYSfiXfHVSkKE8Nhs4uGWY",
                          // Put YOUR OWN KEY here.
                          selectedPlaceWidgetBuilder:
                              (_, selectedPlace, state, isSearchBarFocused) {
                            return isSearchBarFocused
                                ? Container()
                                // Use FloatingCard or just create your own Widget.
                                : FloatingCard(
                                    bottomPosition: 10,
                                    // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
                                    leftPosition: 0.0,
                                    rightPosition: 0.0,
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: state == SearchingState.Searching
                                        ? Center(
                                            child: CircularProgressIndicator())
                                        : Column(
                                              children: <Widget>[
                                                Text(
                                                  "Direccion de Recogida",
                                                  style: TextStyle(
                                                      fontFamily: 'Ambit',
                                                      color: Theme.of(context)
                                                          .accentColor,
                                                      fontSize: 17),
                                                ),
                                                Text(
                                                  selectedPlace
                                                      .formattedAddress,
                                                  style: TextStyle(
                                                      fontFamily: 'Ambit'),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 5,
                                                ),
                                                RaisedButton(
                                                  child: Text(
                                                    "Seleccionar",
                                                    style: TextStyle(
                                                        fontFamily: "Ambit"),
                                                  ),
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  textColor: Colors.black,
                                                  padding: EdgeInsets.fromLTRB(
                                                      10, 10, 10, 10),
                                                  splashColor: Theme.of(context)
                                                      .primaryColorDark,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        new BorderRadius
                                                            .circular(360.0),
                                                    side: BorderSide(
                                                        color: Colors.black),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    Stepcheck(
                                                        selectedPlace.geometry
                                                            .location.lat,
                                                        selectedPlace.geometry
                                                            .location.lng,
                                                        selectedPlace
                                                            .formattedAddress,
                                                        0);
                                                  },
                                                ),
                                              ],
                                            ),
                                  );
                          },
                          initialPosition:
                              _pickPoint == null ? myposition : _pickPoint,
                          useCurrentLocation: true,
                          enableMapTypeButton: false,
                          autocompleteLanguage: 'es-419',
                          region: "CO"),
                    ),
                  );
                },
              )),
        ),
        Positioned(
          top: 95.0,
          right: 15.0,
          left: 15.0,
          child: Container(
              height: 40.0,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.0),
                boxShadow: [
                  BoxShadow(
                      color: Color.fromRGBO(255, 255, 255, 2),
                      offset: Offset(1.0, 5.0),
                      blurRadius: 10,
                      spreadRadius: 3)
                ],
              ),
              child: UnicornOutlineButton(
                strokeWidth: 4,
                radius: 24,
                gradient: LinearGradient(
                    colors: [Colors.black, Theme.of(context).primaryColorDark]),
                child: Flexible(
                  child: Text(
                    _dropText == ""
                        ? "Seleccionar Direccion Entrega"
                        : _dropText,
                    style: TextStyle(fontSize: 16, fontFamily: 'Ambit'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlacePicker(
                          apiKey: "AIzaSyD5kGvzZZprCsYSfiXfHVSkKE8Nhs4uGWY",
                          // Put YOUR OWN KEY here.
                          selectedPlaceWidgetBuilder:
                              (_, selectedPlace, state, isSearchBarFocused) {
                            return isSearchBarFocused
                                ? Container()
                                // Use FloatingCard or just create your own Widget.
                                : FloatingCard(
                                    bottomPosition: 10,
                                    // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
                                    leftPosition: 0.0,
                                    rightPosition: 0.0,
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: state == SearchingState.Searching
                                        ? Center(
                                            child: CircularProgressIndicator())
                                        :  Column(
                                              children: <Widget>[
                                                Text(
                                                  "Direccion de Entrega",
                                                  style: TextStyle(
                                                      fontFamily: 'Ambit',
                                                      color: Theme.of(context)
                                                          .accentColor,
                                                      fontSize: 17),
                                                ),
                                                Text(
                                                  selectedPlace
                                                      .formattedAddress,
                                                  style: TextStyle(
                                                      fontFamily: 'Ambit'),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 5,
                                                ),
                                                RaisedButton(
                                                  child: Text(
                                                    "Seleccionar",
                                                    style: TextStyle(
                                                        fontFamily: "Ambit"),
                                                  ),
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  textColor: Colors.black,
                                                  padding: EdgeInsets.fromLTRB(
                                                      10, 10, 10, 10),
                                                  splashColor: Theme.of(context)
                                                      .primaryColorDark,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        new BorderRadius
                                                            .circular(360.0),
                                                    side: BorderSide(
                                                        color: Colors.black),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    Stepcheck(
                                                        selectedPlace.geometry
                                                            .location.lat,
                                                        selectedPlace.geometry
                                                            .location.lng,
                                                        selectedPlace
                                                            .formattedAddress,
                                                        1);
                                                  },
                                                ),
                                              ],
                                            ),
                                  );
                          },
                          initialPosition:
                              _dropPoint == null ? myposition : _dropPoint,
                          useCurrentLocation: true,
                          enableMapTypeButton: false,
                          autocompleteLanguage: 'es-419',
                          region: "CO"),
                    ),
                  );
                },
              )),
        ),
        Positioned(
            top: 145.0,
            right: 15.0,
            left: 15.0,
            child: AnimatedOpacity(
              opacity: _Deliverycost != null ? 1.0 : 0.0,
              duration: Duration(milliseconds: 1000),
              child: Consumer<DirectionProvider>(builder:
                  (BuildContext context, DirectionProvider api, Widget child) {
                return Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorLight,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  child: Column(
                    children: <Widget>[
                      api.currentPrice != null
                          ? Text("Precio del Mandado:",
                          style: TextStyle(
                              fontFamily: 'Ambit',
                              color: Colors.black,
                              fontSize: 10.0,
                              fontWeight: FontWeight.w500))
                          : Text(""),
                      Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          api.currentPrice != null
                              ? Text(_Deliverycost.toString() + " COP",
                              style: TextStyle(
                                  fontFamily: 'Ambit',
                                  color: Colors.black,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w500))
                              : Text(""),
                          api.currentPrice != null
                              ? Icon(
                            Icons.monetization_on,
                            color: Colors.green,
                          )
                              : Text(""),
                        ],
                      ),
                    api.currentPrice != null
                    ? Text(
                    "*en caso de ser mayor a 5 Kg, se hará un incremento de precio equivalente a volumen y peso",
                    style: TextStyle(
                    backgroundColor: Colors.black12,
                    fontFamily: 'Ambit',
                    color: Colors.black,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500))
                        : Text(""),
                    ],
                  )
                );
              }),
            )),


        Positioned(
            bottom: commentheight,
            right: 15.0,
            left: 15.0,
            child: AnimatedOpacity(
                opacity: _Deliverycost != null ? 1.0 : 0.0,
                duration: Duration(milliseconds: 700),
                child: Container(
                  decoration: BoxDecoration(color: Colors.black26),
                  child: TextField(
                    controller: _note,
                    decoration: InputDecoration(
                      icon: Container(
                        margin: EdgeInsets.only(left: 20, top: 5),
                        width: 10,
                        height: 10,
                        child: Icon(
                          Icons.short_text,
                          color: Colors.white,
                        ),
                      ),
                      labelText: "Mas información",
                      labelStyle: TextStyle(color: Colors.white),
                      hintText: "Mas información",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
                    ),
                    focusNode: _focusNode,
                  ),
                ))),
        _Deliverycost != null
            ? Positioned(
                bottom: 20.0,
                right: 15.0,
                left: 15.0,
                child: AnimatedOpacity(
                  opacity: _Deliverycost != null ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 1000),
                  child: RaisedButton(
                    child: Text("Solicitar Mandado"),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22.0)),
                    elevation: 18.0,
                    onPressed: submitmandado,
                    color: Colors.black,
                    textColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                    splashColor: Theme.of(context).primaryColor,
                  ),
                ))
            : Positioned(bottom: 20.0, right: 15.0, left: 15.0, child: Text(""))
      ],
    );
  }

  Stepcheck(final lat, final lng, String text, int step) async {
    if (step == 0) {
      pickmarkerIcon =
          await getBytesFromAsset('assets/images/pick_marker.png', 100);
      _pickText = text;
      _pickController.text = text;
      _picklat = lat.toString();
      _picklong = lng.toString();
      _pickPoint = LatLng(lat, lng);
      print("aqui" + _pickPoint.toString());
      setState(() {
        _CreateMarkers();
      });
    }
    if (step == 1) {
      dropmarkerIcon =
          await getBytesFromAsset('assets/images/drop_marker.png', 100);
      _dropText = text;
      _dropController.text = text;
      _droplat = lat.toString();
      _droplong = lng.toString();
      _dropPoint = LatLng(lat, lng);
      setState(() {
        _CreateMarkers();
      });
    }
    if (_pickPoint != null && _dropPoint != null) {
      final counter = Provider.of<DirectionProvider>(context, listen: false);
      await _centerView();
      print(counter.currentPrice);
      setState(() {
        _Deliverycost = int.parse(counter.currentPrice);
        if (_Deliverycost < 6000) {
          _Deliverycost = 6000;
        }
      });
    }
  }

  Set<Marker> _CreateMarkers() {
    if (_pickPoint != null) {
      var tmp = Set<Marker>();
      print("aquiiiiiiiiiiiiiiii1111i");
      tmp.add(
        Marker(
            markerId: MarkerId("inicio"),
            position: _pickPoint,
            icon: BitmapDescriptor.fromBytes(pickmarkerIcon)),
      );
      _mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _pickPoint, zoom: 12),
      ));
      if (_dropPoint != null) {
        tmp.add(
          Marker(
              markerId: MarkerId("Destino"),
              position: _dropPoint,
              icon: BitmapDescriptor.fromBytes(dropmarkerIcon)),
        );
      }

      return tmp;
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  _centerView() async {
    var api = Provider.of<DirectionProvider>(context, listen: false);
    await _mapController.getVisibleRegion();

    print("buscando direcciones");
    await api.findDirections(_pickPoint, _dropPoint);
    var left = min(_pickPoint.latitude, _dropPoint.latitude);
    var right = max(_pickPoint.latitude, _dropPoint.latitude);
    var top = max(_pickPoint.longitude, _dropPoint.longitude);
    var bottom = min(_pickPoint.longitude, _dropPoint.longitude);
    api.currentRoute.first.points.forEach((point) {
      left = min(left, 0);
      right = max(right, 0);
      top = max(top, 0);
      bottom = min(bottom, 0);
    });

    var bounds = LatLngBounds(
      southwest: LatLng(left, bottom),
      northeast: LatLng(right, top),
    );
    var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 70);
    _mapController.animateCamera(cameraUpdate);
  }

  Future _onMapCreated(GoogleMapController controller) async {
    _mapController = await controller;
//    _mapController.setMapStyle('[{"featureType":"administrative","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"landscape","elementType":"all","stylers":[{"visibility":"simplified"}]},{"featureType":"poi","elementType":"all","stylers":[{"visibility":"simplified"}]},{"featureType":"road","elementType":"labels","stylers":[{"visibility":"simplified"}]},{"featureType":"road.highway","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"visibility":"on"}]},{"featureType":"road.local","elementType":"all","stylers":[{"visibility":"on"}]},{"featureType":"transit","elementType":"all","stylers":[{"visibility":"simplified"}]},{"featureType":"transit.line","elementType":"geometry","stylers":[{"color":"#3f518c"}]},{"featureType":"water","elementType":"all","stylers":[{"visibility":"simplified"},{"color":"#84afa3"},{"lightness":52}]},{"featureType":"water","elementType":"geometry.fill","stylers":[{"saturation":"-55"},{"color":"#33bae4"}]}],');
    _centerView();
    getLocation();
  }

  void getLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    myposition = LatLng(position.latitude, position.longitude);
    _mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: myposition, zoom: 15),
    ));
  }

  submitmandado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    int code = prefs.getInt('codigo');
    if (_pickText.contains('Bogota') ||
        _pickText.contains('Bogotá') ||
        _dropText.contains('Bogota') ||
        _dropText.contains('Bogotá')) {
      print("Bogota");
      _cityCode = 107;
    } else if (_pickText.contains('Cali') ||
        _pickText.contains('cali') ||
        _dropText.contains('Cali') ||
        _dropText.contains('cali')) {
      print("Cali");
      _cityCode = 150;
    } else if (_pickText.contains('Medellin') ||
        _pickText.contains('Medellín') ||
        _dropText.contains('Medellin') ||
        _dropText.contains('Medellín')) {
      print("Medellin");
      _cityCode = 547;
    } else if (_pickText.contains('Barranquilla') ||
        _pickText.contains('barranquilla') ||
        _dropText.contains('Barranquilla') ||
        _dropText.contains('barranquilla')) {
      print("Barranquilla");
      _cityCode = 88;
    } else if (_pickText.contains('Bucaramanga') ||
        _pickText.contains('bucaramanga') ||
        _dropText.contains('Bucaramanga') ||
        _dropText.contains('bucaramanga')) {
      print("Bucaramanga");
      _cityCode = 118;
    } else if (_pickText.contains('Cartagena') ||
        _pickText.contains('cartagena') ||
        _dropText.contains('Cartagena') ||
        _dropText.contains('cartagena')) {
      print("Cartagena");
      _cityCode = 171;
    } else if (_pickText.contains('Cúcuta') ||
        _pickText.contains('Cucuta') ||
        _pickText.contains('santander') ||
        _dropText.contains('Cúcuta') ||
        _dropText.contains('Cucuta') ||
        _dropText.contains('Santander')) {
      print("Cucuta");
      _cityCode = 275;
    }else if (_pickText.contains('Pereira') ||
        _pickText.contains('Pereira') ||
        _pickText.contains('dosquebradas') ||
        _dropText.contains('Pereira') ||
        _dropText.contains('Dosquebradas')) {
      print("Pereira");
      _cityCode = 657;
    }
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.mutate(
      MutationOptions(
        document: addMutation.addReserveMandado(
            code,
            _cityCode,
            _note.text == "" ? "sin nota" : _note.text,
            _Deliverycost.toString(),
            _pickText,
            _picklat,
            _picklong,
            _dropText,
            _droplat,
            _droplong),
      ),
    );
    print(_dropText);
    print(result.data);
    if (result.data != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HistoryUI(
          data: Data(
            counter: 1,
          ),
        )),
      );

    }

  }
}

Future<Null> displayPrediction(Prediction p, ScaffoldState scaffold) async {
  if (p != null) {
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;
    print(lat);
    print(lng);
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

Future<void> mandadoFinished(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Solicitud Enviada'),
        content: const Text(
            'Su mandado esta siendo procesado y nos pondremos en contacto con usted. Puedes ver el estado de su mandado en el historial'),
        actions: <Widget>[
          FlatButton(
            child: Text('Cerrar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('Ir al historial'),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed("/historial");
            },
          ),
        ],
      );
    },
  );
}
