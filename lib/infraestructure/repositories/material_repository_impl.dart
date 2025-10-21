// lib/data/repositories/material_repository_impl.dart
import 'package:check_job/domain/repositories/material_repository.dart';
import 'package:check_job/domain/services/material_service.dart';
import 'package:check_job/domain/entities/material_entity.dart';

class MaterialRepositoryImpl implements MaterialRepository {
  final MaterialService _materialService;

  MaterialRepositoryImpl({required MaterialService materialService})
      : _materialService = materialService;

  @override
  Stream<List<MaterialEntity>> getMaterials() {
    try {
      return _materialService.getMaterials();
    } catch (e) {
      return Stream.error('Error en repositorio al obtener materiales: $e');
    }
  }

  @override
  Future<List<MaterialEntity>> getMaterialsOnce() async {
    try {
      return await _materialService.getMaterialsOnce();
    } catch (e) {
      return Future.error('Error en repositorio al obtener materiales: $e');
    }
  }

  @override
  Future<void> createMaterial(MaterialEntity material) async {
    try {
      return await _materialService.createMaterial(material);
    } catch (e) {
      return Future.error('Error en repositorio al crear material: $e');
    }
  }

  @override
  Future<void> updateMaterial(MaterialEntity material) async {
    try {
      return await _materialService.updateMaterial(material);
    } catch (e) {
      return Future.error('Error en repositorio al actualizar material: $e');
    }
  }

  @override
  Future<void> deleteMaterial(String materialID) async {
    try {
      return await _materialService.deleteMaterial(materialID);
    } catch (e) {
      return Future.error('Error en repositorio al eliminar material: $e');
    }
  }
}