// lib/data/services/employee_service_impl.dart
import 'dart:typed_data';
import 'package:check_job/domain/entities/enities.dart';
import 'package:check_job/domain/services/employee_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EmployeeServiceImpl implements EmployeeService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  EmployeeServiceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  @override
  Stream<List<EmployeeEntity>> getEmployees() {
    try {
      return _firestore
          .collection('employees')
          .orderBy('name')
          .snapshots()
          .handleError((error) {
            throw 'Error al obtener empleados: $error';
          })
          .asyncMap((snapshot) async {
            final employees = snapshot.docs
                .map((doc) => EmployeeEntity.fromFirestore(doc.data()))
                .toList();

            final allTasks = await _getAllTasksOnce();

            final employeesWithTasks = await Future.wait(
              employees.map((employee) async {
                final employeeTasks = allTasks
                    .where((task) => task.assignedEmployeeID == employee.employeesID)
                    .toList();
                final isActive = _calculateEmployeeActiveStatus(employeeTasks);
                final photoData = await _getEmployeePhoto(employee.employeesID);

                return employee.copyWith(
                  tasks: employeeTasks,
                  isActive: isActive,
                  photoData: photoData,
                );
              }),
            );

            return employeesWithTasks;
          });
    } catch (e) {
      return Stream.error('Error al crear stream de empleados: $e');
    }
  }

  @override
  Future<List<EmployeeEntity>> getEmployeesOnce() async {
    try {
      final snapshot = await _firestore
          .collection('employees')
          .orderBy('name')
          .get(GetOptions(source: Source.server));

      final employees = snapshot.docs
          .map((doc) => EmployeeEntity.fromFirestore(doc.data()))
          .toList();

      final allTasks = await _getAllTasksOnce();

      final employeesWithTasks = await Future.wait(
        employees.map((employee) async {
          final employeeTasks = allTasks
              .where((task) => task.assignedEmployeeID == employee.employeesID)
              .toList();
          final isActive = _calculateEmployeeActiveStatus(employeeTasks);
          final photoData = await _getEmployeePhoto(employee.employeesID);

          return employee.copyWith(
            tasks: employeeTasks,
            isActive: isActive,
            photoData: photoData,
          );
        }),
      );

      return employeesWithTasks;
    } catch (e) {
      return Future.error('Error al obtener empleados: $e');
    }
  }

  Future<Uint8List?> _getEmployeePhoto(String employeeID) async {
    try {
      final ref = _storage.ref().child('employees/$employeeID.jpg');
      final data = await ref.getData();
      return data;
    } catch (e) {
      // Si no se encuentra la foto, retornar null
      return null;
    }
  }

  Future<void> _uploadEmployeePhoto(String employeeID, Uint8List photoData) async {
    try {
      final ref = _storage.ref().child('employees/$employeeID.jpg');
      await ref.putData(photoData);
    } catch (e) {
      throw Exception('Error al subir la foto: $e');
    }
  }

  Future<void> _deleteEmployeePhoto(String employeeID) async {
    try {
      final ref = _storage.ref().child('employees/$employeeID.jpg');
      await ref.delete();
    } catch (e) {
      // Si no existe, no hacer nada
    }
  }

  Future<List<TaskEntity>> _getAllTasksOnce() async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .get(GetOptions(source: Source.server));

      return snapshot.docs
          .map((doc) => TaskEntity.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error al obtener tareas: $e');
      return [];
    }
  }

  bool _calculateEmployeeActiveStatus(List<TaskEntity> tasks) {
    if (tasks.isEmpty) return false;
    return tasks.any((task) => task.status == 'in_progress');
  }

  @override
  Future<void> createEmployee(EmployeeEntity employee, Uint8List? photoData) async {
    try {
      await _firestore
          .collection('employees')
          .doc(employee.employeesID)
          .set(employee.toMap());

      if (photoData != null) {
        await _uploadEmployeePhoto(employee.employeesID, photoData);
      }
    } catch (e) {
      return Future.error('Error al crear empleado: $e');
    }
  }

  @override
  Future<void> updateEmployee(EmployeeEntity employee, Uint8List? photoData) async {
    try {
      await _firestore
          .collection('employees')
          .doc(employee.employeesID)
          .update(employee.toMap());

      if (photoData != null) {
        await _uploadEmployeePhoto(employee.employeesID, photoData);
      }
    } catch (e) {
      return Future.error('Error al actualizar empleado: $e');
    }
  }

  @override
  Future<void> deleteEmployee(String employeeID) async {
    try {
      await _firestore.collection('employees').doc(employeeID).delete();
      await _deleteEmployeePhoto(employeeID);
    } catch (e) {
      return Future.error('Error al eliminar empleado: $e');
    }
  }

  @override
  Stream<List<TaskEntity>> getEmployeeTasks(String employeeID) {
    try {
      return _firestore
          .collection('tasks')
          .where('assignedEmployeeID', isEqualTo: employeeID)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .handleError((error) {
            throw 'Error al obtener tareas del empleado: $error';
          })
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => TaskEntity.fromMap(doc.data()))
                .toList();
          });
    } catch (e) {
      return Stream.error('Error al crear stream de tareas: $e');
    }
  }

  @override
  Future<bool> isEmployeeActive(String employeeID) async {
    try {
      final tasks = await _getEmployeeTasksOnce(employeeID);
      return _calculateEmployeeActiveStatus(tasks);
    } catch (e) {
      return false;
    }
  }

  Future<List<TaskEntity>> _getEmployeeTasksOnce(String employeeID) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('assignedEmployeeID', isEqualTo: employeeID)
          .orderBy('createdAt', descending: true)
          .get(GetOptions(source: Source.server));

      return snapshot.docs
          .map((doc) => TaskEntity.fromMap(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

// En lib/data/services/employee_service_impl.dart - MÉTODO CORREGIDO
@override
Future<EmployeeEntity> getEmployeeWithTasks(String employeeID) async {
  try {
    // 1. Obtener el empleado
    final employeeDoc = await _firestore
        .collection('employees')
        .doc(employeeID)
        .get(GetOptions(source: Source.server));

    if (!employeeDoc.exists) {
      throw Exception('Empleado no encontrado');
    }

    final employeeData = employeeDoc.data()!;
    final employee = EmployeeEntity.fromFirestore(employeeData);

    // 2. Obtener las tareas de ESTE empleado específico
    final tasksSnapshot = await _firestore
        .collection('tasks')
        .where('assignedEmployeeID', isEqualTo: employeeID)
        .get(GetOptions(source: Source.server));

    // 3. Mapear las tareas correctamente
    final tasks = tasksSnapshot.docs.map((doc) {
      try {
        final taskData = doc.data();
        final task = TaskEntity.fromMap(taskData);
        return task;
      } catch (e) {
        // Retornar una tarea vacía para no romper el flujo
        return TaskEntity(
          taskID: '',
          title: '',
          description: '',
          status: 'pending',
          assignedEmployeeID: employeeID,
          assignedEmployeeName: employee.name,
          clientID: '',
          clientName: '',
          createdAt: Timestamp.now(),
          materialsUsed: [],
        );
      }
    }).where((task) => task.taskID.isNotEmpty).toList();

    // 4. Calcular si está activo
    final isActive = tasks.any((task) => 
      task.status != 'completed'
    );

    // 5. Obtener la foto del empleado
    final photoData = await _getEmployeePhoto(employeeID);

    // 6. Retornar empleado con tareas
    return employee.copyWith(
      tasks: tasks,
      isActive: isActive,
      photoData: photoData,
    );
  } catch (e) {
    throw Exception('Error al obtener empleado con tareas: $e');
  }
}

@override
  Future<Uint8List?> getEmployeePhoto(String employeeID) async {
    try {
      final ref = _storage.ref().child('employees/$employeeID.jpg');
      final data = await ref.getData();
      return data;
    } catch (e) {
      // Si no se encuentra la foto, retornar null
      return null;
    }
  }
}