import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'dart:ui' as ui;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/services.dart' show rootBundle;
import "package:flutter/material.dart";
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mandados/requests/GraphQLConfiguration.dart';
import 'package:mandados/requests/QueryMutation.dart';
import 'package:mandados/src/ui/history_ui/data.dart';
import 'package:mandados/src/ui/history_ui/mandado_info.dart';
import 'package:mandados/src/ui/main_map_ui/DirectionsProvider.dart';
import 'package:mandados/src/ui/menu_ui/menu_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

int countf;
class HistoryUI extends StatefulWidget {
  Data data;
  HistoryUI({this.data});
  @override
  _MenuHUIState createState() => _MenuHUIState(
    data: data
  );
}
class _MenuHUIState extends State<HistoryUI> with MenuUI {
  Data data;
  _MenuHUIState({this.data});
  bool isCollapsed = true;
  String name;
  double screenWidth, screenHeight;
  final Duration duration = const Duration(milliseconds: 300);

  @override
  void initState() {
    getname();
    super.initState();
    data.counter == 1 ? WidgetsBinding.instance
        .addPostFrameCallback((_) => mandadoalert(context)) : print("nada");
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
              Main(),
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

  Future getname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    name = prefs.getString('name');
  }
}
class Main extends StatefulWidget {
  @override
  _HistoryUIState createState() => _HistoryUIState();
}

