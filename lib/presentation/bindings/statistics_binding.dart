// lib/presentation/bindings/statistic_binding.dart
import 'package:check_job/domain/repositories/statistics_repository.dart';
import 'package:check_job/domain/services/statistics_service.dart';
import 'package:check_job/infraestructure/repositories/statistics_repository_impl.dart';
import 'package:check_job/infraestructure/services/statistics_service_impl.dart';
import 'package:check_job/presentation/controllers/statistics/statistics_controller.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class StatisticBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StatisticRepository>(() => StatisticRepositoryImpl(firestore:  Get.find<FirebaseFirestore>(),));
    Get.lazyPut<StatisticService>(() => StatisticServiceImpl(firestore:  Get.find<FirebaseFirestore>(),));
    Get.lazyPut<StatisticController>(() => StatisticController(statisticService: Get.find<StatisticService>(), statisticRepository: Get.find<StatisticRepository>()));
  }
}