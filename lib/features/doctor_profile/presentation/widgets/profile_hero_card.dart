import 'package:flutter/material.dart';
import '../../../../core/theme/clinical_tokens.dart';
import '../../data/models/doctor_profile_data.dart';
import 'profile_stats_strip.dart';
import 'profile_title_bar.dart';

/// Full-bleed Hero header for Doctor Profile screen:
/// - Full-width, extends behind status bar, bottom corners rounded (radius 28).
/// - Blue gradient background with faint white ECG line across upper area.
/// - Top row: "Profile" (15 medium, on-primary) + 34px translucent-white circle pencil button.
/// - Left column (~56% width, 16px left padding):
///   * "Verified" chip with check-badge icon (shown only when verified)
///   * Name at 22 medium on two lines (inline-editable in edit mode)
///   * Specialty at 12, 90% opacity (inline-editable in edit mode)
///   * Facility at 12, 75% opacity (inline-editable in edit mode)
///   * Masked "Reg. No. ***XXX" chip
/// - Right side: Doctor photo right-aligned and bottom-anchored, bleeding off edges with soft left fade.
/// - Fallback: Faded person silhouette when no photo is provided.
/// - Camera button: 36px translucent-white circle at bottom-right of photo, shown ONLY in edit mode.
/// - Stats panel: Frosted glass panel inside hero, 12px from left, right, bottom edges.
class ProfileHeroCard extends StatelessWidget {
  final DoctorProfileDetails details;
  final DoctorStats? stats;
  final bool isEditing;
  final TextEditingController nameController;
  final TextEditingController specialtyController;
  final TextEditingController facilityController;
  final VoidCallback onChangePhoto;
  final VoidCallback? onToggleEdit;
  final bool? showCameraButton;

