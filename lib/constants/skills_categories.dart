/// All skills categories and subcategories for Culture Connection
class SkillsCategories {
  static const Map<String, List<String>> categories = {
    '🔧 Technology & Engineering': [
    'Software Development',
    'Web / UX/UI Design',
    'App Development (iOS / Android / Flutter)',
    'Data Analysis / Data Science',
    'Machine Learning / AI Integration',
    'Cybersecurity',
    'Cloud Computing (AWS / Firebase / Azure)',
    'IT Support & Systems Administration',
    'Automation / Scripting',
    'CAD Design / Product Prototyping',
    'Electrical / Mechanical Engineering',
    'Hardware Design / Robotics',
    'Environmental / Civil Engineering'
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
    'Media Relations / Journalism'
  ],

  '💼 Business, Finance & Consulting': [
    'Financial Consulting / Advising',
    'Funding Strategy / Grant Writing',
    'Business Planning & Modeling',
    'Accounting / Bookkeeping',
    'Market Research / Competitive Analysis',
    'Strategic Partnerships',
    'Investor Relations / Pitch Decks',
    'Sales / Lead Generation',
    'Project Management',
    'Business Development',
    'Operations Management',
    'E-Commerce Strategy'
  ],

  '⚖️ Legal, Policy & Governance': [
    'Legal Consulting / Contract Law',
    'Business Formation / Compliance',
    'Intellectual Property / Trademark Law',
    'Civil Rights / Social Justice Advocacy',
    'Policy Research & Development',
    'Public Administration',
    'Regulatory Affairs',
    'Government Relations',
    'Community Organizing',
    'Civic Engagement / Voter Outreach'
  ],

  '🧩 Leadership & Organizational Development': [
    'Executive Coaching',
    'Team Building / Organizational Culture',
    'Diversity, Equity & Inclusion Strategy',
    'Public Speaking / Communication',
    'Change Management',
    'Time Management / Productivity Systems',
    'Conflict Resolution / Mediation',
    'Board Development / Governance'
  ],

  '💡 Entrepreneurship & Innovation': [
    'Startup Formation & Legal Structure',
    'Fundraising / Venture Capital Readiness',
    'Pitching & Investor Relations',
    'Product Development',
    'Scaling Operations',
    'Community Building',
    'Incubator / Accelerator Management',
    'Social Entrepreneurship'
  ],

  '🎨 Creative, Media & Arts': [
    'Photography / Videography',
    'Creative Direction',
    'Fashion Design / Styling',
    'Music Production / Audio Engineering',
    'Writing / Editing / Journalism',
    'Visual Arts / Illustration',
    'Film & Media Production',
    'Acting / Performing Arts',
    'Set Design / Costume Design',
    'Cultural Archiving / Art Curation'
  ],

  '🏥 Healthcare & Medical Professions': [
    'Registered Nursing (RN / LPN)',
    'Physician / Medical Doctor',
    'Physician Assistant (PA)',
    'Nurse Practitioner (NP)',
    'Medical / Clinical Research',
    'Public Health Administration',
    'Healthcare Management / Administration',
    'Allied Health (Radiology / Respiratory / Lab Tech)',
    'Physical Therapy / Occupational Therapy',
    'Pharmacy / Pharmacology',
    'Dental Care / Oral Health',
    'Emergency Medicine / Paramedic Services',
    'Mental Health Services / Psychiatry',
    'Health Policy & Advocacy'
  ],

  '🧪 Science & Research': [
    'Biomedical Research',
    'Environmental Science',
    'Chemistry / Physics',
    'Laboratory Technology',
    'Research Ethics & Compliance',
    'Biotech Innovation',
    'Academic Research',
    'Data Visualization & Reporting'
  ],

  '🧘🏽‍♀️ Health, Wellness & Lifestyle': [
    'Therapy / Counseling',
    'Life Coaching / Mindset Coaching',
    'Nutrition / Fitness Training',
    'Yoga / Meditation Instruction',
    'Wellness Brand Strategy',
    'Health Tech Innovation',
    'Public Health Advocacy',
    'Reproductive Health Education'
  ],

  '🏫 Education, Research & Mentorship': [
    'Tutoring / Academic Support',
    'Curriculum Development',
    'Training & Facilitation',
    'Career Coaching / Resume Support',
    'Mentorship / Professional Guidance',
    'STEM Education',
    'Educational Technology',
    'Instructional Design'
  ],

  '🏠 Trades, Real Estate & Sustainability': [
    'Construction / General Contracting',
    'Real Estate / Property Management',
    'Architecture / Urban Design',
    'Home Design / Interior Decorating',
    'Cleaning / Maintenance',
    'Landscaping / Sustainability',
    'Renewable Energy / Green Building'
  ],

  '💅 Beauty, Fashion & Cosmetology': [
    'Hair Care & Styling',
    'Nail Care',
    'Makeup & Cosmetics',
    'Skin Care & Aesthetics',
    'Body & Spa Services',
    'Wellness & Image Consulting',
    'Beauty Product & Brand Development',
    'Fashion Merchandising / Retail'
  ],

  '🌍 Social Impact & Nonprofit Leadership': [
    'Community Development',
    'Nonprofit Management',
    'Fundraising / Donor Relations',
    'Volunteer Coordination',
    'Program Evaluation',
    'Advocacy / Grassroots Organizing',
    'Environmental Justice',
    'Youth & Family Services'
  ],

  '⚙️ Manufacturing, Supply Chain & Infrastructure': [
    'Manufacturing Operations',
    'Supply Chain Management',
    'Quality Assurance / Quality Control',
    'Industrial Engineering',
    'Materials Science',
    'Logistics / Distribution',
    'Transportation Infrastructure',
    'Energy & Utilities Management'
  ],

  '🪶 Cultural Heritage & Community Preservation': [
    'Museum / Archive Management',
    'Cultural Heritage Preservation',
    'Black History Documentation',
    'Community Storytelling / Oral History',
    'Event Curation / Cultural Festivals',
    'Public Art Initiatives',
    'Heritage Tourism Development'
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
