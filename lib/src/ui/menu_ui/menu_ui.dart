import 'package:flutter/material.dart';
import 'package:mandados/src/ui/history_ui/data.dart';
import 'package:mandados/src/ui/history_ui/history_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

mixin MenuUI{
  Widget menu(context,String name){
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).primaryColor ,
      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: <Widget>[
                _Imageheader(name),
                SizedBox(height: 40,),
                _Item(icon: Icons.home,text: 'Inicio',route :"/dashboard", context: context),
                _Item(icon: Icons.motorcycle,text: 'Mandado',route :"/main_map", context: context),
                _Item(icon: Icons.timer,text: 'Mensajero por Hora',route :"/courier_reserve", context: context),
                _Item(icon: Icons.history,text: 'Historial',route :"/historial", context: context),
                _Item(icon: Icons.business_center,text: 'Visita Comercial',route :"/comercial_visit", context: context),
                SizedBox(height: 40,),
                _Item(icon: Icons.subdirectory_arrow_left,text: 'Cerrar Sesion',route :"/login", context: context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
Widget _Item(
    {IconData icon, String text,String route,BuildContext context, GestureTapCallback onTap}) {
  return ListTile(
    title: InkWell(
      onTap: () async {
        if(route == "/login"){
          SharedPreferences prefs = await SharedPreferences.getInstance();
          //Remove String
          prefs.remove("codigo");
          //Remove bool
          prefs.remove("token");
          //Remove int
          prefs.remove("islogged");
          //Remove double
          prefs.remove("id");
        }
        route == "/historial" ?  Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HistoryUI(
            data: Data(
              counter: 0,
            ),
          )),
        ) : Navigator.of(context).pushReplacementNamed(route);
      },
      child: Row(
        children: <Widget>[
          Icon(icon, color: Colors.white70),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text, style: TextStyle(
                fontFamily: 'Montserrat',
              color: Colors.white
            ),),
          )
        ],
      ),
    ),
    onTap: onTap,
  );
}
Widget _Imageheader(String name) {
  return DrawerHeader(
      margin: EdgeInsets.only(left: 20),
      padding: EdgeInsets.zero,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
        CircleAvatar(
          radius: 50,
          backgroundColor:Colors.black,
          backgroundImage:  NetworkImage("https://www.mandados.com.co/wp-content/uploads/2020/05/b.png"),
        ),
            SizedBox(height: 10,),
            Text(name == null ? "Bienvenido" : "Bienvenido $name",
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500)),
      ]));
}

