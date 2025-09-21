class TaskMaterialUsedEntity {
  final String materialID;
  final String materialName;
  final int quantity;
  final String unit;

  TaskMaterialUsedEntity({
    required this.materialID,
    required this.materialName,
    required this.quantity,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {'materialID': materialID, 'materialName': materialName, 'quantity': quantity, 'unit': unit};
  }

  factory TaskMaterialUsedEntity.fromMap(Map<String, dynamic> map) {
    return TaskMaterialUsedEntity(
      materialID: map['materialID'] ?? '',
      materialName: map['materialName'] ?? '',
      quantity: map['quantity'] ?? 0,
      unit: map['unit'] ?? '',
    );
  }
}
