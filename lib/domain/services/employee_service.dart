// lib/domain/services/employee_service.dart
import 'dart:typed_data';

import 'package:check_job/domain/entities/enities.dart';

abstract class EmployeeService {
  Stream<List<EmployeeEntity>> getEmployees();
  Future<List<EmployeeEntity>> getEmployeesOnce();
  Future<void> createEmployee(EmployeeEntity employee, Uint8List? photoData);
  Future<void> updateEmployee(EmployeeEntity employee, Uint8List? photoData);
  Future<void> deleteEmployee(String employeeID);
  Stream<List<TaskEntity>> getEmployeeTasks(String employeeID);
  Future<bool> isEmployeeActive(String employeeID);
  Future<EmployeeEntity> getEmployeeWithTasks(String employeeID);
  Future<Uint8List?> getEmployeePhoto(String employeeID);
}