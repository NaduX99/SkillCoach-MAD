import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_setup_provider.dart';

class ProfileSetupStep2Screen extends ConsumerStatefulWidget {
  const ProfileSetupStep2Screen({super.key});

  @override
  ConsumerState<ProfileSetupStep2Screen> createState() => _ProfileSetupStep2ScreenState();
}

class _ProfileSetupStep2ScreenState extends ConsumerState<ProfileSetupStep2Screen> {
  String? _selectedEducation;

  final List<String> _educationLevels = [
    'High School',
    'Associate Degree',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'Doctorate (PhD)',
    'Other/None'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(PhosphorIcons.caretLeft(), color: Colors.black87),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Setup Your Profile',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          'Step 2 of 5',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F2FE), // Light blue background for icon
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIcons.graduationCap(),
                    color: const Color(0xFF0284C7), // Darker blue icon
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Segmented Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Row(
              children: List.generate(5, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < 4 ? 6.0 : 0),
                    decoration: BoxDecoration(
                      color: index < 2 ? const Color(0xFF00C7D4) : const Color(0xFFF1F5F9), // Teal for active, light grey for inactive
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // AI Coach Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F9FF),
                      border: Border.all(color: const Color(0xFFD6E4F8)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6FB1FC), Color(0xFF1C5CE5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(PhosphorIcons.sparkle(PhosphorIconsStyle.fill), color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'AI Coach',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(PhosphorIcons.dotsThree(), color: const Color(0xFF00C7D4), size: 16),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Your education background helps me understand your learning style.",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFF334155),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Center Avatar Section
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFD8F3F1), // Light teal background
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      PhosphorIcons.graduationCap(),
                      size: 48,
                      color: const Color(0xFF0096B1), // Deep teal icon
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Education Dropdown Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "What's your education level?",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedEducation,
                    icon: Icon(
                      PhosphorIcons.caretDown(),
                      color: const Color(0xFF94A3B8),
                      size: 20,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC), // very light grey background
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 12),
                        child: Icon(
                          PhosphorIcons.graduationCap(PhosphorIconsStyle.fill),
                          color: const Color(0xFF3A3A3A),
                          size: 20,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 24,
                      ),
                    ),
                    hint: Text(
                      'Select level',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF334155),
                      fontSize: 14,
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    items: _educationLevels.map((String level) {
                      return DropdownMenuItem<String>(
                        value: level,
                        child: Text(level),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedEducation = newValue;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Navigation Button
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _selectedEducation != null
                    ? () {
                        ref.read(profileSetupProvider.notifier).setEducation(_selectedEducation!);
                        context.pushNamed('profile_setup_step3');
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedEducation != null ? const Color(0xFF3265D6) : const Color(0xFFE2E8F0), // match screenshot button shade
                  foregroundColor: _selectedEducation != null ? Colors.white : const Color(0xFF94A3B8),
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  disabledForegroundColor: const Color(0xFF94A3B8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Next',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

