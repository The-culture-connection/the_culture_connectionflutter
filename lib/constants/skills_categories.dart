/// All skills categories and subcategories for Culture Connection
class SkillsCategories {
  static const Map<String, List<String>> categories = {
    '🔧 Technology & Engineering': [
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
    '📢 Marketing, Branding & PR': [
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
    '💼 Business, Finance & Consulting': [
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
    '🧩 Leadership & Organizational Development': [
      'Executive Leadership Coaching',
      'Team Building / Organizational Culture',
      'Diversity, Equity & Inclusion Strategy',
      'Public Speaking / Communication',
      'Time Management / Productivity Systems',
      'Conflict Resolution / Mediation',
    ],
    '💡 Entrepreneurship & Startups': [
      'Startup Formation & Legal Structure',
      'Fundraising / Venture Capital Readiness',
      'Pitching & Investor Relations',
      'Product Development',
      'Scaling Operations',
      'Community Building',
    ],
    '🎨 Creative, Media & Arts': [
      'Photography / Videography',
      'Creative Direction',
      'Fashion Design / Styling',
      'Music Production / Audio Engineering',
      'Writing / Editing / Journalism',
      'Visual Arts / Illustration',
      'Acting / Performing Arts',
    ],
    '🧘🏽‍♀️ Health, Wellness & Lifestyle': [
      'Therapy / Counseling',
      'Life Coaching / Mindset Coaching',
      'Nutrition / Fitness Training',
      'Yoga / Meditation Instruction',
      'Wellness Brand Strategy',
      'Health Tech Innovation',
    ],
    '🏫 Education & Mentorship': [
      'Tutoring / Academic Support',
      'Curriculum Development',
      'Training & Facilitation',
      'Career Coaching / Resume Support',
      'Mentorship / Professional Guidance',
    ],
    '🏠 Trades & Services': [
      'Construction / General Contracting',
      'Real Estate / Property Management',
      'Home Design / Interior Decorating',
      'Cleaning / Maintenance',
      'Landscaping / Sustainability',
    ],
    '💅 Cosmetology': [
      'Hair Care & Styling',
      'Nail Care',
      'Makeup & Cosmetics',
      'Skin Care & Aesthetics',
      'Body & Spa Services',
      'Wellness & Image',
      'Beauty Product & Brand Services',
    ],
  };

  /// Get all category names
  static List<String> getCategoryNames() {
    return categories.keys.toList();
  }

  /// Get all skills for a specific category
  static List<String> getSkillsForCategory(String category) {
    return categories[category] ?? [];
  }

  /// Get all skills flattened into a single list
  static List<String> getAllSkills() {
    List<String> allSkills = [];
    categories.forEach((category, skills) {
      allSkills.addAll(skills);
    });
    return allSkills;
  }

  /// Search skills by query
  static List<String> searchSkills(String query) {
    if (query.isEmpty) return [];
    
    final lowercaseQuery = query.toLowerCase();
    List<String> results = [];
    
    categories.forEach((category, skills) {
      for (var skill in skills) {
        if (skill.toLowerCase().contains(lowercaseQuery)) {
          results.add(skill);
        }
      }
    });
    
    return results;
  }

  /// Get category for a specific skill
  static String? getCategoryForSkill(String skill) {
    for (var entry in categories.entries) {
      if (entry.value.contains(skill)) {
        return entry.key;
      }
    }
    return null;
  }
}
