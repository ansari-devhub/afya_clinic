import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
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
                child: const Icon(Icons.local_hospital, size: 20, color: AppTheme.onPrimary),
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
          BottomNavItem(icon: Icons.people, label: 'Patients'),
          BottomNavItem(icon: Icons.calendar_month, label: 'Schedule'),
          BottomNavItem(icon: Icons.message, label: 'Messages'),
          BottomNavItem(icon: Icons.person, label: 'Profile'),
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
            'Hello, John.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Here is an overview of your health dashboard today.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          _buildNextAppointmentCard(),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              Expanded(child: _buildQuickAccessCard(Icons.folder_open, 'Records', 'Medical history')),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(child: _buildQuickAccessCard(Icons.science, 'Lab Results', '2 new available')),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              Expanded(child: _buildQuickAccessCard(Icons.medication, 'Prescriptions', '1 needs refill')),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(child: _buildQuickAccessCard(Icons.receipt_long, 'Billing', 'No balance due')),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            'Recent Updates',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          _buildRecentUpdateItem(
            Icons.science,
            'Blood Test Results Ready',
            'Your recent lipid panel results are now available for review.',
            '2 hours ago',
          ),
          _buildRecentUpdateItem(
            Icons.event_available,
            'Appointment Reminder',
            'Please complete your pre-visit questionnaire before 2:30 PM today.',
            'Yesterday',
          ),
        ],
      ),
    );
  }

  Widget _buildNextAppointmentCard() {
    return Card(
      color: AppTheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'NEXT APPOINTMENT',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    'Confirmed',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.onSecondary,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Cardiology Checkup',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppTheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  'Today, 2:30 PM',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppTheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  'Main Campus, Room 402',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            const Divider(),
            const SizedBox(height: AppTheme.spacingMd),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primary,
                  child: const Icon(Icons.person, color: AppTheme.onPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. Sarah Jenkins',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        'Lead Cardiologist',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text('Check-in'),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.directions, size: 20),
                    label: const Text('Directions'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(IconData icon, String title, String subtitle) {
    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                ),
                child: Icon(icon, color: AppTheme.primary),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentUpdateItem(IconData icon, String title, String subtitle, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
          ),
          child: Icon(icon, color: AppTheme.primary),
        ),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitle),
            const SizedBox(height: 4),
            Text(
              time,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
