# Phase 2: The Live Experience (Real-Time Interaction)

## Goal
Implement the core multimodal interaction: a real-time voice interview with Gemini, accompanied by a dynamic audio visualizer.

## 1. Gemini Multimodal Live Integration
*   **Service:** Create a `GeminiLiveService` to handle WebSocket connections.
*   **Protocol:** Implement the Multimodal Live API handshake and message exchange (audio buffer streaming).
*   **Prompt Injection Defense:** 
    *   **Pre-System Guardrail:** Encapsulate the "Biographer" persona within a high-priority system instruction that explicitly forbids internal prompt disclosure or character hijacking.
    *   **Sanitization Layer:** Implement a server-side (Cloud Function) filter to scan outgoing system instructions for forbidden tokens.
*   **System Prompt:** Configure the "Biographer/Therapist" persona to drive reflective follow-up questions.

*   **Barge-in Logic:** Implement real-time audio stream monitoring to immediately silence AI playback when user voice activity is detected (client-side interruption).


## 2. Audio Capture & Playback
*   **Recording:** Use the `record` package to stream microphone input at the required sample rate.
    *   **Strategy:** Implement 100ms chunking for outgoing audio to maintain a balance between low latency and network efficiency.
*   **Playback:** Use `just_audio` or a low-latency audio buffer player to play AI-generated voice responses.


## 3. Cosmic Audio Visualizer
*   **UI:** A full-screen interactive visualizer.
*   **Implementation:** 
    *   Use `CustomPainter` to draw waves or particles reacting to microphone frequency data.
    *   Colors should transition between deep purples and indigos based on volume/pitch.
*   **Rationale:** Sensory feedback confirms the system is listening and creates an immersive "interview" atmosphere.

## 4. Implementation Steps
1.  Set up `web_socket_channel` to connect to the Gemini Multimodal Live endpoint.
2.  Implement the audio recording service to pipe buffers into the WebSocket.
3.  Implement the audio playback service to handle incoming binary audio frames from Gemini.
4.  Develop the `VisualizerPainter` and integrate it with the microphone stream.
5.  Implement a **Firebase Cloud Function** as a secure proxy for the Gemini Live API handshake to avoid exposing the API key in client code.
6.  Build the `LiveInterviewScreen` UI.


## Validation & Success Criteria
*   [x] Connection to Gemini Live WebSocket is established and maintained.
*   [x] API Key is safely pulled from `FlutterSecureStorage` and used in the WebSocket handshake.
*   [x] System prompt configures the "Biographer" persona with strict narrative focus.
*   [x] App captures user voice (16kHz PCM) and pipes chunks to Gemini.
*   [x] App receives and plays AI-generated PCM audio buffers in real-time.
*   [x] Visualizer reacts dynamically to the user's voice intensity.
*   [x] Session can be started and terminated gracefully from the Library UI.
*   [ ] Audio latency is low enough for a natural conversation feel (Pending E2E physical device testing).

---

## 🎞️ Production Refinements & Technical Debt

1. **Multimodal WebSocket Handshake (Finalized - May 03)**:
   - **Root Cause**: The Gemini Live API requires a specific setup sequence that was causing `403 Forbidden` errors due to malformed headers.
   - **Implementation**: Refactored the `GeminiLiveService` to strictly follow the auth-header pattern and implemented a `ConnectionStateProvider` to track the handshake in the UI.

2. **Real-Time PCM Streaming Architecture (Finalized - May 03)**:
   - **Root Cause**: Standard Flutter audio packages (`just_audio`, `audioplayers`) are optimized for file/URL playback and lack native support for low-latency raw PCM buffer streaming required for a "Live" feel.
   - **Implementation**: Integrated `flutter_pcm_sound` for raw 16-bit PCM playback and refactored `AudioService` to pipe WebSocket binary frames directly into the audio driver, bypassing file-system overhead.

3. **Reactive Cosmic Visualizer (Finalized - May 03)**:
   - **Root Cause**: Static UIs fail to convey the "listening" state of the AI, leading to user confusion and reduced immersion.
   - **Implementation**: Developed a `CustomPainter` that consumes a high-frequency amplitude stream (50ms intervals) to drive a multi-layered wave animation, providing immediate visual confirmation of audio capture.

