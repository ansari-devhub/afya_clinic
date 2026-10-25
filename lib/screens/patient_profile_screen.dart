import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/patient_model.dart';

class PatientProfileScreen extends StatelessWidget {
  final String patientId;

  const PatientProfileScreen({
    super.key,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    // Demo data - in production, fetch from Firebase
    final patient = PatientModel(
      id: patientId,
      mrn: 'MRN-84920',
      name: 'Eleanor M. Vance',
      dob: DateTime(1968, 3, 14),
      gender: Gender.female,
      status: PatientStatus.critical,
      department: 'Cardiology',
      bloodType: 'A+',
      heartRate: 72,
      weight: 142,
      height: '5\'6"',
      allergies: ['Penicillin (Severe Anaphylaxis)', 'Latex (Mild Rash)'],
      chronicConditions: ['Type 2 Diabetes', 'Hypertension'],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Center'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppTheme.primary,
                            child: const Icon(Icons.person, size: 40, color: AppTheme.onPrimary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patient.name,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                                  ),
                                  child: Text(
                                    '#${patient.mrn}',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: AppTheme.primary,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'DOB: Mar 14, 1968 (${patient.age} y/o) • ${patient.genderString}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      const Divider(),
                      const SizedBox(height: AppTheme.spacingMd),
                      Row(
                        children: [
                          Expanded(child: _buildVitalCard(context, 'Blood Type', patient.bloodType ?? 'N/A', Icons.bloodtype, AppTheme.error)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildVitalCard(context, 'Heart Rate', '${patient.heartRate} bpm', Icons.favorite, AppTheme.secondary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildVitalCard(context, 'Weight', '${patient.weight} lbs', Icons.monitor_weight, AppTheme.primary)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildVitalCard(context, 'Height', patient.height ?? 'N/A', Icons.height, AppTheme.tertiary)),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.note_add, size: 20),
                              label: const Text('New Note'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.edit, size: 20),
                              label: const Text('Prescribe'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.science, size: 20),
                              label: const Text('Order Lab'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildSection(
              context,
              'Allergies & Alerts',
              Icons.warning,
              AppTheme.error,
              true,
              Column(
                children: patient.allergies.map((allergy) {
                  final isSevere = allergy.contains('Severe');
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSevere ? AppTheme.error : AppTheme.errorContainer,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      allergy,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isSevere ? AppTheme.onError : AppTheme.onErrorContainer,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  );
                }).toList(),
              ),
            ),
            _buildSection(
              context,
              'Chronic Conditions',
              Icons.medical_information,
              AppTheme.primary,
              false,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: patient.chronicConditions.map((condition) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          condition,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Diagnosed: ${condition == 'Type 2 Diabetes' ? '2018' : '2020'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            _buildSection(
              context,
              'Visit Timeline',
              Icons.history,
              AppTheme.primary,
              false,
              Column(
                children: [
                  _buildTimelineItem(
                    context,
                    'Cardiology Consult',
                    'Dr. H. Smith • Dept of Cardiology',
                    'Patient reports decreased shortness of breath after adjusting Lisinopril dosage. BP steady at 125/80. Scheduled follow-up in 6 months.',
                    'Oct 24, 2023',
                  ),
                  _buildTimelineItem(
                    context,
                    'Annual Routine Physical',
                    'Dr. M. Lee • General Practice',
                    '',
                    'Jan 15, 2023',
                  ),
                  _buildTimelineItem(
                    context,
                    'Lab Work (Lipid Panel)',
                    '',
                    '',
                    'Jan 10, 2023',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
    bool isExpanded,
    Widget content,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: 4),
      child: Card(
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: isExpanded,
            leading: Icon(icon, color: iconColor),
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: content,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    String title,
    String subtitle,
    String description,
    String date,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Text(
                date,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
