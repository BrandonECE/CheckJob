// lib/domain/services/client_service.dart
import 'package:check_job/domain/entities/client_entity.dart';
import 'package:check_job/domain/entities/enities.dart';


abstract class ClientService {
  Stream<List<ClientEntity>> getClients();
  Future<List<ClientEntity>> getClientsOnce();
  Future<void> createClient(ClientEntity client);
  Future<void> updateClient(ClientEntity client);
  Future<void> deleteClient(String clientID);
  Stream<List<TaskEntity>> getClientTasks(String clientID);
  Future<bool> isClientActive(String clientID);
  Future<ClientEntity> getClientWithTasks(String clientID);
}

