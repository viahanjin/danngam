import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../shared/constants/app_dimensions.dart';
import '../../../shared/constants/app_strings.dart';
import '../../../shared/extensions/build_context_ext.dart';
import '../../../shared/widgets/app_button.dart';

/// Onboarding Screen Model
class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// Onboarding Screen
/// Shows app features with page view and navigation
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: '단감 - 농기계 공유',
      description: '농부들을 위한 장비\n공유 플랫폼',
      icon: Icons.agriculture, // 🚜 트랙터 아이콘
    ),
    OnboardingPage(
      title: '쉽고 빠른 예약',
      description: '몇 번의 클릭만으로\n장비를 예약하세요',
      icon: Icons.schedule, // ⏱️ 시간 아이콘
    ),
    OnboardingPage(
      title: '지금 시작하세요',
      description: '저렴한 가격으로\n필요한 장비를 대여하세요',
      icon: Icons.attach_money, // 💰 돈 아이콘
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _skipOnboarding() {
    _navigateToLogin();
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    AppStrings.skip,
                    style: context.bodyMedium?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _OnboardingPageWidget(page: page);
                },
              ),
            ),

            // Indicators and Navigation
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.borderLight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingLarge),

                  // Next/Get Started Button
                  AppButton(
                    label: _currentPage == _pages.length - 1
                        ? AppStrings.getStarted
                        : AppStrings.next,
                    onPressed: _nextPage,
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

/// Individual Onboarding Page Widget
class _OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const _OnboardingPageWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: AppDimensions.imageSizeLarge,
            height: AppDimensions.imageSizeLarge,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXLarge),

          // Title
          Text(
            page.title,
            style: context.displaySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),

          // Description
          Text(
            page.description,
            style: context.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
