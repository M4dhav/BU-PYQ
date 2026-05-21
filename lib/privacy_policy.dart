import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BU Scholar - Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last Updated: May 16, 2026',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Introduction',
              'Welcome to BU Scholar ("we," "our," or "us"). This Privacy Policy explains our approach to user privacy and data when you use our BU Scholar application (the "App"), a comprehensive companion application designed specifically for Bennett University students.',
            ),
            _buildSection(
              'No Data Collection Policy',
              'We are committed to protecting your privacy and want to be transparent about our data practices:\n\n'
                  '• BU Scholar does not collect any personal information from users.\n\n'
                  '• We do not request, store, or process any personally identifiable information such as names, email addresses, or student credentials.\n\n'
                  '• We do not track or collect usage data, analytics, or metrics about how you use the application.\n\n'
                  '• The application functions entirely with publicly available academic resources that do not require user authentication or personalization.',
            ),
            _buildSection(
              'Local Device Storage',
              'While the app does not collect user data for external storage or processing:\n\n'
                  '• The app may store certain preferences locally on your device (such as UI settings) to improve your experience.\n\n'
                  '• This information never leaves your device and is not accessible to us or any third parties.\n\n'
                  '• Clearing the app\'s cache or uninstalling the app will remove any locally stored preferences.',
            ),
            _buildSection(
              'Third-Party Services',
              'Our application fetches content directly from a public GitHub repository (BU-PYQ) to deliver the question-paper index and PDF files. Important notes about this usage:\n\n'
                  '• The app retrieves a single JSON manifest (pyq-data.json) and individual PDF files from raw.githubusercontent.com. These requests are unauthenticated and identical for every user.\n\n'
                  '• GitHub may log standard request metadata (such as IP address and user agent) as part of serving these public files, governed by GitHub\'s own privacy policy. We do not receive, access, or store any of this data.\n\n'
                  '• No user identification, accounts, or tracking are implemented in the app.\n\n'
                  '• We do not use analytics services to track app usage.',
            ),
            _buildSection(
              'App Permissions',
              'Our app only requests the minimum permissions necessary to provide its core functionality:\n\n'
                  '• Internet access: Required to fetch academic resources like question papers from our content server.\n\n'
                  '• Storage access: Required only for downloading PDF files when explicitly requested by the user.',
            ),
            _buildSection(
              'Children\'s Privacy',
              'The App is primarily designed for university students. Since we do not collect any personal data from users of any age, there are no specific provisions needed regarding children\'s data. Parents or guardians can allow children to use the app with confidence that no personal information is being collected.',
            ),
            _buildSection(
              'Changes to This Privacy Policy',
              'We may update our Privacy Policy from time to time to reflect changes in our practices or for other operational, legal, or regulatory reasons. We will notify users of any substantive changes by updating the "Last Updated" date on this policy. Users are encouraged to review this Privacy Policy periodically.',
            ),
            _buildSection(
              'Your Rights',
              'Since we don\'t collect any personal data, there are no specific user rights that need to be addressed regarding data access, correction, or deletion. The app is designed with privacy by default and by design.',
            ),
            _buildSection(
              'Contact Us',
              'If you have questions or comments about this Privacy Policy or our data practices, please contact us at:\n\n'
                  'BU Scholar Team\n'
                  'Email: support@m4dhav.dev',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
      ],
    );
  }
}
