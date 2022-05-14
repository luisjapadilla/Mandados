import "package:flutter/material.dart";
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mandados/requests/GraphQLConfiguration.dart';
import "package:graphql_flutter/graphql_flutter.dart";
import 'package:mandados/requests/QueryMutation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class formWindow extends StatefulWidget {
  formWindow (this.location, this.direction, this.picklat, this.picklong);
  LatLng location;
  String direction;
  String picklat, picklong;
  @override
  State<StatefulWidget> createState() =>
      _AlertDialogWindow(location,direction,picklat,picklong);
}

class _AlertDialogWindow extends State<formWindow> {
  _AlertDialogWindow (this.location, this.direction, this.picklat, this.picklong);
  TextEditingController txtId = TextEditingController();
  TextEditingController txtName = TextEditingController();
  TextEditingController txtLastName = TextEditingController();
  TextEditingController txtAge = TextEditingController();
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();
  QueryMutation addMutation = QueryMutation();
  TextEditingController _note = TextEditingController();
  TextEditingController _addnumber = TextEditingController();
  String dateReserve = "";
  LatLng location;
  String direction;
  String picklat, picklong;
  String price;
  int _cityCode;

  @override
  void initState() {
    super.initState();
    dateReserve = "Fecha y Hora del servicio";
  }
  String dropdownValue = '1';
  String hoursvalue = '4';
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AlertDialog(
      title: Text( "Mensajero Por Hora"),
      content: Container(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
            ),
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 0.0),
                  child: FlatButton(
                    color: Colors.black,
                      shape:  RoundedRectangleBorder(borderRadius:BorderRadius.circular(22.0) ),
                      onPressed: () {
                        DatePicker.showDateTimePicker(context,
                            showTitleActions: true,
                             onChanged: (date) {
                              print('change $date');
                            }, onConfirm: (date) {
                              print('confirm $date');
                              setState(() {
                                dateReserve = date.day.toString()+"-"+date.month.toString()+"-"+date.year.toString()+" a las "+date.hour.toString()+":"+date.minute.toString();
                              });
                            }, currentTime: DateTime.now(), locale: LocaleType.es);
                      },
                      child: Text(
                        dateReserve,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      )
                  )
                ),
          Container(
            padding: EdgeInsets.only(top: 50.0),
            child: Row(
              children: <Widget>[
                Text("Numero de mensajeros"),
                SizedBox(width: 20,),
                DropdownButton<String>(
                  value: dropdownValue,
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
                      dropdownValue = newValue;
                    });
                  },
                  items: <String>['1', '2', '3', '4']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),

              ],
            )
          ),
                Container(
                    padding: EdgeInsets.only(top: 100.0),
                    child: Row(
                      children: <Widget>[
                        Text("Cantidad de Horas"),
                        SizedBox(width: 20,),
                        DropdownButton<String>(
                          value: hoursvalue,
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
                              hoursvalue = newValue;
                            });
                          },
                          items: <String>["4","5","6","7","8"]
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    )
                ),
                Container(
                    padding: EdgeInsets.only(top: 150.0),
                    child: TextField(
                      controller: _note,
                      decoration: InputDecoration(
                        icon: Container(
                          child: Icon(
                            Icons.short_text,
                            color: Colors.black,
                          ),
                        ),
                        labelText: "Información Importante",
                        hintText: "Información Importante",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
                      ),
                    )
                ),
                Container(
                    padding: EdgeInsets.only(top: 200.0),
                    child: TextField(
                      controller: _addnumber,
                      keyboardType: TextInputType.number,
                      obscureText: false,
                      decoration: InputDecoration(
                        icon: Container(
                          child: Icon(
                            Icons.phone_android,
                            color: Colors.black,
                          ),
                        ),
                        labelText: "Numero adicional",
                        hintText: "Numero adicional",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
                      ),
                    )
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        Row(
          children: <Widget>[
            Text(
              costService(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),
            ),
            Icon(Icons.attach_money, color: Colors.orange),
          ],
        ),
        FlatButton(
          child: Text("Cerrar"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FlatButton(
          child: Text( "Solicitar"),
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            //Return String
            int code = prefs.getInt('codigo');
            String note = _note.text;
            String xnumer = _addnumber.text;
            String completenote = "$dropdownValue mensajeros por $hoursvalue horas. Nota: $note. Numero adicional: $xnumer";
            if(dateReserve == "Fecha y Hora del servicio"){
              missingdate(context);
            }
            else{
            if(direction.contains('Bogota')||direction.contains('Bogotá')||direction.contains('Bogota')||direction.contains('Bogotá')){
              print("Bogota");
              _cityCode = 107;
            }else  if(direction.contains('Cali')||direction.contains('cali')||direction.contains('Cali')||direction.contains('cali')){
              print("Cali");
              _cityCode = 150;
            }else if(direction.contains('Medellin')||direction.contains('Medellín')||direction.contains('Medellin')||direction.contains('Medellín')){
              print("Medellin");
              _cityCode = 547;
            }else if(direction.contains('Barranquilla')||direction.contains('barranquilla')||direction.contains('Barranquilla')||direction.contains('barranquilla')){
              print("Barranquilla");
              _cityCode = 88;
            }else if(direction.contains('Bucaramanga')||direction.contains('bucaramanga')||direction.contains('Bucaramanga')||direction.contains('bucaramanga')){
              print("Bucaramanga");
              _cityCode = 118;
            }else if(direction.contains('Cartagena')||direction.contains('cartagena')||direction.contains('Cartagena')||direction.contains('cartagena')){
              print("Cartagena");
              _cityCode = 171;
            }
            print("$code");
            GraphQLClient _client = graphQLConfiguration.clientToQuery();
            QueryResult result = await _client.mutate(
              MutationOptions(
                document: addMutation.addReserveCourier(
                  _cityCode,
                    completenote,
                  picklat,
                  picklong,
                  price,
                  code,
                  direction,
                    dateReserve
                ),
              ),
            );
            print(result.data);
            if(result.data != null){
               Navigator.of(context).pop();
               finished(context);
            }
            }
          },
        )
      ],
    );
  }

  String costService() {
    int i = int.parse(hoursvalue)*int.parse(dropdownValue)*14000;
    price = i.toString();
    return price;
  }
  Future<void> missingdate(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Fecha Faltante'),
          content: const Text('Por favor Ingrese la fecha y hora deseada del servicio'),
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
  Future<void> finished(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Perfecto!'),
          content: const Text('Se ha enviado tu solicitud, nos pondremos en contacto con usted pronto. Puede revisar el estado de su solicitud en su historial'),
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
}