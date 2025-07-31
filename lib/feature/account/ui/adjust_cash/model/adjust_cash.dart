class AdjustCash {
  final int id;
  final String name;

  AdjustCash({required this.id, required this.name});

  factory AdjustCash.fromJson(Map<String, dynamic> json) {
    return AdjustCash(
      id: json['id'],
      name: json['name'],
    );
  }
}