4. **FlutterPcmSound API Mismatch and Parameter Alignment (Finalized - May 28)**:
   - **Root Cause**: The project was configured with `flutter_pcm_sound: ^1.0.3`. The library's `setup` method expects a `channelCount` parameter rather than `channels`, and the `feed` method requires wrapping the raw audio bytes buffer in a `PcmArrayInt16` object rather than passing a raw `Uint8List`. This caused compilation failures and runtime errors during live voice session playback initialization.
   - **Implementation**: Updated the `AudioService` configuration calls: changed `channels: 1` to `channelCount: 1` in `FlutterPcmSound.setup` and wrapped the `Uint8List` chunk in a `PcmArrayInt16` in `FlutterPcmSound.feed`.

## 🎬 Active Limitations & Narrative Backlog

### Issue 1: Double-Pop Navigation Bug after Voice Session
**Status**: ⚠️ Confirmed Unresolved — Verified in [live_interview_screen.dart](file:///Users/louisye/Desktop/Louis%20Y./StoryArc/lib/features/live_session/live_interview_screen.dart#L137-L155): the `.then` callback of `showModalBottomSheet` triggers `Navigator.pop(context)` if `_analyzedSession != null`, which causes a second pop if the sheet was already closed via the `onComplete` callback, navigating the user back to the Library Screen instead of the Plotline details timeline.

**Option A (recommended)**: **Local State Completion Flag** — Introduce a local boolean flag `completed` in `_showEmojiStudio`. Set it to true in the `onComplete` callback and check `!completed` in the `.then` block before executing a pop.
  - *Pros*: Correctly preserves navigation stack; resolves navigation jumps cleanly.
  - *Cons*: Adds minor state-tracking variable within the dialog trigger context.

**Option B**: **Unified Modal Dismissal Navigation** — Only call `Navigator.pop(context)` (to close the bottom sheet) inside `onComplete`, and delegate the screen pop entirely to the `.then` handler, so only one pop is executed on the main screen context.
  - *Pros*: Simplifies popping logic; single responsibility for popping the parent screen.
  - *Cons*: May cause issues if different transitions are needed for success vs cancellation.

Your selection: Proceed with Option A.

---

### Issue 2: Missing User Turn Transcription in Live Session
**Status**: ⚠️ Confirmed Unresolved — Verified in [gemini_live_service.dart](file:///Users/louisye/Desktop/Louis%20Y./StoryArc/lib/services/gemini_live_service.dart#L71-L98): the WebSocket message handler only appends AI model turns (`Biographer: ...`) to the conversation transcript, omitting the user's spoken contributions entirely and leading the analysis engine to analyze only the therapist's questions.

**Option A (recommended)**: **Multimodal Server Turn Tracking** — Update `_handleMessage` to parse the user's turn data returned by the Gemini Multimodal Live API server, or utilize a client-side speech-to-text package to transcribe and append user utterances in real-time.
  - *Pros*: Creates a complete transcript of the conversation, resulting in accurate post-session summary and sentiment mapping.
  - *Cons*: Adds complexity to WebSocket message parsing or increases resource overhead by running client-side speech recognition.

**Option B**: **Summarized Session Flow** — Send raw audio or use a separate quick audio-transcription API call upon ending the session to retrieve the full user monologue.
  - *Pros*: Keeps the real-time WebSocket communication simpler.
  - *Cons*: Introduces additional API network delay at the end of the session.

Your selection: Proceed with Option A.

---

- **Audio Buffer Underflow**: On unstable connections, AI voice playback can stutter. Implementing a jitter buffer in the `AudioService` is suggested.
- **Echo Cancellation**: Standard Flutter audio recording may capture the speaker's output on some devices. Moving to `flutter_webrtc` for hardware-level AEC is suggested for Phase 3.
- **Voice Activity Detection (VAD)**: The current implementation streams silence to Gemini. Implementing client-side VAD to pause the stream when the user is not speaking is suggested for token optimization.
- **Session Continuity**: WebSocket drops cause a loss of conversation state. Persisting the current session transcript to Firestore in real-time for seamless reconnection is suggested.



