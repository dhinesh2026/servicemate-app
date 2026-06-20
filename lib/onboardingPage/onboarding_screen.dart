import 'package:flutter/material.dart';
import 'package:servicemate_app/loginPage/signupPage.dart';
import '../loginPage/loginPage.dart';
import '../widgets/BaseWidget.dart';

// Custom Colors for your app (consistent with other pages)
class AppColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF8B5CF6);
  static const Color secondary = Color(0xFF10B981);
  static const Color accent = Color(0xFFF59E0B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color dotActive = Color(0xFF6366F1);
  static const Color dotInactive = Color(0xFFE2E8F0);
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/step1.png",
      "title": "Find Best Solutions for Your Home",
      "subtitle": "Discover professional services tailored to your home needs. Quality service providers at your fingertips."
    },
    {
      "image": "assets/images/step2.png",
      "title": "Quality Service Within Your Budget",
      "subtitle": "Get the best value for your money with our affordable pricing and premium service quality."
    },
    {
      "image": "assets/images/step3.png",
      "title": "Exceptional Service Experience",
      "subtitle": "Enjoy seamless service delivery with trusted professionals and reliable customer support."
    },
  ];

  void _nextPage() {
    if (_currentIndex < onboardingData.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignupPage()),
      );
    }
  }

  void _skipToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, right: 20),
                  child: _currentIndex == onboardingData.length - 1
                      ? const SizedBox.shrink()
                      : TextButton(
                          onPressed: _skipToLogin,
                          child: Text(
                            "Skip",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                ),
              ),

              // PageView Content
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Image Section
                          Expanded(
                            flex: 6,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 20),
                              child: Image.asset(
                                onboardingData[index]["image"]!,
                                fit: BoxFit.contain,
                                width: double.infinity,
                              ),
                            ),
                          ),

                          // Text Content Section
                          Expanded(
                            flex: 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Title
                                Text(
                                  onboardingData[index]["title"]!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Subtitle
                                Text(
                                  onboardingData[index]["subtitle"]!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary,
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // Dot Indicators
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    onboardingData.length,
                                    (dotIndex) => AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.symmetric(horizontal: 6),
                                      height: 8,
                                      width: _currentIndex == dotIndex ? 32 : 8,
                                      decoration: BoxDecoration(
                                        color: _currentIndex == dotIndex
                                            ? AppColors.primary
                                            : AppColors.dotInactive,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: _currentIndex == dotIndex
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.primary.withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ]
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Button Section
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Get Started/Next Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                          shadowColor: AppColors.primary.withOpacity(0.3),
                        ),
                        onPressed: _nextPage,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentIndex == onboardingData.length - 1
                                  ? "Get Started"
                                  : "Continue",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_currentIndex == onboardingData.length - 1)
                              const SizedBox(width: 8),
                            if (_currentIndex == onboardingData.length - 1)
                              const Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Secondary Option for Last Screen
                    if (_currentIndex == onboardingData.length - 1)
                      TextButton(
                        onPressed: _skipToLogin,
                        child: Text(
                          "I already have an account",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}