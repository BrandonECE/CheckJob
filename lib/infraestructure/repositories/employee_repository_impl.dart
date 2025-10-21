// lib/data/repositories/employee_repository_impl.dart
import 'dart:typed_data';
import 'package:check_job/domain/entities/enities.dart';
import 'package:check_job/domain/repositories/employee_repository.dart';
import 'package:check_job/domain/services/employee_service.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeService _employeeService;

  EmployeeRepositoryImpl({required EmployeeService employeeService})
      : _employeeService = employeeService;

  @override
  Stream<List<EmployeeEntity>> getEmployees() {
    try {
      return _employeeService.getEmployees();
    } catch (e) {
      return Stream.error('Error en repositorio al obtener empleados: $e');
    }
  }

  @override
  Future<List<EmployeeEntity>> getEmployeesOnce() async {
    try {
      return await _employeeService.getEmployeesOnce();
    } catch (e) {
      return Future.error('Error en repositorio al obtener empleados: $e');
    }
  }

  @override
  Future<void> createEmployee(EmployeeEntity employee, Uint8List? photoData) async {
    try {
      return await _employeeService.createEmployee(employee, photoData);
    } catch (e) {
      return Future.error('Error en repositorio al crear empleado: $e');
    }
  }

  @override
  Future<void> updateEmployee(EmployeeEntity employee, Uint8List? photoData) async {
    try {
      return await _employeeService.updateEmployee(employee, photoData);
    } catch (e) {
      return Future.error('Error en repositorio al actualizar empleado: $e');
    }
  }

  @override
  Future<void> deleteEmployee(String employeeID) async {
    try {
      return await _employeeService.deleteEmployee(employeeID);
    } catch (e) {
      return Future.error('Error en repositorio al eliminar empleado: $e');
    }
  }

  @override
  Stream<List<TaskEntity>> getEmployeeTasks(String employeeID) {
    try {
      return _employeeService.getEmployeeTasks(employeeID);
    } catch (e) {
      return Stream.error('Error en repositorio al obtener tareas: $e');
    }
  }

  @override
  Future<bool> isEmployeeActive(String employeeID) async {
    try {
      return await _employeeService.isEmployeeActive(employeeID);
    } catch (e) {
      return Future.error('Error en repositorio al verificar estado: $e');
    }
  }

  @override
  Future<EmployeeEntity> getEmployeeWithTasks(String employeeID) async {
    try {
      return await _employeeService.getEmployeeWithTasks(employeeID);
    } catch (e) {
      return Future.error('Error en repositorio al obtener empleado con tareas: $e');
    }
  }
  
  @override
  Future<Uint8List?> getEmployeePhoto(String employeeID) async {
  try {
      return await _employeeService.getEmployeePhoto(employeeID);
    } catch (e) {
      return Future.error('Error en repositorio al obtener empleado con tareas: $e');
    }
  }
}