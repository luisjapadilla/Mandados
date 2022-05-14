import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mandados/requests/GraphQLConfiguration.dart';
import 'package:flutter/material.dart';
import 'package:mandados/src/ui/comercial_visit_ui/comercial_visit_ui.dart';
import 'package:mandados/src/ui/courier_reserve_ui/courier_reserve_ui.dart';
import 'package:mandados/src/ui/dashboard_ui/dashboard.dart';
import 'package:mandados/src/ui/history_ui/history_ui.dart';
import 'package:mandados/src/ui/login_ui/login_ui.dart';
import 'package:mandados/src/ui/main_map_ui/DirectionsProvider.dart';
import 'package:mandados/src/ui/main_map_ui/main_map_ui.dart';
import 'package:mandados/states/app_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Return String
  bool islogged = prefs.getBool('islogged');
  Widget _default = LoginUi();
  if(islogged == true){
    _default = DashboardUI();
  }
  return runApp(
    GraphQLProvider(
        client: graphQLConfiguration.client,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: AppState(),
            )
          ],
          child: ChangeNotifierProvider(
              create: (_) => DirectionProvider(),
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Mandados',
                theme: ThemeData(
                    primaryColor: const Color(0xFFFF5900),
                    primaryColorDark: const Color(0xFF9F2B00),
                    primaryColorLight: const Color(0xFFFFD68A),
                    accentColor: const Color(0xFFf8a45e),
                    fontFamily: 'Abel'
                ),
                routes: <String, WidgetBuilder>{
                  "/main_map": (BuildContext context) => MapMUI(),
                  "/courier_reserve": (BuildContext context) => ReserveCUI(),
                  "/login": (BuildContext context) => LoginUi(),
                  "/dashboard": (BuildContext context) => DashboardUI(),
                  "/historial": (BuildContext context) => HistoryUI(),
                  "/comercial_visit": (BuildContext context) => ComercialVUI(),
                },
                home: SplashScreen.navigate(
                  name: 'assets/splash.flr',
                    next: (_) => _default,
                  startAnimation: 'Untitled',
                  backgroundColor: Color(0xffcecece),
                ),
              )
          )
        )),
  );
}


