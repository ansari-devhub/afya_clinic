import '../../config/app_assets.dart';

/// Data model representing an onboarding carousel slide.
class OnboardingSlideData {
  final String title;
  final String subtitle;
  final String imageAsset;

  const OnboardingSlideData({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
  });
}

/// The 5 onboarding slides content for Afya Clinic.
const List<OnboardingSlideData> onboardingSlides = [
  OnboardingSlideData(
    title: 'Book in seconds',
    subtitle: 'Pick a doctor and a time that suits you. No queues.',
    imageAsset: AppAssets.onboarding1,
  ),
  OnboardingSlideData(
    title: 'See a doctor from home',
    subtitle: 'Video consultations with licensed doctors, wherever you are.',
    imageAsset: AppAssets.onboarding2,
  ),
  OnboardingSlideData(
    title: 'Your records, in your pocket',
    subtitle: 'Prescriptions, lab results and visit history, all in one place.',
    imageAsset: AppAssets.onboarding3,
  ),
  OnboardingSlideData(
    title: 'Never miss a dose',
    subtitle: 'Smart reminders for medication and follow-up visits.',
    imageAsset: AppAssets.onboarding4,
  ),
  OnboardingSlideData(
    title: 'Pay your way',
    subtitle: 'Settle bills with M-Pesa or your insurance cover, right in the app.',
    imageAsset: AppAssets.onboarding5,
  ),
];
