import 'package:flutter/material.dart';
import '../models/business.dart';

class BusinessCard extends StatelessWidget {
  final Business business;
  final VoidCallback? onTap;

  const BusinessCard({
    super.key,
    required this.business,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF2d2d2e),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF685BC6), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Business Name and Category
              Row(
                children: [
                  Expanded(
                    child: Text(
                      business.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (business.rating != null) ...[
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      business.rating!.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                business.category,
                style: const TextStyle(
                  color: Color(0xFF685BC6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              
              // Description
              if (business.description.isNotEmpty) ...[
                Text(
                  business.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              
              // Address and Distance
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white54, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      business.displayAddress,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (business.displayDistance != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      business.displayDistance!,
                      style: const TextStyle(
                        color: Color(0xFF685BC6),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              
              // Phone and Hours
              if (business.phone.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.white54, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      business.displayPhone,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
              
              if (business.hours.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.white54, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      business.displayHours,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Price and Online Status
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                    color: const Color(0xFF685BC6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                    child: Text(
                      business.budget,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (business.isOnline) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Online',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
