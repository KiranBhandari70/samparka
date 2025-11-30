import 'package:flutter/material.dart';

class TermsPrivacyScreen extends StatefulWidget {
  static const String routeName = '/terms-privacy';

  const TermsPrivacyScreen({Key? key}) : super(key: key);

  @override
  State<TermsPrivacyScreen> createState() => _TermsPrivacyScreenState();
}

class _TermsPrivacyScreenState extends State<TermsPrivacyScreen> {
  bool _showTerms = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _showTerms ? 'Terms of Service' : 'Privacy Policy',
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
              child: _showTerms
                  ? _buildTermsContent()
                  : _buildPrivacyContent(),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------- TAB SWITCH ----------------------
  Widget _buildTabs(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          _tabButton("Terms of Service", true),
          _tabButton("Privacy Policy", false),
        ],
      ),
    );
  }

  Widget _tabButton(String text, bool isTerms) {
    bool isSelected = _showTerms == isTerms;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _showTerms = isTerms),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFFFF8C00) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFFFF8C00) : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------- TERMS CONTENT ----------------------
  Widget _buildTermsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionHeader('Terms of Service'),

        _buildSection(
          'Acceptance of Terms',
          'By accessing and using Samparka, you accept and agree to this agreement...',
        ),

        _buildSection(
          'User Accounts',
          '• You must be at least 13 years old...\n'
              '• You are responsible for account security...\n'
              '• Provide accurate information...',
        ),

        _buildSection(
          'User Content',
          '• You retain ownership of your content...\n'
              '• We may display, modify your content...\n'
              '• Illegal or harmful content is prohibited...',
        ),

        _buildSection(
          'Events & Meetings',
          'Samparka is not responsible for the actions of event organizers...',
        ),

        _buildSection(
          'Prohibited Activities',
          '• Harassment or abuse\n• Illegal activity\n• Impersonation\n• Spam\n• Using bots...',
        ),

        _buildSection(
          'Termination',
          'We may suspend or terminate your account for policy violations.',
        ),

        _buildSection(
          'Contact Us',
          'support@samparka.com',
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  // ---------------------- PRIVACY CONTENT ----------------------
  Widget _buildPrivacyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionHeader('Privacy Policy'),

        _buildSection(
          'Information We Collect',
          'Personal Data:\n• Name, phone, email\n• Profile info\n• Location data\n\nUsage Data:\n• Device info\n• Logs and analytics',
        ),

        _buildSection(
          'How We Use Your Data',
          '• Improve app features\n• Personalize experience\n• Show nearby events\n• Maintain security',
        ),

        _buildSection(
          'Data Sharing',
          'We share data with:\n• Event organizers\n• Service operators\n• When legally required',
        ),

        _buildSection(
          'Your Privacy Rights',
          'You may request data deletion, export, correction, etc.',
        ),

        _buildSection(
          'Children\'s Privacy',
          'Samparka is not for users under 13. We do not knowingly collect their data.',
        ),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFF8C00).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield, color: Color(0xFFFF8C00)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Your privacy matters to us. We protect your information.',
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

  // ---------------------- REUSABLES ----------------------
  Widget sectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          'Last updated: ${DateTime.now().year}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
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
                  fontWeight: FontWeight.bold, fontSize: 18)),
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
