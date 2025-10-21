// lib/presentation/controllers/client/client_controller.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:check_job/domain/entities/client_entity.dart';
import 'package:check_job/domain/repositories/client_repository.dart';
import 'package:check_job/presentation/controllers/admin/admin_controller.dart';
import 'package:check_job/presentation/controllers/audit_log/audit_log_controller.dart';

import '../../../domain/entities/enities.dart';

class ClientController extends GetxController {
  final ClientRepository _clientRepository;
  final AdminController _adminController;
  StreamSubscription? _clientsSubscription;

  ClientController({
    required ClientRepository clientRepository,
    required AdminController adminController,
  }) : _clientRepository = clientRepository,
       _adminController = adminController;

  final RxList<ClientEntity> clients = <ClientEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isButtonDeleteLoading = false.obs;
  final Rx<ClientEntity?> selectedClient = Rx<ClientEntity?>(null);

  @override
  void onInit() {
    _loadClients();
    super.onInit();
  }

  @override
  void onClose() {
    _clientsSubscription?.cancel();
    super.onClose();
  }

   Future<void>  _loadClients() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 300));    
    _clientsSubscription = _clientRepository.getClients().listen(
      (clientsList) {
        clients.assignAll(clientsList);
        isLoading.value = false;
      },
      onError: (error) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Error al cargar clientes: $error',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
    );
  }

  Future<void> refreshClients() async {
    try {
      isLoading.value = true;
      final clientsList = await _clientRepository.getClientsOnce();
      clients.assignAll(clientsList);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al actualizar clientes: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void changeDeleteButtonValue(bool isButtonDeleteLoading) {
    this.isButtonDeleteLoading.value = isButtonDeleteLoading;
  }

  Future<void> selectClient(String clientID) async {
    try {
      isLoading.value = true;
      selectedClient.value = await _clientRepository.getClientWithTasks(clientID);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Error al cargar cliente: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void changeLoadingValue(bool isLoadingNewValue) {
    isLoading.value = isLoadingNewValue;
  }

  void clearSelection() {
    selectedClient.value = null;
  }

  Future<void> createClient({
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 800));

      final client = ClientEntity(
        clientID: _generateClientId(),
        name: name,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
        isActive: false,
        tasks: [],
      );

      // 1) Crear cliente
      await _clientRepository.createClient(client);

      // 2) Intentar registrar en audit log
      try {
        await AuditLogController.logAction(
          action: 'client_created',
          actorID: _adminController.currentAdmin?.adminID ?? 'unknown',
          target: client.name,
        );
      } catch (auditError) {
        // 3) Si falla el audit, revertir (borrar cliente creado)
        try {
          await _clientRepository.deleteClient(client.clientID);
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
        'Cliente creado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      refreshClients();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo crear el cliente: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateClient({
    required String clientID,
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 800));

      // 1) Guardar el estado anterior para posible rollback
      final clientIndex = clients.indexWhere((c) => c.clientID == clientID);
      if (clientIndex == -1) throw Exception('Cliente no encontrado');

      final oldClient = clients[clientIndex];
      final updatedClient = oldClient.copyWith(
        name: name,
        email: email,
        phone: phone,
      );

      // 2) Actualizar
      await _clientRepository.updateClient(updatedClient);

      // 3) Intentar registrar en audit log
      try {
        await AuditLogController.logAction(
          action: 'client_updated',
          actorID: _adminController.currentAdmin?.adminID ?? 'unknown',
          target: oldClient.name,
        );
      } catch (auditError) {
        // 4) Si falla audit, revertir a oldClient
        try {
          await _clientRepository.updateClient(oldClient);
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
        'Cliente actualizado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      refreshClients();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar el cliente: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteClient(String clientID, String clientName) async {
    try {
      isLoading.value = true;
      isButtonDeleteLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 800));

      // Verificar si el cliente tiene tareas activas
      final client = await _clientRepository.getClientWithTasks(clientID);
      final activeTasks = client.inProgressTasks;

      if (activeTasks.isNotEmpty) {
        Get.snackbar(
          'Error',
          'No se puede eliminar el cliente porque tiene tareas activas',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // 1) Obtener snapshot actual del cliente para poder restaurarlo si hace falta
      final clientIndex = clients.indexWhere((c) => c.clientID == clientID);
      if (clientIndex == -1) throw Exception('Cliente no encontrado');

      final existingClient = clients[clientIndex];

      // 2) Borrar
      await _clientRepository.deleteClient(clientID);

      // 3) Intentar registrar en audit log
      try {
        await AuditLogController.logAction(
          action: 'client_deleted',
          actorID: _adminController.currentAdmin?.adminID ?? 'unknown',
          target: clientName,
        );
      } catch (auditError) {
        // 4) Si falla audit, intentar restaurar el documento eliminado
        try {
          await _clientRepository.createClient(existingClient);
        } catch (rollbackError) {
          Get.snackbar(
            'Error crítico',
            'No se pudo registrar la acción ni restaurar el cliente.\n'
            'Audit error: $auditError\nRollback error: $rollbackError',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          throw Exception('Audit y rollback fallaron: $auditError / $rollbackError');
        }
        throw Exception('No se pudo registrar la acción (audit). Se restauró el cliente eliminado.');
      }

      Get.back();
      Get.snackbar(
        'Éxito',
        'Cliente eliminado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      refreshClients();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar el cliente: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isButtonDeleteLoading.value = false;
    }
  }

  // Helper methods para acceder a datos del cliente seleccionado
  List<TaskEntity> get selectedClientTasks => selectedClient.value?.tasks ?? [];
  bool get isSelectedClientActive => selectedClient.value?.isActive ?? false;
  int get selectedClientCompletedTasks => selectedClient.value?.completedTasks.length ?? 0;
  int get selectedClientInProgressTasks => selectedClient.value?.inProgressTasks.length ?? 0;

  String _generateClientId() {
    return 'cli_${DateTime.now().millisecondsSinceEpoch}';
  }
}