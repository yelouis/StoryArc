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
   - **Implementation**: Enforced Firestore sub-collections (`users/{userId}/plotlines/{plotlineId}/sessions`) for `Session` objects to ensure referential integrity and logical grouping.

2. **Narrative Repository Pattern (Finalized - May 03)**:
   - **Root Cause**: Direct Firestore calls from the UI would lead to tight coupling and difficult testing.
   - **Implementation**: Implemented `PlotlineRepository` and `SessionRepository` using Riverpod providers. Added automatic `lastActive` timestamp updates on the `Plotline` whenever a new `Session` is added.

3. **Glassmorphic UI Foundation (Finalized - May 03)**:
   - **Root Cause**: Standard Material cards lacked the "Cinematic" feel required for the project.
   - **Implementation**: Refactored `PlotlineCard` with `flutter_animate` to include scale-up transitions, shimmer effects, and a custom pinning mechanism.

4. **Dynamic Library Filtering (Finalized - May 03)**:
   - **Root Cause**: A static list of plotlines becomes unmanageable as the library grows.
   - **Implementation**: Implemented a functional search system and a "Pinned" section in `LibraryScreen` to prioritize active narratives.

## 🎬 Active Limitations & Narrative Backlog

- **Emoji Picker Performance**: The standard `emoji_picker_flutter` can cause minor frame drops during the first load. Investigating pre-caching or native picker alternatives for Phase 2.
- **Advanced Conflict Resolution**: Firestore handles basic offline sync, but concurrent edits on multiple devices for the same entry are not yet handled with a specific merge strategy.
- **Rich Text Support**: Manual entries are currently plain text. Implementing a Markdown or Delta-based rich text editor is suggested for Phase 2.
- **Draft Recovery**: While local state holds the current entry, a crash during editing would result in data loss. Implementing an `Isar`-based local draft cache is suggested.



