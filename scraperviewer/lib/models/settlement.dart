class Settlement {
  final int id;
  final String name;
  final String county;
  final bool enabled;

  Settlement({this.id, this.name, this.county, this.enabled});

  factory Settlement.fromJson(Map<String, dynamic> json) {
    return Settlement(
        id: json['id'],
        name: json['name'],
        county: json['county'],
        enabled: json['enabled']);
  }
}