class _HistoryUIState extends State<Main> {
  String type = 'Mandado Normal';
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();
  List<MandadoInfo> listPerson = List<MandadoInfo>();
  List<MandadoInfo> listHourly = List<MandadoInfo>();
  bool mapReady = false;
  final LatLng fromPoint = LatLng(4.624335, -74.063644);
  LatLng _pickPoint ;
  LatLng _dropPoint;
  GoogleMapController _mapController;
  Uint8List pickmarkerIcon;
  Uint8List dropmarkerIcon;
  String mensajeroName;
  String mensajeroPic;
  String mensajeronumber;
  QueryMutation addMutation = QueryMutation();
  void fillList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int code = prefs.getInt('codigo');
    QueryMutation queryMutation = QueryMutation();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.query(
      QueryOptions(
        document: queryMutation.userHistory(code),
      ),
    );
    if (!result.hasException) {
      print(result);
      pickmarkerIcon = await getBytesFromAsset('assets/images/pick_marker.png', 100);
      dropmarkerIcon = await getBytesFromAsset('assets/images/drop_marker.png', 100);
      print(result.data["historialMandadosNormal"]);

      for (var i = 0; i < result.data["historialMandadosNormal"].length; i++) {
        setState(() {
          listPerson.add(
            MandadoInfo(
              result.data["historialMandadosNormal"][i]["precio"],
              result.data["historialMandadosNormal"][i]["fecha_creado"],
              result.data["historialMandadosNormal"][i]["codigo"],
              result.data["historialMandadosNormal"][i]["nota"],
              result.data["historialMandadosNormal"][i]["nombre_estado"],
              result.data["historialMandadosNormal"][i]["codigo_estado"],
              result.data["historialMandadosNormal"][i]["coordenadas_recogida_latitud"],
              result.data["historialMandadosNormal"][i]["coordenadas_recogida_longitud"],
              result.data["historialMandadosNormal"][i]["coordenadas_entrega_latitud"],
              result.data["historialMandadosNormal"][i]["coordenadas_entrega_longitud"],
              result.data["historialMandadosNormal"][i]["direccion_recogida"],
              result.data["historialMandadosNormal"][i]["direccion_entrega"],
              result.data["historialMandadosNormal"][i]["ciudad"],
              result.data["historialMandadosNormal"][i]["codigo_mensajero"],
            ),
          );
        });
      }
    }
  }
  void fillListHourly() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int code = prefs.getInt('codigo');
    QueryMutation queryMutation = QueryMutation();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.query(
      QueryOptions(
        document: queryMutation.hourlyHistory(code),
      ),
    );
    if (!result.hasException) {
      for (var i = 0; i < result.data["historialMandadosPorHora"].length; i++) {
        setState(() {
          listHourly.add(
            MandadoInfo(
              result.data["historialMandadosPorHora"][i]["precio"],
              result.data["historialMandadosPorHora"][i]["fecha_creado"],
              result.data["historialMandadosPorHora"][i]["codigo"],
              result.data["historialMandadosPorHora"][i]["nota"],
              result.data["historialMandadosPorHora"][i]["nombre_estado"],
              result.data["historialMandadosPorHora"][i]["codigo_estado"],
              result.data["historialMandadosPorHora"][i]["coordenadas_recogida_latitud"],
              result.data["historialMandadosPorHora"][i]["coordenadas_recogida_longitud"],
              result.data["historialMandadosPorHora"][i]["coordenadas_entrega_latitud"],
              result.data["historialMandadosPorHora"][i]["coordenadas_entrega_longitud"],
              result.data["historialMandadosPorHora"][i]["direccion_recogida"],
              result.data["historialMandadosPorHora"][i]["direccion_entrega"],
              result.data["historialMandadosPorHora"][i]["ciudad"],
              result.data["historialMandadosPorHora"][i]["codigo_mensajero"],
            ),
          );
        });
      }
    }
  }
  @override
  void initState() {
    super.initState();
    fillList();
    fillListHourly();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            listPerson.clear();
            listHourly.clear();
            fillList();
            fillListHourly();
          });
        },
        label: Text('Refrescar'),
        icon: Icon(Icons.refresh),
        backgroundColor: Colors.yellow,
      ),
      body: Stack(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Text(
                    "Mi Historial",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17.0),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      DropdownButton<String>(
                        value: type,
                        icon: Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor
                        ),
                        underline: Container(
                          height: 2,
                          color: Colors.black,
                        ),
                        onChanged: (String newValue) {
                          setState(() {
                            type = newValue;
                          });
                        },
                        items: <String>['Mandado Normal', 'Mensajero por Hora']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              )
            ),
            type == 'Mandado Normal' ? Container(
              padding: EdgeInsets.only(top: 70.0),
              child: ListView.builder(
                itemCount: listPerson.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () async {
                      QueryResult result = await LoadMensajero(listPerson[index].getMensajero());
                      if (!result.hasException) {
                        mensajeroName = result.data["perfilMensajero"]["pNombre"]+" "+ result.data["perfilMensajero"]["pApellido"];
                        mensajeroPic = result.data["perfilMensajero"]["foto"];
                        mensajeronumber = result.data["perfilMensajero"]["codigoCelular"];
                      }else{
                        mensajeroName= "nada";
                      }
                      openMap(context,listPerson[index].getCodigo(),listPerson[index].getPrecio(),listPerson[index].getLatOrigin(),listPerson[index].getLonOrigin(),listPerson[index].getLatDestiny(),listPerson[index].getLonDestiny(),listPerson[index].getDirectionOrigin(),listPerson[index].getDirectionDestiny(),listPerson[index].getnota(),listPerson[index].getMensajero(),listPerson[index].getEstadoCode());
                    },
                    child: Card(
                      elevation: 8.0,
                      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white),
                        child:   ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            leading: Container(
                              padding: EdgeInsets.only(right: 12.0),
                              decoration: new BoxDecoration(
                                  border: new Border(
                                      right: new BorderSide(width: 1.0, color: Colors.white24))),
                              child: listPerson[index].getEstadoCode() == 1 ? Icon(Icons.hourglass_full, color: Colors.amber)
                              : listPerson[index].getEstadoCode() == 2 ? Icon(Icons.autorenew, color: Colors.cyan)
                              : listPerson[index].getEstadoCode() == 3 ? Icon(Icons.done, color: Colors.green)
                              : Icon(Icons.clear, color: Colors.red),
                            ),
                            title: Text(
                              "Mandado del dia ${listPerson[index].getFecha()}",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                            // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

                            subtitle: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    listPerson[index].getEstadoCode() == 1 ?
                                    Text("En espera", style: TextStyle(color: Colors.black))
                                    : listPerson[index].getEstadoCode() == 2 ?
                                    Text("En Proceso", style: TextStyle(color: Colors.black))
                                    : listPerson[index].getEstadoCode() == 3 ?
                                    Text("Finalizado", style: TextStyle(color: Colors.black))
                                    : Text("Cancelado", style: TextStyle(color: Colors.black)),
                                    Icon(Icons.linear_scale, color: Colors.orange),
                                    Text("${listPerson[index].getCodigo()}", style: TextStyle(color: Colors.black)),
                                    SizedBox(width: 15,),
                                    Icon(Icons.attach_money, color: Colors.green),
                                    Text("${listPerson[index].getPrecio()}", style: TextStyle(color: Colors.black))
                                  ],
                                ),
                              ],
                            ),
                            trailing:
                            Icon(Icons.keyboard_arrow_right, color: Colors.black, size: 30.0)),
                      ),
                    ),
                  );
                },
              ),
            ) :
            Container(
              padding: EdgeInsets.only(top: 70.0),
              child: ListView.builder(
                itemCount: listHourly.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: (){
                      openMap(context,listPerson[index].getCodigo(),listPerson[index].getPrecio(),listPerson[index].getLatOrigin(),listPerson[index].getLonOrigin(),listPerson[index].getLatDestiny(),listPerson[index].getLonDestiny(),listPerson[index].getDirectionOrigin(),listPerson[index].getDirectionDestiny(),listPerson[index].getnota(),listPerson[index].getMensajero(),listPerson[index].getEstadoCode());
                    },
                    child: Card(
                      elevation: 8.0,
                      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white),
                        child:   ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            leading: Container(
                              padding: EdgeInsets.only(right: 12.0),
                              decoration: new BoxDecoration(
                                  border: new Border(
                                      right: new BorderSide(width: 1.0, color: Colors.white24))),
                              child: listHourly[index].getEstadoCode() == 1 ? Icon(Icons.hourglass_full, color: Colors.amber)
                                  : listHourly[index].getEstadoCode() == 2 ? Icon(Icons.autorenew, color: Colors.cyan)
                                  : listHourly[index].getEstadoCode() == 3 ? Icon(Icons.done, color: Colors.green)
                                  : Icon(Icons.clear, color: Colors.red),
                            ),
                            title: Text(
                              "Mensajero por hora del dia ${listHourly[index].getFecha()}",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                            // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

                            subtitle: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    listHourly[index].getEstadoCode() == 1 ?
                                    Text("En espera", style: TextStyle(color: Colors.black))
                                        : listHourly[index].getEstadoCode() == 2 ?
                                    Text("En Proceso", style: TextStyle(color: Colors.black))
                                        : listHourly[index].getEstadoCode() == 3 ?
                                    Text("Finalizado", style: TextStyle(color: Colors.black))
                                        : Text("Cancelado", style: TextStyle(color: Colors.black)),
                                    Icon(Icons.linear_scale, color: Colors.orange),
                                    Text("${listHourly[index].getCodigo()}", style: TextStyle(color: Colors.black)),
                                    SizedBox(width: 15,),
                                    Icon(Icons.attach_money, color: Colors.green),
                                    Text("${listHourly[index].getPrecio()}", style: TextStyle(color: Colors.black))
                                  ],
                                ),
                              ],
                            ),
                            trailing:
                            Icon(Icons.keyboard_arrow_right, color: Colors.black, size: 30.0)),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
      ),
    );
  }

  Future<void> openMap(BuildContext context,int mandadoid, String price, String picklat, String picklon, String droplat, String droplon, String pickdirection, String dropdirection, String note, int mensajero, int estado) {
    TextEditingController nombre = TextEditingController();
    _pickPoint = LatLng(double.parse(picklat), double.parse(picklon));
    _dropPoint = LatLng(double.parse(droplat), double.parse(droplon));

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          body: Container(
            child:
            Column(
              children: <Widget>[
                Container(
                  height: 300,
                  child: Consumer<DirectionProvider>(builder:
                      (BuildContext context, DirectionProvider api, Widget child) {
                    return GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: fromPoint,
                        zoom: 4,
                      ),
                      onMapCreated: _onMapCreated,
                      markers: _CreateMarkers(),
                      polylines: api.currentRoute,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                    );
                  }),
                ),
 Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Theme.of(context).primaryColorLight,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey,
                                offset: Offset(1.0, 5.0),
                                blurRadius: 10,
                                spreadRadius: 3)
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text("Direccion de Recogida", style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              fontFamily: 'Ambit',
                            ),),
                            SelectableText(
                              pickdirection,
                              style: TextStyle(
                                  color: Colors.black,
                                fontSize: 15,
                                fontFamily: 'Ambit',
                              ),
                            ),
                            SizedBox(height: 10,),
                            Text("Direccion de Entrega", style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              fontFamily: 'Ambit',
                            ),),
                            SelectableText(
                              dropdirection,
                              style: TextStyle(
                                  color: Colors.black,
                                fontSize: 15,
                                fontFamily: 'Ambit',
                              ),
                            ),
                            SizedBox(height: 10,),
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.attach_money, color: Colors.green),
                                  Text(
                                    price,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      fontFamily: 'Ambit',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(note,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                fontFamily: 'Ambit',
                              ),),
                            SizedBox(height: 10,),
                            mensajeronumber != "sin definir" ? Center(
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundColor:Colors.black,
                                       backgroundImage: MemoryImage(ConvertBytes(mensajeroPic)),
                                    ),
                                    SelectableText('$mensajeroName',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17,
                                            fontFamily: 'Ambit',
                                          ),),
                                    SelectableText('$mensajeronumber',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                        fontFamily: 'Ambit',
                                      ),),


                                  ],
                                ),
                              ),
                            ):  estado == 1 ? Text(
                              "Esperando Ser Aceptado",
                              style: TextStyle(
                                color: Colors.black,
                                  fontSize: 15,
                                fontFamily: 'Ambit',
                              ),
                            ) : estado == 3 ? Text(
                              "Finalizado",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontFamily: 'Ambit',
                              ),
                            ) : Text(
                              "Cancelado",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontFamily: 'Ambit',
                              ),
                            ),
                          ],
                        )
                ),
                SizedBox(height: 20,),
                estado == 3 ? Container(
//                  bottom: 5,
//                  left: 5,
//                  right: 5,
                  child: Column(
                    children: <Widget>[
                      Text("Califica el servicio:",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 13
                  ),),
                      RatingBar(
                        initialRating: 3,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Theme.of(context).primaryColor,
                        ),
                        onRatingUpdate: (rating) {
                          print(rating);
                          calificar(context);
                        },
                      ),
                    ],
                  )
                ) : Container(
//                  bottom: 5,
//                  left: 5,
//                  right: 5,
                  child: Text(""),
                ),
                Container(
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Row(
                      children: <Widget>[
                          FlatButton(
                            child: Text('Cerrar'),
                            onPressed: () async {
                              Navigator.of(context).pop();
                            },
                          ),
                          estado == 1 ? FlatButton(
                            child: Text('Cancelar Mandado'),
                            onPressed: () async {
                              Cancelmandado(context, mandadoid);
                            },
                          ) : Text(""),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
  Future<void> Cancelmandado(BuildContext contextm, int id) {
    TextEditingController nombre = TextEditingController();
    return showDialog<void>(
      context: contextm,
      builder: (BuildContext context) {
        GraphQLClient _client = graphQLConfiguration.clientToQuery();
        return AlertDialog(
          title: Text('¿Seguro que desea cancelar el mandado?'),
          actions: <Widget>[
            FlatButton(
              child: Text('SI'),
              onPressed: () async {
                QueryResult result = await _client.mutate(
                  MutationOptions(
                    document: addMutation.cancelarMandado(
                        id
                    ),
                  ),
                );
                listPerson.clear();
                fillList();
                Navigator.of(context).pop();
                Navigator.of(contextm).pop();
              },
            ),
            FlatButton(
              child: Text('NO'),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> calificar(BuildContext contextm) {
    TextEditingController nombre = TextEditingController();
    return showDialog<void>(
      context: contextm,
      builder: (BuildContext context) {
        GraphQLClient _client = graphQLConfiguration.clientToQuery();
        return AlertDialog(
          title: Text('Gracias Por Calificarnos!!'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Set<Marker> _CreateMarkers() {
    if(mapReady == true ) {
      var tmp = Set<Marker>();
      tmp.add(
        Marker(
            markerId: MarkerId("inicio"),
            position: _pickPoint,
            icon: BitmapDescriptor.fromBytes(pickmarkerIcon)
        ),
      );

      tmp.add(
        Marker(
            markerId: MarkerId("Destino"),
            position: _dropPoint,
            icon: BitmapDescriptor.fromBytes(dropmarkerIcon)
        ),
      );
      _mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _pickPoint, zoom: 12),
      ));
      return tmp;
    }
  }
  ConvertBytes(String byte){
    Uint8List bytes = base64.decode(byte);
    return bytes;
  }
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
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
  }
  Future _onMapCreated(GoogleMapController controller) async {
    _mapController = await controller;
    mapReady = true;
    _centerView();
    await _CreateMarkers();
//    _mapController.setMapStyle('[{"featureType":"administrative","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"landscape","elementType":"all","stylers":[{"visibility":"simplified"}]},{"featureType":"poi","elementType":"all","stylers":[{"visibility":"simplified"}]},{"featureType":"road","elementType":"labels","stylers":[{"visibility":"simplified"}]},{"featureType":"road.highway","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"visibility":"on"}]},{"featureType":"road.local","elementType":"all","stylers":[{"visibility":"on"}]},{"featureType":"transit","elementType":"all","stylers":[{"visibility":"simplified"}]},{"featureType":"transit.line","elementType":"geometry","stylers":[{"color":"#3f518c"}]},{"featureType":"water","elementType":"all","stylers":[{"visibility":"simplified"},{"color":"#84afa3"},{"lightness":52}]},{"featureType":"water","elementType":"geometry.fill","stylers":[{"saturation":"-55"},{"color":"#33bae4"}]}],');
  }

  Future LoadMensajero(int mensajero) async {
    QueryMutation queryMutation = QueryMutation();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.query(
      QueryOptions(
        document: queryMutation.profilemensajero(mensajero),
      ),
    );
    return result;
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



mandadoalert(BuildContext context) {
  return AwesomeDialog(
    context: context,
    animType: AnimType.TOPSLIDE,
    dialogType: DialogType.SUCCES,
    title: 'Mandado Enviado',
    desc:   'Estamos buscando mensajero! Aqui podra ver el estado del mandado',
    btnOkColor: Theme.of(context).primaryColorLight,
    btnOkOnPress: () {},
  )..show();
}