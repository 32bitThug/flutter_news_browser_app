import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_browser/rss_news/screens/sources_selection_screen.dart';
import 'category_selection_screen.dart';
import 'language_selection_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final String selectedLanguage;

  WelcomeScreen({required this.selectedLanguage});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  final PageController _secondPageController = PageController();
  String selectedLanguage = "";
  Map<String, Map<String, dynamic>> localizedText = {};
  int _currentPageIndex = 0; // Track the current page index of the second PageView

  Map<String, List<String>> onboardingImages = {
    'en': [
      'assets/onBoarding_images/english_img1.png',
      'assets/onBoarding_images/english_img2.png',
      'assets/onBoarding_images/english_img3.png',
    ],
    'hi': [
      'assets/onBoarding_images/hindi_img1.png',
      'assets/onBoarding_images/hindi_img2.png',
      'assets/onBoarding_images/hindi_img3.png',
    ],
    'kd': [
      'assets/onBoarding_images/kannada_img1.png',
      'assets/onBoarding_images/kannada_img2.png',
      'assets/onBoarding_images/kannada_img3.png',
    ],
  };

  @override
  void initState() {
    super.initState();
    selectedLanguage = widget.selectedLanguage;
    _loadLocalizedText();
    _autoSlidePages();
  }

  void _autoSlidePages() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_pageController.hasClients) {
        int currentPage = _pageController.page!.round();
        if (currentPage < 2) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeIn,
          );
        } else {
          _pageController.jumpToPage(0);
        }
        _autoSlidePages();
      }
    });
  }

  void _loadLocalizedText() {
    localizedText = {
      'en': {
        'welcome': 'Discover the Best News Experience!',
        'selectLanguage': 'Your World, Your Language',
        'promotions': {
          'text1': 'Stay Ahead with Real-time News!',
          'text2': 'News From Trusted Sources Just for You!',
          'text3': 'Get Personalized News, Anytime, Anywhere!',
        },
        'almostDone': 'Your Personalized Feed Awaits!',
      },
      'hi': {
        'welcome': 'सबसे बेहतरीन न्यूज़ अनुभव का आनंद लें!',
        'selectLanguage': 'आपकी भाषा, आपकी दुनिया',
        'promotions': {
          'text1': 'रियल-टाइम न्यूज़ से हमेशा आगे रहें!',
          'text2': 'विश्वसनीय स्रोतों से न्यूज़, सिर्फ आपके लिए!',
          'text3': 'कहीं भी, कभी भी, आपकी पसंदीदा न्यूज़!',
        },
        'almostDone': 'आपका व्यक्तिगत न्यूज़ फीड तैयार है!',
      },
      'kd': {
        'welcome': 'ಉತ್ತಮ ಸುದ್ದಿಗಳ ಅನುಭವವನ್ನು ಅನ್ವೇಷಿಸಿ!',
        'selectLanguage': 'ನಿಮ್ಮ ಪ್ರಪಂಚ, ನಿಮ್ಮ ಭಾಷೆ',
        'promotions': {
          'text1': 'ವಾಸ್ತವಿಕ ಕಾಲದ ಸುದ್ದಿಗಳೊಂದಿಗೆ ಮುಂಚೆ ಇರಿ!',
          'text2': 'ನಿಮಗಾಗಿ ನಂಬಬಹುದಾದ ಮೂಲಗಳಿಂದ ಸುದ್ದಿಗಳು!',
          'text3': 'ಯಾವುದೇ ಸಮಯದಲ್ಲಿ, ಎಲ್ಲಿಯೂ, ನಿಮ್ಮ ವೈಯಕ್ತಿಕ ಸುದ್ದಿಗಳು!',
        },
        'almostDone': 'ನಿಮ್ಮ ವೈಯಕ್ತಿಕ ಸುದ್ದಿ ಫೀಡ್ ಸಿದ್ಧವಾಗಿದೆ!',
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // First PageView
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  children: [
                    _firstOnBoardingScreen(),
                    _secondOnBoardingScreen(),
                    _thirdOnBoardingScreen(),
                  ],
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: 3,
                      effect: ExpandingDotsEffect(
                        activeDotColor: Colors.white,
                        dotColor: Colors.grey,
                        dotHeight: 5,
                        dotWidth: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Second PageView
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                PageView(
                  controller: _secondPageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageIndex = index; // Update current page index
                    });
                  },
                  children: const [
                    LanguageSelectionScreen(fromWelcomeScreen: true),
                    CategoriesSelectionScreen(fromWelcomeScreen: true),
                    SourcesSelectionScreen(),
                  ],
                ),
                // Floating action buttons
                _buildFloatingActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build the floating action buttons based on the current page index
  // Build the floating action buttons based on the current page index
  Widget _buildFloatingActionButtons() {
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          Visibility(
            visible: _currentPageIndex > 0, // Show only if not on the first slide
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: FloatingActionButton(
                onPressed: () {
                  _secondPageController.previousPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                backgroundColor: Colors.blue,
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ),
          // Next button
          Visibility(
            visible: _currentPageIndex < 2, // Show only if not on the last slide
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: FloatingActionButton(
                onPressed: () {
                  _secondPageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Icon(Icons.arrow_forward),
                backgroundColor: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }


  // Build Onboarding Screens
  Widget _firstOnBoardingScreen() {
    String image = onboardingImages[selectedLanguage]![0];
    return _buildOnboardingScreen(image, localizedText[selectedLanguage]!['welcome']!);
  }

  Widget _secondOnBoardingScreen() {
    String image = onboardingImages[selectedLanguage]![1];
    return _buildOnboardingScreen(image, localizedText[selectedLanguage]!['promotions']['text2']!);
  }

  Widget _thirdOnBoardingScreen() {
    String image = onboardingImages[selectedLanguage]![2];
    return _buildOnboardingScreen(image, localizedText[selectedLanguage]!['almostDone']!);
  }

  // Reusable method for building onboarding screens
  Widget _buildOnboardingScreen(String image, String text) {
    return Stack(
      children: [
        // Background image
        ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        // Text on top of the image
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Center(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}
