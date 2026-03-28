import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morphmaze/prefs_service.dart';
import 'app_theme.dart';

class HighScoreScreen extends StatefulWidget {
  const HighScoreScreen({super.key});

  @override
  State<HighScoreScreen> createState() => _HighScoreScreenState();
}

class _HighScoreScreenState extends State<HighScoreScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  int _highScore = 0;
  List<int> _history = [];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
    _load();
  }

  Future<void> _load() async {
    final hs = await PrefsService.getHighScore();
    final hist = await PrefsService.getScoreHistory();
    if (mounted) setState(() { _highScore = hs; _history = hist; });
  }

  Future<void> _reset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reset Scores?',
            style: GoogleFonts.orbitron(color: AppTheme.textPrimary, fontSize: 16, letterSpacing: 1)),
        content: Text('This will erase all saved scores.',
            style: GoogleFonts.rajdhani(color: AppTheme.textMuted, fontSize: 15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: Text('CANCEL', style: GoogleFonts.orbitron(color: AppTheme.textMuted, fontSize: 11))),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: Text('RESET', style: GoogleFonts.orbitron(color: AppTheme.neonPink, fontSize: 11))),
        ],
      ),
    );
    if (confirm == true) {
      await PrefsService.resetHighScore();
      _load();
    }
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
          child: Column(
            children: [
              _buildHeader(),
              _buildBestCard(),
              const SizedBox(height: 20),
              Expanded(child: _buildHistory()),
              _buildResetBtn(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
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
          Text('HIGH SCORES',
              style: GoogleFonts.orbitron(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: 3,
                  shadows: [Shadow(color: AppTheme.neonYellow.withOpacity(0.5), blurRadius: 12)])),
        ],
      ),
    );
  }

  Widget _buildBestCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [AppTheme.neonYellow.withOpacity(0.2), AppTheme.neonPink.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppTheme.neonYellow.withOpacity(0.5), width: 1.5),
        boxShadow: [BoxShadow(color: AppTheme.neonYellow.withOpacity(0.1), blurRadius: 30)],
      ),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 48)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ALL-TIME BEST',
                  style: GoogleFonts.rajdhani(
                      color: AppTheme.neonYellow, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 2)),
              Text('$_highScore',
                  style: GoogleFonts.orbitron(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.neonYellow,
                      shadows: [Shadow(color: AppTheme.neonYellow.withOpacity(0.7), blurRadius: 20)])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_esports_rounded, color: AppTheme.textMuted.withOpacity(0.3), size: 64),
            const SizedBox(height: 16),
            Text('No games yet!',
                style: GoogleFonts.orbitron(color: AppTheme.textMuted, fontSize: 14, letterSpacing: 1)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _history.length,
      itemBuilder: (_, i) {
        final score = _history[i];
        final colors = [AppTheme.neonYellow, AppTheme.accent, AppTheme.neonPurple];
        final color = i < 3 ? colors[i] : AppTheme.textMuted;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.07),
            border: Border.all(color: color.withOpacity(i < 3 ? 0.4 : 0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.2)),
                child: Center(
                  child: Text('${i + 1}',
                      style: GoogleFonts.orbitron(fontSize: 12, color: color, fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(width: 16),
              Text('SCORE',
                  style: GoogleFonts.rajdhani(color: AppTheme.textMuted, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 2)),
              const Spacer(),
              Text('$score',
                  style: GoogleFonts.orbitron(
                      fontSize: 20,
                      color: color,
                      fontWeight: FontWeight.w900,
                      shadows: [Shadow(color: color.withOpacity(0.5), blurRadius: 8)])),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResetBtn() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: OutlinedButton.icon(
        onPressed: _reset,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: AppTheme.neonPink.withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(double.infinity, 0),
        ),
        icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.neonPink, size: 18),
        label: Text('RESET SCORES',
            style: GoogleFonts.orbitron(fontSize: 12, color: AppTheme.neonPink, fontWeight: FontWeight.w700, letterSpacing: 2)),
      ),
    );
  }
}