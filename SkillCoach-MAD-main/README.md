# SkillCoachR

SkillCoachR is an AI-powered skill-building platform designed to help users learn new skills efficiently while maintaining a healthy work-life balance. It provides personalized roadmaps, progress tracking, and interactive learning tools.

## Key Features

- Personalized Roadmaps: Automatically generated paths based on user goals and current skill levels.
- AI Analysis: Deep analysis of skill gaps and learning progress.
- Interactive Learning: Integrated games like Sudoku to sharpen cognitive skills.
- Health-First Coaching: Global "Rest Reminders" that suggest breaks every 30 minutes to prevent burnout.
- Real-Time Support: Built-in chat functionality for immediate assistance.
- Visual Progress: Dynamic charts and analytics to track growth over time.

## Tech Stack

- Framework: Flutter
- State Management: Riverpod (using Riverpod Generator for type-safety)
- Navigation: GoRouter (with support for nested navigation)
- Backend: Firebase (Authentication, Firestore, and Cloud Functions)
- Design: Material 3, Google Fonts (Poppins), and Phosphor Icons
- Data Handling: Freezed and JSON Serializable for robust data models

## Project Structure

The project follows a feature-based architecture with a centralized core layer:

- lib/core/: Contains shared logic, themes, routing, and global services.
- lib/features/: Contains independent modules like Auth, Roadmap, Chat, and Games.
- lib/main.dart: The central entry point where all services are initialized.

## Getting Started

1. Clone the repository.
2. Ensure you have the Flutter SDK installed (version 3.10.0 or higher).
3. Run 'flutter pub get' to install all dependencies.
4. Run 'flutter pub run build_runner build' to generate necessary code files.
5. Connect your Firebase project and add the 'google-services.json' file to the android/app directory.
6. Run the app using 'flutter run'.

## Architecture Highlights

- Reactive UI: The app UI updates instantly to data changes using Riverpod providers.
- Smart Routing: Uses Stateful Shell Routes to maintain tab states across the application.
- Global Well-being: A top-level listener monitors session time to encourage healthy learning habits.
