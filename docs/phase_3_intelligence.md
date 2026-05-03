# Phase 3: Intelligence & Reflection (The Narrative Engine)

## Goal
Transform raw session transcripts into meaningful narrative data and visualize the emotional journey through an interactive timeline.

## 1. Post-Session Processing Pipeline
*   **Trigger:** Automatically runs after a live or manual session ends.
*   **Service:** Use **Gemini 1.5 Flash** (REST API) to analyze the full transcript.
*   **Tasks:**
    *   **Summarization:** Create a 1-2 sentence "punchy" summary.
    *   **Titling:** Generate a short, descriptive title.
    *   **Mood Analysis:** Extract a mood keyword (e.g., "Anxious," "Elated") and a sentiment score (-1.0 to 1.0).
    *   **Emoji Suggestion:** Select 3 emojis that best represent the session's theme or specific events.

*   **Secure Infrastructure:**
    *   **Rate Limiting:** Implement a Firebase Cloud Function to handle analysis requests, enforcing a rate limit (e.g., 5 requests/minute per user) to prevent API abuse.
    *   **Output Validation:** Use a strict JSON schema for Gemini's response and implement a validation layer to discard malformed or malicious AI output.

*   **User Refinement (HITL):** Allow users to manually override the AI-generated title, summary, or mood emoji to maintain narrative agency.
*   **Background Processing:** Offload JSON parsing and heavy analysis logic to a background `Isolate` to prevent UI thread blocking during post-session generation.

*   **Prompt Strategy:** Utilize few-shot prompting to ensure the "Narrative Engine" maintains a consistent cinematic tone in summaries.


## 2. Interactive Narrative Timeline
*   **UI:** A vertical timeline for each Plotline.
*   **Nodes:** Each session is represented as a node on the timeline.
*   **Mood Mapping Logic:**
    *   Map the sentiment score to a Red-Yellow-Green hex code gradient.
    *   -1.0 (Red) -> 0.0 (Yellow) -> 1.0 (Green).
*   **Rationale:** Visualizes the "emotional arc" of the story at a glance.

## 3. Implementation Steps
1.  Set up the `AnalysisService` for Gemini 1.5 Flash.
2.  Implement logic to update the `Session` model with summary/mood metadata.
3.  Build the `TimelineWidget` using a `ListView.builder` or a dedicated timeline package.
4.  Implement the `MoodColorMapper` utility for gradient interpolation.
5.  Deploy the **Analysis Cloud Function** and integrate with the Flutter app.
6.  Add "Read More" functionality to view full transcripts and summaries.


## Validation & Success Criteria
*   [ ] Each completed session generates a summary and title within 5-10 seconds.
*   [ ] The timeline displays sessions in reverse chronological order.
*   [ ] Timeline nodes are color-coded correctly according to the detected mood.
*   [ ] Tapping a timeline node displays the full AI-generated metadata.
*   [ ] Sentiment scores consistently map to the intended colors (e.g., "Frustrated" appears reddish).
*   [ ] Analysis requests are successfully rate-limited at the backend level.
*   [ ] Malformed AI JSON responses are caught and handled gracefully without crashing the UI.


---

## 🎞️ Production Refinements & Technical Debt

1. **Analysis Isolate Pattern (Finalized - May 03)**:
   - **Root Cause**: Parsing long session transcripts on the main thread was causing frame drops (jank) in the timeline animation.
   - **Implementation**: Implemented the `compute` function to delegate transcript analysis to a separate Dart isolate, keeping the cosmic UI fluid.

## 🎬 Active Limitations & Narrative Backlog

- **Context Window Limits**: Extremely long journal sessions might exceed the initial context window for Gemini 1.5 Flash analysis. Implementing a "rolling summary" or chunked analysis strategy is suggested.
- **Mood Color Collisions**: Highly nuanced moods (e.g., "Bitter-Sweet") can result in muddy colors. Moving to a HSL-based color interpolation for better clarity is suggested.
- **Token Budgeting**: Frequent manual re-analysis can be costly. Implementing a caching layer for the `AnalysisService` that only triggers if the transcript change exceeds a 10% threshold is suggested.
- **Sentiment Nuance**: The -1.0 to 1.0 scale collapses complex emotions. Transitioning to a **Plutchik's Wheel** mapping (8 primary emotions) is suggested for more cinematic visualization in Phase 4.


