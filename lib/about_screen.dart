import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: SafeArea(
        child: FadeTransition(
          opacity: _ctrl,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildLogoSection(),
                const SizedBox(height: 32),
                _buildInfoCard(
                  icon: Icons.info_outline_rounded,
                  color: AppTheme.accent,
                  title: 'ABOUT THE GAME',
                  content: 'MorphMaze is a fast-paced arcade puzzle game where you morph your shape to survive! '
                      'Control a Circle, Square, or Triangle and match the holes in incoming walls. '
                      'How far can you go?',
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  icon: Icons.code_rounded,
                  color: AppTheme.neonPurple,
                  title: 'DEVELOPER',
                  content: 'Built with Flutter & Dart\nPowered by Canvas rendering\nAhmad — ToolDynoApps',
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  icon: Icons.gamepad_rounded,
                  color: AppTheme.neonGreen,
                  title: 'HOW TO PLAY',
                  content: '1. Tap a shape button at the bottom\n'
                      '2. Match your shape to the hole in the wall\n'
                      '3. Wrong shape = GAME OVER!\n'
                      '4. Survive longer to level up!',
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  icon: Icons.star_rounded,
                  color: AppTheme.neonYellow,
                  title: 'VERSION',
                  content: 'MorphMaze v1.0.0\nCategory: Arcade / Puzzle\nPlatform: Android',
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.bgCard,
                border: Border.all(color: AppTheme.wallBorder)),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 16),
          ),
        ),
        const SizedBox(width: 16),
        Text('ABOUT',
            style: GoogleFonts.orbitron(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
                letterSpacing: 3,
                shadows: [Shadow(color: AppTheme.accent.withOpacity(0.5), blurRadius: 12)])),
      ],
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppTheme.accent.withOpacity(0.2), Colors.transparent],
              ),
              border: Border.all(color: AppTheme.accent.withOpacity(0.4), width: 2),
            ),
            child: CustomPaint(painter: _AboutLogoPainter()),
          ),
          const SizedBox(height: 12),
          Text('MORPHMAZE',
              style: GoogleFonts.orbitron(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: 4,
                  shadows: [Shadow(color: AppTheme.accent.withOpacity(0.6), blurRadius: 16)])),
          const SizedBox(height: 4),
          Text('MORPH · MATCH · SURVIVE',
              style: GoogleFonts.rajdhani(
                  fontSize: 12, color: AppTheme.textMuted, letterSpacing: 3, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color color,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.07),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content,
              style: GoogleFonts.rajdhani(
                  fontSize: 15,
                  color: AppTheme.textPrimary.withOpacity(0.85),
                  height: 1.6,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _AboutLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final cp = Paint()..color = AppTheme.circleColor..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(cx - 16, cy - 8), 12, cp);

    final sp = Paint()..color = AppTheme.squareColor..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 14, cy - 8), width: 20, height: 20), const Radius.circular(3)), sp);

    final tp = Paint()..color = AppTheme.triangleColor..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final tri = Path()
      ..moveTo(cx, cy + 22)
      ..lineTo(cx + 14, cy + 4)
      ..lineTo(cx - 14, cy + 4)
      ..close();
    canvas.drawPath(tri, tp);
  }

  @override
  bool shouldRepaint(_) => false;
}