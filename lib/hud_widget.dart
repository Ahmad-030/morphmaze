import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'game_engine.dart';

class HudWidget extends StatelessWidget {
  final GameEngine engine;
  final VoidCallback onPause;

  const HudWidget({super.key, required this.engine, required this.onPause});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildStat('SCORE', '${engine.score}', AppTheme.accent),
          const SizedBox(width: 12),
          _buildStat('LEVEL', '${engine.level}', AppTheme.neonPurple),
          const Spacer(),
          _buildStat('BEST', '${engine.highScore}', AppTheme.neonYellow),
          const SizedBox(width: 12),
          _buildPauseBtn(),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: GoogleFonts.rajdhani(
                  fontSize: 10,
                  color: color.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5)),
          Text(value,
              style: GoogleFonts.orbitron(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.w900,
                  shadows: [Shadow(color: color.withOpacity(0.6), blurRadius: 8)])),
        ],
      ),
    );
  }

  Widget _buildPauseBtn() {
    return GestureDetector(
      onTap: onPause,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.bgCard,
          border: Border.all(color: AppTheme.wallBorder, width: 1.5),
        ),
        child: const Icon(Icons.pause_rounded, color: AppTheme.textPrimary, size: 20),
      ),
    );
  }
}