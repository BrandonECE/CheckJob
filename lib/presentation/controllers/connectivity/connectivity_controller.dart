// lib/presentation/controllers/connectivity/connectivity_controller.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

class ConnectivityController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Estado de conectividad
  final RxBool hasInternetConnection = true.obs;
  final RxBool isCheckingConnection = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _startListening();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  Future<void> _initConnectivity() async {
    isCheckingConnection.value = true;
    
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      _showToast('Error al verificar conectividad: $e', isError: true);
    } finally {
      isCheckingConnection.value = false;
    }
  }

  void _startListening() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
      onError: (error) {
        _showToast('Error en monitoreo de red: $error', isError: true);
      },
    );
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasConnected = hasInternetConnection.value;
    
    // Verificar si hay al menos un tipo de conexión activa
    final isNowConnected = results.any((result) => result != ConnectivityResult.none);

    hasInternetConnection.value = isNowConnected;

    // Mostrar toast solo cuando cambia el estado
    if (wasConnected != isNowConnected) {
      if (isNowConnected) {
        _showToast('Conexión a Internet restaurada', isError: false);
      } else {
        _showToast('Sin conexión a Internet', isError: true);
      }
    }
  }

  void _showToast(String message, {required bool isError}) {
    toastification.show(
    title: Text(message),
    type: isError ? ToastificationType.error : ToastificationType.success,
    style: ToastificationStyle.fillColored,
    alignment: Alignment.topCenter,       // desde arriba
    showProgressBar: true,                // barra de progreso opcional
    autoCloseDuration: const Duration(seconds: 3),
    icon: isError
        ? const Icon(Icons.error_outline, color: Colors.white)
        : const Icon(Icons.check_circle_outline, color: Colors.white),
  );
  }

  // Método para verificar conectividad manualmente
  Future<bool> checkConnection() async {
    isCheckingConnection.value = true;
    
    try {
      final results = await _connectivity.checkConnectivity();
      final isConnected = results.any((result) => result != ConnectivityResult.none);
      hasInternetConnection.value = isConnected;
      return isConnected;
    } catch (e) {
      _showToast('Error al verificar conexión: $e', isError: true);
      return false;
    } finally {
      isCheckingConnection.value = false;
    }
  }

  // Método para obtener el estado actual como texto
  String get connectionStatus {
    if (isCheckingConnection.value) return 'Verificando...';
    return hasInternetConnection.value ? 'Conectado' : 'Sin conexión';
  }

  // Método para obtener el icono según el estado
  IconData get connectionIcon {
    if (isCheckingConnection.value) return Icons.network_check;
    return hasInternetConnection.value ? Icons.wifi : Icons.wifi_off;
  }

  // Método para obtener el color según el estado
  Color get connectionColor {
    if (isCheckingConnection.value) return Colors.orange;
    return hasInternetConnection.value ? Colors.green : Colors.red;
  }

  // Método para obtener el tipo de conexión actual
  String get connectionType {
    if (isCheckingConnection.value) return 'Verificando...';
    if (!hasInternetConnection.value) return 'Sin conexión';
    
    // Este método necesitaría ser actualizado para mostrar el tipo específico
    // Por simplicidad, devolvemos "Conectado"
    return 'Conectado';
  }
}