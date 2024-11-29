import 'package:flutter/material.dart';

class GenderCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String selectedGender;
  final Function(String)? onSelect;
  final bool enabled;

  const GenderCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.selectedGender,
    required this.onSelect,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedGender == value;
    return Expanded(
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: InkWell(
          onTap: enabled ? () => onSelect?.call(value) : null,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: isSelected ? Colors.deepPurpleAccent : Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: Colors.deepPurpleAccent, width: 2)
                  : null,
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
