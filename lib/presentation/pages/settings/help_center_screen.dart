import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  static const String routeName = '/help-center';

  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search for help...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _QuickActionCard(
            icon: Icons.email,
            title: 'Contact Support',
            subtitle: 'Get help from our team',
            onTap: () => _showContactSupport(context),
          ),
          _QuickActionCard(
            icon: Icons.bug_report,
            title: 'Report a Bug',
            subtitle: 'Let us know about issues',
            onTap: () => _showReportBug(context),
          ),
          _QuickActionCard(
            icon: Icons.feedback,
            title: 'Send Feedback',
            subtitle: 'Share your suggestions',
            onTap: () => _showFeedback(context),
          ),

          const SizedBox(height: 24),

          // FAQ Sections
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _FAQSection(
            title: 'Getting Started',
            faqs: [
              _FAQ(
                question: 'How do I create an account?',
                answer:
                'Tap on "Sign up" on the login screen. You can sign up with email, phone, or Google.',
              ),
              _FAQ(
                question: 'How do I find events near me?',
                answer:
                'Go to the Discover tab to browse events happening around you. Use the Map View or filters.',
              ),
              _FAQ(
                question: 'How do I create an event?',
                answer:
                'Tap the "+" button in the bottom navigation bar, fill out event details, and tap "Create Event".',
              ),
            ],
          ),

          _FAQSection(
            title: 'Events',
            faqs: [
              _FAQ(
                question: 'How do I join an event?',
                answer:
                'Open any event from Discover or Explore and tap "Join Event". You will get confirmation once added.',
              ),
              _FAQ(
                question: 'What are the ticket types?',
                answer:
                'Free: No cost\nPaid: Regular ticket\nVIP: Premium access with benefits\nEvent organizers set the prices.',
              ),
              _FAQ(
                question: 'Can I cancel my event registration?',
                answer:
                'Yes. Go to Profile > Upcoming Events and select "Cancel Registration". Refunds depend on organizer policy.',
              ),
            ],
          ),

          _FAQSection(
            title: 'Groups & Social',
            faqs: [
              _FAQ(
                question: 'How do I join a group?',
                answer:
                'Go to Groups tab, browse suggested groups, and tap "Join Group".',
              ),
              _FAQ(
                question: 'How do I follow someone?',
                answer:
                'Open a user profile and tap "Follow". You\'ll see their updates on your feed.',
              ),
              _FAQ(
                question: 'How do I send a message?',
                answer:
                'Open a user profile and tap "Message", or find users through search.',
              ),
            ],
          ),

          _FAQSection(
            title: 'Rewards & Points',
            faqs: [
              _FAQ(
                question: 'How do I earn reward points?',
                answer:
                'Earn points by attending events, hosting events, completing profile, and engaging socially.',
              ),
              _FAQ(
                question: 'What can I do with reward points?',
                answer:
                'Redeem for discounts at partner businesses, unlock badges, or access exclusive events.',
              ),
            ],
          ),

          _FAQSection(
            title: 'Account & Settings',
            faqs: [
              _FAQ(
                question: 'How do I change profile information?',
                answer:
                'Go to Profile > Edit Profile to update everything including bio, phone, location, and interests.',
              ),
              _FAQ(
                question: 'How do I enable dark mode?',
                answer:
                'Go to Settings > Appearance and toggle "Dark Mode" on.',
              ),
              _FAQ(
                question: 'How do I delete my account?',
                answer:
                'Go to Settings > Privacy and Security > Delete Account. This action is permanent.',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Still Need Help Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8C00).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border:
              Border.all(color: const Color(0xFFFF8C00).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.support_agent,
                    size: 48, color: Color(0xFFFF8C00)),
                const SizedBox(height: 12),
                const Text(
                  'Still Need Help?',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Our support team is here to assist you anytime.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showContactSupport(context),
                  icon: const Icon(Icons.email),
                  label: const Text('Contact Support'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C00),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------
  // MODAL SHEETS
  // -------------------------------

  void _showContactSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape:
      const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _ModalForm(
        title: 'Contact Support',
        fields: const [
          _FormFieldData(label: 'Subject'),
          _FormFieldData(label: 'Message', isLarge: true),
        ],
        buttonText: 'Send Message',
        onSubmitMessage: 'Message sent! We\'ll get back to you soon.',
      ),
    );
  }

  void _showReportBug(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape:
      const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _ModalForm(
        title: 'Report a Bug',
        fields: const [
          _FormFieldData(label: 'Bug Title'),
          _FormFieldData(
              label: 'Describe the issue',
              hint: 'What happened? What were you trying to do?',
              isLarge: true),
        ],
        buttonText: 'Submit Report',
        onSubmitMessage: 'Bug report submitted. Thank you!',
      ),
    );
  }

  void _showFeedback(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape:
      const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _ModalForm(
        title: 'Send Feedback',
        fields: const [
          _FormFieldData(
              label: 'Your Feedback',
              hint: 'Share your thoughts and suggestions...',
              isLarge: true),
        ],
        buttonText: 'Send Feedback',
        onSubmitMessage: 'Thank you for your feedback!',
      ),
    );
  }
}

// -------------------------------
// QUICK ACTION CARD
// -------------------------------

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF8C00).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFFF8C00)),
        ),
        title:
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// -------------------------------
// FAQ SECTION
// -------------------------------

class _FAQSection extends StatelessWidget {
  final String title;
  final List<_FAQ> faqs;

  const _FAQSection({
    required this.title,
    required this.faqs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF8C00),
            ),
          ),
        ),
        ...faqs.map((faq) => _FAQTile(faq: faq)).toList(),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _FAQ {
  final String question;
  final String answer;

  const _FAQ({required this.question, required this.answer});
}

class _FAQTile extends StatefulWidget {
  final _FAQ faq;

  const _FAQTile({required this.faq});

  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(widget.faq.question,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFFFF8C00),
                  ),
                ],
              ),
              if (_isExpanded)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    widget.faq.answer,
                    style: TextStyle(
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------
// MODAL FORM USED FOR ALL BOTTOM SHEETS
// -------------------------------

class _FormFieldData {
  final String label;
  final String? hint;
  final bool isLarge;

  const _FormFieldData({required this.label, this.hint, this.isLarge = false});
}

class _ModalForm extends StatelessWidget {
  final String title;
  final List<_FormFieldData> fields;
  final String buttonText;
  final String onSubmitMessage;

  const _ModalForm({
    required this.title,
    required this.fields,
    required this.buttonText,
    required this.onSubmitMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          ...fields.map(
                (f) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                maxLines: f.isLarge ? 5 : 1,
                decoration: InputDecoration(
                  labelText: f.label,
                  hintText: f.hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(onSubmitMessage)),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8C00),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
