# Story Arc: AI-Powered Journaling Ecosystem
## Master Implementation Plan (Flutter Edition)

Story Arc is a modular, AI-first journaling ecosystem designed to transform unstructured conversations into consistent, meaningful life narratives called **"Plotlines."**

**Primary Goal:** Build and publish a high-end, premium mobile application for iOS and Android using **Flutter**, delivering a cinematic journaling experience powered by the Gemini Multimodal Live API.

---

## The Vision: Project North Star
The objective is to move from "log-based" journaling to "story-based" reflection. Every interaction should feel cinematic, empathetic, and organized around life's major arcs (Plotlines) rather than just timestamps.

---

## Technical Stack
*   **Framework:** Flutter (Dart)
*   **Backend & Auth:** **Firebase** (Auth, Firestore, Storage, Cloud Functions)
*   **State Management:** Riverpod (for robust, testable state)
*   **Persistence:** **Cloud Firestore (Offline-First)** — Google's industry standard for seamless local/cloud synchronization.
*   **AI Integration:** 
    *   **Gemini Multimodal Live API:** Real-time voice interaction via WebSockets.
    *   **Gemini 1.5 Flash:** Post-session metadata, mood, and **symbolic emoji extraction**.
    *   **BYOAI Pattern:** Supports user-provided API keys via the **Connection Studio** for reduced operational friction and data sovereignty.

*   **Security:** Firebase Security Rules, Cloud Function API Proxies, Prompt Injection Guardrails, **`flutter_secure_storage`** for encrypted API key storage.
*   **Media:** `record` (audio capture), `web_socket_channel` (Gemini connection), `just_audio` (playback).
*   **UI/UX:** `CustomPainter` (Visualizer), `Google Fonts` (Typography), `Animate Do` or `Flutter Animate` (Micro-animations).


---

## Implementation Phases

### [Phase 0: The Project North Star & Foundation](file:///Users/louisye/Desktop/Louis/StoryArc/docs/phase_0_foundation.md) [COMPLETE]
**Goal:** Establish the Flutter environment, theme, and core data models. Focus on the architectural "spine" of the app.

### [Phase 1: The Narrative Core (Library & Basic Input)](file:///Users/louisye/Desktop/Louis/StoryArc/docs/phase_1_narrative_core.md) [COMPLETE]
**Goal:** Implement the Plotline Library dashboard and manual entry capabilities. This establishes the CRUD layer and navigation.

### [Phase 2: The Live Experience (Real-Time Interaction)](file:///Users/louisye/Desktop/Louis/StoryArc/docs/phase_2_live_experience.md) [COMPLETE]
**Goal:** Integrate the Gemini Multimodal Live API and build the real-time audio visualizer for the core "Interview" experience.

### [Phase 3: Intelligence & Reflection (The Narrative Engine)](file:///Users/louisye/Desktop/Louis/StoryArc/docs/phase_3_intelligence.md) [COMPLETE]
**Goal:** Automate session analysis (summaries, mood) and build the interactive Narrative Timeline.

### [Phase 4: Symbolic Anchors (The Emoji Studio)](file:///Users/louisye/Desktop/Louis/StoryArc/docs/phase_4_cinematic_storytelling.md) [COMPLETE]
**Goal:** Replace complex image generation with a lightweight, symbolic anchoring system using AI-suggested emojis.

---

## User Journeys (Validation Targets)
*   **Journey A: The New Start:** Onboarding, creating first Plotline, and completing a first voice session.
*   **Journey B: The Reflective Review:** Navigating the timeline and using color-coded mood mapping to find insights.
*   **Journey C: Symbolic Reflection:** Reviewing a completed Plotline through the lens of its visual emoji anchors in the Emoji Studio.


---

## 🎞️ Production Refinements & Technical Debt

1. **Flutter/Dart Strategy (Finalized - May 03)**:
   - **Root Cause**: The project required a highly interactive UI with low-latency audio—traditionally difficult in cross-platform frameworks.
   - **Implementation**: Selected Flutter for its superior `CustomPainter` performance and FFI (Foreign Function Interface) capabilities, which will be essential for Phase 2 audio streaming.

2. **Secure Onboarding & Component Architecture (Finalized - May 03)**:
   - **Root Cause**: Handling user-provided API keys required a secure, persistent, and reactive solution, while the UI needed a premium, reusable design system.
   - **Implementation**: Implemented a cinematic "Prologue" and "Connection Studio" flow utilizing `flutter_secure_storage` and a suite of frosted-glass `ArcWidgets` to ensure both security and a high-end aesthetic from the first launch.

3. **Symbolic Pivot & Emoji Studio (Finalized - May 03)**:
   - **Root Cause**: High latency and operational costs of image generation threatened the "Live" feel of the app.
   - **Implementation**: Pivoted to a symbolic anchor system. Developed the `EmojiStudioWidget` and integrated it into the post-session flow for both voice and manual entries, allowing users to select AI-suggested "Hero Symbols" for their timeline.

## 🎬 Active Limitations & Narrative Backlog

- **Platform Parity**: Initial development is focused on iOS. Android-specific audio latency tuning is suggested for Phase 2.
- **Offline Mode**: The Narrative Engine requires an internet connection for Gemini. A local-only "Legacy Mode" with basic text-based summaries is suggested as a long-term goal.
- **Data Sovereignty**: StoryArc now prioritizes user-owned infrastructure. By allowing users to provide their own Gemini API keys, they maintain control over their data usage and costs. Future refinements include "Export to PDF/Markdown" to ensure full narrative portability.
- **Service Dependency**: The app's "Connection Studio" provides an abstraction layer that allows users to swap Gemini keys or potentially integrate other LLM providers (OpenAI/Anthropic) in the future, preventing vendor lock-in.
- **Accessibility & Inclusion**: Voice-first interaction may exclude users with speech impediments or those in loud environments. Strengthening the "Manual Entry" flow and adding a "Text-to-Speech" (TTS) backup for the AI is suggested for universal accessibility.
- **Cinematic Onboarding**: The transition from a blank state to a "Live Session" can be intimidating. Implementing a guided "Prologue" session that explains the "Plotline" concept is suggested for Phase 1.
- **Operational Costs**: Multimodal Live API usage can incur high costs. Implementing a local "Token Tracker" or usage-limiting policy in the `AppConfig` is suggested for long-term sustainability.


