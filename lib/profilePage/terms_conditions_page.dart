// terms_conditions_page.dart
import 'package:flutter/material.dart';
import '../widgets/BaseWidget.dart';

class TermsConditionsPage extends StatefulWidget {
  const TermsConditionsPage({super.key});

  @override
  State<TermsConditionsPage> createState() => _TermsConditionsPageState();
}

class _TermsConditionsPageState extends State<TermsConditionsPage> {
  bool _isAccepted = false;

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Terms & Conditions',
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Last Updated
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Last Updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Introduction
                    _buildSectionTitle('1. Introduction'),
                    _buildSectionContent(
                      'Welcome to our service booking application. These Terms and Conditions ("Terms") govern your use of our mobile application and services. By accessing or using our app, you agree to be bound by these Terms.',
                    ),

                    _buildSectionTitle('2. Acceptance of Terms'),
                    _buildSectionContent(
                      'By creating an account, accessing, or using our services, you acknowledge that you have read, understood, and agree to be bound by these Terms and our Privacy Policy. If you do not agree to these Terms, please do not use our services.',
                    ),

                    _buildSectionTitle('3. Service Description'),
                    _buildSectionContent(
                      'Our application provides a platform for users to book various services from verified service providers. We act as an intermediary between users and service providers, facilitating bookings and payments.',
                    ),

                    _buildSectionTitle('4. User Account and Registration'),
                    _buildSectionContent(
                      '• You must be at least 18 years old to create an account\n'
                      '• You are responsible for maintaining the confidentiality of your account credentials\n'
                      '• You must provide accurate and complete information during registration\n'
                      '• You are responsible for all activities that occur under your account',
                    ),

                    _buildSectionTitle('5. Booking and Payment Terms'),
                    _buildSectionContent(
                      '• All bookings are subject to availability and service provider acceptance\n'
                      '• Payment is processed securely through our integrated payment systems\n'
                      '• Cancellation policies vary by service provider and are displayed at the time of booking\n'
                      '• Refunds are processed according to our refund policy',
                    ),

                    _buildSectionTitle('6. User Responsibilities'),
                    _buildSectionContent(
                      'You agree to:\n'
                      '• Use the service in compliance with all applicable laws\n'
                      '• Provide accurate information for bookings\n'
                      '• Treat service providers with respect\n'
                      '• Not misuse or attempt to hack our systems\n'
                      '• Report any issues or concerns promptly',
                    ),

                    _buildSectionTitle('7. Service Provider Terms'),
                    _buildSectionContent(
                      '• Service providers are independent contractors\n'
                      '• We do not directly employ service providers\n'
                      '• Service quality is the responsibility of the individual provider\n'
                      '• We facilitate communication and payment but do not guarantee service outcomes',
                    ),

                    _buildSectionTitle('8. Privacy and Data Protection'),
                    _buildSectionContent(
                      'Your privacy is important to us. Our collection and use of personal information is governed by our Privacy Policy, which is incorporated into these Terms by reference.',
                    ),

                    _buildSectionTitle('9. Intellectual Property'),
                    _buildSectionContent(
                      'All content, features, and functionality of our app are owned by us and are protected by copyright, trademark, and other intellectual property laws.',
                    ),

                    _buildSectionTitle('10. Limitation of Liability'),
                    _buildSectionContent(
                      'To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, special, or consequential damages resulting from your use of our services.',
                    ),

                    _buildSectionTitle('11. Dispute Resolution'),
                    _buildSectionContent(
                      'Any disputes arising from these Terms shall be resolved through binding arbitration in accordance with the rules of the jurisdiction where our company is registered.',
                    ),

                    _buildSectionTitle('12. Termination'),
                    _buildSectionContent(
                      'We reserve the right to suspend or terminate your account at any time for violation of these Terms or for any other reason at our sole discretion.',
                    ),

                    _buildSectionTitle('13. Changes to Terms'),
                    _buildSectionContent(
                      'We may update these Terms from time to time. We will notify users of significant changes through the app or email. Continued use after changes constitutes acceptance of the new Terms.',
                    ),

                    _buildSectionTitle('14. Contact Information'),
                    _buildSectionContent(
                      'If you have any questions about these Terms, please contact us at:\n'
                      'Email: support@servicemate.com\n'
                      'Phone: +91 (044) 26591233\n'
                      'Address: NO:14,1 st Street,Puzhal \nChennai, Tamilnadu - 600066',
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Bottom acceptance section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Checkbox with agreement text
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _isAccepted,
                        onChanged: (value) {
                          setState(() {
                            _isAccepted = value ?? false;
                          });
                        },
                        activeColor: Colors.blue,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isAccepted = !_isAccepted;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              'I have read and agree to the Terms & Conditions',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Accept button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isAccepted
                          ? () {
                              _showAcceptanceDialog();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isAccepted ? Colors.blue : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Accept Terms & Conditions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.titleMedium?.color,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  void _showAcceptanceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              Text('Terms Accepted'),
            ],
          ),
          content: Text(
            'Thank you for accepting our Terms & Conditions. You can now enjoy all features of our app.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to profile page
              },
              child: Text(
                'Continue',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}