// lib/data/services/material_service_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:check_job/domain/services/material_service.dart';
import 'package:check_job/domain/entities/material_entity.dart';

class MaterialServiceImpl implements MaterialService {
  final FirebaseFirestore _firestore;

  MaterialServiceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Stream<List<MaterialEntity>> getMaterials() {
    try {
      return _firestore
          .collection('materials')
          .orderBy('name')
          .snapshots()
          .handleError((error) {
            throw 'Error al obtener materiales: $error';
          })
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => MaterialEntity.fromFirestore(doc.data()))
                .toList();
          });
    } catch (e) {
      return Stream.error('Error al crear stream de materiales: $e');
    }
  }

  @override
  Future<List<MaterialEntity>> getMaterialsOnce() async {
    try {
      final snapshot = await _firestore
          .collection('materials')
          .orderBy('name')
          .get(GetOptions(source: Source.server));
      return snapshot.docs
          .map((doc) => MaterialEntity.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      return Future.error('Error al obtener materiales: $e');
    }
  }

  @override
  Future<void> createMaterial(MaterialEntity material) async {
    try {
      await _firestore
          .collection('materials')
          .doc(material.materialID)
          .set(material.toMap());
    } catch (e) {
      return Future.error('Error al crear material: $e');
    }
  }

  @override
  Future<void> updateMaterial(MaterialEntity material) async {
    try {
      final updatedMaterial = material.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection('materials')
          .doc(material.materialID)
          .update(updatedMaterial.toMap());
    } catch (e) {
      return Future.error('Error al actualizar material: $e');
    }
  }

  @override
  Future<void> deleteMaterial(String materialID) async {
    try {
      await _firestore
          .collection('materials')
          .doc(materialID)
          .delete();
    } catch (e) {
      return Future.error('Error al eliminar material: $e');
    }
  }
}