//import 'package:flutter/material.dart';
//import 'package:mandados/src/ui/courier_reserve_ui/courier_reserve_ui.dart';
//import 'package:mandados/src/ui/dashboard_ui/dashboard.dart';
//import 'package:mandados/src/ui/login_ui/login_ui.dart';
//import 'package:mandados/src/ui/main_map_ui/DirectionsProvider.dart';
//import 'package:mandados/src/ui/main_map_ui/main_map_ui.dart';
//import 'package:provider/provider.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//
//
//class App extends StatelessWidget {
//  Widget app = LoginUi();
//  App(this.app);
//  @override
//  Widget build(BuildContext context) {
//    return ChangeNotifierProvider(
//        builder: (_) => DirectionProvider(),
//        child: MaterialApp(
//          debugShowCheckedModeBanner: false,
//          title: 'Mandados',
//          theme: ThemeData(
//              primaryColor: const Color(0xFFFF8A00),
//              primaryColorDark: const Color(0xFF9F2B00),
//              primaryColorLight: const Color(0xFFFFD68A),
//              accentColor: const Color(0xFFf8a45e),
//              fontFamily: 'Abel'
//          ),
//          routes: <String, WidgetBuilder>{
//            "/main_map": (BuildContext context) => MapMUI(),
//            "/courier_reserve": (BuildContext context) => ReserveCUI(),
//            "/login": (BuildContext context) => LoginUi(),
//            "/dashboard": (BuildContext context) => DashboardUI(),
//          },
//
//          home: app,
//        )
//    );
//  }
//}