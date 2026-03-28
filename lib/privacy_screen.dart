import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'app_theme.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  static const String _privacyHtml = '''
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Privacy Policy</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    background: #080B1A;
    color: #EEF2FF;
    font-family: -apple-system, sans-serif;
    padding: 24px 20px;
    line-height: 1.7;
  }
  h1 {
    font-size: 22px;
    color: #00F5FF;
    letter-spacing: 2px;
    margin-bottom: 6px;
    text-transform: uppercase;
  }
  .subtitle { color: #7B8FCA; font-size: 12px; margin-bottom: 28px; }
  h2 {
    font-size: 14px;
    color: #B24BF3;
    letter-spacing: 1px;
    margin: 22px 0 8px;
    text-transform: uppercase;
  }
  p { font-size: 14px; color: #B0BAD8; margin-bottom: 10px; }
  .card {
    background: #0F1428;
    border: 1px solid #2E3F72;
    border-radius: 12px;
    padding: 16px;
    margin-bottom: 14px;
  }
</style>
</head>
<body>
<h1>Privacy Policy</h1>
<p class="subtitle">Last updated: 2024 &nbsp;·&nbsp; MorphMaze</p>
<div class="card">
  <h2>Overview</h2>
  <p>MorphMaze ("the game") is developed by ToolDynoApps. We are committed to protecting your privacy. This policy explains how we handle information in relation to your use of the game.</p>
</div>
<div class="card">
  <h2>Data We Collect</h2>
  <p>MorphMaze stores only the following data <strong>locally on your device</strong> using SharedPreferences:</p>
  <p>• High score and score history</p>
  <p>• Last level played</p>
  <p>• Sound/music preferences</p>
  <p>No personal data is collected, transmitted, or shared with third parties.</p>
</div>
<div class="card">
  <h2>Internet Usage</h2>
  <p>MorphMaze does not require an internet connection for gameplay. No data is sent to external servers.</p>
</div>
<div class="card">
  <h2>Third-Party Services</h2>
  <p>This game does not integrate any third-party analytics, advertising SDKs, or tracking libraries.</p>
</div>
<div class="card">
  <h2>Children's Privacy</h2>
  <p>MorphMaze is suitable for all ages. We do not knowingly collect any personal information from children under 13.</p>
</div>
<div class="card">
  <h2>Changes to This Policy</h2>
  <p>We may update this policy from time to time. Continued use of the app after changes constitutes your acceptance of the updated policy.</p>
</div>
<div class="card">
  <h2>Contact</h2>
  <p>If you have questions about this privacy policy, please contact us via the Google Play Store listing for MorphMaze.</p>
</div>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.bgDeep)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _isLoading = false),
      ))
      ..loadHtmlString(_privacyHtml);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
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
                  Text('PRIVACY POLICY',
                      style: GoogleFonts.orbitron(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                          letterSpacing: 2,
                          shadows: [Shadow(color: AppTheme.accent.withOpacity(0.5), blurRadius: 12)])),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading)
                    Container(
                      color: AppTheme.bgDeep,
                      child: const Center(
                        child: CircularProgressIndicator(color: AppTheme.accent),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}