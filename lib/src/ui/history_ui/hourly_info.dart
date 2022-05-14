class HourlyInfo {
  HourlyInfo(this.precio, this.fecha, this.codigo, this.nota, this.estado, this.estadocode);

  final String precio;
  final String fecha;
  final String nota;
  final int codigo;
  final String estado;
  final int estadocode;

  getPrecio() => this.precio;

  getFecha() => this.fecha;

  getCodigo () => this.codigo;

  getnota() => this.nota;

  getEstado() => this.estado;

  getEstadoCode() => this.estadocode;
}