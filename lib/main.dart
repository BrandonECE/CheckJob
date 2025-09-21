import 'package:check_job/config/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await InitFirebaseClean().initializeDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CheckJob',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00796B)),
      ),
      initialRoute: Routes.myTaskLookUpView,
      getPages: Routes.pages,
    );
  }
}
// init_firebase_clean.dart

class InitFirebaseClean {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lista de colecciones raíz definidas en tu esquema
  final List<String> _rootCollections = [
    'admins',
    'employees',
    'clients',
    'tasks',
    // task_comments es subcolección -> no listado aquí
    'invoices',
    'notifications',
    'materials',
    'reports',
    'statistics',
    'settings',
    // audit_logs es subcolección -> no listado aquí
    // 'task_comments' y 'audit_logs' se borran como subcolecciones
  ];

  /// Límite de batch para Firestore
  static const int _batchLimit = 500;

  Future<void> initializeDatabase({bool force = true}) async {
    try {
      print('🔄 Empezando inicialización limpia de la base de datos...');

      // 0. Confirmar borrado previo si force == true
      if (force) {
        print('🧹 Borrando colecciones conocidas antes de insertar...');
        for (final collection in _rootCollections) {
          await _deleteAllDocsInCollection(collection);
        }

        // Borrar subcolecciones conocidas:
        // - task_comments (por cada documento en tasks)
        // - audit_logs (por el doc settings/app_config si existe)
        await _deleteTaskCommentsSubcollections();
        await _deleteAuditLogsUnderSettings();
        print('✅ Borrado inicial completado.');
      }

      // 1. Crear admins
      await _firestore.collection('admins').doc('admin_001').set({
        'adminID': 'admin_001',
        'name': 'Administrador Principal',
        'email': 'admin@checkjob.com',
        'createdAt': Timestamp.now(),
      });

      // 2. Crear employees (observa que el campo solicitado es "employeesID")
      final List<Map<String, dynamic>> employees = [
        {
          'employeesID': 'emp_001',
          'name': 'Juan Pérez',
          'photoUrl': null, // URL a Cloud Storage si aplica
          'isActive': true,
          'phone': '+1234567890',
          'email': 'contacto@abc.com',
          'createdAt': Timestamp.now(),
        },
        {
          'employeesID': 'emp_002',
          'name': 'María López',
              'phone': '+0987654321',
          'email': 'info@xyz.com',
          'photoUrl': null,
          'isActive': true,
          'createdAt': Timestamp.now(),
        },
        {
          'employeesID': 'emp_003',
          'name': 'Carlos Rodríguez',
               'phone': '+1122334455',
          'email': 'ventas@negocio123.com',
          'photoUrl': null,
          'isActive': false,
          'createdAt': Timestamp.now(),
        },
      ];

      for (final e in employees) {
        final String? id = e['employeesID'] as String?;
        if (id == null || id.isEmpty) continue;
        await _firestore.collection('employees').doc(id).set(e);
      }

      // 3. Crear clients
      final List<Map<String, dynamic>> clients = [
        {
          'clientID': 'cli_001',
          'name': 'Empresa ABC',
          'phone': '+1234567890',
          'email': 'contacto@abc.com',
          'createdAt': Timestamp.now(),
        },
        {
          'clientID': 'cli_002',
          'name': 'Compañía XYZ',
          'phone': '+0987654321',
          'email': 'info@xyz.com',
          'createdAt': Timestamp.now(),
        },
        {
          'clientID': 'cli_003',
          'name': 'Negocio 123',
          'phone': '+1122334455',
          'email': 'ventas@negocio123.com',
          'createdAt': Timestamp.now(),
        },
      ];

      for (final c in clients) {
        final String? id = c['clientID'] as String?;
        if (id == null || id.isEmpty) continue;
        await _firestore.collection('clients').doc(id).set(c);
      }

      // 4. Crear materials
      final List<Map<String, dynamic>> materials = [
        {
          'materialID': 'mat_001',
          'name': 'Aceite Motor Sintético',
          'currentStock': 42,
          'minStock': 10,
          'unit': 'Lts',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'materialID': 'mat_002',
          'name': 'Filtro de Aire Premium',
          'currentStock': 8,
          'minStock': 15,
          'unit': 'Pzas',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'materialID': 'mat_003',
          'name': 'Bujías Iridium',
          'currentStock': 25,
          'minStock': 20,
          'unit': 'Pzas',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'materialID': 'mat_004',
          'name': 'Pastillas de Freno Delanteras',
          'currentStock': 5,
          'minStock': 8,
          'unit': 'Pzas',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
      ];

      for (final m in materials) {
        final String? id = m['materialID'] as String?;
        if (id == null || id.isEmpty) continue;
        await _firestore.collection('materials').doc(id).set(m);
      }

      // 5. Crear tasks (sin campos adicionales no solicitados)
      final List<Map<String, dynamic>> tasks = [
        {
          'taskID': 'task_001',
          'title': 'Mantenimiento Preventivo Completo',
          'description':
          'Cambio de aceite sintético, filtros de aire y aceite, revisión de frenos y sistema eléctrico',
          'status': 'completed', // por ejemplo: pending, in_progress, completed
          'assignedEmployeeID': 'emp_001',
          'assignedEmployeeName': "Juan Marcos",
          'clientName': "Pedro Pascal",
          'clientID': 'cli_001',
          'createdAt': Timestamp.now(),
          'completedAt': Timestamp.now(),
          'clientFeedback': {'approved': true, 'submittedAt': Timestamp.now()},
          'materialsUsed': [
            {'materialID': 'mat_001', 'materialName': 'Aceite', 'quantity': 4, 'unit': 'Lts'},
            {'materialID': 'mat_002', 'materialName': 'Tortnillos', 'quantity': 1, 'unit': 'Pzas'},
            {'materialID': 'mat_004', 'materialName': 'Bandejas', 'quantity': 4, 'unit': 'Pzas'},
          ],
        },
        {
          'taskID': 'task_002',
          'title': 'Reparación Sistema de Inyección',
          'description':
              'Diagnóstico y reparación del sistema de inyección, cambio de bujías y limpieza de inyectores',
          'status': 'in_progress',
          'assignedEmployeeID': 'emp_002',
          'assignedEmployeeName': "Maria Juana",
          'clientName': "Pedro Emmanuel",
          'clientID': 'cli_002',
          'createdAt': Timestamp.now(),
          'completedAt': null,
          'clientFeedback': null,
          'materialsUsed': [
            {'materialID': 'mat_003', 'materialName': 'Tornullos', 'quantity': 4, 'unit': 'Pzas'},
          ],
        },
      ];

      for (final t in tasks) {
        final String? id = t['taskID'] as String?;
        if (id == null || id.isEmpty) continue;
        // Guardar tarea (documento)
        await _firestore.collection('tasks').doc(id).set(t);

        // Si la tarea tiene comentarios (ejemplo para task_001), creamos subcolección task_comments
        if (t['status'] == 'completed') {
          // Un ejemplo simple: crear 1 comentario
          await _firestore
              .collection('tasks')
              .doc(id)
              .collection('task_comments')
              .doc('comment_001')
              .set({
                'taskID': id,
                'text':
                    'Tarea completada satisfactoriamente. Cliente muy satisfecho.',
                'createdAt': Timestamp.now(),
              });
        }
      }

      // 6. Crear invoices
      await _firestore.collection('invoices').doc('inv_001').set({
        'invoicesID': 'inv_001',
        'taskID': 'task_001',
        'clientName': "Juan Pablo",
        'clientID': 'cli_001',
        'amount': 285.75,
        'status': 'paid',
        'dueDate': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 30)),
        ),
        'createdAt': Timestamp.now(),
      });

