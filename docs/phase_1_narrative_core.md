# Phase 1: The Narrative Core (Library & Basic Input)

## Goal
Build the primary user interface and CRUD functionality for managing Plotlines and manual journal entries.

## 1. Plotline Library (Dashboard)
*   **UI:** A vertically scrolling list or grid of `Plotline` cards.
*   **Search & Discovery:** Add a search bar to filter Plotlines by title or emoji.
*   **Pinned Plotlines:** Allow users to "pin" active stories to the top of the dashboard.
*   **Card Design:** Glassmorphic cards showing the emoji, title, and "last active" timestamp.

*   **Micro-Interactions:** Implement subtle scale-up animations using `Flutter Animate` when hovering or tapping a `PlotlineCard`.
*   **Navigation:** Tapping a card opens the detailed Timeline view for that Plotline via a custom hero transition.


## 2. "Add Plotline" Flow
*   **Interaction:** A Floating Action Button (FAB) or prominent "New Narrative" button.
*   **Screen:** A clean modal or full-screen input for:
    *   Title (String)
    *   Emoji (Using an emoji picker package like `emoji_picker_flutter`)
*   **Rationale:** Segmenting life into arcs makes progress tangible.

## 3. Manual Entry System
*   **UI:** A dedicated screen for text-based journaling.
*   **Features:**
    *   Auto-saving drafts.
    *   Integration with the Plotline selection.
*   **Rationale:** Ensures users can journal in quiet environments or when voice is not preferred.
*   **Cloud Infrastructure:**
    *   **Cloud Firestore:** Set up a `users/{userId}/plotlines` collection.
    *   **Repository Pattern:** Implement a `FirestoreRepository` that interacts directly with Firestore. Since offline persistence is enabled, the UI remains responsive even without a network.
    *   **Security Rules:** Implement strict per-user isolation:

      ```js
      match /users/{userId}/plotlines/{plotlineId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      ```


## 4. Implementation Steps
1.  Build the `LibraryScreen` (Dashboard) UI.
2.  Implement the `PlotlineCard` widget with glassmorphism effects.
3.  Create the `AddPlotlineScreen` and integrate with Firestore/Riverpod state.
4.  Build the `ManualEntryScreen` with a rich text input.
5.  Implement the `PlotlineRepository` using the `cloud_firestore` package.
6.  Set up basic navigation using `GoRouter` or standard Navigator.



## Validation & Success Criteria
*   [ ] User can create a new Plotline with an emoji and title.
*   [ ] Created Plotlines appear immediately on the Dashboard.
*   [ ] User can navigate from a Plotline card to an empty timeline.
*   [ ] A manual text entry can be saved and associated with a specific Plotline.
*   [ ] Data successfully persists locally and syncs to the cloud automatically via Firestore.

*   [ ] Unauthorized users are blocked from accessing other users' plotlines via Firestore rules.
*   [ ] UI handles empty states (e.g., "Start your first Plotline").


---

## 🎞️ Production Refinements & Technical Debt

1. **Plotline-Session Relationship (Finalized - May 03)**:
   - **Root Cause**: Initial model design had weak coupling between sessions and plotlines, risking orphaned data.
   - **Implementation**: Enforced `isar` links between `Session` and `Plotline` objects to ensure referential integrity and simplify "Narrative Engine" lookups.

## 🎬 Active Limitations & Narrative Backlog

- **Emoji Picker Performance**: The standard `emoji_picker_flutter` can cause jank on lower-end devices during the initial load. Optimizing the asset pre-loading or using a native picker is suggested.
- **Draft Persistence**: Manual entries currently lose state if the app process is killed. Implementing an `AutoSaveProvider` that debounces to Firestore is suggested.
- **Library Clutter**: As the number of Plotlines increases, the dashboard becomes hard to manage. Implementing "Archived Plotlines" to hide completed stories is suggested.
- **Offline Integrity**: Firestore handles basic offline sync. However, planning for complex "conflict resolution" (e.g., editing the same note on two devices) is suggested.



