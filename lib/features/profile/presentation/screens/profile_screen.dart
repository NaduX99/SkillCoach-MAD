import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/aesthetic_background.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_stats_widget.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      body: AestheticBackground(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile',
              style: GoogleFonts.orbitron(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
                letterSpacing: 1.5,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Color(0xFF1E293B)),
              onPressed: () {
                // Open Settings
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedListTile({required IconData icon, required String title}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF64748B)),
      title: Text(title, style: GoogleFonts.poppins(color: const Color(0xFF1E293B))),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
      onTap: () {},
    );
  }
}
