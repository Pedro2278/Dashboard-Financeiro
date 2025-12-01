class CategoryModel {
  final int? id;
  final String name;
  final bool isIncome;
  final int color;

  CategoryModel({
    this.id,
    required this.name,
    required this.isIncome,
    required this.color,
  });

  // >>>>>>> COLE O copyWith AQUI <<<<<<<<
  CategoryModel copyWith({int? id, String? name, bool? isIncome, int? color}) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isIncome: isIncome ?? this.isIncome,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isIncome': isIncome ? 1 : 0,
      'color': color,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      isIncome: map['isIncome'] == 1,
      color: map['color'],
    );
  }
}
