import "package:flutter/material.dart";
import "package:graphql_flutter/graphql_flutter.dart";
import 'package:shared_preferences/shared_preferences.dart';

class GraphQLConfiguration {

  static HttpLink httpLink = HttpLink(
    uri: "http://45.79.196.91:5000/api/v1/graphql",
  );

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
        link: AuthLink(
          getToken: () async => 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJwbGFjYVZlaGljdWxvIjoiIiwiY29kaWdvIjozMSwidXN1YXJpbyI6IkNsaWVudGUgQXBwIn0.ml3IbRTtnVLm01kHuEebVVAG6bXDHfma1RSXZFyG7K4pcP6Q-qhJG5IXxpyqAlBpcnJlys1bhEXGHv1rOT9o77oHib_VdkGke41Kq--cv-l1HQF4E-NHjhz7CCk7uxrnq43nVjCdpHP-YO88QRT7TM0KhlcEtR9artki37qSdW3_cIVC5ne9iapMRxqSHzgnQfvYur9KBqWEFGcoE3zm84M5yN6KgkYbIPZ74BHveA7uvh8lmNAtB7Vchw6ZKj3u0ItM6EQXKecXZshECCCAYENTBpRZIF4J1F6VPI_qRnkRY9ZgIBIKfGIVRCsP3DcozCg6c_avJqoE5brKQBDWfQ',
          // OR
          // getToken: () => 'Bearer <YOUR_PERSONAL_ACCESS_TOKEN>',
        ).concat(httpLink),
      cache: InMemoryCache(),
    ),
  );

  GraphQLClient clientToQuery() {
    return GraphQLClient(
      cache: InMemoryCache(),
      link: AuthLink(
        getToken: () async => 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJwbGFjYVZlaGljdWxvIjoiIiwiY29kaWdvIjozMSwidXN1YXJpbyI6IkNsaWVudGUgQXBwIn0.ml3IbRTtnVLm01kHuEebVVAG6bXDHfma1RSXZFyG7K4pcP6Q-qhJG5IXxpyqAlBpcnJlys1bhEXGHv1rOT9o77oHib_VdkGke41Kq--cv-l1HQF4E-NHjhz7CCk7uxrnq43nVjCdpHP-YO88QRT7TM0KhlcEtR9artki37qSdW3_cIVC5ne9iapMRxqSHzgnQfvYur9KBqWEFGcoE3zm84M5yN6KgkYbIPZ74BHveA7uvh8lmNAtB7Vchw6ZKj3u0ItM6EQXKecXZshECCCAYENTBpRZIF4J1F6VPI_qRnkRY9ZgIBIKfGIVRCsP3DcozCg6c_avJqoE5brKQBDWfQ',
        // OR
        // getToken: () => 'Bearer <YOUR_PERSONAL_ACCESS_TOKEN>',
      ).concat(httpLink),
    );
  }
  static tokenget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = prefs.getString('token');
    print(stringValue);
    return stringValue;
  }
}