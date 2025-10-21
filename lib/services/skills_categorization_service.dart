class SkillsCategorizationService {
  static const Map<String, List<String>> _skillCategories = {
    'Technology & Engineering': [
      'Software Development',
      'Web Design / UX/UI Design',
      'App Development (iOS / Android / Flutter)',
      'Data Analysis / Data Science',
      'Machine Learning / AI Integration',
      'Cybersecurity',
      'Cloud Computing (AWS / Firebase / Azure)',
      'IT Support & Systems Administration',
      'Automation / Scripting',
      'CAD Design / Product Prototyping',
      'Electrical / Mechanical Engineering',
    ],
    'Marketing, Branding & PR': [
      'Public Relations (PR)',
      'Brand Strategy',
      'Marketing Campaign Development',
      'Social Media Management',
      'Copywriting / Content Strategy',
      'Influencer Relations',
      'Event Marketing / Experiential Marketing',
      'SEO / SEM / Paid Ads',
      'Graphic Design',
      'Video Editing / Photography',
    ],
    'Business, Finance & Consulting': [
      'Financial Consulting',
      'Funding Strategy / Grant Writing',
      'Business Planning & Modeling',
      'Accounting / Bookkeeping',
      'Market Research / Competitive Analysis',
      'Strategic Partnerships',
      'Investor Relations / Pitch Decks',
      'Sales / Lead Generation',
      'Project Management',
      'Business Development',
    ],
    'Leadership & Organizational Development': [
      'Executive Leadership Coaching',
      'Team Building / Organizational Culture',
      'Diversity, Equity & Inclusion Strategy',
      'Public Speaking / Communication',
      'Time Management / Productivity Systems',
      'Conflict Resolution / Mediation',
    ],
    'Entrepreneurship & Startups': [
      'Startup Formation & Legal Structure',
      'Fundraising / Venture Capital Readiness',
      'Pitching & Investor Relations',
      'Product Development',
      'Scaling Operations',
      'Community Building',
    ],
    'Creative, Media & Arts': [
      'Photography / Videography',
      'Creative Direction',
      'Fashion Design / Styling',
      'Music Production / Audio Engineering',
      'Writing / Editing / Journalism',
      'Visual Arts / Illustration',
      'Acting / Performing Arts',
    ],
    'Health, Wellness & Lifestyle': [
      'Therapy / Counseling',
      'Life Coaching / Mindset Coaching',
      'Nutrition / Fitness Training',
      'Yoga / Meditation Instruction',
      'Wellness Brand Strategy',
      'Health Tech Innovation',
    ],
    'Education & Mentorship': [
      'Tutoring / Academic Support',
      'Curriculum Development',
      'Training & Facilitation',
      'Career Coaching / Resume Support',
      'Mentorship / Professional Guidance',
    ],
    'Trades & Services': [
      'Construction / General Contracting',
      'Real Estate / Property Management',
      'Home Design / Interior Decorating',
      'Cleaning / Maintenance',
      'Landscaping / Sustainability',
    ],
  };

  /// Get the main category for a given sub-skill
  static String? getMainCategoryForSkill(String subSkill) {
    for (final entry in _skillCategories.entries) {
      if (entry.value.contains(subSkill)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Get all sub-skills for a given main category
  static List<String> getSubSkillsForCategory(String mainCategory) {
    return _skillCategories[mainCategory] ?? [];
  }

  /// Get all main categories
  static List<String> getAllMainCategories() {
    return _skillCategories.keys.toList();
  }

  /// Categorize a list of sub-skills into their main categories
  static Map<String, List<String>> categorizeSkills(List<String> subSkills) {
    final Map<String, List<String>> categorized = {};
    
    for (final subSkill in subSkills) {
      final mainCategory = getMainCategoryForSkill(subSkill);
      if (mainCategory != null) {
        if (!categorized.containsKey(mainCategory)) {
          categorized[mainCategory] = [];
        }
        categorized[mainCategory]!.add(subSkill);
      }
    }
    
    return categorized;
  }

  /// Get the main categories that contain any of the provided sub-skills
  static List<String> getMainCategoriesForSkills(List<String> subSkills) {
    final Set<String> mainCategories = {};
    
    for (final subSkill in subSkills) {
      final mainCategory = getMainCategoryForSkill(subSkill);
      if (mainCategory != null) {
        mainCategories.add(mainCategory);
      }
    }
    
    return mainCategories.toList();
  }
}
