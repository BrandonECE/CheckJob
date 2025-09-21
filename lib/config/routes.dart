import 'package:check_job/presentation/views/views.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

/// Clase Routes centralizada
class Routes {
  Routes._(); // Evita instanciación

  // Nombres de rutas
  static const myTaskLookUpView = '/myTaskLookUpView';
  static const myAdminLoginView = '/myAdminLoginView';
  static const myAdminPanelView = '/myAdminPanelView';
  static const myCreateTaskView = '/myCreateTaskView';

  static const myEmployeesView = '/myEmployeesView';
  static const myEmployeePortalView = '/myEmployeePortalView';
  static const myCreateEmployeeView = '/myCreateEmployeeView';

  static const myUserTaskDetailView = '/myUserTaskDetailView';
  static const myAdminTaskDetailView = '/myAdminTaskDetailView';
  static const myDashboardView = '/myDashboardView';
  static const myClientsView = '/myClientsView';
  static const myClientPortalView = '/myClientPortalView';
  static const myCreateClientView = '/myCreateClientView';
  static const myMaterialsView = '/myMaterialsView';
  static const myCreateMaterialView = '/myCreateMaterialView';
  static const myMaterialPortalView = '/myMaterialPortalView';
  static const myInvoicesView = '/myInvoicesView';
  static const myInvoicePortalView = '/myInvoicePortalView'; 
  static const myReportsView = '/myReportsView';
  static const mySettingsView = '/mySettingsView';
  static const myTaskListView = '/myTaskListView';
  static const myStatisticsView = '/myStatisticsView';
  static const myNotificationsView = '/myNotificationsView';
  static const myProfileView = '/myProfileView';
  static const myAuditLogsView = '/myAuditLogsView';

  // Listado de rutas con páginas
  static final pages = [
    _myTaskLookUpView(),
    _myUserTaskDetailView(),
    _myAdminTaskDetailView(),
    _myAdminLoginView(),
    _myAdminPanelView(),
    _myCreateTaskView(),
    _myEmployeesView(),
    _myEmployeePortalView(),
    _myCreateEmployeeView(),
    _myDashboardView(),
    _myClientsView(),
    _myClientPortalView(),
    _myCreateClientView(),
    _myMaterialsView(),
    _myCreateMaterialView(),
    _myMaterialPortalView(),
    _myInvoicesView(),
    _myInvoicePortalView(),
    _myReportsView(),
    _mySettingsView(),
    _myTaskListView(),
    _myStatisticsView(),
    _myNotificationsView(),
    _myProfileView(),
    _myAuditLogsView(),
  ];

  // Métodos para cada ruta
  static GetPage<dynamic> _myTaskLookUpView() {
    return GetPage(
      name: myTaskLookUpView,
      page: () => const MyTaskLookUpView(),
      transition: Transition.upToDown,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myUserTaskDetailView() {
    return GetPage(
      name: myUserTaskDetailView,
      page: () => const MyUserTaskDetailView(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myAdminTaskDetailView() {
    return GetPage(
      name: myAdminTaskDetailView,
      page: () => const MyAdminTaskDetailView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myAdminLoginView() {
    return GetPage(
      name: myAdminLoginView,
      page: () => const MyAdminLoginView(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myAdminPanelView() {
    return GetPage(
      name: myAdminPanelView,
      page: () => const MyAdminPanelView(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myCreateTaskView() {
    return GetPage(
      name: myCreateTaskView,
      page: () => const MyCreateTaskView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myEmployeesView() {
    return GetPage(
      name: myEmployeesView,
      page: () => MyEmployeesView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myEmployeePortalView() {
    return GetPage(
      name: myEmployeePortalView,
      page: () => const MyEmployeePortalView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myCreateEmployeeView() {
    return GetPage(
      name: myCreateEmployeeView,
      page: () => const MyCreateEmployeeView(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  // Nuevos métodos para las rutas adicionales
  static GetPage<dynamic> _myDashboardView() {
    return GetPage(
      name: myDashboardView,
      page: () => const MyDashboardView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myClientsView() {
    return GetPage(
      name: myClientsView,
      page: () => const MyClientsView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myClientPortalView() {
    return GetPage(
      name: myClientPortalView,
      page: () => const MyClientPortalView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myCreateClientView() {
    return GetPage(
      name: myCreateClientView,
      page: () => const MyCreateClientView(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myMaterialsView() {
    return GetPage(
      name: myMaterialsView,
      page: () => const MyMaterialsView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myCreateMaterialView() {
    return GetPage(
      name: myCreateMaterialView,
      page: () => const MyCreateMaterialView(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myMaterialPortalView() {
    return GetPage(
      name: myMaterialPortalView,
      page: () => const MyMaterialPortalView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myInvoicesView() {
    return GetPage(
      name: myInvoicesView,
      page: () => const MyInvoicesView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myInvoicePortalView() {
    return GetPage(
      name: myInvoicePortalView,
      page: () => const MyInvoicePortalView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myReportsView() {
    return GetPage(
      name: myReportsView,
      page: () => const MyReportsView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _mySettingsView() {
    return GetPage(
      name: mySettingsView,
      page: () => const MySettingsView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myTaskListView() {
    return GetPage(
      name: myTaskListView,
      page: () => const MyTaskListView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myStatisticsView() {
    return GetPage(
      name: myStatisticsView,
      page: () => const MyStatisticsView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myNotificationsView() {
    return GetPage(
      name: myNotificationsView,
      page: () => const MyNotificationsView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myProfileView() {
    return GetPage(
      name: myProfileView,
      page: () => const MyProfileView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myAuditLogsView() {
    //
    return GetPage(
      name: myAuditLogsView,
      page: () => MyAuditLogsView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }
}
