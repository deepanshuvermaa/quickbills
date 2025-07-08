import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
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
              '1. Information We Collect',
              'QuickBills collects the following types of information:\n\n'
              '• Personal Information: Name, email address, phone number, business details\n'
              '• Business Data: Products, inventory, sales transactions, customer information\n'
              '• Usage Data: App usage patterns, device information, crash reports\n'
              '• Payment Information: Subscription details (processed securely by payment partners)',
            ),
            _buildSection(
              context,
              '2. How We Use Your Information',
              'We use the collected information to:\n\n'
              '• Provide and maintain our service\n'
              '• Process transactions and manage subscriptions\n'
              '• Send important updates and notifications\n'
              '• Improve our app and develop new features\n'
              '• Provide customer support\n'
              '• Comply with legal obligations',
            ),
            _buildSection(
              context,
              '3. Data Storage and Security',
              '• Your data is stored on secure servers with encryption at rest and in transit\n'
              '• We implement industry-standard security measures including SSL/TLS\n'
              '• Regular security audits are performed\n'
              '• Access to data is restricted to authorized personnel only\n'
              '• Local data on your device is encrypted using platform-specific security features',
            ),
            _buildSection(
              context,
              '4. Data Sharing',
              'We do not sell, trade, or rent your personal information. We may share data only:\n\n'
              '• With your explicit consent\n'
              '• To comply with legal obligations\n'
              '• With service providers who assist in app operations (under strict agreements)\n'
              '• In case of business merger or acquisition (with notice)',
            ),
            _buildSection(
              context,
              '5. Your Rights',
              'You have the right to:\n\n'
              '• Access your personal data\n'
              '• Correct inaccurate data\n'
              '• Request deletion of your data\n'
              '• Export your data in a portable format\n'
              '• Opt-out of marketing communications\n'
              '• Lodge a complaint with data protection authorities',
            ),
            _buildSection(
              context,
              '6. Data Retention',
              '• We retain your data as long as your account is active\n'
              '• After account deletion, data is retained for 90 days for recovery purposes\n'
              '• Some data may be retained longer for legal compliance\n'
              '• Anonymized data may be retained for analytics',
            ),
            _buildSection(
              context,
              '7. Third-Party Services',
              'QuickBills integrates with:\n\n'
              '• Payment processors (Razorpay) for subscription management\n'
              '• Cloud storage providers for data backup\n'
              '• Analytics services for app improvement\n'
              '• SMS/Email services for notifications\n\n'
              'Each service has its own privacy policy which we encourage you to review.',
            ),
            _buildSection(
              context,
              '8. Children\'s Privacy',
              'QuickBills is not intended for use by children under 13 years of age. We do not knowingly collect personal information from children.',
            ),
            _buildSection(
              context,
              '9. Changes to Privacy Policy',
              'We may update this privacy policy from time to time. We will notify you of any changes by:\n\n'
              '• Posting the new policy in the app\n'
              '• Sending an email notification\n'
              '• Requiring acceptance for material changes',
            ),
            _buildSection(
              context,
              '10. Contact Us',
              'If you have questions about this Privacy Policy, please contact us:\n\n'
              'Email: privacy@quickbills.com\n'
              'Phone: +91 1800 123 4567\n'
              'Address: QuickBills Technologies Pvt. Ltd.\n'
              '123 Business Park, Bangalore 560001, India',
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