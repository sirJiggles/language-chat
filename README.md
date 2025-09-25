# Language Learning Chat

A minimal Flutter app that lets you practice a language by speaking to a ChatGPT-powered tutor. The UI shows a large microphone button to record your speech and a fading text band above it that displays the assistant's reply. The assistant also speaks back using Text-to-Speech.

## Features

- Microphone button to start/stop speech recognition
- Sends your recognized speech to OpenAI Chat Completions
- Fading display of the assistant message, and optional tap-to-repeat via TTS
- Simple chat history bubbles for context

## Requirements

- Flutter 3.22+
- An OpenAI API key
- iOS 13+ or Android 6.0+ recommended

> Note: The `speech_to_text` plugin works best on iOS/Android. Web support is limited and may not work depending on the browser.

## Configuration

You can provide secrets and settings via a `.env` file (recommended) or via direct `--dart-define` flags.

### Using a .env file (recommended)

1. Copy `.env.sample` to `.env` and fill it in:

```
cp .env.sample .env
# edit .env and set OPENAI_API_KEY and (optionally) TARGET_LANGUAGE
```

2. Launch with Dart defines from file:

```
flutter run -d ios --dart-define-from-file=.env
# or
flutter run -d android --dart-define-from-file=.env
# or
flutter run -d chrome --dart-define-from-file=.env
```

The app reads `OPENAI_API_KEY` in `lib/services/chat_service.dart` via `String.fromEnvironment`.

You can set a default or override the target language by defining `TARGET_LANGUAGE` in `.env` or passing it via `--dart-define`.

## Running

### iOS Simulator

1. Ensure CocoaPods dependencies are installed: `cd ios && pod install && cd ..`
2. Run:

```bash
flutter run -d ios --dart-define=OPENAI_API_KEY=sk-...your_key...
```

On first use, iOS will prompt for microphone and speech recognition permissions.

### Android Emulator / Device

```bash
flutter run -d android --dart-define=OPENAI_API_KEY=sk-...your_key...
```

Android will request microphone permission on first use. Internet permission is already added.

### Web (Experimental)

```bash
flutter run -d chrome --dart-define=OPENAI_API_KEY=sk-...your_key...
```

Speech recognition may not function in the browser. Use mobile platforms for a full experience.

## VS Code Launch Config

A ready-to-use VS Code launch config is included at `.vscode/launch.json`. It passes `--dart-define-from-file=.env` for iOS, Android, and Chrome. Select one of the "Flutter (… ) – .env" launch entries from the Run and Debug panel.

## Platform Permissions

- Android: `android/app/src/main/AndroidManifest.xml` includes `INTERNET` and `RECORD_AUDIO`.
- iOS: `ios/Runner/Info.plist` includes `NSMicrophoneUsageDescription` and `NSSpeechRecognitionUsageDescription`.

## Customize Target Language

In `lib/services/chat_service.dart` you can set a preferred target language:

```dart
// main.dart
ChangeNotifierProvider(create: (_) => ChatService(targetLanguage: 'French')),
```

The system prompt encourages concise replies in your target language with gentle corrections.

## Troubleshooting

- If you see `OpenAI API key is missing`, re-run with `--dart-define=OPENAI_API_KEY=...`.
- If TTS does not play audio, ensure the device is not muted and the platform supports TTS voices for your language.
- For permission issues on mobile, uninstall the app and re-run to re-trigger permission prompts.

## Security

Do not hardcode your API key in the source code or commit it to source control. Use environment defines as shown above.

