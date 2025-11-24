import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BlackCardDetailScreen extends StatefulWidget {
  final String claimedCodeId;
  final String dealId;

  const BlackCardDetailScreen({
    Key? key,
    required this.claimedCodeId,
    required this.dealId,
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
      final dealDoc = await FirebaseFirestore.instance
          .collection('ultraBlackFriday')
          .doc('data')
          .collection('deals')
          .doc(widget.dealId)
          .get();

      if (dealDoc.exists) {
        final dealData = dealDoc.data()!;
        final businessId = dealData['businessId'];

        if (businessId != null) {
          final businessDoc = await FirebaseFirestore.instance
              .collection('ultraBlackFriday')
              .doc('data')
              .collection('businesses')
              .doc(businessId)
              .get();

          if (businessDoc.exists) {
            setState(() {
              _businessData = businessDoc.data();
              _isLoading = false;
            });
            return;
          }
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
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
                              _businessData!['name'] ?? 'Business Name',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Category/Type
                            if (_businessData!['category'] != null)
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
                                  _businessData!['category'],
                                  style: const TextStyle(
                                    color: Color(0xFFFF6600),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 24),

                            // Description
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
                              _businessData!['description'] ??
                                  'No description available',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Location Section
                            if (_businessData!['address'] != null)
                              _buildLocationSection(),

                            const SizedBox(height: 32),

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
    final coverUrl = _businessData!['coverImageUrl'];

    return Stack(
      children: [
        // Cover Image
        if (coverUrl != null)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              image: DecorationImage(
                image: NetworkImage(coverUrl),
                fit: BoxFit.cover,
              ),
            ),
          )
        else
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

  Widget _buildLocationSection() {
    final address = _businessData!['address'];
    final latitude = _businessData!['latitude'];
    final longitude = _businessData!['longitude'];

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
        InkWell(
          onTap: () {
            if (latitude != null && longitude != null) {
              _launchUrl(
                  'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
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
                    address,
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
        if (latitude != null && longitude != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                _launchUrl(
                    'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
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
    return _businessData!['instagram'] != null ||
        _businessData!['facebook'] != null ||
        _businessData!['twitter'] != null ||
        _businessData!['tiktok'] != null;
  }

  Widget _buildSocialMediaButtons() {
    return Row(
      children: [
        if (_businessData!['instagram'] != null)
          _buildSocialButton(
            icon: Icons.camera_alt,
            label: 'Instagram',
            onTap: () => _launchUrl(_businessData!['instagram']),
          ),
        if (_businessData!['facebook'] != null)
          _buildSocialButton(
            icon: Icons.facebook,
            label: 'Facebook',
            onTap: () => _launchUrl(_businessData!['facebook']),
          ),
        if (_businessData!['twitter'] != null)
          _buildSocialButton(
            icon: Icons.message,
            label: 'Twitter',
            onTap: () => _launchUrl(_businessData!['twitter']),
          ),
        if (_businessData!['tiktok'] != null)
          _buildSocialButton(
            icon: Icons.music_note,
            label: 'TikTok',
            onTap: () => _launchUrl(_businessData!['tiktok']),
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


