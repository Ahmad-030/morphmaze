import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

class GameOverOverlay extends StatefulWidget {
  final int score;
  final int highScore;
  final int level;
  final VoidCallback onRetry;
  final VoidCallback onMenu;

  const GameOverOverlay({
    super.key,
    required this.score,
    required this.highScore,
    required this.level,
    required this.onRetry,
    required this.onMenu,
  });

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _isNewRecord => widget.score >= widget.highScore && widget.score > 0;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        color: Colors.black.withOpacity(0.82),
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: AppTheme.bgCard,
                border: Border.all(color: AppTheme.neonPink.withOpacity(0.5), width: 1.5),
                boxShadow: [BoxShadow(color: AppTheme.neonPink.withOpacity(0.2), blurRadius: 40)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isNewRecord) _buildNewRecord(),
                  const SizedBox(height: 8),
                  Text('GAME OVER',
                      style: GoogleFonts.orbitron(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.neonPink,
                          letterSpacing: 3,
                          shadows: [Shadow(color: AppTheme.neonPink.withOpacity(0.7), blurRadius: 20)])),
                  const SizedBox(height: 24),
                  _buildStatRow('SCORE', widget.score, AppTheme.accent),
                  const SizedBox(height: 10),
                  _buildStatRow('BEST', widget.highScore, AppTheme.neonYellow),
                  const SizedBox(height: 10),
                  _buildStatRow('LEVEL', widget.level, AppTheme.neonPurple),
                  const SizedBox(height: 28),
                  _ActionBtn(
                      label: 'RETRY',
                      icon: Icons.replay_rounded,
                      color: AppTheme.accent,
                      isPrimary: true,
                      onTap: widget.onRetry),
                  const SizedBox(height: 12),
                  _ActionBtn(
                      label: 'MAIN MENU',
                      icon: Icons.home_rounded,
                      color: AppTheme.textMuted,
                      onTap: widget.onMenu),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewRecord() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: [AppTheme.neonYellow.withOpacity(0.3), AppTheme.neonPink.withOpacity(0.2)]),
        border: Border.all(color: AppTheme.neonYellow.withOpacity(0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text('NEW RECORD!',
              style: GoogleFonts.orbitron(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.neonYellow,
                  letterSpacing: 2)),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withOpacity(0.07),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.rajdhani(
                  fontSize: 14, color: AppTheme.textMuted, fontWeight: FontWeight.w600, letterSpacing: 2)),
          Text('$value',
              style: GoogleFonts.orbitron(
                  fontSize: 20,
                  color: color,
                  fontWeight: FontWeight.w900,
                  shadows: [Shadow(color: color.withOpacity(0.6), blurRadius: 10)])),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: isPrimary
          ? ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: Icon(icon, color: AppTheme.bgDeep, size: 18),
        label: Text(label,
            style: GoogleFonts.orbitron(
                fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.bgDeep, letterSpacing: 2)),
      )
          : OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: color.withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: color.withOpacity(0.07),
        ),
        icon: Icon(icon, color: color, size: 18),
        label: Text(label,
            style: GoogleFonts.orbitron(
                fontSize: 13, fontWeight: FontWeight.w700, color: color, letterSpacing: 2)),
      ),
    );
  }
}