import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({Key? key}) : super(key: key);

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Question 1: Business interests
  final Set<String> _selectedBusinessTypes = {};
  final List<String> _businessTypes = [
    'Food & Restaurants',
    'Beauty & Self-care',
    'Health & Wellness',
    'Fitness',
    'Professional Services',
    'Home Services',
    'Events & Entertainment',
    'Clothing & Apparel',
    'Tech & Gadgets',
    'Education & Learning',
    'Kids & Family',
    'Finance & Money',
    'Social & Nightlife',
  ];

  // Question 2: Top goals
  final Set<String> _selectedGoals = {};
  final List<String> _goals = [
    'Save money',
    'Discover Black-owned businesses',
    'Support local',
    'Improve my health',
    'Level up professionally',
    'Learn new skills',
    'Meet new people',
    'Prepare for holidays / events',
  ];

  // Question 3: Online or in-person
  String? _preferredMode;

  // Question 4: Shopping frequency
  String? _shoppingFrequency;
  final List<String> _frequencies = [
    'Every week',
    'A few times a month',
    'Occasionally',
    'Rarely',
  ];

  // Question 5: Spending areas (max 3)
  final Set<String> _spendingAreas = {};
  final List<String> _spendingOptions = [
    'Hair',
    'Nails',
    'Skincare',
    'Fitness',
    'Food delivery',
    'Travel',
    'Childcare',
    'Learning / classes',
    'Home improvement',
    'Entertainment',
    'Clothing',
    'Personal development',
  ];

  // Question 6: Life stages
  final Set<String> _lifeStages = {};
  final List<String> _lifeStageOptions = [
    'Student',
    'Entrepreneur',
    'New professional',
    'Parent',
    'Caregiver',
    'Newly moved to the city',
    'Recently single / dating',
    'Recently graduated',
  ];

  // Question 7: Price range
  int _priceRange = 2;

  // Question 8: Event preferences
  final Set<String> _eventPreferences = {};
  final List<String> _eventOptions = [
    'Brunch',
    'Nightlife',
    'Professional mixers',
    'Fitness groups',
    'Art events',
    'Volunteer events',
  ];

  // Question 9: Upcoming plans
  final Set<String> _upcomingPlans = {};
  final List<String> _planOptions = [
    'Birthday',
    'Holiday shopping',
    'Vacation',
    'Moving',
    'New job',
    'Baby',
    'Wedding',
  ];

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Ultra Black Friday',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              )
            : null,
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / 9,
                        backgroundColor: Colors.grey[800],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFF6600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_currentPage + 1}/9',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildQuestion1(),
                _buildQuestion2(),
                _buildQuestion3(),
                _buildQuestion4(),
                _buildQuestion5(),
                _buildQuestion6(),
                _buildQuestion7(),
                _buildQuestion8(),
                _buildQuestion9(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildQuestion1() {
    return _buildQuestionTemplate(
      question: 'What kinds of businesses are you most interested in?',
      subtitle: 'Select all that apply',
      child: _buildMultiSelectOptions(
        options: _businessTypes,
        selectedOptions: _selectedBusinessTypes,
        onChanged: (value) {
          setState(() {
            if (_selectedBusinessTypes.contains(value)) {
              _selectedBusinessTypes.remove(value);
            } else {
              _selectedBusinessTypes.add(value);
            }
          });
        },
      ),
    );
  }

  Widget _buildQuestion2() {
    return _buildQuestionTemplate(
      question: 'What are your top goals right now?',
      subtitle: 'This helps with lifestyle-based targeting. Select all that apply',
      child: _buildMultiSelectOptions(
        options: _goals,
        selectedOptions: _selectedGoals,
        onChanged: (value) {
          setState(() {
            if (_selectedGoals.contains(value)) {
              _selectedGoals.remove(value);
            } else {
              _selectedGoals.add(value);
            }
          });
        },
      ),
    );
  }

  Widget _buildQuestion3() {
    return _buildQuestionTemplate(
      question: 'Do you prefer online or in-person?',
      subtitle: 'Choose one',
      child: Column(
        children: [
          _buildRadioOption('Online', _preferredMode == 'Online', () {
            setState(() {
              _preferredMode = 'Online';
            });
          }),
          _buildRadioOption('In-person', _preferredMode == 'In-person', () {
            setState(() {
              _preferredMode = 'In-person';
            });
          }),
        ],
      ),
    );
  }

  Widget _buildQuestion4() {
    return _buildQuestionTemplate(
      question: 'How often do you shop with local or Black-owned businesses?',
      subtitle: 'Choose one',
      child: Column(
        children: _frequencies
            .map((freq) => _buildRadioOption(
                  freq,
                  _shoppingFrequency == freq,
                  () {
                    setState(() {
                      _shoppingFrequency = freq;
                    });
                  },
                ))
            .toList(),
      ),
    );
  }

  Widget _buildQuestion5() {
    return _buildQuestionTemplate(
      question: 'Which areas do you spend the MOST money on?',
      subtitle: 'Select up to three',
      child: _buildMultiSelectOptions(
        options: _spendingOptions,
        selectedOptions: _spendingAreas,
        maxSelections: 3,
        onChanged: (value) {
          setState(() {
            if (_spendingAreas.contains(value)) {
              _spendingAreas.remove(value);
            } else if (_spendingAreas.length < 3) {
              _spendingAreas.add(value);
            }
          });
        },
      ),
    );
  }

  Widget _buildQuestion6() {
    return _buildQuestionTemplate(
      question: 'Are you currently in any of these life stages?',
      subtitle: 'Select all that apply',
      child: _buildMultiSelectOptions(
        options: _lifeStageOptions,
        selectedOptions: _lifeStages,
        onChanged: (value) {
          setState(() {
            if (_lifeStages.contains(value)) {
              _lifeStages.remove(value);
            } else {
              _lifeStages.add(value);
            }
          });
        },
      ),
    );
  }

  Widget _buildQuestion7() {
    return _buildQuestionTemplate(
      question: 'What price range do you prefer for most purchases?',
      subtitle: 'Slide to select',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Text(
                  '\$',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: index < _priceRange
                        ? const Color(0xFFFF6600)
                        : Colors.grey[700],
                  ),
                );
              }),
            ),
          ),
          Slider(
            value: _priceRange.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            activeColor: const Color(0xFFFF6600),
            inactiveColor: Colors.grey[700],
            onChanged: (value) {
              setState(() {
                _priceRange = value.toInt();
              });
            },
          ),
          Text(
            _priceRange == 1
                ? 'Budget-friendly'
                : _priceRange == 2
                    ? 'Affordable'
                    : _priceRange == 3
                        ? 'Moderate'
                        : _priceRange == 4
                            ? 'Premium'
                            : 'Luxury',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion8() {
    return _buildQuestionTemplate(
      question: 'What events do you enjoy?',
      subtitle: 'Select all that apply',
      child: _buildMultiSelectOptions(
        options: _eventOptions,
        selectedOptions: _eventPreferences,
        onChanged: (value) {
          setState(() {
            if (_eventPreferences.contains(value)) {
              _eventPreferences.remove(value);
            } else {
              _eventPreferences.add(value);
            }
          });
        },
      ),
    );
  }

  Widget _buildQuestion9() {
    return _buildQuestionTemplate(
      question: 'Do you have any upcoming plans?',
      subtitle: 'Select all that apply',
      child: _buildMultiSelectOptions(
        options: _planOptions,
        selectedOptions: _upcomingPlans,
        onChanged: (value) {
          setState(() {
            if (_upcomingPlans.contains(value)) {
              _upcomingPlans.remove(value);
            } else {
              _upcomingPlans.add(value);
            }
          });
        },
      ),
    );
  }

  Widget _buildQuestionTemplate({
    required String question,
    required String subtitle,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }

  Widget _buildMultiSelectOptions({
    required List<String> options,
    required Set<String> selectedOptions,
    required Function(String) onChanged,
    int? maxSelections,
  }) {
    return Column(
      children: options.map((option) {
        final isSelected = selectedOptions.contains(option);
        final isDisabled = maxSelections != null &&
            selectedOptions.length >= maxSelections &&
            !isSelected;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: isDisabled ? null : () => onChanged(option),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF6600).withOpacity(0.2)
                    : Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF6600)
                      : Colors.grey[800]!,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: isSelected
                        ? const Color(0xFFFF6600)
                        : Colors.grey[600],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isDisabled ? Colors.grey[700] : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRadioOption(String option, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFF6600).withOpacity(0.2)
                : Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFFFF6600) : Colors.grey[800]!,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? const Color(0xFFFF6600) : Colors.grey[600],
              ),
              const SizedBox(width: 12),
              Text(
                option,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.grey[900]!,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleNextOrSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6600),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _currentPage == 8 ? 'Submit' : 'Next',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _handleNextOrSubmit() {
    if (_currentPage == 8) {
      _submitQuestionnaire();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitQuestionnaire() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final questionnaireData = {
        'businessInterests': _selectedBusinessTypes.toList(),
        'topGoals': _selectedGoals.toList(),
        'preferredMode': _preferredMode,
        'shoppingFrequency': _shoppingFrequency,
        'spendingAreas': _spendingAreas.toList(),
        'lifeStages': _lifeStages.toList(),
        'priceRange': _priceRange,
        'eventPreferences': _eventPreferences.toList(),
        'upcomingPlans': _upcomingPlans.toList(),
        'completedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'ultraBlackFridayPreferences': questionnaireData,
        'ultraBlackFridayQuestionnaireCompleted': true,
      });

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving preferences: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}


