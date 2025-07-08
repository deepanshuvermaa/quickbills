import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. Acceptance of Terms',
              'By downloading, installing, or using QuickBills, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our application.',
            ),
            _buildSection(
              context,
              '2. License to Use',
              'QuickBills grants you a limited, non-exclusive, non-transferable license to use the application for your personal or business use in accordance with these terms.',
            ),
            _buildSection(
              context,
              '3. User Accounts',
              '• You are responsible for maintaining the confidentiality of your account credentials\n'
              '• You must provide accurate and complete information during registration\n'
              '• You are responsible for all activities that occur under your account\n'
              '• You must notify us immediately of any unauthorized use of your account',
            ),
            _buildSection(
              context,
              '4. Subscription and Payments',
              '• QuickBills offers various subscription plans with different features\n'
              '• Subscription fees are billed in advance on a monthly or annual basis\n'
              '• All payments are non-refundable unless otherwise stated\n'
              '• We reserve the right to modify subscription prices with 30 days notice',
            ),
            _buildSection(
              context,
              '5. Data Protection',
              '• We implement industry-standard security measures to protect your data\n'
              '• You retain ownership of all data you input into QuickBills\n'
              '• We will not sell or share your data with third parties without consent\n'
              '• Regular backups are your responsibility',
            ),
            _buildSection(
              context,
              '6. Acceptable Use',
              'You agree not to:\n'
              '• Use the app for any illegal or unauthorized purpose\n'
              '• Attempt to breach or circumvent any security measures\n'
              '• Interfere with or disrupt the service\n'
              '• Upload malicious code or viruses\n'
              '• Use the app to harass, abuse, or harm others',
            ),
            _buildSection(
              context,
              '7. Intellectual Property',
              'All content, features, and functionality of QuickBills are owned by us and are protected by international copyright, trademark, and other intellectual property laws.',
            ),
            _buildSection(
              context,
              '8. Limitation of Liability',
              'QuickBills shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use or inability to use the service.',
            ),
            _buildSection(
              context,
              '9. Termination',
              'We may terminate or suspend your account immediately, without prior notice, for breach of these Terms of Service.',
            ),
            _buildSection(
              context,
              '10. Changes to Terms',
              'We reserve the right to modify these terms at any time. We will notify users of any material changes via email or in-app notification.',
            ),
            _buildSection(
              context,
              '11. Contact Information',
              'If you have any questions about these Terms of Service, please contact us at:\n\n'
              'Email: support@quickbills.com\n'
              'Phone: +91 1800 123 4567',
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('I Understand'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}