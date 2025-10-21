// lib/data/repositories/client_repository_impl.dart
import 'package:check_job/domain/entities/client_entity.dart';
import 'package:check_job/domain/entities/enities.dart';
import 'package:check_job/domain/repositories/client_repository.dart';
import 'package:check_job/domain/services/client_service.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientService _clientService;

  ClientRepositoryImpl({required ClientService clientService})
      : _clientService = clientService;

  @override
  Stream<List<ClientEntity>> getClients() {
    try {
      return _clientService.getClients();
    } catch (e) {
      return Stream.error('Error en repositorio al obtener clientes: $e');
    }
  }

  @override
  Future<List<ClientEntity>> getClientsOnce() async {
    try {
      return await _clientService.getClientsOnce();
    } catch (e) {
      return Future.error('Error en repositorio al obtener clientes: $e');
    }
  }

  @override
  Future<void> createClient(ClientEntity client) async {
    try {
      return await _clientService.createClient(client);
    } catch (e) {
      return Future.error('Error en repositorio al crear cliente: $e');
    }
  }

  @override
  Future<void> updateClient(ClientEntity client) async {
    try {
      return await _clientService.updateClient(client);
    } catch (e) {
      return Future.error('Error en repositorio al actualizar cliente: $e');
    }
  }

  @override
  Future<void> deleteClient(String clientID) async {
    try {
      return await _clientService.deleteClient(clientID);
    } catch (e) {
      return Future.error('Error en repositorio al eliminar cliente: $e');
    }
  }

  @override
  Stream<List<TaskEntity>> getClientTasks(String clientID) {
    try {
      return _clientService.getClientTasks(clientID);
    } catch (e) {
      return Stream.error('Error en repositorio al obtener tareas: $e');
    }
  }

  @override
  Future<bool> isClientActive(String clientID) async {
    try {
      return await _clientService.isClientActive(clientID);
    } catch (e) {
      return Future.error('Error en repositorio al verificar estado: $e');
    }
  }

  @override
  Future<ClientEntity> getClientWithTasks(String clientID) async {
    try {
      return await _clientService.getClientWithTasks(clientID);
    } catch (e) {
      return Future.error('Error en repositorio al obtener cliente con tareas: $e');
    }
  }
}