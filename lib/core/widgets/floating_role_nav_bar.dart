import 'package:flutter/material.dart';
import '../theme/clinical_tokens.dart';

/// Navigation item model for [FloatingRoleNavBar].
class RoleNavItem {
  final IconData icon;
  final String label;
  final String? semanticLabel;

  const RoleNavItem({
    required this.icon,
    required this.label,
    this.semanticLabel,
  });
}

/// Floating pill bottom navigation bar for clinical app roles.
///
/// Spec:
/// - Floating pill, filled primary, radius 30, ~62px tall, 14px side margin from screen edge.
/// - 4 tabs in order: Dashboard, Schedule, Patients, Profile.
/// - The ACTIVE tab lifts above the bar as a 44px circle (surface color with a 3px surface ring, primary icon),
///   its label sits inside the bar below the circle in on-primary medium weight.
/// - Inactive tabs: on-primary icon and label at ~80% opacity.
/// - Minimum 44px touch targets per tab.
class FloatingRoleNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<RoleNavItem> items;
  final Animation<double>? barSlideAnimation;
  final Animation<double>? activeCircleScaleAnimation;
  final Animation<double>? labelsFadeAnimation;

  const FloatingRoleNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = defaultDoctorTabs,
    this.barSlideAnimation,
    this.activeCircleScaleAnimation,
    this.labelsFadeAnimation,
  });

  static const List<RoleNavItem> defaultDoctorTabs = [
    RoleNavItem(
      icon: Icons.grid_view_outlined,
      label: 'Dashboard',
      semanticLabel: 'Dashboard Tab',
    ),
    RoleNavItem(
      icon: Icons.calendar_today_outlined,
      label: 'Schedule',
      semanticLabel: 'Schedule Tab',
    ),
    RoleNavItem(
      icon: Icons.people_outline_rounded,
      label: 'Patients',
      semanticLabel: 'Patients Tab',
    ),
    RoleNavItem(
      icon: Icons.person_outline_rounded,
      label: 'Profile',
      semanticLabel: 'Profile Tab',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = ClinicalTokens.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    // Total height accounts for the lifted active circle (-16px above the 62px bar)
    const barHeight = 62.0;
    const liftOffset = 14.0;
    const totalHeight = barHeight + liftOffset;

    final navBarWidget = Padding(
      padding: EdgeInsets.only(
        left: ClinicalTokens.screenSidePadding,
        right: ClinicalTokens.screenSidePadding,
        bottom: bottomInset > 0 ? bottomInset + 4 : 14.0,
      ),
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Pill container background
            Container(
              height: barHeight,
              decoration: BoxDecoration(
                color: tokens.primary,
                borderRadius: BorderRadius.circular(ClinicalTokens.radiusBottomNav),
                boxShadow: [
                  BoxShadow(
                    color: tokens.primary.withValues(alpha: 0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isActive = index == currentIndex;

                  return Expanded(
                    child: Semantics(
                      button: true,
                      selected: isActive,
                      label: item.semanticLabel ?? item.label,
                      child: InkWell(
                        onTap: () => onTap(index),
                        borderRadius: BorderRadius.circular(ClinicalTokens.radiusBottomNav),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 44),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                               if (isActive) ...[
                                 // Space placeholder for the lifted active circle
                                 const SizedBox(height: 22),
                                 _buildLabel(
                                   item.label,
                                   tokens.navLabelStyle.copyWith(
                                     fontWeight: FontWeight.w600,
                                     color: tokens.onPrimary,
                                   ),
                                 ),
                               ] else ...[
                                 Icon(
                                   item.icon,
                                   size: ClinicalTokens.defaultIconSize,
                                   color: tokens.onPrimary.withValues(alpha: 0.80),
                                 ),
                                 const SizedBox(height: 4),
                                 _buildLabel(
                                   item.label,
                                   tokens.navLabelStyle.copyWith(
                                     color: tokens.onPrimary.withValues(alpha: 0.80),
                                   ),
                                 ),
                               ],
                             ],
                           ),
                         ),
                       ),
                     ),
                   );
                 }),
               ),
             ),

             // Active tab lifted 44px circle
             Positioned(
               top: 0,
               left: 0,
               right: 0,
               child: Row(
                 children: List.generate(items.length, (index) {
                   final isActive = index == currentIndex;
                   if (!isActive) {
                     return const Expanded(child: SizedBox());
                   }

                   return Expanded(
                     child: Center(
                       child: GestureDetector(
                         onTap: () => onTap(index),
                         child: _buildActiveCircle(tokens, items[index].icon),
                       ),
                     ),
                   );
                 }),
               ),
             ),
           ],
         ),
       ),
     );

    if (barSlideAnimation == null) return navBarWidget;

    return AnimatedBuilder(
      animation: barSlideAnimation!,
      builder: (context, child) {
        final val = barSlideAnimation!.value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 40.0 * (1.0 - val)),
          child: child,
        );
      },
      child: navBarWidget,
    );
  }

  Widget _buildLabel(String label, TextStyle style) {
    final textWidget = Text(label, style: style);
    if (labelsFadeAnimation == null) return textWidget;
    return AnimatedBuilder(
      animation: labelsFadeAnimation!,
      builder: (context, child) => Opacity(
        opacity: labelsFadeAnimation!.value.clamp(0.0, 1.0),
        child: child,
      ),
      child: textWidget,
    );
  }

  Widget _buildActiveCircle(ClinicalTokens tokens, IconData icon) {
    final circleWidget = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: tokens.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: tokens.surface,
          width: 3.0,
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
          icon,
          size: ClinicalTokens.defaultIconSize + 2,
          color: tokens.primary,
        ),
      ),
    );

    if (activeCircleScaleAnimation == null) return circleWidget;

    return AnimatedBuilder(
      animation: activeCircleScaleAnimation!,
      builder: (context, child) {
        final progress = activeCircleScaleAnimation!.value;
        final scale = (0.6 + 0.4 * progress).clamp(0.0, 1.2);
        final opacity = progress.clamp(0.0, 1.0);
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: circleWidget,
    );
  }
}
