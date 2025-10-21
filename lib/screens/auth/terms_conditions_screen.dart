import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'registration_screen.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  bool _hasAcceptedTerms = false;
  bool _hasAcceptedEULA = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Loginimage1-3.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        const Text(
                          'Terms & Conditions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please read and accept our terms to continue',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Terms and Conditions Content
                        _buildTermsContent(),
                        
                        const SizedBox(height: 24),
                        
                        // EULA Content
                        _buildEULAContent(),
                        
                        const SizedBox(height: 32),
                        
                        // Acceptance Checkboxes
                        _buildAcceptanceCheckboxes(),
                        
                        const SizedBox(height: 24),
                        
                        // Continue Button
                        _buildContinueButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1d1d1e),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFF7E00),
                  width: 2,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'BACK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Matches-StrikeRough',
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const Spacer(),
          
          // Logo
          Image.asset(
            'assets/CC_PrimaryLogo_SilverPurple.png',
            width: 120,
            height: 60,
          ),
        ],
      ),
    );
  }

  Widget _buildTermsContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1d1d1e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF7E00), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Terms of Service',
            style: TextStyle(
              color: Color(0xFFFF7E00),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Last Updated: December 2024',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '1. Acceptance of Terms\n\nBy accessing and using The Culture Connection app, you accept and agree to be bound by the terms and provision of this agreement.\n\n2. Use License\n\nPermission is granted to temporarily download one copy of The Culture Connection app for personal, non-commercial transitory viewing only.\n\n3. User Accounts\n\nYou are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.\n\n4. Prohibited Uses\n\nYou may not use our app:\n• For any unlawful purpose or to solicit others to perform unlawful acts\n• To violate any international, federal, provincial, or state regulations, rules, laws, or local ordinances\n• To infringe upon or violate our intellectual property rights or the intellectual property rights of others\n• To harass, abuse, insult, harm, defame, slander, disparage, intimidate, or discriminate\n• To submit false or misleading information\n\n5. Content\n\nOur app allows you to post, link, store, share and otherwise make available certain information, text, graphics, videos, or other material. You are responsible for the content that you post to the app.\n\n6. Privacy Policy\n\nYour privacy is important to us. Please review our Privacy Policy, which also governs your use of the app.\n\n7. Termination\n\nWe may terminate or suspend your account and bar access to the app immediately, without prior notice or liability, under our sole discretion, for any reason whatsoever and without limitation.\n\n8. Disclaimer\n\nThe information on this app is provided on an "as is" basis. To the fullest extent permitted by law, this Company excludes all representations, warranties, conditions and terms relating to our app and the use of this app.\n\n9. Governing Law\n\nThese terms and conditions are governed by and construed in accordance with the laws of the United States.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEULAContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1d1d1e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF7E00), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'End User License Agreement (EULA)',
            style: TextStyle(
              color: Color(0xFFFF7E00),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Last Updated: December 2024',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '1. Grant of License\n\nSubject to the terms of this Agreement, The Culture Connection grants you a limited, non-exclusive, non-transferable license to use the app solely for your personal, non-commercial purposes.\n\n2. Restrictions\n\nYou may not:\n• Copy, modify, or create derivative works of the app\n• Reverse engineer, decompile, or disassemble the app\n• Remove any proprietary notices or labels\n• Distribute, sell, or sublicense the app\n\n3. Intellectual Property\n\nThe app and its original content, features, and functionality are and will remain the exclusive property of The Culture Connection and its licensors.\n\n4. User-Generated Content\n\nYou retain ownership of content you create and share through the app, but grant us a license to use, display, and distribute such content in connection with the app.\n\n5. Privacy and Data Collection\n\nWe collect and process personal information in accordance with our Privacy Policy. By using the app, you consent to such collection and processing.\n\n6. Updates and Modifications\n\nWe reserve the right to modify or update the app at any time. Continued use after such modifications constitutes acceptance of the updated terms.\n\n7. Termination\n\nThis license is effective until terminated by either you or us. We may terminate this license at any time if you fail to comply with any term of this agreement.\n\n8. Disclaimer of Warranties\n\nThe app is provided "as is" without warranties of any kind, either express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose, or non-infringement.\n\n9. Limitation of Liability\n\nIn no event shall The Culture Connection be liable for any indirect, incidental, special, consequential, or punitive damages arising out of or relating to your use of the app.\n\n10. Governing Law\n\nThis agreement shall be governed by and construed in accordance with the laws of the United States.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptanceCheckboxes() {
    return Column(
      children: [
        // Terms Acceptance
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hasAcceptedTerms ? const Color(0xFFFF7E00) : Colors.grey,
              width: 2,
            ),
          ),
          child: CheckboxListTile(
            title: const Text(
              'I have read and agree to the Terms of Service',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
            value: _hasAcceptedTerms,
            activeColor: const Color(0xFFFF7E00),
            checkColor: Colors.white,
            onChanged: (bool? value) {
              setState(() {
                _hasAcceptedTerms = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // EULA Acceptance
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hasAcceptedEULA ? const Color(0xFFFF7E00) : Colors.grey,
              width: 2,
            ),
          ),
          child: CheckboxListTile(
            title: const Text(
              'I have read and agree to the End User License Agreement',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
            value: _hasAcceptedEULA,
            activeColor: const Color(0xFFFF7E00),
            checkColor: Colors.white,
            onChanged: (bool? value) {
              setState(() {
                _hasAcceptedEULA = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    final canContinue = _hasAcceptedTerms && _hasAcceptedEULA;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: canContinue && !_isLoading ? _continueToRegistration : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canContinue 
              ? const Color(0xFFFF7E00) 
              : Colors.grey.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'CONTINUE TO REGISTRATION',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: canContinue ? Colors.white : Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }

  Future<void> _continueToRegistration() async {
    setState(() => _isLoading = true);
    
    // Simulate a brief loading period
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const RegistrationScreen(),
        ),
      );
    }
  }
}

