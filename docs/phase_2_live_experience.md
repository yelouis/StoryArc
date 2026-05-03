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
*   [ ] Connection to Gemini Live WebSocket is established and maintained.
*   [ ] API Key is never stored in plain text or transmitted directly from the client without a secure handshake.
*   [ ] System prompt remains resilient against basic injection attempts (e.g., "Ignore previous instructions").
*   [ ] App captures user voice and receives an intelligent, audible response from the AI.

*   [ ] Visualizer reacts dynamically to the user's voice intensity.
*   [ ] Session can be started, paused, and terminated gracefully.
*   [ ] Audio latency is low enough for a natural conversation feel.

---

## 🎞️ Production Refinements & Technical Debt

1. **Multimodal WebSocket Handshake (Finalized - May 03)**:
   - **Root Cause**: The Gemini Live API requires a specific setup sequence that was causing `403 Forbidden` errors due to malformed headers.
   - **Implementation**: Refactored the `GeminiLiveService` to strictly follow the auth-header pattern and implemented a `ConnectionStateProvider` to track the handshake in the UI.

## 🎬 Active Limitations & Narrative Backlog

- **Audio Buffer Underflow**: On unstable connections, AI voice playback can stutter. Implementing a jitter buffer in the `AudioPlaybackService` is suggested.
- **Echo Cancellation**: Standard Flutter audio recording may capture the speaker's output on some devices. Moving to the `flutter_webrtc` audio processing stack for hardware-level echo cancellation is suggested for Phase 3.
- **VAD Implementation**: Sending silence to Gemini wastes tokens and bandwidth. Implementing client-side Voice Activity Detection (VAD) using a lightweight TFLite model or simple amplitude thresholds is suggested.
- **Connection Recovery**: WebSocket drops during a session can lose session state. Implementing a "Reconnection Handshake" that preserves the current transcript context is suggested.


