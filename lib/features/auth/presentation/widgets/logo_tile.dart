import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../config/app_assets.dart';
import '../../../../core/widgets/neo/neo_card.dart';

/// Raised rounded-square card holding the Afya Clinic app logo.
class LogoTile extends StatelessWidget {
  final double size;
  final double iconSize;

  const LogoTile({
    super.key,
    this.size = 72.0,
    this.iconSize = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: NeoCard(
        width: size,
        height: size,
        borderRadius: BorderRadius.circular(size * 0.28),
        padding: EdgeInsets.zero,
        child: Center(
          child: SvgPicture.asset(
            AppAssets.logo,
            width: iconSize,
            height: iconSize,
          ),
        ),
      ),
    );
  }
}
