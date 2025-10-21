// lib/data/services/client_service_impl.dart
import 'package:check_job/domain/entities/client_entity.dart';
import 'package:check_job/domain/entities/enities.dart';
import 'package:check_job/domain/services/client_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientServiceImpl implements ClientService {
  final FirebaseFirestore _firestore;

  ClientServiceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Stream<List<ClientEntity>> getClients() {
    try {
      return _firestore
          .collection('clients')
          .orderBy('name')
          .snapshots()
          .handleError((error) {
            throw 'Error al obtener clientes: $error';
          })
          .asyncMap((snapshot) async {
            // Obtener todos los clientes
            final clients = snapshot.docs
                .map((doc) => ClientEntity.fromFirestore(doc.data()))
                .toList();

            // Obtener todas las tareas una sola vez
            final allTasks = await _getAllTasksOnce();

            print(allTasks);

            // Poblar cada cliente con sus tareas correspondientes
            final clientsWithTasks = clients.map((client) {
              final clientTasks = allTasks
                  .where((task) => task.clientID == client.clientID)
                  .toList();
              final isActive = _calculateClientActiveStatus(clientTasks);

              return client.copyWith(tasks: clientTasks, isActive: isActive);
            }).toList();

            return clientsWithTasks;
          });
    } catch (e) {
      return Stream.error('Error al crear stream de clientes: $e');
    }
  }

  @override
  Future<List<ClientEntity>> getClientsOnce() async {
    try {
      final snapshot = await _firestore
          .collection('clients')
          .orderBy('name')
          .get(GetOptions(source: Source.server));

      final clients = snapshot.docs
          .map((doc) => ClientEntity.fromFirestore(doc.data()))
          .toList();

      // Obtener todas las tareas
      final allTasks = await _getAllTasksOnce();

      // Poblar cada cliente con sus tareas
      final clientsWithTasks = clients.map((client) {
        final clientTasks = allTasks
            .where((task) => task.clientID == client.clientID)
            .toList();
        final isActive = _calculateClientActiveStatus(clientTasks);

        return client.copyWith(tasks: clientTasks, isActive: isActive);
      }).toList();

      return clientsWithTasks;
    } catch (e) {
      return Future.error('Error al obtener clientes: $e');
    }
  }

  // Método para obtener todas las tareas de una vez
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

  // Calcular si el cliente está activo basado en sus tareas
  bool _calculateClientActiveStatus(List<TaskEntity> tasks) {
    if (tasks.isEmpty) return false;

    // Cliente activo si tiene al menos una tarea en progreso sin feedback
    return tasks.any(
      (task) => task.status == 'in_progress' && task.clientFeedback == null,
    );
  }

  @override
  Future<void> createClient(ClientEntity client) async {
    try {
      await _firestore
          .collection('clients')
          .doc(client.clientID)
          .set(client.toMap());
    } catch (e) {
      return Future.error('Error al crear cliente: $e');
    }
  }

  @override
  Future<void> updateClient(ClientEntity client) async {
    try {
      await _firestore
          .collection('clients')
          .doc(client.clientID)
          .update(client.toMap());
    } catch (e) {
      return Future.error('Error al actualizar cliente: $e');
    }
  }

  @override
  Future<void> deleteClient(String clientID) async {
    try {
      await _firestore.collection('clients').doc(clientID).delete();
    } catch (e) {
      return Future.error('Error al eliminar cliente: $e');
    }
  }

  @override
  Stream<List<TaskEntity>> getClientTasks(String clientID) {
    try {
      return _firestore
          .collection('tasks')
          .where('clientID', isEqualTo: clientID)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .handleError((error) {
            throw 'Error al obtener tareas del cliente: $error';
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
  Future<bool> isClientActive(String clientID) async {
    try {
      final tasks = await _getClientTasksOnce(clientID);
      return _calculateClientActiveStatus(tasks);
    } catch (e) {
      return false;
    }
  }

  // Obtener tareas de un cliente específico (una sola vez)
  Future<List<TaskEntity>> _getClientTasksOnce(String clientID) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('clientID', isEqualTo: clientID)
          .orderBy('createdAt', descending: true)
          .get(GetOptions(source: Source.server));

      print("HEREEEEEEEE: ${snapshot.docs}");

      return snapshot.docs
          .map((doc) => TaskEntity.fromMap(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Nuevo método para obtener un cliente con todas sus tareas
  @override
  Future<ClientEntity> getClientWithTasks(String clientID) async {
    try {
      
      // 1. Obtener el cliente
      final clientDoc = await _firestore
          .collection('clients')
          .doc(clientID)
          .get(GetOptions(source: Source.server));

      if (!clientDoc.exists) {
        throw Exception('Cliente no encontrado');
      }

      final clientData = clientDoc.data()!;
      final client = ClientEntity.fromFirestore(clientData);

      // 2. Obtener las tareas de ESTE cliente específico
      final tasksSnapshot = await _firestore
          .collection('tasks')
          .where('clientID', isEqualTo: clientID)
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
            assignedEmployeeID: '',
            assignedEmployeeName: '',
            clientID: clientID,
            clientName: client.name,
            createdAt: Timestamp.now(),
            materialsUsed: [],
          );
        }
      }).where((task) => task.taskID.isNotEmpty).toList();


      // 4. Calcular si está activo
      final isActive = tasks.any((task) => task.clientFeedback == null
      );


      // 5. Retornar cliente con tareas
      return client.copyWith(
        tasks: tasks,
        isActive: isActive,
      );
    } catch (e) {
      // En lugar de Future.error, lanzamos la excepción directamente
      throw Exception('Error al obtener cliente con tareas: $e');
    }
  }
}
