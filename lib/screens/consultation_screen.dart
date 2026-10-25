import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class ConsultationScreen extends StatefulWidget {
  final String patientId;

  const ConsultationScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final _subjectiveController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _assessmentController = TextEditingController();
  final _planController = TextEditingController();
  final List<String> _symptoms = ['Cough', 'Fever'];

  @override
  void dispose() {
    _subjectiveController.dispose();
    _objectiveController.dispose();
    _assessmentController.dispose();
    _planController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('local_hospital'),
            const SizedBox(width: 8),
            const Text('Medical Center'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientHeader(),
            const SizedBox(height: AppTheme.spacingLg),
            _buildSymptoms(),
            const SizedBox(height: AppTheme.spacingLg),
            _buildSOAPSection(
              'Subjective',
              Icons.mic,
              _subjectiveController,
              "Patient's own words...",
            ),
            const SizedBox(height: AppTheme.spacingLg),
            _buildSOAPSection(
              'Objective',
              null,
              _objectiveController,
              'Clinical observations, vitals...',
            ),
            const SizedBox(height: AppTheme.spacingLg),
            _buildAssessmentSection(),
            const SizedBox(height: AppTheme.spacingLg),
            _buildPlanSection(),
            const SizedBox(height: AppTheme.spacingLg),
            _buildVitalsSection(),
            const SizedBox(height: AppTheme.spacingLg),
            _buildSignOffSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          border: Border(
            top: BorderSide(
              color: AppTheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Save Draft'),
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Complete'),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.check_circle, color: AppTheme.onPrimary),
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
              ),
              child: const Center(
                child: Text(
                  'img',
                  style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'John Doe',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary,
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Text(
                          'Active Consult',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.onSecondary,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'DOB: 15 May 1980 (43y) • Male',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptoms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.sick, color: AppTheme.error, size: 20),
            const SizedBox(width: 8),
            Text(
              'Presenting Symptoms',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._symptoms.map((symptom) => Chip(
                  label: Text(symptom),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    setState(() => _symptoms.remove(symptom));
                  },
                )),
            ActionChip(
              avatar: const Icon(Icons.add, size: 16),
              label: const Text('Add Symptom'),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSOAPSection(
    String title,
    IconData? icon,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (icon != null) const Spacer(),
            if (icon != null)
              IconButton(
                icon: const Icon(Icons.mic, size: 20),
                onPressed: () {},
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSm),
        TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: hint,
          ),
        ),
      ],
    );
  }

  Widget _buildAssessmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.search, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Assessment',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSm),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search ICD-10 Diagnosis Codes...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        TextField(
          controller: _assessmentController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Detailed assessment notes...',
          ),
        ),
      ],
    );
  }

  Widget _buildPlanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.assignment, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Plan',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Row(
          children: [
            _buildPlanButton(Icons.medical_services, 'Rx'),
            const SizedBox(width: 8),
            _buildPlanButton(Icons.science, 'Labs'),
            const SizedBox(width: 8),
            _buildPlanButton(Icons.event, 'Follow-up'),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSm),
        TextField(
          controller: _planController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Treatment plan, medications...',
          ),
        ),
      ],
    );
  }

  Widget _buildPlanButton(IconData icon, String label) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildVitalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Vitals',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Row(
          children: [
            Expanded(child: _buildVitalCard('BP', '120/80', 'mmHg')),
            const SizedBox(width: 8),
            Expanded(child: _buildVitalCard('HR', '72', 'bpm')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildVitalCard('Temp', '38.2', '°c')),
            const SizedBox(width: 8),
            Expanded(child: _buildVitalCard('SpO2', '98', '%')),
          ],
        ),
      ],
    );
  }

  Widget _buildVitalCard(String label, String value, String unit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOffSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sign-off',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Container(
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.outline),
            borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
          ),
          child: Center(
            child: TextButton(
              onPressed: () {},
              child: const Text('Sign Here'),
            ),
          ),
        ),
      ],
    );
  }
}
