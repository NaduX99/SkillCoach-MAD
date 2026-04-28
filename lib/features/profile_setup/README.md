# Profile Setup Feature

This feature handles the 5-step onboarding flow for new users, gathering necessary information such as:
1. Introduction & Welcome
2. Education Level
3. Experience Level
4. Career Goals
5. Completion and Dashboard Routing

## State Management
We use Riverpod (`profile_setup_provider.dart`) to persist the selections across the 5 screens before finally sending the data to the backend upon completion.
