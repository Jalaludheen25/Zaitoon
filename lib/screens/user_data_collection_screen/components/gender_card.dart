import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zaitoon/constants/color_class.dart';

class GenderCard extends StatelessWidget {
  final String icon; // SVG asset path
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const GenderCard({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 92,
        decoration: BoxDecoration(
          color:
              isSelected ? ColorClass.violet30.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? ColorClass.violet30
                : ColorClass.black87.withOpacity(0.1),
            width: isSelected ? 1 : 0.5,
          ),
         
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              width: 32,
              height: 32,
              color: isSelected
                  ? ColorClass.violet30
                  : ColorClass.black87.withOpacity(0.6),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? ColorClass.violet30
                    : ColorClass.black87.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
