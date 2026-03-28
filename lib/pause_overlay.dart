import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

class PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: AppTheme.bgCard,
            border: Border.all(color: AppTheme.accent.withOpacity(0.4), width: 1.5),
            boxShadow: [BoxShadow(color: AppTheme.accent.withOpacity(0.15), blurRadius: 40)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pause_circle_filled_rounded, color: AppTheme.accent, size: 52),
              const SizedBox(height: 12),
              Text('PAUSED',
                  style: GoogleFonts.orbitron(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                      letterSpacing: 4,
                      shadows: [Shadow(color: AppTheme.accent.withOpacity(0.6), blurRadius: 16)])),
              const SizedBox(height: 28),
              _OverlayBtn(label: 'RESUME', icon: Icons.play_arrow_rounded, color: AppTheme.accent, onTap: onResume),
              const SizedBox(height: 12),
              _OverlayBtn(label: 'RESTART', icon: Icons.replay_rounded, color: AppTheme.neonPurple, onTap: onRestart),
              const SizedBox(height: 12),
              _OverlayBtn(label: 'EXIT TO MENU', icon: Icons.home_rounded, color: AppTheme.textMuted, onTap: onMenu),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverlayBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _OverlayBtn({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: color.withOpacity(0.6), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: color.withOpacity(0.08),
        ),
        icon: Icon(icon, color: color, size: 18),
        label: Text(label,
            style: GoogleFonts.orbitron(
                fontSize: 12, fontWeight: FontWeight.w700, color: color, letterSpacing: 2)),
      ),
    );
  }
}