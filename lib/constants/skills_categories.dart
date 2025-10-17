/// Skills categories for Culture Connection app
class SkillsCategories {
  /// Technology & Engineering
  static const String techCategory = '🔧 Technology & Engineering';
  static const List<String> technologySkills = [
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
  ];

  /// Marketing, Branding & PR
  static const String marketingCategory = '📢 Marketing, Branding & PR';
  static const List<String> marketingSkills = [
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
  ];

  /// Business, Finance & Consulting
  static const String businessCategory = '💼 Business, Finance & Consulting';
  static const List<String> businessSkills = [
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
  ];

  /// Leadership & Organizational Development
  static const String leadershipCategory =
      '🧩 Leadership & Organizational Development';
  static const List<String> leadershipSkills = [
    'Executive Leadership Coaching',
    'Team Building / Organizational Culture',
    'Diversity, Equity & Inclusion Strategy',
    'Public Speaking / Communication',
    'Time Management / Productivity Systems',
    'Conflict Resolution / Mediation',
  ];

  /// Entrepreneurship & Startups
  static const String entrepreneurshipCategory = '💡 Entrepreneurship & Startups';
  static const List<String> entrepreneurshipSkills = [
    'Startup Formation & Legal Structure',
    'Fundraising / Venture Capital Readiness',
    'Pitching & Investor Relations',
    'Product Development',
    'Scaling Operations',
    'Community Building',
  ];

  /// Creative, Media & Arts
  static const String creativeCategory = '🎨 Creative, Media & Arts';
  static const List<String> creativeSkills = [
    'Photography / Videography',
    'Creative Direction',
    'Fashion Design / Styling',
    'Music Production / Audio Engineering',
    'Writing / Editing / Journalism',
    'Visual Arts / Illustration',
    'Acting / Performing Arts',
  ];

  /// Health, Wellness & Lifestyle
  static const String wellnessCategory = '🧘🏽‍♀️ Health, Wellness & Lifestyle';
  static const List<String> wellnessSkills = [
    'Therapy / Counseling',
    'Life Coaching / Mindset Coaching',
    'Nutrition / Fitness Training',
    'Yoga / Meditation Instruction',
    'Wellness Brand Strategy',
    'Health Tech Innovation',
  ];

  /// Education & Mentorship
  static const String educationCategory = '🏫 Education & Mentorship';
  static const List<String> educationSkills = [
    'Tutoring / Academic Support',
    'Curriculum Development',
    'Training & Facilitation',
    'Career Coaching / Resume Support',
    'Mentorship / Professional Guidance',
  ];

  /// Trades & Services
  static const String tradesCategory = '🏠 Trades & Services';
  static const List<String> tradesSkills = [
    'Construction / General Contracting',
    'Real Estate / Property Management',
    'Home Design / Interior Decorating',
    'Cleaning / Maintenance',
    'Landscaping / Sustainability',
  ];

  /// All categories map
  static const Map<String, List<String>> allCategories = {
    techCategory: technologySkills,
    marketingCategory: marketingSkills,
    businessCategory: businessSkills,
    leadershipCategory: leadershipSkills,
    entrepreneurshipCategory: entrepreneurshipSkills,
    creativeCategory: creativeSkills,
    wellnessCategory: wellnessSkills,
    educationCategory: educationSkills,
    tradesCategory: tradesSkills,
  };

  /// Get all skills as a flat list
  static List<String> getAllSkillsFlat() {
    return [
      ...technologySkills,
      ...marketingSkills,
      ...businessSkills,
      ...leadershipSkills,
      ...entrepreneurshipSkills,
      ...creativeSkills,
      ...wellnessSkills,
      ...educationSkills,
      ...tradesSkills,
    ];
  }

  /// Get category for a skill
  static String? getCategoryForSkill(String skill) {
    for (var entry in allCategories.entries) {
      if (entry.value.contains(skill)) {
        return entry.key;
      }
    }
    return null;
  }
}
