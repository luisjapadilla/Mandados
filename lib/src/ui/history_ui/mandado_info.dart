class MandadoInfo {
  MandadoInfo(this.precio, this.fecha, this.codigo, this.nota, this.estado, this.estadocode, this.latorigin, this. lonorigin, this.latdestiny, this.londestiny, this.directionorigin, this.directiondestiny, this.ciudad, this.MensajeroCode );

  final String precio;
  final String fecha;
  final String nota;
  final int codigo;
  final String estado;
  final int estadocode;

  final String latorigin;
  final String lonorigin;

  final String latdestiny;
  final String londestiny;

  final String directionorigin;
  final String directiondestiny;

  final String ciudad;

  final int MensajeroCode;

  getPrecio() => this.precio;
  getFecha() => this.fecha;
  getCodigo () => this.codigo;
  getnota() => this.nota;
  getEstado() => this.estado;
  getEstadoCode() => this.estadocode;

  getLatOrigin() => this.latorigin;
  getLonOrigin() => this.lonorigin;

  getLatDestiny() => this.latdestiny;
  getLonDestiny() => this.londestiny;

  getDirectionOrigin() => this.directionorigin;
  getDirectionDestiny() => this.directiondestiny;

  getCiudad() => this.ciudad;

  getMensajero() => this.MensajeroCode;

}