      // 7. Crear notifications
      await _firestore.collection('notifications').doc('notif_001').set({
        'notificationID': 'notif_001',
        'targetID': 'admin_001',
        'title': 'Tarea Completada Exitosamente',
        'body':
            'El mantenimiento preventivo para Empresa ABC ha sido completado',
        'type': 'task_completed',
        'read': false,
        'createdAt': Timestamp.now(),
      });

      // 8. Crear reports
      await _firestore.collection('reports').doc('rep_2023_11').set({
        'reportID': 'rep_2023_11',
        'type': 'tareas_mensuales',
        'dateRange': 'Noviembre 2023',
        'data': {
          'total_tareas': 15,
          'completadas': 10,
          'pendientes': 3,
          'en_progreso': 2,
        },
        'createdAt': Timestamp.now(),
      });

      // 9. Crear statistics
      await _firestore.collection('statistics').doc('stats_2023_11').set({
        'statisticID': 'stats_2023_11',
        'metric': 'tareas_mensuales',
        'value': 15,
        'date': Timestamp.fromDate(DateTime(2023, 11, 30)),
      });

      // 10. Crear settings (con defaultEmailTemplate)
      await _firestore.collection('settings').doc('app_config').set({
        'settingsID': 'app_config',
        'companyName': 'CheckJob Taller Mecánico',
        'createdAt': Timestamp.now(),
        'defaultEmailTemplate':
            'Estimado cliente, su trabajo ha sido completado.',
      });

