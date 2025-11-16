import 'dart:async';
import 'package:get/get.dart';
import 'package:check_job/domain/services/daily_stats_generation_service.dart';

class DailyStatsGenerationController extends GetxController {
  final DailyStatsGenerationService _service;
  Timer? _dailyCheckTimer;
  Timer? _minuteCheckTimer;
  
  final RxBool isGenerating = false.obs;
  final RxString lastGenerationStatus = 'No iniciado'.obs;
  final Rx<DateTime?> lastSuccessfulGeneration = Rx<DateTime?>(null);

  DailyStatsGenerationController(this._service);

  @override
  void onInit() {
    super.onInit();
    _initializeGenerationSystem();
  }

  @override
  void onClose() {
    _dailyCheckTimer?.cancel();
    _minuteCheckTimer?.cancel();
    super.onClose();
  }

  void _initializeGenerationSystem() {
    // Ejecutar inmediatamente al iniciar
    _checkAndGenerate();
    
    // Timer cada minuto para verificar si cambió el día
    _minuteCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkForDayChange();
    });

    // Timer diario como backup (cada 24 horas)
    _dailyCheckTimer = Timer.periodic(const Duration(hours: 24), (timer) {
      _checkAndGenerate();
    });

    lastGenerationStatus.value = 'Sistema inicializado - Verificando cada minuto';
  }

  void _checkForDayChange() {
    final now = DateTime.now();
    final lastGen = lastSuccessfulGeneration.value;
    
    // Si no tenemos última generación o si cambió el día
    if (lastGen == null || now.day != lastGen.day || now.month != lastGen.month || now.year != lastGen.year) {
      _checkAndGenerate();
    }
  }

  Future<void> _checkAndGenerate() async {
    if (isGenerating.value) return;
    
    isGenerating.value = true;
    lastGenerationStatus.value = 'Verificando necesidad de generación...';
    
    try {
      final generated = await _service.checkAndGenerateDailyStats();
      
      if (generated) {
        lastSuccessfulGeneration.value = DateTime.now();
        lastGenerationStatus.value = '✓ Generación completada - ${DateTime.now().toString()}';
        print('✅ Daily stats generated successfully');
      } else {
        lastGenerationStatus.value = '✓ No se necesitaba generación - ${DateTime.now().toString()}';
      }
    } catch (e) {
      lastGenerationStatus.value = '✗ Error en generación: $e';
      print('❌ Error generating daily stats: $e');
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> forceGeneration() async {
    await _checkAndGenerate();
  }

  // Para debugging - obtener estado del sistema
  Map<String, dynamic> getSystemStatus() {
    return {
      'isGenerating': isGenerating.value,
      'lastGenerationStatus': lastGenerationStatus.value,
      'lastSuccessfulGeneration': lastSuccessfulGeneration.value?.toString() ?? 'Nunca',
      'nextCheck': 'Cada minuto',
      'systemActive': _minuteCheckTimer != null && !_minuteCheckTimer!.isActive,
    };
  }
}