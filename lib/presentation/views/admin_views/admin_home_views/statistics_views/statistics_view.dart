// lib/presentation/views/my_statistics_view.dart
import 'package:check_job/presentation/controllers/statistics/statistics_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyStatisticsView extends StatelessWidget {
  const MyStatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final StatisticController controller = Get.find<StatisticController>();
    return Scaffold(
      backgroundColor: _blendWithWhite(context, 0.03),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, controller),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTimeFilters(context, controller),
                      const SizedBox(height: 20),
                      _buildChartsGrid(context, controller),
                      const SizedBox(height: 20),
                      _buildDetailedStats(context, controller),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, StatisticController controller) {
    final color = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(11.5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new, size: 18, color: color),
            ),
          ),
          Text(
            'Estadísticas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Obx(
            () => controller.isLoading.value
                ? Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.7),
                    ),
                  )
                : IconButton(
                    icon: Icon(Icons.refresh, color: color),
                    onPressed: () => controller.refreshStatistics(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilters(
    BuildContext context,
    StatisticController controller,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(
        () => Row(
          children: controller.timeFilters
              .map(
                (filter) => _timeFilterButton(
                  context,
                  filter,
                  controller.selectedTimeFilter.value == filter,
                  controller,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _timeFilterButton(
    BuildContext context,
    String text,
    bool isActive,
    StatisticController controller,
  ) {
    return GestureDetector(
      onTap: () => controller.setTimeFilter(text),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildChartsGrid(
    BuildContext context,
    StatisticController controller,
  ) {
    return Obx(
      () => GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        children: [
          _chartCard(
            context,
            'Tareas Comp.',
            Icons.pie_chart,
            Colors.blue,
            controller.isLoading.value
                ? ''
                : controller.completedTasks.toString(),
            controller,
            'completed_tasks',
          ),
          _chartCard(
            context,
            'Ingresos',
            Icons.bar_chart,
            Colors.green,
            controller.isLoading.value ? '' : controller.formattedMonthlyIncome,
            controller,
            'monthly_income',
          ),
          _chartCard(
            context,
            'Clientes Activos',
            Icons.people,
            Colors.orange,
            controller.isLoading.value
                ? ''
                : controller.activeClients.toString(),
            controller,
            'active_clients',
          ),
          _chartCard(
            context,
            'Productividad',
            Icons.trending_up,
            Colors.purple,
            controller.isLoading.value
                ? ''
                : controller.formattedProductivityIndex,
            controller,
            'productivity_index',
          ),
        ],
      ),
    );
  }

  Widget _chartCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String value,
    StatisticController controller,
    String metricKey,
  ) {
    final isLoading = value.isEmpty;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: isLoading
                    ? SizedBox(
                        key: ValueKey('loading_$metricKey'),
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      )
                    : Text(
                        key: ValueKey(value),
                        value,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Animated comparison line: muestra "cargando" cuando controller.isLoading
          Obx(() {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: controller.isLoading.value
                  ? Align(
                      alignment: Alignment.centerLeft,
                      key: ValueKey('cmp_loading_$metricKey'),
                      child: SizedBox(
                        height: 16,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Comparando...',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Obx(() {
                      final text = controller.comparisonTextForMetric(
                        metricKey,
                      );
                      final c = controller.comparisonColorForMetric(metricKey);
                      return Align(
                        alignment: Alignment.centerLeft,
                        key: ValueKey('cmp_text_$metricKey'),
                        child: SizedBox(
                          height: 16,
                          child: Text(
                            text,
                            style: TextStyle(fontSize: 10, color: c),
                          ),
                        ),
                      );
                    }),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailedStats(
    BuildContext context,
    StatisticController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Métricas Detalladas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Obx(
          () => GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            children: [
              _metricItem(
                context,
                'Tasa de Completación',
                controller.isLoading.value
                    ? ''
                    : controller.formattedCompletionRate,
                Colors.green,
              ),
              _metricItem(
                context,
                'Tiempo Promedio',
                controller.isLoading.value
                    ? ''
                    : controller.formattedAverageTaskTime,
                Colors.blue,
              ),
              _metricItem(
                context,
                'Clientes Satisfechos',
                controller.isLoading.value
                    ? ''
                    : controller.formattedClientSatisfaction,
                Colors.orange,
              ),
              _metricItem(
                context,
                'Tareas Pendientes',
                controller.isLoading.value
                    ? ''
                    : controller.pendingTasks.toString(),
                Colors.purple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricItem(
    BuildContext context,
    String title,
    String value,
    Color color,
  ) {
    final isLoading = value.isEmpty;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            duration: const Duration(milliseconds: 120),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: isLoading
                ? Align(
                    key: ValueKey('metric_loading_$title'),
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ),
                  )
                : Align(
                    key: ValueKey('metric_value_$title'),
                    alignment: Alignment.topLeft,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  static Color _blendWithWhite(BuildContext context, double amount) {
    final primary = Theme.of(context).colorScheme.primary;
    return Color.alphaBlend(primary.withOpacity(amount), Colors.white);
  }
}
