# Profile Feature

This directory handles the user profile management view.

## Structure
*   **`screens/`**: Contains the main `profile_screen.dart` layout.
*   **`widgets/`**: Reusable components such as `profile_header_widget.dart` and `profile_stats_widget.dart` to keep the main screen clean.
*   **`providers/`**: Uses Riverpod (`profile_provider.dart`) to hold the user's name, email, avatar, and learning statistics.

This architecture ensures a clean separation between UI components and business logic.
