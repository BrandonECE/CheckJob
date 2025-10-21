// lib/presentation/controllers/material_controller.dart
import 'dart:async';

import 'package:check_job/presentation/controllers/admin/admin_controller.dart';
import 'package:check_job/presentation/controllers/audit_log/audit_log_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:check_job/domain/entities/material_entity.dart';
import 'package:check_job/domain/repositories/material_repository.dart';

class MaterialController extends GetxController {
  final MaterialRepository _materialRepository;
  final AdminController _adminController;
  StreamSubscription? _materialsSubscription;

  MaterialController({
    required MaterialRepository materialRepository,
    required AdminController adminController,
  }) : _materialRepository = materialRepository,
       _adminController = adminController;

  final RxList<MaterialEntity> materials = <MaterialEntity>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<MaterialEntity?> selectedMaterial = Rx<MaterialEntity?>(null);

  @override
  void onInit() {
    _loadMaterials();
    super.onInit();
  }

  @override
  void onClose() {
    _materialsSubscription?.cancel();
    super.onClose();
  }

   Future<void>  _loadMaterials() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    _materialsSubscription = _materialRepository.getMaterials().listen((mats) {
      materials.assignAll(mats);
      isLoading.value = false;
    });
  }

  Future<void> createMaterial({
    required String name,
    required int currentStock,
    required int minStock,
    required String unit,
  }) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 800));

      final material = MaterialEntity(
        materialID: _generateMaterialId(),
        name: name,
        currentStock: currentStock,
        minStock: minStock,
        unit: unit,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 1) Crear material
      await _materialRepository.createMaterial(material);

      // 2) Intentar registrar en audit log
      try {
        await AuditLogController.logAction(
          action: 'material_created',
          actorID: _adminController.currentAdmin?.adminID ?? 'unknown',
          target: material.name,
        );
      } catch (auditError) {
        // 3) Si falla el audit, revertir (borrar material creado)
        try {
          await _materialRepository.deleteMaterial(material.materialID);
        } catch (rollbackError) {
          Get.snackbar(
            'Error crítico',
            'No se pudo registrar la acción ni revertir la creación.\n'
            'Audit error: $auditError\nRollback error: $rollbackError',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          throw Exception('Audit y rollback fallaron: $auditError / $rollbackError');
        }
        throw Exception('No se pudo registrar la acción (audit). Se revirtió la creación.');
      }

      Get.back();
      Get.snackbar(
        'Éxito',
        'Material creado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo crear el material: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  

Future<void> refreshMaterials() async {
  try {
    isLoading.value = true;
    final materialsList = await _materialRepository.getMaterialsOnce();
    materials.assignAll(materialsList);
  } catch (e) {
    Get.snackbar(
      'Error',
      'Error al actualizar materiales: $e',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    isLoading.value = false;
  }
}

  Future<void> updateMaterial({
    required String materialID,
    required int currentStock,
    required int minStock,
  }) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 800));

      // 1) Guardar el estado anterior para posible rollback
      final materialIndex = materials.indexWhere((m) => m.materialID == materialID);
      if (materialIndex == -1) throw Exception('Material no encontrado');

      final oldMaterial = materials[materialIndex];
      final updatedMaterial = oldMaterial.copyWith(
        currentStock: currentStock,
        minStock: minStock,
        updatedAt: DateTime.now(),
      );

      // 2) Actualizar
      await _materialRepository.updateMaterial(updatedMaterial);

      // 3) Intentar registrar en audit log
      try {
        await AuditLogController.logAction(
          action: 'material_updated',
          actorID: _adminController.currentAdmin?.adminID ?? 'unknown',
          target: oldMaterial.name,
        );
      } catch (auditError) {
        // 4) Si falla audit, revertir a oldMaterial
        try {
          await _materialRepository.updateMaterial(oldMaterial);
        } catch (rollbackError) {
          Get.snackbar(
            'Error crítico',
            'No se pudo registrar la acción ni revertir la actualización.\n'
            'Audit error: $auditError\nRollback error: $rollbackError',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          throw Exception('Audit y rollback fallaron: $auditError / $rollbackError');
        }
        throw Exception('No se pudo registrar la acción (audit). Se revirtió la actualización.');
      }

      Get.back();
      Get.snackbar(
        'Éxito',
        'Material actualizado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar el material: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMaterial(String materialID, String materialName) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 800));

      // 1) Obtener snapshot actual del material para poder restaurarlo si hace falta
      final materialIndex = materials.indexWhere((m) => m.materialID == materialID);
      if (materialIndex == -1) throw Exception('Material no encontrado');

      final existingMaterial = materials[materialIndex];

      // 2) Borrar
      await _materialRepository.deleteMaterial(materialID);

      // 3) Intentar registrar en audit log
      try {
        await AuditLogController.logAction(
          action: 'material_deleted',
          actorID: _adminController.currentAdmin?.adminID ?? 'unknown',
          target: materialName,
        );
      } catch (auditError) {
        // 4) Si falla audit, intentar restaurar el documento eliminado
        try {
          await _materialRepository.createMaterial(existingMaterial);
        } catch (rollbackError) {
          Get.snackbar(
            'Error crítico',
            'No se pudo registrar la acción ni restaurar el material.\n'
            'Audit error: $auditError\nRollback error: $rollbackError',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          throw Exception('Audit y rollback fallaron: $auditError / $rollbackError');
        }
        throw Exception('No se pudo registrar la acción (audit). Se restauró el material eliminado.');
      }

      Get.back();
      Get.snackbar(
        'Éxito',
        'Material eliminado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar el material: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void selectMaterial(MaterialEntity material) {
    selectedMaterial.value = material;
  }

  void clearSelection() {
    selectedMaterial.value = null;
  }

  Map<String, int> getInventoryStats() {
    final total = materials.length;
    final lowStock = materials.where((m) => m.status == 'Bajo').length;
    final criticalStock = materials.where((m) => m.status == 'Crítico').length;
    final outOfStock = materials.where((m) => m.status == 'Agotado').length;

    return {
      'total': total,
      'low': lowStock,
      'critical': criticalStock,
      'outOfStock': outOfStock,
    };
  }

  String _generateMaterialId() {
    return 'mat_${DateTime.now().millisecondsSinceEpoch}';
  }
}