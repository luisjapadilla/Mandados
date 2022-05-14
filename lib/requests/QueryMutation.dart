class QueryMutation {
  String addMandado(int codecity,
                    String note,
                    String dropLongitude,
                    String dropLatitude,
                    String pickLongitude,
                    String pickLatitude,
                    String cost,
                    String client,
                    String dropDirection,
                    String pickDirection) {
    return """
     mutation crearMandado {
         crearMandadoCA(
           ca: {
             codigoCiudad: $codecity
             nota: "$note"
             coordenadasEntregaLongitud: "$dropLongitude"
             precio: "$cost"
             coordenadasRecogidaLongitud: "$pickLongitude"
             codigoClienteApp: "$client"
             codigoVehiculo: 4
             direccionRecogida: "$pickDirection"
             coordenadasEntregaLatitud: "$dropLatitude"
             direccionEntrega: "$dropDirection"
             coordenadasRecogidaLatitud: "$pickLatitude"
           }
         ) {
           codigo
         }
        }
    """;
  }
  String addReserveMandado(int clientcode , int cityCode, String note , String cost , String pickDirection, String pickLat, String pickLng, String dropDirection, String dropLat, String dropLng) {
    return """
     mutation crearMandado {
       crearMandadoCA(
         ca: {
           codigoCiudad: $cityCode
           nota: "$note"
           coordenadasEntregaLongitud: "$dropLng"
           precio: "$cost"
           coordenadasRecogidaLongitud: "$pickLng"
           codigoClienteApp: $clientcode
           codigoVehiculo: 4
           direccionRecogida: "$pickDirection"
           coordenadasEntregaLatitud: "$dropLat"
           direccionEntrega: "$dropDirection"
           coordenadasRecogidaLatitud: "$pickLat"
         }
       ) {
         codigo
       }
}
    """;
  }
  String addReserveCourier(int cityCode, String note, String lat, String long, String price, int clientCode, String direction, String dateTime) {
    return """
  mutation crearMandado {
   crearMandadoPorHoraCA(
     mandado: {
       codigoCiudad: $cityCode
       nota: "$note"
       coordenadasEntregaLongitud: "$long"
       precio: "$price"
       coordenadasRecogidaLongitud: "$long"
       codigoClienteApp: $clientCode
       codigoVehiculo: 4
       direccionRecogida: "$direction"
       coordenadasEntregaLatitud: "$lat"
       direccionEntrega: "$direction"
       coordenadasRecogidaLatitud: "$lat"
       servicioInicia: "$dateTime",
       servicioTermina: "$dateTime"
     }
   ) {
     codigo
   }
 }
    """;
  }
  String userHistory(int code) {
    return """
query {
  historialMandadosNormal(codigoCliente: $code){
    ciudad,
    codigo,
    codigo_ciudad,
    codigo_direccion,
     codigo_estado,
   codigo_vehiculo
     codigo_mensajero
    coordenadas_entrega_latitud
    coordenadas_entrega_longitud
    coordenadas_recogida_latitud
    coordenadas_recogida_longitud
   direccion_entrega
    direccion_recogida
    fecha_creado
    hora_creado
    nombre_estado
     nota
    vehiculo
    precio
  }
}
    """;
  }
  String hourlyHistory(int code) {
    return """
query hmh{
 historialMandadosPorHora(codigoCliente: $code){
     ciudad,
     codigo,
     codigo_ciudad,
     codigo_direccion,
     codigo_estado,
     codigo_vehiculo
     codigo_mensajero
     coordenadas_entrega_latitud
     coordenadas_entrega_longitud
     coordenadas_recogida_latitud
     coordenadas_recogida_longitud
     direccion_entrega
     direccion_recogida
     fecha_creado
   		hora_creado  
  	nombre_estado
     nota
     vehiculo
     precio
   }
 }
    """;
  }
  String getAll(){
    return """ 
      {
        persons{
          id
          name
          lastName
          age
        }
      }
    """;
  }
  String profile(int id){
    return """
       query perfil{
          perfilCliente(codigo: $id){
            celular,
             nombre,
             pNombre,
             nota
          }
 }
    """;
  }
  String profilemensajero(int id){
    return """
      query mensajero{
    perfilMensajero(codigo: $id){
    codigoCelular
    foto
    pNombre
    pApellido
    }
}
    """;
  }
  String deletePerson(id){
    return """
      mutation{
        deletePerson(id: "$id"){
          id
        }
      } 
    """;
  }

  String editPerson(String id, String name, String lastName, int age){
    return """
      mutation{
          editPerson(id: "$id", name: "$name", lastName: "$lastName", age: $age){
            name
            lastName
          }
      }    
     """;
  }
  String cancelarMandado(int id){
    return """
     mutation finalizar {
        cancelarMandado(
        codigoMandado: $id
       ) {
         codigo
       }
      }   
     """;
  }
}