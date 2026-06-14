import 'package:flutter/material.dart';

// MARK: - Grid Info Cards Component
class InfoCard extends StatelessWidget {
  final Color backgroundColor;
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color textColor;
  final bool isUpcomingCard;

  const InfoCard({
    super.key,
    required this.backgroundColor,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.textColor,
    this.isUpcomingCard = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Icon(icon, size: isUpcomingCard ? 28 : 50, color: iconColor),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isUpcomingCard ? Colors.white70 : Colors.indigo.shade700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: isUpcomingCard ? 18 : 26,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}