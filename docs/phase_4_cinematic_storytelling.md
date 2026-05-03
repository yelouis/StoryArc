# Phase 4: Symbolic Anchors (The Emoji Studio)

## Goal
Replace complex image generation with a lightweight, symbolic anchoring system. Assign representative emojis to sessions to create a "Visual Narrative Timeline" that is fast, cost-effective, and aesthetically consistent.

## 1. AI Emoji Selection
*   **Intelligence Integration:** Leverage the Phase 3 pipeline to have Gemini suggest 3 candidate emojis based on the session transcript.
*   **Prompt Strategy:** "Based on the following journal session, suggest 3 emojis that capture the core events or emotional peak. Output only the emojis."
*   **Rationale:** Emojis are universal, require zero storage overhead, and provide immediate visual recognition on the timeline.

## 2. The Emoji Studio UI
*   **Interaction:** After a session, the user is presented with the 3 AI-suggested emojis.
*   **Customization:** A "Search Emoji" button allows users to open a full emoji picker if the AI suggestions don't fit.
*   **Display:** The selected emoji becomes the "Hero Symbol" for that session node on the timeline.

## 3. Implementation Steps
1.  Update the `Analysis Cloud Function` to return a `suggested_emojis` array.
2.  Build the `EmojiSelectionWidget` to display AI suggestions with a "Select" interaction.
3.  Integrate the `emoji_picker_flutter` package for manual overrides.
4.  Update the `TimelineNode` to prominently display the `sessionEmoji`.

## Validation & Success Criteria
*   [ ] Gemini consistently suggests contextually relevant emojis for diverse session topics.
*   [ ] Selected emojis are correctly persisted in the Firestore `Session` document.
*   [ ] The Narrative Timeline displays the session emoji clearly, improving scannability.
*   [ ] Manual emoji selection works seamlessly if AI suggestions are rejected.

---

## 🎞️ Production Refinements & Technical Debt

1. **Symbolic Pivot (Finalized - May 03)**:
   - **Root Cause**: Cinematic image generation introduced significant latency (~10s), high operational costs, and storage complexity.
   - **Implementation**: Pivoted to a symbolic anchor system using Emojis. This removed the dependency on Imagen/Vertex AI and eliminated the need for Firebase Storage media management.

## 🎬 Active Limitations & Narrative Backlog

- **Emoji Consistency**: Different OS versions (iOS vs Android) may render emojis differently. Standardizing on a web-safe emoji font or using SVG assets for key symbols is suggested.
- **Symbolic Trends**: Implementing a "Mood Cloud" that visualizes the most used emojis across a Plotline is suggested for Phase 5.
- **Narrative Continuity**: Ensuring the AI doesn't suggest the same emoji for every session in a Plotline to maintain visual variety.
