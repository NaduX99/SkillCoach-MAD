# News Insights Feature

This directory handles the "World News & AI" section of the application.

## Architecture & State Management

*   **`domain/models/news_article.dart`**: Defines the data structure for a single news article.
*   **`presentation/providers/news_provider.dart`**: Uses Riverpod (`StateNotifierProvider`) to hold and manage the state of the news feed. It provides the initial list of articles.
*   **`presentation/widgets/news_card_widget.dart`**: A highly reusable UI component responsible for displaying a `NewsArticle`.
*   **`presentation/screens/news_insights_screen.dart`**: The main screen that acts as a `ConsumerWidget` to read data from the `newsProvider` and render a list of `NewsCardWidget`s.

This structure allows for easy unit testing and future integration with a remote API.
