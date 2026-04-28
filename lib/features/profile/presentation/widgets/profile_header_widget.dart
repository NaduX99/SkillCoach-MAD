import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String name;
  final String email;
  final String avatarUrl;

  const ProfileHeaderWidget({
    Key? key,
    required this.name,
    required this.email,
    required this.avatarUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(avatarUrl),
          backgroundColor: Colors.grey[200],
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
