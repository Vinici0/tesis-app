// To parse this JSON data, do
//
//     final salesResponse = salesResponseFromMap(jsonString);

import 'dart:convert';

import 'package:flutter_maps_adv/models/mensajes_response.dart';

class SalesResponse {
  SalesResponse({
    required this.ok,
    required this.salas,
    required this.totalUsuarios,
  });

  bool ok;
  List<Sala> salas;
  int totalUsuarios;

  factory SalesResponse.fromJson(String str) =>
      SalesResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SalesResponse.fromMap(Map<String, dynamic> json) => SalesResponse(
        ok: json["ok"],
        salas: List<Sala>.from(json["salas"].map((x) => Sala.fromMap(x))),
        totalUsuarios: json["totalUsuarios"],
      );

  Map<String, dynamic> toMap() => {
        "ok": ok,
        "salas": List<dynamic>.from(salas.map((x) => x.toMap())),
        "totalUsuarios": totalUsuarios,
      };
}

Sala salaFromMap(String str) => Sala.fromMap(json.decode(str));

String salaToMap(Sala data) => json.encode(data.toMap());

class Sala {
  String uid;
  String nombre;
  String codigo;
  String color;
  String idUsuario;
  String propietario;
  List<String>? usuarios;
  List<Mensaje>? mensajes;

  Sala({
    required this.nombre,
    required this.codigo,
    required this.color,
    required this.uid,
    required this.idUsuario,
    required this.propietario,
    this.usuarios,
    this.mensajes,
  });

  factory Sala.fromMap(Map<String, dynamic> json) => Sala(
        nombre: json["nombre"],
        uid: json.containsKey("uid") ? json["uid"] : json["_id"],
        codigo: json["codigo"],
        color: json["color"],
        idUsuario: json["idUsuario"],
        mensajes: json["mensajes"] == null
            ? []
            : List<Mensaje>.from(json["mensajes"]!.map((x) => x)),
        usuarios: json["usuarios"] == null
            ? []
            : List<String>.from(json["usuarios"]!.map((x) => x)),
        propietario: json["propietario"],
      );

  Map<String, dynamic> toMap() => {
        "nombre": nombre,
        "codigo": codigo,
        "_id": uid,
        "color": color,
        "idUsuario": idUsuario,
        "mensajes":
            mensajes == null ? [] : List<Mensaje>.from(mensajes!.map((x) => x)),
        "usuarios":
            usuarios == null ? [] : List<dynamic>.from(usuarios!.map((x) => x)),
        "propietario": propietario,
      };
}
