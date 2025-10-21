// lib/domain/services/material_service.dart
import 'package:check_job/domain/entities/material_entity.dart';

abstract class MaterialService {
  Stream<List<MaterialEntity>> getMaterials();
  Future<List<MaterialEntity>> getMaterialsOnce();
  Future<void> createMaterial(MaterialEntity material);
  Future<void> updateMaterial(MaterialEntity material);
  Future<void> deleteMaterial(String materialID);
}