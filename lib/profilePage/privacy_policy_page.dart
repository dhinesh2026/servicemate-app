// privacy_policy_page.dart
import 'package:flutter/material.dart';
import '../widgets/BaseWidget.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= 200) {
      if (!_showBackToTop) {
        setState(() {
          _showBackToTop = true;
        });
      }
    } else {
      if (_showBackToTop) {
        setState(() {
          _showBackToTop = false;
        });
      }
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Privacy Policy',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.privacy_tip,
                          size: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Last updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Introduction
                  _buildSection(
                    context,
                    '1. Introduction',
                    'Welcome to our service booking application. We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you about how we look after your personal data when you visit our application and tell you about your privacy rights and how the law protects you.',
                  ),

                  // Information We Collect
                  _buildSection(
                    context,
                    '2. Information We Collect',
                    'We collect, use, store and transfer different kinds of personal data about you which we have grouped together as follows:\n\n'
                    '• Identity Data: First name, last name, username\n'
                    '• Contact Data: Email address, telephone numbers, addresses\n'
                    '• Profile Data: Your interests, preferences, feedback and survey responses\n'
                    '• Technical Data: Internet protocol (IP) address, login data, browser type and version\n'
                    '• Usage Data: Information about how you use our application and services\n'
                    '• Marketing and Communications Data: Your preferences in receiving marketing from us',
                  ),

                  // How We Use Your Information
                  _buildSection(
                    context,
                    '3. How We Use Your Information',
                    'We will only use your personal data when the law allows us to. Most commonly, we will use your personal data in the following circumstances:\n\n'
                    '• To register you as a new customer\n'
                    '• To process and deliver your service bookings\n'
                    '• To manage our relationship with you\n'
                    '• To improve our application, products/services, marketing or customer relationships\n'
                    '• To make suggestions and recommendations to you about services that may be of interest to you',
                  ),

                  // Data Security
                  _buildSection(
                    context,
                    '4. Data Security',
                    'We have put in place appropriate security measures to prevent your personal data from being accidentally lost, used or accessed in an unauthorised way, altered or disclosed. In addition, we limit access to your personal data to those employees, agents, contractors and other third parties who have a business need to know.',
                  ),

                  // Data Retention
                  _buildSection(
                    context,
                    '5. Data Retention',
                    'We will only retain your personal data for as long as reasonably necessary to fulfil the purposes we collected it for, including for the purposes of satisfying any legal, regulatory, tax, accounting or reporting requirements.',
                  ),

                  // Your Legal Rights
                  _buildSection(
                    context,
                    '6. Your Legal Rights',
                    'Under certain circumstances, you have rights under data protection laws in relation to your personal data:\n\n'
                    '• Request access to your personal data\n'
                    '• Request correction of your personal data\n'
                    '• Request erasure of your personal data\n'
                    '• Object to processing of your personal data\n'
                    '• Request restriction of processing your personal data\n'
                    '• Request transfer of your personal data\n'
                    '• Right to withdraw consent',
                  ),

                  // Third-Party Links
                  _buildSection(
                    context,
                    '7. Third-Party Links',
                    'This application may include links to third-party websites, plug-ins and applications. Clicking on those links or enabling those connections may allow third parties to collect or share data about you. We do not control these third-party websites and are not responsible for their privacy statements.',
                  ),

                  // Cookies
                  _buildSection(
                    context,
                    '8. Cookies',
                    'Our application uses cookies to distinguish you from other users. This helps us to provide you with a good experience when you browse our application and also allows us to improve our application. You can set your device to refuse all or some cookies, or to alert you when cookies are being sent.',
                  ),

                  // Children\'s Privacy
                  _buildSection(
                    context,
                    '9. Children\'s Privacy',
                    'Our service is not intended for children under the age of 13. We do not knowingly collect personal identifiable information from children under 13. If you are a parent or guardian and you are aware that your child has provided us with personal data, please contact us.',
                  ),

                  // Changes to Privacy Policy
                  _buildSection(
                    context,
                    '10. Changes to This Privacy Policy',
                    'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date at the top of this Privacy Policy.',
                  ),

                  // Contact Information
                  _buildContactSection(context),

                  const SizedBox(height: 100), // Extra space for floating button
                ],
              ),
            ),

            // Floating Back to Top Button
            if (_showBackToTop)
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.small(
                  onPressed: _scrollToTop,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '11. Contact Us',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'If you have any questions about this Privacy Policy, please contact us:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 12),
                _buildContactItem(context, Icons.email, 'ideonixis@gmail.com'),
                const SizedBox(height: 8),
                _buildContactItem(context, Icons.phone, '+91 98405 42133'),
                const SizedBox(height: 8),
                _buildContactItem(
                  context, 
                  Icons.location_on, 
                  'NO:14,1 st Street,Puzhal\nChennai, Tamilnadu - 600066\nIndia'
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ],
    );
  }
}