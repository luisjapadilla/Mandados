import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mandados/src/ui/history_ui/data.dart';
import 'package:mandados/src/ui/history_ui/history_ui.dart';
import 'package:mandados/states/my_icons_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
class DashboardUI extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}
class _DashboardState extends State<DashboardUI>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SpeedDial(
        child: Icon(MyIcons.whatsapp, size: 50, color: Colors.green,),
        // both default to 16
        marginRight: 18,
        marginBottom: 20,
        animatedIconTheme: IconThemeData(size: 22.0),
        // this is ignored if animatedIcon is non null
        // child: Icon(Icons.add),
        visible: true,
        // If true user is forced to close dial manually
        // by tapping main button and overlay is not rendered.
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        onOpen: () => print('OPENING DIAL'),
        onClose: () => print('DIAL CLOSED'),
        tooltip: 'Speed Dial',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
              child:  Icon(MyIcons.whatsapp, size: 40, color: Colors.blue,),
              backgroundColor: Colors.white,
              label: 'Medellín',
              labelStyle: TextStyle(fontSize: 18.0,fontFamily: 'Ambit',),
              onTap: () {
                FlutterOpenWhatsapp.sendSingleMessage("+573163161954", "Hola, Mandados Medellin");
              }
          ),
          SpeedDialChild(
              child:  Icon(MyIcons.whatsapp, size: 40, color: Colors.red,),
              backgroundColor: Colors.white,
              label: 'Bogotá',
              labelStyle: TextStyle(fontSize: 18.0,fontFamily: 'Ambit'),
              onTap: () {
                FlutterOpenWhatsapp.sendSingleMessage("+573007277778", "Hola, Mandados Bogota");
              }
          ),
          SpeedDialChild(
              child:  Icon(MyIcons.whatsapp, size: 40, color: Colors.amber,),
              backgroundColor: Colors.white,
              label: 'Barranquilla',
              labelStyle: TextStyle(fontSize: 18.0,fontFamily: 'Ambit'),
              onTap: () {
                FlutterOpenWhatsapp.sendSingleMessage("+573046307370", "Hola, Mandados Barranquilla");
              }
          ),
          SpeedDialChild(
              child:  Icon(MyIcons.whatsapp, size: 40, color: Colors.purple,),
              backgroundColor: Colors.white,
              label: 'Cali',
              labelStyle: TextStyle(fontSize: 18.0,fontFamily: 'Ambit'),
              onTap: () {
                FlutterOpenWhatsapp.sendSingleMessage("+573135528686", "Hola, Mandados Cali");
              }
          ),
          SpeedDialChild(
              child:  Icon(MyIcons.whatsapp, size: 40, color: Colors.greenAccent,),
              backgroundColor: Colors.white,
              label: 'Cartagena',
              labelStyle: TextStyle(fontSize: 18.0,fontFamily: 'Ambit'),
              onTap: () {
                FlutterOpenWhatsapp.sendSingleMessage("+573135838011", "Hola, Mandados Cartagena");
              }
          ),
          SpeedDialChild(
              child:  Icon(MyIcons.whatsapp, size: 40, color: Colors.limeAccent,),
              backgroundColor: Colors.white,
              label: 'Bucaramanga',
              labelStyle: TextStyle(fontSize: 18.0,fontFamily: 'Ambit'),
              onTap: () {
                FlutterOpenWhatsapp.sendSingleMessage("+573115121210", "Hola, Mandados Bucaramanga");
              }
          ),
          SpeedDialChild(
              child:  Icon(MyIcons.whatsapp, size: 40, color: Colors.pink,),
              backgroundColor: Colors.white,
              label: 'Cúcuta',
              labelStyle: TextStyle(fontSize: 18.0,fontFamily: 'Ambit'),
              onTap: () {
                FlutterOpenWhatsapp.sendSingleMessage("+573209007656", "Hola, Mandados Cucuta");
              }
          ),
          SpeedDialChild(
              child:  Icon(MyIcons.whatsapp, size: 40, color: Colors.brown,),
              backgroundColor: Colors.white,
              label: 'Pereira',
              labelStyle: TextStyle(fontSize: 18.0,fontFamily: 'Ambit'),
              onTap: () {
                FlutterOpenWhatsapp.sendSingleMessage("+573006997033", "Hola, Mandados Pereira");
              }
          ),
        ],
      ),
      body:  Container(
        color: Colors.white,
        child: Stack(
          children: <Widget>[
            ClipPath(
              clipper: linemenu(),
              child: Container(
                color: Theme.of(context).primaryColor,
                height: 250,
              ),),
            Container(
              margin: EdgeInsets.only(top: 50),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 15.0),
                    child:  Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(width: 20.0, height: 50.0),
                        Text(
                          "Mandados",
                          style: TextStyle(fontSize: 35.0, fontFamily: 'Harvest', fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(width: 20.0, height: 50.0),
                        RotateAnimatedTextKit(
                            onTap: () {
                              print("Tap Event");
                            },
                            text: ["Mensajería", "Paqueteria", "Por Horas"],
                            textStyle: TextStyle(fontSize: 25.0, fontFamily: "Red Rose", color: Colors.white),
                          textAlign: TextAlign.start,
                            repeatForever: true
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 150,
                          child: GestureDetector(
                            child: Hero(
                              tag: "card1",
                              child: Card(
                                color: Color.fromRGBO(246,246,246,0.6),
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: Column(
                                  children: <Widget>[
                                    Icon(Icons.motorcycle, size: 100.0,color: Colors.black54,),
                                    Text("Solicitar Mandado",textAlign: TextAlign.center,style: TextStyle(
                                        color: Colors.black54,
                                        fontFamily: 'Ambit',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none

                                    ),)
                                  ],
                                ),
                              ),
                            ),
                            onLongPress: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) {
                                return DetailScreen(card : 1 , icon: Icon(Icons.motorcycle, size: 100.0,color: Colors.white54), title: "Solicitar Mandado", route: "", description: "Domicilos a tu casa");
                              }));
                            },
                            onTap: (){
                              Navigator.of(context).pushReplacementNamed("/main_map");
                            },
                          ),
                        ),
                        Container(
                          width: 150,
                          child: GestureDetector(
                            child: Hero(
                              tag: "card2",
                              child: Card(
                                color: Color.fromRGBO(246,246,246,0.6),
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: Column(
                                  children: <Widget>[
                                    Icon(Icons.assignment, size: 100.0,color: Colors.black54,),
                                    Text("Historial de Mandados",textAlign: TextAlign.center,style: TextStyle(
                                        color: Colors.black54,
                                        fontFamily: 'Ambit',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none

                                    ),)
                                  ],
                                ),
                              ),
                            ),
                            onLongPress: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) {
                                return DetailScreen(card : 2 , icon: Icon(Icons.assignment, size: 100.0,color: Colors.white54), title: "Historial", route: "", description: "Domicilos a tu casa");
                              }));
                            },
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => HistoryUI(
                                  data: Data(
                                    counter: 0,
                                  ),
                                )),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 150,
                          child: GestureDetector(
                            child: Hero(
                              tag: "card3",
                              child: Card(
                                color: Color.fromRGBO(246,246,246,0.6),
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: Column(
                                  children: <Widget>[
                                    Icon(Icons.business_center, size: 100.0,color: Colors.black54,),
                                    Text("Visita Comercial",textAlign: TextAlign.center,style: TextStyle(
                                        color: Colors.black54,
                                        fontFamily: 'Ambit',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none
                                    ),)
                                  ],
                                ),
                              ),
                            ),
                            onLongPress: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) {
                                return DetailScreen(card : 2 , icon: Icon(Icons.business_center, size: 100.0,color: Colors.white54), title: "Visital Comercial", route: "", description: "Domicilos a tu casa");
                              }));
                            },
                            onTap: (){
                              Navigator.of(context).pushReplacementNamed("/comercial_visit");
                            },
                          ),
                        ),
                        Container(
                          width: 150,
                          child: GestureDetector(
                            child: Hero(
                              tag: "card4",
                              child: Card(
                                color: Color.fromRGBO(246,246,246,0.6),
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: Column(
                                  children: <Widget>[
                                    Icon(Icons.timer, size: 100.0,color: Colors.black54,),
                                    Text("Mensajero por Hora",textAlign: TextAlign.center,style: TextStyle(
                                        color: Colors.black54,
                                        fontFamily: 'Ambit',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none

                                    ),)
                                  ],
                                ),
                              ),
                            ),
                            onLongPress: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) {
                                return DetailScreen(card : 2 , icon: Icon(Icons.business_center, size: 100.0,color: Colors.white54), title: "Mensajero por Hora", route: "", description: "Domicilos a tu casa");
                              }));
                            },
                            onTap: (){
                              Navigator.of(context).pushReplacementNamed("/courier_reserve");
                            },
                          ),
                        ),

                      ],
                    ),
                  ),
                  Container(
                    width: 300,
                    child: GestureDetector(
                      child: Hero(
                        tag: "card7",
                        child: Card(
                          color: Color.fromRGBO(246,246,246,0.6),
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Column(
                            children: <Widget>[
                              Text("Cerrar Sesion",textAlign: TextAlign.center,style: TextStyle(
                                  color: Colors.black54,
                                  fontFamily: 'Ambit',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none
                              ),)
                            ],
                          ),
                        ),
                      ),
                      onTap: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        //Remove String
                        prefs.remove("codigo");
                        //Remove bool
                        prefs.remove("token");
                        //Remove int
                        prefs.remove("islogged");
                        //Remove double
                        prefs.remove("id");
                        Navigator.of(context).pushReplacementNamed("/login");
                      },
                    ),
                  ),

                ],
              ),
            ),

          ],
        ),
      ),

    );
  }

}

class linemenu extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0.0, size.height - 20);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
    Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class DetailScreen extends StatelessWidget {
  final int card;
  final Icon icon;
  final String title;
  final String route;
  final String description;

  const DetailScreen({Key key, this.card, this.icon, this.title, this.route, this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: "card$card",
            child: Column(
              children: <Widget>[
                Container(
                    margin: EdgeInsets.all(50),
                    child: Column(
                      children: <Widget>[

                        Text(title,textAlign: TextAlign.center,style: TextStyle(
                            color: Colors.black54,
                            fontFamily: 'Ambit',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none
                        ),),
                        Text(
                          "Conoce sobre este servicio: Solicita un Mandado desde cualquier lugar colocando la direccion ",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              decoration: TextDecoration.none
                          ),
                        ),
                        Container(
                          width: 300,
                          child: Card(
                            color: Theme.of(context).primaryColor,
                            elevation: 10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                icon,
                                Text(
                                  "Solicitar",
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: '',
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                ),

              ],
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}