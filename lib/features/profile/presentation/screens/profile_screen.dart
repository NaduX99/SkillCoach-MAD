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
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: child,
              ),
            );
          },
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
                  _buildAnimatedListTile(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                  ),
                  _buildAnimatedListTile(
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                  ),
                  _buildAnimatedListTile(
                    icon: Icons.security,
                    title: 'Security',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedListTile({required IconData icon, required String title}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: GoogleFonts.poppins()),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
