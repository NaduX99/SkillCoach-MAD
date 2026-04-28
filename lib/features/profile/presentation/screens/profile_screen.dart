import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/profile_provider.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_stats_widget.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black87),
            onPressed: () {
              // Open Settings
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileHeaderWidget(
                  name: profileState.name,
                  email: profileState.email,
                  avatarUrl: profileState.avatarUrl,
                ),
                const SizedBox(height: 32),
                
                ProfileStatsWidget(
                  hoursLearned: profileState.hoursLearned,
                  coursesCompleted: profileState.coursesCompleted,
                ),
                const SizedBox(height: 32),
                
                // Settings Options
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text('Edit Profile', style: GoogleFonts.poppins()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_none),
                  title: Text('Notifications', style: GoogleFonts.poppins()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: Text('Security', style: GoogleFonts.poppins()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
