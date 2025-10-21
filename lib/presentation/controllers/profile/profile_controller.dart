// lib/presentation/controllers/profile/profile_controller.dart
import 'dart:async';
import 'package:check_job/domain/repositories/task_repository.dart';
import 'package:check_job/domain/repositories/client_repository.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final TaskRepository _taskRepository;
  final ClientRepository _clientRepository;

  StreamSubscription? _tasksSubscription;
  StreamSubscription? _clientsSubscription;

  ProfileController({
    required TaskRepository taskRepository,
    required ClientRepository clientRepository,
  })  : _taskRepository = taskRepository,
        _clientRepository = clientRepository;

  // Estados de carga
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  // Estadísticas para el perfil
  final RxInt totalTasksCount = 0.obs;
  final RxInt totalClientsCount = 0.obs;

  @override
  void onInit() {
    _loadProfileStats();
    super.onInit();
  }

  @override
  void onClose() {
    _tasksSubscription?.cancel();
    _clientsSubscription?.cancel();
    super.onClose();
  }

  void _loadProfileStats() {
    isLoading.value = true;
    error.value = '';

    try {
      // Cargar tareas
      _tasksSubscription = _taskRepository.getTasks().listen(
        (tasks) {
          totalTasksCount.value = tasks.length;
          _checkLoadingComplete();
        },
        onError: (err) {
          error.value = 'Error al cargar tareas: $err';
          totalTasksCount.value = 0;
          _checkLoadingComplete();
        },
      );

      // Cargar clientes
      _clientsSubscription = _clientRepository.getClients().listen(
        (clients) {
          totalClientsCount.value = clients.length;
          _checkLoadingComplete();
        },
        onError: (err) {
          error.value = 'Error al cargar clientes: $err';
          totalClientsCount.value = 0;
          _checkLoadingComplete();
        },
      );
    } catch (e) {
      error.value = 'Error inicial: $e';
      isLoading.value = false;
      totalTasksCount.value = 0;
      totalClientsCount.value = 0;
    }
  }

  void _checkLoadingComplete() {
    // Solo marcar como no loading cuando ambos streams han emitido al menos un valor
    // Esto evita que isLoading cambie demasiado rápido
    if (totalTasksCount.value >= 0 && totalClientsCount.value >= 0) {
      Future.delayed(const Duration(milliseconds: 300), () {
        isLoading.value = false;
      });
    }
  }

  Future<void> refreshProfileStats() async {
    isLoading.value = true;
    error.value = '';

    try {
      await Future.delayed(const Duration(milliseconds: 600));
      
      final tasks = await _taskRepository.getTasksOnce();
      final clients = await _clientRepository.getClientsOnce();
      
      totalTasksCount.value = tasks.length;
      totalClientsCount.value = clients.length;
      
    } catch (e) {
      error.value = 'Error al actualizar: $e';
      Get.snackbar(
        'Error',
        'No se pudieron actualizar las estadísticas: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Método para obtener las estadísticas actuales
  Map<String, int> getProfileStats() {
    return {
      'totalTasks': totalTasksCount.value,
      'totalClients': totalClientsCount.value,
    };
  }
}