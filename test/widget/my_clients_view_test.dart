import 'package:check_job/presentation/views/admin_views/admin_home_views/clients_views/clients_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:check_job/domain/entities/client_entity.dart';
import 'package:check_job/domain/entities/enities.dart';

// Fake controller para pruebas
class FakeClientController extends GetxController {
  final RxList<ClientEntity> clients = <ClientEntity>[].obs;
  final RxBool isLoading = false.obs;

  // selectClient lo dejamos como registro de llamada opcional
  String? lastSelectedId;
  Future<void> selectClient(String clientID) async {
    lastSelectedId = clientID;
    // simulamos delay corto si quieres
    await Future.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  testWidgets('Muestra loader, luego lista de clientes y estado Activo/Inactivo', (tester) async {
    // preparar fake controller y datos
    final fake = FakeClientController();
    fake.isLoading.value = true; // al inicio está cargando

    final clientActive = ClientEntity(
      clientID: 'c1',
      name: 'Active User',
      email: 'active@example.com',
      phone: '111111',
      createdAt: DateTime.now(),
      isActive: true,
      tasks: [],
    );

    final clientInactive = ClientEntity(
      clientID: 'c2',
      name: 'Inactive User',
      email: 'inactive@example.com',
      phone: '222222',
      createdAt: DateTime.now(),
      isActive: false,
      tasks: [],
    );

    // renderizar widget pasando el controller fake
    await tester.pumpWidget(
      MaterialApp(
        home: MyClientsView(externalController: fake),
      ),
    );

    // en estado loading debe verse el CircularProgressIndicator
    await tester.pump(); // un frame
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    //  ahora simulamos que llegaron los datos
    fake.clients.assignAll([clientActive, clientInactive]);
    fake.isLoading.value = false;

    // actualizar la UI y esperar a que todo se estabilice
    await tester.pumpAndSettle();

    // ahora el loader NO debe estar
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // y los items sí
    expect(find.text('Active User'), findsOneWidget);
    expect(find.text('Inactive User'), findsOneWidget);

    // comprobar que se muestran las etiquetas Activo/Inactivo
    expect(find.text('Activo'), findsOneWidget);
    expect(find.text('Inactivo'), findsOneWidget);

    // opcional: comprobar que cada card tiene su key
    expect(find.byKey(const Key('client-card-c1')), findsOneWidget);
    expect(find.byKey(const Key('client-card-c2')), findsOneWidget);
  });
}
