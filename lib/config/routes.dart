import 'package:check_job/presentation/bindings/admin_panel_binding.dart';
import 'package:check_job/presentation/bindings/admin_task_binding.dart';
import 'package:check_job/presentation/bindings/audit_log_binding.dart';
import 'package:check_job/presentation/bindings/client_binding.dart';
import 'package:check_job/presentation/bindings/dashboard_binding.dart';
import 'package:check_job/presentation/bindings/employee_binding.dart';
import 'package:check_job/presentation/bindings/invoice_binding.dart';
import 'package:check_job/presentation/bindings/material_binding.dart';
import 'package:check_job/presentation/bindings/notification_binding.dart';
import 'package:check_job/presentation/bindings/profile_binding.dart';
import 'package:check_job/presentation/bindings/report_binding.dart';
import 'package:check_job/presentation/bindings/statistics_binding.dart';
import 'package:check_job/presentation/bindings/user_task_binding.dart';
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
    _myAdminLoginView(),
    _myAdminPanelView(),
    _myCreateTaskView(),
    _myTaskListView(),
    _myAdminTaskDetailView(),
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
    _myStatisticsView(),
    _myNotificationsView(),
    _myProfileView(),
    _myAuditLogsView(),
  ];

  // Métodos para cada ruta
static GetPage<dynamic> _myTaskLookUpView() {
  return GetPage(
    name: myTaskLookUpView,
    page: () => MyTaskLookUpView(),
    binding: UserTaskBinding(),
    transition: Transition.upToDown,
    transitionDuration: const Duration(milliseconds: 460),
    curve: Curves.fastLinearToSlowEaseIn,
  );
}

static GetPage<dynamic> _myUserTaskDetailView() {
  return GetPage(
    name: myUserTaskDetailView,
    page: () => const MyUserTaskDetailView(),
    binding: UserTaskBinding(),
    transition: Transition.downToUp,
    transitionDuration: const Duration(milliseconds: 460),
    curve: Curves.fastLinearToSlowEaseIn,
  );
}

  static GetPage<dynamic> _myAdminLoginView() {
    return GetPage(
      name: myAdminLoginView,
      page: () => MyAdminLoginView(), // Quita el const
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myAdminPanelView() {
    return GetPage(
      name: myAdminPanelView,
      bindings: [AdminPanelBinding(), NotificationBinding()],
      page: () => MyAdminPanelView(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myCreateTaskView() {
    return GetPage(
      name: myCreateTaskView,
      bindings: [AuditLogBinding(), ClientBinding(), MaterialBinding(), EmployeeBinding(), AdminTaskBinding()],
      page: () => const MyCreateTaskView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myTaskListView() {
    return GetPage(
      name: myTaskListView,
      bindings: [AuditLogBinding(), MaterialBinding() ,AdminTaskBinding()],
      page: () => const MyTaskListView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myAdminTaskDetailView() {
    return GetPage(
      name: myAdminTaskDetailView,
      bindings: [AuditLogBinding(), MaterialBinding() ,AdminTaskBinding()],
      page: () => const MyAdminTaskDetailView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

// En tu routes.dart, actualiza las rutas de empleados:
static GetPage<dynamic> _myEmployeesView() {
  return GetPage(
    name: myEmployeesView,
    page: () => MyEmployeesView(),
    bindings: [AuditLogBinding(), EmployeeBinding()], // Agregar el binding
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 460),
    curve: Curves.fastLinearToSlowEaseIn,
  );
}

static GetPage<dynamic> _myEmployeePortalView() {
  return GetPage(
    name: myEmployeePortalView,
    page: () => MyEmployeePortalView(),
    bindings: [AuditLogBinding(), EmployeeBinding()], // Agregar el binding

    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 460),
    curve: Curves.fastLinearToSlowEaseIn,
  );
}

static GetPage<dynamic> _myCreateEmployeeView() {
  return GetPage(
    name: myCreateEmployeeView,
    page: () => MyCreateEmployeeView(),
    bindings: [AuditLogBinding(), EmployeeBinding()], // Agregar el binding
    transition: Transition.downToUp,
    transitionDuration: const Duration(milliseconds: 460),
    curve: Curves.fastLinearToSlowEaseIn,
  );
}
  // Nuevos métodos para las rutas adicionales
  static GetPage<dynamic> _myDashboardView() {
    return GetPage(
      name: myDashboardView,
      binding: DashboardBinding(),
      page: () => const MyDashboardView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myClientsView() {
    return GetPage(
      name: myClientsView,
       bindings: [AuditLogBinding(), ClientBinding()],
      page: () => MyClientsView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myClientPortalView() {
    return GetPage(
      name: myClientPortalView,
        bindings: [AuditLogBinding(), ClientBinding()],
      page: () => MyClientPortalView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myCreateClientView() {
    return GetPage(
      name: myCreateClientView,
          bindings: [AuditLogBinding(), ClientBinding()],
      page: () => MyCreateClientView(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  // En routes.dart
  static GetPage<dynamic> _myMaterialsView() {
    return GetPage(
      name: myMaterialsView,
      page: () => MyMaterialsView(),
      bindings: [AuditLogBinding(), MaterialBinding()],
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myCreateMaterialView() {
    return GetPage(
      name: myCreateMaterialView,
      page: () => MyCreateMaterialView(),
      bindings: [AuditLogBinding(), MaterialBinding()],
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myMaterialPortalView() {
    return GetPage(
      name: myMaterialPortalView,
      page: () => MyMaterialPortalView(),
      bindings: [AuditLogBinding(), MaterialBinding()],
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

static GetPage<dynamic> _myInvoicesView() {
  return GetPage(
    name: myInvoicesView,
    page: () => MyInvoicesView(),
    bindings: [AuditLogBinding(), InvoiceBinding()],
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 460),
    curve: Curves.fastLinearToSlowEaseIn,
  );
}

static GetPage<dynamic> _myInvoicePortalView() {
  return GetPage(
    name: myInvoicePortalView,
    page: () => MyInvoicePortalView(),
    bindings: [AuditLogBinding(), InvoiceBinding()],
    transition: Transition.rightToLeft,
    transitionDuration: const Duration(milliseconds: 460),
    curve: Curves.fastLinearToSlowEaseIn,
  );
}
  static GetPage<dynamic> _myReportsView() {
    return GetPage(
      name: myReportsView,
      bindings: [AuditLogBinding(), ReportBinding()],
      page: () => MyReportsView(),
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

  static GetPage<dynamic> _myStatisticsView() {
    return GetPage(
      name: myStatisticsView,
      binding: StatisticBinding(),
      page: () => const MyStatisticsView(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  // En routes.dart
  static GetPage<dynamic> _myNotificationsView() {
    return GetPage(
      name: myNotificationsView,
      page: () => MyNotificationsView(),
      binding: NotificationBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  static GetPage<dynamic> _myProfileView() {
    return GetPage(
      name: myProfileView,
      binding: ProfileBinding(),
      page: () => MyProfileView(), // Quita el const
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  // En routes.dart
  static GetPage<dynamic> _myAuditLogsView() {
    return GetPage(
      name: myAuditLogsView,
      page: () => MyAuditLogsView(),
      binding: AuditLogBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 460),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }
}
