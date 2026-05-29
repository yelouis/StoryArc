---
name: Bug Documentation Guidelines
description: A strict style guide for documenting resolved bugs, refinements, and unresolved limitations in the StoryArc project. Follow this to maintain a consistent and machine-readable engineering history.
---

# Bug and Refinement Documentation Guidelines

This guidelines document defines how technical issues, bug fixes, and future suggestions MUST be documented in the project's `docs/phase_*.md` files. Following this guide ensures that the repository history is transparent, actionable, and easily parsed by both humans and AI agents.

---

## 1. Resolved Issues & Production Refinements

This section is for work that has been completed, verified, and merged.

### Mandatory Structure
- **Heading**: Use `## 🎞️ Production Refinements & Technical Debt`.
- **Status Indicator**: Every item MUST include the resolution date in the format: `(Finalized - Month DD)`.
- **Level**: Use numbered lists for individual entries.
- **Problem/Solution Pattern**: Each entry MUST use the following sub-bullets:
    - `**Root Cause**`: Detailed technical explanation of what was broken, domain constraints, and failure modes.
    - `**Implementation**`: Detailed specific technical fix or architectural change.

### Style Constraints
- **Detail**: Provide a comprehensive and detailed description of the problem, explaining the technical root cause, domain constraints, and the impact on the pipeline. Avoid overly brief summaries.
- **Specificity**: Name specific files, error types, or package dependencies (e.g., `web_socket_channel` or `emoji_picker_flutter`).
- **No Fluff**: Avoid generic phrases like "Fixed a bug." State exactly what was broken and how it was fixed.

---

## 2. Active Limitations & Narrative Backlog

This section is for active limitations, known bugs that aren't yet fixed, and architectural debt. It MUST provide actionable remediation paths for the user to choose from.

### Mandatory Structure
- **Heading**: Use `## 🎬 Active Limitations & Narrative Backlog`.
- **Issue Headings**: Use `### Issue [Number]: [Title]`.
- **Status Line**: Start with `**Status**: ⚠️ Confirmed Unresolved — [Description and verification details]`.
- **Remediation Options**: Provide a reasonable amount of detailed options (Option A, Option B, etc.). If it is an easy issue, one option is enough; if it is a hard issue, offer more solutions.
- **Recommendation**: Label the preferred approach with `(recommended)`.
- **Pros/Cons**: Each option MUST include a bulleted list of `Pros` and `Cons`.
- **Selection Line**: End each issue block with `Your selection: _____`.
- **Separation**: Use `---` horizontal rules between multiple issues.

### Style Constraints
- **Technical Transparency**: The Status line must explain *why* the issue is still unresolved (e.g., "Verified in `analysis_service.dart` (lines 40-50)").
- **Detailed Trade-offs**: Pros and Cons should be technical and specific (e.g., "Increases Dart SDK version requirements," "Forces package overrides").
- **No Placeholders**: Do not use vague options. Every option must be a viable technical implementation path.

---

## 3. Formatting Examples (The "Look and Feel")

### Correct Example for Resolved Issues:
```markdown
## 🎞️ Production Refinements & Technical Debt

1. **Dart SDK and dependency mismatch (Finalized - May 28)**:
   - **Root Cause**: The project was configured with `emoji_picker_flutter: ^2.4.0` (which does not exist on pub.dev) and `web_socket_channel: ^2.4.5` (which requires Dart SDK >=3.2.0, whereas the environment is running 3.0.6).
   - **Implementation**: Downgraded `emoji_picker_flutter` to `^2.2.0` in `pubspec.yaml` and constrained `web_socket_channel` to `^2.4.1` to align with the environment's Dart SDK.
```

### Correct Example for Unresolved Issues:
```markdown
## 🎬 Active Limitations & Narrative Backlog

### Issue 1: WebSocket Audio Latency on Android
**Status**: ⚠️ Confirmed Unresolved — Verified in `gemini_live_service.dart`: the buffer size of the incoming WebSocket PCM stream leads to audio stutter and a 1.2s delay on physical Android devices.

**Option A (recommended)**: **Native Audio Buffer Tuning** — Implement a custom audio chunk player using native channels (Kotlin/Swift) to bypass the Dart event loop.
  - *Pros*: Reduces latency under 150ms; resolves event loop congestion.
  - *Cons*: Increases platform dependency footprint; requires writing native code.

**Option B**: **Dynamic Chunk Resizing** -- Dynamically resize PCM packet chunks from 1024 to 512 bytes on the client based on socket speed.
  - *Pros*: Entirely Dart-based; simple configuration change.
  - *Cons*: Higher CPU overhead due to more frequent calls to PCM channel.

Your selection: _____
```

## 4. Enforcement Guidelines
- **Audit Requirement**: Before closing a task, Antigravity MUST check the relevant documentation to ensure it aligns with this style guide.
- **Redundancy**: If a task spans multiple docs, update the most relevant one and cross-reference if necessary.
