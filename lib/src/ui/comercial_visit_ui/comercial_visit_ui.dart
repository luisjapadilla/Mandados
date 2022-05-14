import "package:flutter/material.dart";
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mandados/requests/GraphQLConfiguration.dart';
import 'package:mandados/requests/QueryMutation.dart';
import 'package:mandados/src/ui/history_ui/mandado_info.dart';
import 'package:mandados/src/ui/menu_ui/menu_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComercialVUI extends StatefulWidget {
  @override
  _ComercialVUIState createState() => _ComercialVUIState();
}
class _ComercialVUIState extends State<ComercialVUI> with MenuUI {
  bool isCollapsed = true;
  String name;
  double screenWidth, screenHeight;
  final Duration duration = const Duration(milliseconds: 300);
  TextEditingController  nameBuss = new TextEditingController();
  TextEditingController  namePerson = new TextEditingController();
  TextEditingController  contactNumber = new TextEditingController();
  TextEditingController  comment = new TextEditingController();
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
              child: Container(
                color: Theme.of(context).primaryColor,
              ),
            ),
            menu(context,name),
            form(context),
          ],
        ),
      ),
    );
  }

  Widget form(context) {
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
  GlobalKey<FormState> keyForm= new GlobalKey();
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SingleChildScrollView(
      child: Container(
        child: Stack(
          children: <Widget>[
            ClipPath(
              clipper: linemenu(),
              child: Container(
                color: Color.fromRGBO(255,138,0,0.82),
                height: 250,
              ),),
            Container(
              padding: EdgeInsets.only(top: 10),
              margin: EdgeInsets.all(15),
              child: Card(
                color: Color.fromRGBO(246,246,246,0.6),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Container(
                  margin: EdgeInsets.all(8),
                  child: Column(
                    children: <Widget>[
                      Text("Visita Comercial", style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 20,
                          color: Colors.black
                      ),),
                      SizedBox(height: 20,),
                  TextFormField(
                  decoration: new InputDecoration(
                    labelText: "Nombre de la empresa",
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(
                      ),
                    ),
                    //fillColor: Colors.green
                  ),
                  ),
                      SizedBox(height: 20,),
                      TextFormField(
                        decoration: new InputDecoration(
                          labelText: "Nombre de la persona",
                          fillColor: Colors.white,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(25.0),
                            borderSide: new BorderSide(
                            ),
                          ),
                          //fillColor: Colors.green
                        ),
                      ),
                      SizedBox(height: 20,),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: new InputDecoration(
                          labelText: "Numero de telefono",
                          fillColor: Colors.white,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(25.0),
                            borderSide: new BorderSide(
                            ),
                          ),
                          //fillColor: Colors.green
                        ),
                      ),
                      SizedBox(height: 20,),
                      TextFormField(
                        decoration: new InputDecoration(
                          labelText: "Comentario",
                          fillColor: Colors.white,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(25.0),
                            borderSide: new BorderSide(
                            ),
                          ),
                          //fillColor: Colors.green
                        ),
                      ),
                      SizedBox(height: 20,),
                      RaisedButton(
                        child: Text("Enviar"),
                        shape:  RoundedRectangleBorder(borderRadius:BorderRadius.circular(22.0) ),
                        elevation: 18.0,
                        onPressed: (){

                        },
                        color: Colors.black,
                        textColor: Theme.of(context).accentColor,
                        padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                        splashColor: Theme.of(context).primaryColor,
                      ),
                      SizedBox(height: 20,),
                    ],
                  ),
                ),
              ),
            )
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