class LocationModel {
  final String municipio;
  final String departamento;
  LocationModel({required this.municipio, required this.departamento});
  String get fullName => "$municipio, $departamento";
}
