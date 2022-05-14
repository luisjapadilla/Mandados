import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mandados/requests/QueryMutation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../main.dart';

class LoginUi extends StatefulWidget {
  @override
  _LoginUiState createState() => _LoginUiState();
}

class _LoginUiState extends State<LoginUi> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  TextEditingController Id = TextEditingController();
  QueryMutation addMutation = QueryMutation();

  @override
  Widget build(BuildContext context) {
    final Tlftxt = TextField(
      keyboardType: TextInputType.number,
      obscureText: false,
      style: style,
      controller: Id,
      decoration: InputDecoration(
          filled: true,
          fillColor: Color.fromRGBO(246, 246, 246, 0.6),
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Numero de Celular",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xFFFF8A00),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () async {
          if (Id.text.length > 5) {
            String url = 'http://45.79.196.91:5000/api/v1/loginApp';
            Map map = {
              'celular': Id.text.trim(),
            };
            print(Id.text);
            String response = await apilogin(url, map);

            if (response ==
                "error") {
              registerDialog(context, Id.text.trim(),);
            } else {
              Map jsonRes = jsonDecode(response);
              String tokenDec = jsonRes['token'].toString();
              String tokenSplit = tokenDec.split(".")[1];
              var basetoken = base64Url.decode(base64Url.normalize(tokenSplit));
              String code = utf8.decode(basetoken);
              Map codemap = jsonDecode(code);
              int codeint = codemap['codigo'];
              print(codeint);
              QueryMutation queryMutation = QueryMutation();
              GraphQLClient _client = graphQLConfiguration.clientToQuery();
              QueryResult result = await _client.query(
              QueryOptions(
              document: queryMutation.profile(codeint),
              ),
              );
              String name;
              if (!result.hasException) {
                name = result.data["perfilCliente"]["pNombre"];
                print(name);
              }else{
                name= "cliente";
              }
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setInt('codigo', codeint);
              prefs.setString('token', tokenDec);
              prefs.setString('name', name);
              prefs.setString('id', Id.text);
              prefs.setBool('islogged', true);
              Navigator.of(context).pushReplacementNamed("/dashboard");
            }
          } else {
            numerror(context);
          }
        },
        child: Text("Ingresar",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: CustomPaint(
      painter: BluePainter(),
      child: Center(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(20),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 155.0,
                        child: Image.asset(
                          "assets/images/logo_login.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 45.0),
                      Tlftxt,
                      SizedBox(height: 45.0),
                      loginButon,
                      SizedBox(height: 15.0),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "problemas al ingresar?",
                              style: TextStyle(color: Colors.black),
                            ),
                            InkWell(
                              child: Text(
                                "click aqui",
                                style: TextStyle(
                                  color: Color(0xFFFF8A00),
                                ),
                              ),
                              onTap: () async {
                                launch('https://mandados.com.co/ayudal');
                              },
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }
}

class User {
  final String token;

  User(this.token);

  User.fromJson(Map<String, dynamic> json) : token = json['token'];

  Map<String, dynamic> toJson() => {
        'token': token,
      };
}

Future<String> apilogin(String url, Map jsonMap) async {
  HttpClient httpClient = new HttpClient();
  HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
  request.headers.set('content-type', 'application/json');
  request.add(utf8.encode(json.encode(jsonMap)));
  HttpClientResponse response = await request.close();
  // todo - you should check the response.statusCode
  int code = await response.statusCode;
  String reply = await response.transform(utf8.decoder).join();
  print("Este codigo: "+code.toString());
  if (code == 200) {
    Map date = jsonDecode(reply);
    httpClient.close();
    return reply;
  } else {
    httpClient.close();
    return "error";
  }
}

Future<String> apiregister(String url, Map jsonMap) async {
  HttpClient httpClient = new HttpClient();
  HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
  request.headers.set('content-type', 'application/json');
  request.add(utf8.encode(json.encode(jsonMap)));
  HttpClientResponse response = await request.close();
  // todo - you should check the response.statusCode
  String reply = await response.transform(utf8.decoder).join();
  Map date = jsonDecode(reply);
  httpClient.close();
  return reply;
}

Future<void> numerror(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Numero Incorrecto'),
        content: const Text('Ingrese un numero de telefono valido'),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> registerDialog(BuildContext context, String num) {
  TextEditingController nombre = TextEditingController();
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('¿Usuario Nuevo?'),
        content: TextField(
          controller: nombre,
          obscureText: false,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Dinos tu nombre",
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Registrarte'),
            onPressed: () async {
              String url = 'http://45.79.196.91:5000/api/v1/register';
              Map map = {'celular': num, 'p_nombre': nombre.text};
              print(nombre.text);
              String response = await apiregister(url, map);
              Map jsonRes = jsonDecode(response);
              String tokenDec = jsonRes['token'].toString();
              String tokenSplit = tokenDec.split(".")[1];
              var basetoken = base64Url.decode(base64Url.normalize(tokenSplit));
              String code = utf8.decode(basetoken);
              Map codemap = jsonDecode(code);
              var codeint = codemap['codigo'];
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setInt('codigo', codeint);
              prefs.setString('token', tokenDec);
              prefs.setString('id', num);
              prefs.setString('name', nombre.text);
              prefs.setBool('islogged', true);
              Navigator.of(context).pushReplacementNamed("/dashboard");
            },
          ),
        ],
      );
    },
  );
}

class BluePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height;
    final width = size.width;
    Paint paint = Paint();

    Path mainBackground = Path();
    mainBackground.addRect(Rect.fromLTRB(0, 0, width, height));
    paint.color = Colors.white;
    canvas.drawPath(mainBackground, paint);

    Path ovalPath = Path();
    // Start paint from 20% height to the left
    ovalPath.moveTo(0, height * 0.2);

    // paint a curve from current position to middle of the screen
    ovalPath.quadraticBezierTo(
        width * 0.45, height * 0.25, width * 0.51, height * 0.5);

    // Paint a curve from current position to bottom left of screen at width * 0.1
    ovalPath.quadraticBezierTo(width * 0.58, height * 0.8, width * 0.1, height);

    // draw remaining line to bottom left side
    ovalPath.lineTo(0, height);

    // Close line to reset it back
    ovalPath.close();

    paint.color = Color(0xFFFF5900);
    canvas.drawPath(ovalPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
