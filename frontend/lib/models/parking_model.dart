import 'dart:convert';

List<Espacio> espacioListFromJson(String str) => List<Espacio>.from(json.decode(str).map((x) => Espacio.fromJson(x)));

class Espacio {
  int id;
  String identificador; // "A1"
  String estado;        // "LIBRE", "OCUPADO"
  bool esPreferencial;

  Espacio({
    required this.id,
    required this.identificador,
    required this.estado,
    required this.esPreferencial,
  });

  factory Espacio.fromJson(Map<String, dynamic> json) => Espacio(
    id: json["id"],
    identificador: json["identificador"],
    estado: json["estado"],
    esPreferencial: json["esPreferencial"] ?? false,
  );
}