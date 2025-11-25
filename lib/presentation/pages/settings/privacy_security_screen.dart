import 'package:flutter/material.dart';

class PrivacySecurityScreen extends StatefulWidget {
  static const String routeName = '/privacy-security';

  const PrivacySecurityScreen({Key? key}) : super(key: key);

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _showPrivacy = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _showPrivacy ? "Privacy" : "Security",
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Column(
        children: [
          _buildTabs(context),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _showPrivacy
                  ? _buildPrivacyContent()
                  : _buildSecurityContent(),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------- TOP TABS (SWITCH) ----------------------
  Widget _buildTabs(BuildContext context) {
    return Row(
      children: [
        _tabButton("Privacy", true),
        _tabButton("Security", false),
      ],
    );
  }

  Widget _tabButton(String text, bool privacyTab) {
    bool selected = _showPrivacy == privacyTab;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _showPrivacy = privacyTab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? const Color(0xFFFF8C00) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? const Color(0xFFFF8C00) : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------- PRIVACY CONTENT ----------------------
  Widget _buildPrivacyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header("Privacy Settings"),

        _buildSection(
          "Data Collection",
          "We collect only the minimum data needed to provide better recommendations. "
              "This includes profile details, location (when permission is given), and usage activity.",
        ),

        _buildSection(
          "Control Your Data",
          "• Download your data\n"
              "• Request deletion anytime\n"
              "• Edit or update personal info\n"
              "• Turn off location access",
        ),

        _buildSection(
          "Location Privacy",
          "Your location is used only to show nearby events. You can disable it from your phone settings.",
        ),

        _buildSection(
          "Ad & Tracking",
          "We do not sell your personal info. Limited anonymous analytics may be used to improve features.",
        ),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFF8C00).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: const [
              Icon(Icons.lock_open, color: Color(0xFFFF8C00)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "You stay in control of your data at all times.",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // ---------------------- SECURITY CONTENT ----------------------
  Widget _buildSecurityContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header("Security Settings"),

        _buildSection(
          "Account Protection",
          "We use industry-level encryption and security practices to protect your account from unauthorized access.",
        ),

        _buildSection(
          "Login Safety",
          "• Secure password storage\n"
              "• Automatic suspicious login blocking\n"
              "• Device verification support",
        ),

        _buildSection(
          "Two-Factor Authentication (2FA)",
          "Add an extra layer of protection by enabling 2FA through SMS or Authenticator apps. "
              "This helps prevent unauthorized access even if your password is compromised.",
        ),

        _buildSection(
          "Report Suspicious Activity",
          "If you notice unusual behavior or account changes, contact support immediately.",
        ),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: const [
              Icon(Icons.shield, color: Colors.redAccent),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Your security is our highest priority.",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  // ---------------------- REUSABLE COMPONENTS ----------------------
  Widget _header(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text("Updated: ${DateTime.now().year}", style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