      // 11. Crear audit_logs como subcolección bajo settings/app_config
      await _firestore
          .collection('settings')
          .doc('app_config')
          .collection('audit_logs')
          .doc('log_001')
          .set({
            'auditLogID': 'log_001',
            'action': 'database_initialized',
            'actorID': 'admin_001',
            'target': 'complete_database',
            'timestamp': Timestamp.now(),
          });

      print(
        '🎉 Base de datos inicializada con la estructura solicitada (12 colecciones/subcolecciones).',
      );
    } catch (e, st) {
      print('❌ Error durante inicialización limpia: $e');
      print(st);
    }
  }

  /// Borra todos los documentos de una colección raíz.
  /// Si la colección tiene muchos documentos, se hace en batches de tamaño _batchLimit.
  Future<void> _deleteAllDocsInCollection(String collectionPath) async {
    final collRef = _firestore.collection(collectionPath);

    while (true) {
      final snapshot = await collRef.limit(_batchLimit).get();
      if (snapshot.docs.isEmpty) break;

      final WriteBatch batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Si la colección es 'tasks' o 'settings', también intentamos borrar subcolecciones por doc:
      if (collectionPath == 'tasks') {
        // Para cada doc que hemos eliminado, intentamos borrar 'task_comments'
        // (Nota: si la doc ya fue borrada, no podremos acceder; por seguridad,
        //  iteramos sobre snapshot.docs antes de borrarlos para limpiar subcolecciones).
        // Sin embargo, ya borramos los docs; aquí repetimos borrado de subcolecciones
        // por si existen docs nuevos. Llamamos a función auxiliar.
        await _deleteTaskCommentsSubcollections();
      } else if (collectionPath == 'settings') {
        await _deleteAuditLogsUnderSettings();
      }
    }
  }

  /// Busca todos los documentos en 'tasks' y borra la subcolección 'task_comments' si existe.
  Future<void> _deleteTaskCommentsSubcollections() async {
    final tasksSnapshot = await _firestore.collection('tasks').get();
    for (final taskDoc in tasksSnapshot.docs) {
      final commentsRef = taskDoc.reference.collection('task_comments');
      // Borrar en batches
      while (true) {
        final commentsSnap = await commentsRef.limit(_batchLimit).get();
        if (commentsSnap.docs.isEmpty) break;
        final WriteBatch batch = _firestore.batch();
        for (final c in commentsSnap.docs) {
          batch.delete(c.reference);
        }
        await batch.commit();
      }
    }
  }

  /// Borra audit_logs bajo settings/app_config (si existe)
  Future<void> _deleteAuditLogsUnderSettings() async {
    final settingsDocRef = _firestore.collection('settings').doc('app_config');
    final auditRef = settingsDocRef.collection('audit_logs');

    while (true) {
      final snap = await auditRef.limit(_batchLimit).get();
      if (snap.docs.isEmpty) break;
      final WriteBatch batch = _firestore.batch();
      for (final d in snap.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }
  }
}
