# Phase 0: The Project North Star & Foundation

## Goal
Establish the architectural foundation of the Story Arc Flutter application, including the design system, persistent storage, and core data models.

## 1. Environment & Project Setup
*   **Initialization:** Create a new Flutter project: `flutter create story_arc`.
*   **Dependency Injection:** Configure **Riverpod** for global state management.
*   **Database Setup:** Integrate **Cloud Firestore** for a unified local-first and cloud-synced persistence layer.
    *   **Norms:** Use Firestore's built-in offline persistence to ensure a seamless "Industry Standard" UX.

*   **Assets:** Configure `pubspec.yaml` with Google Fonts (Outfit/Inter) and initial assets.
*   **Firebase Core:** Initialize Firebase via the FlutterFire CLI (`flutterfire configure`).
*   **Monitoring & Analytics:** Integrate **Firebase Crashlytics** and **Analytics** for real-time error tracking and user journey insights.
*   **CI/CD Pipeline:** Set up **GitHub Actions** for automated testing and building of the Flutter app.
*   **Authentication Baseline:** Implement `firebase_auth` for secure identity management.

    *   **Strategy:** Anonymous auth for immediate entry, Google Sign-in for cloud persistence.


## 2. Design System (Cosmic Theme)
*   **ThemeData:** Define a custom `ThemeData` with a dark cosmic palette:
    *   `Primary`: Deep Indigo (#1A1B4B)
    *   `Background`: Midnight Black (#0A0A0A)
    *   `Accent`: Electric Purple (#7B2CBF)
*   **Typography:** Set up `TextTheme` using Google Fonts for a premium look.
*   **Components:** Create reusable styled components: `ArcCard`, `ArcButton`, `ArcTextField`.
*   **Feature-First Architecture:** Organize `lib/` by feature (e.g., `lib/features/library`, `lib/features/live_session`) to ensure scalability as the Narrative Engine grows.


## 3. Narrative Data Model
*   **Plotline Model:**
    ```dart
    class Plotline {
      String id;
      String title;
      String emoji;
      PlotlineStatus status;
      DateTime createdAt;
    }
    ```
*   **Session Model:**
    ```dart
    class Session {
      String id;
      String plotlineId;
      DateTime date;
      String transcript;
      String? summary;
      String? moodKeyword;
      double moodScore; // -1.0 to 1.0
      String? emoji; // Visual anchor for the session (replaces imagePath)
    }
    ```
*   **Config Model (Settings):**
    ```dart
    class AppConfig {
      String? geminiApiKey; // Optional if user provides their own
      String personaPrompt;
      bool isHapticFeedbackEnabled;
      bool useUserApiKey; // Toggle for BYOAI mode
    }
    ```

## 4. Connection Studio (API Management)
*   **Goal:** Provide a zero-friction UI for users to connect their own LLM accounts.
*   **UI Features:**
    *   **Onboarding Slide:** A cinematic introduction to "Bring Your Own AI."
    *   **Secure Input:** An `ArcTextField` with obfuscation for API keys.
    *   **Validation:** A "Test Connection" button that runs a simple "Hello" prompt to Gemini.
    *   **Persistence:** Use `flutter_secure_storage` to save the key locally (encrypted).

## 5. Implementation Steps
1.  Initialize Flutter project and clean up boilerplate.
2.  Add core dependencies (`flutter_riverpod`, `cloud_firestore`, `firebase_core`, `firebase_auth`, `path_provider`, `flutter_secure_storage`).
3.  Implement the `Theme`, `AuthService`, and `AppConfig` providers.
4.  Build the **Connection Studio** UI for initial onboarding.
5.  Configure **Cloud Firestore Offline Persistence** in the `AppConfig` initialization logic.
6.  Configure **Firebase Security Rules** (Initial Lock-down: `allow read, write: if false;`).



## Validation & Success Criteria
*   [ ] App launches to a "Welcome" screen with the correct cosmic theme.
*   [ ] A test `Plotline` can be saved to and retrieved from the local database.
*   [ ] Typography matches the "Outfit" or "Inter" specification.
*   [ ] State is correctly managed via Riverpod (verify with a simple counter or theme switcher).
*   [ ] Firebase is successfully initialized and an anonymous user is created on launch.
*   [ ] Secure storage successfully holds the initial Gemini API key dummy value.


---

## 🎞️ Production Refinements & Technical Debt

1. **Architecture Baseline (Finalized - May 03)**:
   - **Root Cause**: Initial project scoping required a balance between rapid prototyping (Flutter) and heavy AI integration (Gemini).
   - **Implementation**: Adopted a feature-first directory structure and established Riverpod as the single source of truth for the `Narrative Engine` state to prevent logic fragmentation.

## 🎬 Active Limitations & Narrative Backlog

- **Firestore Collection Scaling**: Currently, large datasets are handled via standard listeners. Moving to a paginated fetching strategy for the `Timeline` is suggested before Phase 1 completion.

- **Theme Flexibility**: The cosmic theme is hardcoded for dark mode. Implementing a dynamic theme switcher that reacts to the current "Plotline mood" is suggested for Phase 3.
- **Secure Storage**: Sensitive data like API keys should not be stored in plain Firestore. Utilizing `flutter_secure_storage` for the `AppConfig` sensitive fields is highly suggested.
- **Firestore Indexing**: As the "Narrative Engine" complexity grows, composite indexes will be required for complex timeline filtering.