  const ProfileHeroCard({
    super.key,
    required this.details,
    this.stats,
    required this.isEditing,
    required this.nameController,
    required this.specialtyController,
    required this.facilityController,
    required this.onChangePhoto,
    this.onToggleEdit,
    this.showCameraButton,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    // Height ~350 plus top safe-area inset (about 45% of screen height; min 340, max 460)
    final heroHeight = (screenHeight * 0.45).clamp(340.0, 460.0) + topInset;

    // Camera button is shown ONLY in edit mode (or if explicitly enabled)
    final shouldShowCamera = showCameraButton ?? isEditing;

    return Container(
      width: double.infinity,
      height: heroHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tokens.primary,
            const Color(0xFF2C5FC9),
          ],
        ),
        // Only the bottom corners are rounded (radius 28)
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: tokens.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // 1. Decorative faint heartbeat (ECG) line across the upper area
            Positioned(
              left: 0,
              right: 0,
              top: topInset + 40.0,
              height: 70.0,
              child: IgnorePointer(
                child: CustomPaint(
                  size: Size(screenWidth, 70.0),
                  painter: const EcgLinePainter(),
                ),
              ),
            ),

            // 2. Doctor Photo: right-aligned and bottom-anchored, bleeding off right and bottom edges
            Positioned(
              right: 0,
              bottom: 0,
              top: topInset + 46.0,
              width: screenWidth * 0.46,
              child: _buildPhoto(tokens),
            ),

            // 3. Top Title Row: "Profile" top-left + 34px translucent pencil button top-right
            Positioned(
              left: 16,
              right: 16,
              top: topInset + 8.0,
              child: ProfileTitleBar(
                isEditing: isEditing,
                onToggleEdit: onToggleEdit ?? () {},
                inHero: true,
              ),
            ),

            // 4. Left Column (~56% width, 16px left padding, below the title row)
            Positioned(
              left: 16,
              top: topInset + 56.0,
              width: screenWidth * 0.54,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                    // "Verified" chip with check-badge icon (shown only when verified)
                    if (details.isVerified) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.30),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 13,
                              color: tokens.onPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: tokens.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Doctor Name at 22 medium on two lines (or TextField when editing)
                    if (!isEditing)
                      Text(
                        details.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: tokens.onPrimary,
                          height: 1.15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      TextField(
                        controller: nameController,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: tokens.onPrimary,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: tokens.onPrimary.withValues(alpha: 0.6),
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: tokens.onPrimary),
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),

                    // Specialty: 12, 90% opacity
                    if (!isEditing)
                      Text(
                        details.specialty,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: tokens.onPrimary.withValues(alpha: 0.90),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      TextField(
                        controller: specialtyController,
                        style: TextStyle(
                          fontSize: 12,
                          color: tokens.onPrimary.withValues(alpha: 0.90),
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 2),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: tokens.onPrimary.withValues(alpha: 0.4),
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: tokens.onPrimary),
                          ),
                        ),
                      ),
                    const SizedBox(height: 2),

                    // Facility: 12, 75% opacity
                    if (!isEditing)
                      Text(
                        details.facility,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: tokens.onPrimary.withValues(alpha: 0.75),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      TextField(
                        controller: facilityController,
                        style: TextStyle(
                          fontSize: 12,
                          color: tokens.onPrimary.withValues(alpha: 0.75),
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 2),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: tokens.onPrimary.withValues(alpha: 0.4),
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: tokens.onPrimary),
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),

                    // "Reg. No." chip: masked as before, translucent white, radius 10, text 11
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.30),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        details.maskedRegistrationNumber,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: tokens.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // 5. Camera button: shown ONLY in edit mode, 36px translucent-white circle at bottom-right of photo
            if (shouldShowCamera)
              Positioned(
                right: 16,
                bottom: 84.0, // Above frosted stats panel
                child: Semantics(
                  button: true,
                  label: 'Change profile photo',
                  child: InkWell(
                    onTap: onChangePhoto,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.30),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.50),
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 18,
                          color: tokens.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 6. Stats panel: INSIDE the hero, 12px from left, right, bottom edges, radius 16, frosted glass
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: ProfileStatsStrip(
                stats: stats ??
                    const DoctorStats(
                      experienceYears: 12,
                      totalPatients: 1240,
                      totalConsults: 3860,
                    ),
                isFrosted: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoto(ClinicalTokens tokens) {
    final photoUrl = details.photoUrl;

    Widget photoWidget;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
        photoWidget = Image.network(
          photoUrl,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (context, error, stackTrace) => _buildFallbackSilhouette(),
        );
      } else {
        photoWidget = Image.asset(
          photoUrl,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (context, error, stackTrace) => _buildFallbackSilhouette(),
        );
      }
    } else {
      photoWidget = _buildFallbackSilhouette();
    }

    // Soft fade on its left edge so it blends into the gradient
    return ShaderMask(
      shaderCallback: (rect) {
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.0, 0.32, 1.0],
          colors: [
            Colors.transparent,
            Colors.white,
            Colors.white,
          ],
        ).createShader(rect);
      },
      blendMode: BlendMode.dstIn,
      child: photoWidget,
    );
  }

  Widget _buildFallbackSilhouette() {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Icon(
        Icons.person_rounded,
        size: 160,
        color: Colors.white.withValues(alpha: 0.16),
      ),
    );
  }
}

/// Decorative ECG Heartbeat line painter across upper area of hero.
class EcgLinePainter extends CustomPainter {
  const EcgLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.20)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final y = size.height * 0.45;
    final w = size.width;

    path.moveTo(0, y);
    // Left baseline
    path.lineTo(w * 0.36, y);
    // P wave (small bump)
    path.lineTo(w * 0.385, y - 5);
    path.lineTo(w * 0.405, y);
    // Q dip
    path.lineTo(w * 0.415, y + 6);
    // R spike (tall upward peak)
    path.lineTo(w * 0.435, y - 44);
    // S dip (deep downward spike)
    path.lineTo(w * 0.455, y + 20);
    // Return to baseline
    path.lineTo(w * 0.470, y);
    // T wave (gentle curve)
    path.quadraticBezierTo(w * 0.490, y - 10, w * 0.510, y);
    // Baseline across to right edge
    path.lineTo(w, y);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
