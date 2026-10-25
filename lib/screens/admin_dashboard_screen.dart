import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primary,
                child: const Icon(Icons.admin_panel_settings, size: 20, color: AppTheme.onPrimary),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        title: const Text('Medical Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildDashboardView() : Container(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavItem(icon: Icons.dashboard, label: 'Dashboard'),
          BottomNavItem(icon: Icons.group, label: 'Patients'),
          BottomNavItem(icon: Icons.calendar_month, label: 'Schedule'),
          BottomNavItem(icon: Icons.chat, label: 'Messages'),
        ],
      ),
    );
  }

  Widget _buildDashboardView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Admin Analytics & Operations Dashboard',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download, size: 20),
            label: const Text('Export Report'),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          _buildRevenueCard(),
          const SizedBox(height: AppTheme.spacingMd),
          _buildStatCard('Staff Active', '24', Icons.badge, null),
          const SizedBox(height: AppTheme.spacingMd),
          _buildStatCard('Bed Occupancy', '85%', Icons.bed, 'High', 0.85),
          const SizedBox(height: AppTheme.spacingMd),
          _buildStatCard('Avg Wait Time', '14m', Icons.schedule, null),
          const SizedBox(height: AppTheme.spacingLg),
          _buildTopDiagnosesCard(),
          const SizedBox(height: AppTheme.spacingLg),
          _buildCriticalAlertsCard(),
        ],
      ),
    );
  }

  Widget _buildRevenueCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Revenue Summary',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up, size: 14, color: AppTheme.secondary),
                      const SizedBox(width: 4),
                      Text(
                        '+12.5%',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Weekly performance metrics',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 200,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          return Text(
                            days[value.toInt()],
                            style: Theme.of(context).textTheme.labelSmall,
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _buildBarGroup(0, 80),
                    _buildBarGroup(1, 120),
                    _buildBarGroup(2, 110),
                    _buildBarGroup(3, 180),
                    _buildBarGroup(4, 95),
                    _buildBarGroup(5, 140),
                    _buildBarGroup(6, 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: x == 3 ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.3),
          width: 24,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, String? badge, [double? progress]) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
          ),
          child: Icon(icon, color: AppTheme.primary),
        ),
        title: Text(label),
        subtitle: progress != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  if (badge != null)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary,
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Text(
                        badge,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.onSecondary,
                            ),
                      ),
                    ),
                ],
              )
            : Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildTopDiagnosesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Top Diagnoses',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            _buildDiagnosisItem('Upper Respiratory Infection', 142, 1.0),
            _buildDiagnosisItem('Hypertension', 98, 0.69),
            _buildDiagnosisItem('Type 2 Diabetes', 65, 0.46),
            _buildDiagnosisItem('Sprain/Strain', 41, 0.29),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosisItem(String name, int count, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: Theme.of(context).textTheme.bodyMedium),
              Text('$count cases', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.surfaceContainer,
            color: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalAlertsCard() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.error, width: 2),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning, color: AppTheme.error),
                  const SizedBox(width: 8),
                  Text(
                    'Critical Alerts',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.errorContainer,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      '3 Urgent',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.onErrorContainer,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMd),
              _buildAlertItem('ICU Capacity Reached', 'All ICU beds currently occupied. Initiating overflow protocol.'),
              _buildAlertItem('Pharmacy Restock Delayed', 'Delivery of broad-spectrum antibiotics delayed by 24h.'),
              _buildAlertItem('Staffing Shortage - ER', '2 RN call-outs for night shift. Require immediate coverage.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertItem(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: AppTheme.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
