import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BlackCardDetailScreen extends StatefulWidget {
  final String claimedCodeId;
  final String themeDocId;
  final String businessId;

  const BlackCardDetailScreen({
    Key? key,
    required this.claimedCodeId,
    required this.themeDocId,
    required this.businessId,
  }) : super(key: key);

  @override
  State<BlackCardDetailScreen> createState() => _BlackCardDetailScreenState();
}

class _BlackCardDetailScreenState extends State<BlackCardDetailScreen> {
  Map<String, dynamic>? _businessData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBusinessData();
  }

  Future<void> _loadBusinessData() async {
    try {
      if (widget.themeDocId.isEmpty || widget.businessId.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Fetch business document from Ultra Black Friday collection
      final businessDoc = await FirebaseFirestore.instance
          .collection('Ultra Black Friday')
          .doc(widget.themeDocId)
          .collection('businesses')
          .doc(widget.businessId)
          .get();

      if (businessDoc.exists) {
        setState(() {
          _businessData = businessDoc.data();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading business data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Business Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF6600),
              ),
            )
          : _businessData == null
              ? Center(
                  child: Text(
                    'Business information not available',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Business Logo/Header
                      _buildHeader(),

                      // Business Info
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Business Name
                            Text(
                              _businessData!['businessName'] ?? 'Business Name',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Category/Type
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (_businessData!['mainCategory'] != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF6600)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFFFF6600),
                                      ),
                                    ),
                                    child: Text(
                                      _businessData!['mainCategory'],
                                      style: const TextStyle(
                                        color: Color(0xFFFF6600),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                if (_businessData!['subCategory'] != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.grey[700]!,
                                      ),
                                    ),
                                    child: Text(
                                      _businessData!['subCategory'],
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                if (_businessData!['priceRange'] != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.grey[700]!,
                                      ),
                                    ),
                                    child: Text(
                                      _businessData!['priceRange'],
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Deal Information
                            if (_businessData!['deal'] != null)
                              _buildDealSection(_businessData!['deal'] as Map<String, dynamic>),

                            const SizedBox(height: 24),

                            // Description
                            if (_businessData!['shortDescription'] != null) ...[
                              const Text(
                                'About',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _businessData!['shortDescription'],
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Service Types
                            if (_businessData!['serviceTypes'] != null &&
                                (_businessData!['serviceTypes'] as List).isNotEmpty) ...[
                              const Text(
                                'Service Type',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: (_businessData!['serviceTypes'] as List)
                                    .map<Widget>((type) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[800],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            type.toString(),
                                            style: TextStyle(
                                              color: Colors.grey[300],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Hours
                            if (_businessData!['hours'] != null) ...[
                              const Text(
                                'Hours',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _businessData!['hours'],
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            const SizedBox(height: 32),

                            // Location Section
                            if (_businessData!['address'] != null)
                              _buildLocationSection(),

                            const SizedBox(height: 32),

                            // Booking Link
                            if (_businessData!['bookingLink'] != null) ...[
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _launchUrl(_businessData!['bookingLink']),
                                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                                  label: const Text(
                                    'Book Appointment',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF6600),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Menu Link
                            if (_businessData!['menuLink'] != null) ...[
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => _launchUrl(_businessData!['menuLink']),
                                  icon: const Icon(Icons.menu_book, color: Color(0xFFFF6600)),
                                  label: const Text(
                                    'View Menu / Services',
                                    style: TextStyle(color: Color(0xFFFF6600)),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFFF6600)),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],

                            // Contact Information
                            const Text(
                              'Contact Information',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Phone
                            if (_businessData!['phone'] != null)
                              _buildContactItem(
                                icon: Icons.phone,
                                label: 'Phone',
                                value: _businessData!['phone'],
                                onTap: () =>
                                    _launchUrl('tel:${_businessData!['phone']}'),
                              ),

                            // Website
                            if (_businessData!['website'] != null)
                              _buildContactItem(
                                icon: Icons.language,
                                label: 'Website',
                                value: _businessData!['website'],
                                onTap: () => _launchUrl(_businessData!['website']),
                              ),

                            // Email
                            if (_businessData!['email'] != null)
                              _buildContactItem(
                                icon: Icons.email,
                                label: 'Email',
                                value: _businessData!['email'],
                                onTap: () =>
                                    _launchUrl('mailto:${_businessData!['email']}'),
                              ),

                            const SizedBox(height: 32),

                            // Social Media
                            if (_hasSocialMedia())
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Social Media',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildSocialMediaButtons(),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    final logoUrl = _businessData!['logoUrl'];

    return Stack(
      children: [
        // Cover/Background
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFF6600).withOpacity(0.8),
                const Color(0xFFFF8833).withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Logo overlay
        if (logoUrl != null)
          Positioned(
            bottom: -40,
            left: 20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 4),
                image: DecorationImage(
                  image: NetworkImage(logoUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDealSection(Map<String, dynamic> dealData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6600).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF6600).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deal Details',
            style: TextStyle(
              color: Color(0xFFFF6600),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (dealData['title'] != null) ...[
            Text(
              dealData['title'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (dealData['discountValue'] != null && dealData['discountType'] != null) ...[
            Text(
              '${dealData['discountValue']}${dealData['discountType']}',
              style: const TextStyle(
                color: Color(0xFFFF6600),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (dealData['description'] != null) ...[
            Text(
              dealData['description'],
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (dealData['terms'] != null) ...[
            const Text(
              'Terms & Conditions:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dealData['terms'],
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (dealData['redemptionInstructions'] != null) ...[
            const Text(
              'How to Redeem:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dealData['redemptionInstructions'],
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    final addressData = _businessData!['address'] as Map<String, dynamic>?;
    final mapLink = addressData?['mapLink'];

    String? addressString;
    if (addressData != null) {
      final parts = <String>[];
      if (addressData['street'] != null) parts.add(addressData['street']);
      if (addressData['city'] != null) parts.add(addressData['city']);
      if (addressData['state'] != null) parts.add(addressData['state']);
      if (addressData['zip'] != null) parts.add(addressData['zip']);
      addressString = parts.join(', ');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Where to Redeem',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (addressString != null && addressString.isNotEmpty)
          InkWell(
            onTap: () {
              if (mapLink != null && mapLink.toString().isNotEmpty) {
                _launchUrl(mapLink.toString());
              } else if (addressString != null) {
                _launchUrl(
                    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(addressString)}');
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFFFF6600),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      addressString,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        if (addressString != null && addressString.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                if (mapLink != null && mapLink.toString().isNotEmpty) {
                  _launchUrl(mapLink.toString());
                } else {
                  _launchUrl(
                      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(addressString!)}');
                }
              },
              icon: const Icon(Icons.directions, color: Colors.white),
              label: const Text(
                'Get Directions',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6600),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFFFF6600),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[600],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasSocialMedia() {
    final social = _businessData!['social'] as Map<String, dynamic>?;
    if (social == null) return false;
    return social['instagram'] != null ||
        social['facebook'] != null ||
        social['twitter'] != null ||
        social['tiktok'] != null ||
        social['linkedin'] != null;
  }

  Widget _buildSocialMediaButtons() {
    final social = _businessData!['social'] as Map<String, dynamic>?;
    if (social == null) return const SizedBox.shrink();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (social['instagram'] != null)
          _buildSocialButton(
            icon: Icons.camera_alt,
            label: 'Instagram',
            onTap: () => _launchUrl(social['instagram']),
          ),
        if (social['facebook'] != null)
          _buildSocialButton(
            icon: Icons.facebook,
            label: 'Facebook',
            onTap: () => _launchUrl(social['facebook']),
          ),
        if (social['twitter'] != null)
          _buildSocialButton(
            icon: Icons.message,
            label: 'Twitter',
            onTap: () => _launchUrl(social['twitter']),
          ),
        if (social['tiktok'] != null)
          _buildSocialButton(
            icon: Icons.music_note,
            label: 'TikTok',
            onTap: () => _launchUrl(social['tiktok']),
          ),
        if (social['linkedin'] != null)
          _buildSocialButton(
            icon: Icons.business,
            label: 'LinkedIn',
            onTap: () => _launchUrl(social['linkedin']),
          ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFF6600)),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFFFF6600),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open link'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}


