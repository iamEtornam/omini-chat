# Omini Chat

A powerful on-device AI chat application built with Flutter and [flutter_gemma](https://pub.dev/packages/flutter_gemma). Chat with Google's Gemma AI model running entirely on your device for enhanced privacy and offline functionality.

## Features

✨ **On-Device AI** - Run Gemma 3 1B model locally on your device  
🔒 **Privacy First** - No data sent to external servers  
📱 **Cross-Platform** - Works on Android, iOS, and Web  
💬 **Multi-Conversation** - Manage multiple chat conversations  
🎨 **Modern UI** - Beautiful Material Design 3 interface  
📦 **Clean Architecture** - Feature-first organization with Riverpod state management  
💾 **Persistent Storage** - Save and resume conversations  
⚡ **Fast Performance** - GPU-accelerated model inference  
📦 **Asset Loading** - Model loaded directly from app assets, no download required  
🖼️ **Image Support** - Send images with text for multimodal chat (requires vision-enabled model)

## Screenshots

<div align="center">
  <img src="screenshots/chat_screen.png" width="250" alt="Chat Screen">
  <img src="screenshots/conversations.png" width="250" alt="Conversations">
  <img src="screenshots/download.png" width="250" alt="Model Download">
</div>

## Architecture

This app follows Clean Architecture principles with a feature-first organization:

```
lib/
├── core/                          # Shared/common code
│   ├── error/                     # Error handling, failures
│   ├── utils/                     # Utility functions and extensions
│   └── constants/                 # App-wide constants
├── features/                      # All app features
│   └── chat/                      # Chat feature
│       ├── data/                  # Data layer
│       │   ├── datasources/       # Remote and local data sources
│       │   ├── models/            # DTOs and data models
│       │   └── repositories/      # Repository implementations
│       ├── domain/                # Domain layer
│       │   ├── entities/          # Business objects
│       │   ├── repositories/      # Repository interfaces
│       │   └── usecases/          # Business logic use cases
│       └── presentation/          # Presentation layer
│           ├── providers/         # Riverpod state management
│           ├── pages/             # Screen widgets
│           └── widgets/           # Feature-specific widgets
└── main.dart                      # Entry point
```

### Tech Stack

- **State Management:** Riverpod
- **AI Model:** flutter_gemma (Gemma 3 270M)
- **Functional Programming:** Dartz (Either for error handling)
- **Local Storage:** SharedPreferences
- **Code Generation:** json_serializable
- **UI:** Material Design 3

## Getting Started

### Prerequisites

- Flutter SDK (>=3.9.2)
- Xcode (for iOS development) with minimum iOS 16.0
- Android Studio (for Android development)
- The Gemma 3 1B model file (gemma3-1B-it-int4.task) placed in `assets/` folder
- Note: The model file (~1GB) is NOT included in the repository. Download it from [Hugging Face](https://huggingface.co/litert-community/gemma-3-1b-it) and place it in the `assets/` directory

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/yourusername/omini_chat.git
cd omini_chat
```

2. **Download the Gemma 3 1B model:**
   - Download `gemma3-1B-it-int4.task` from [Hugging Face](https://huggingface.co/litert-community/gemma-3-1b-it/resolve/main/gemma-3-1b-it-int4.task)
   - Place it in the `assets/` directory
   - The model file should be at: `assets/gemma3-1B-it-int4.task`

3. **Install dependencies:**
```bash
flutter pub get
```

4. **Generate code (optional, already included):**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

5. **Run the app:**
```bash
flutter run
```

## Platform-Specific Setup

### iOS

The iOS configuration is already set up in the project. Key configurations:

1. **Podfile** - Uses static linking and sets minimum iOS version to 16.0
2. **Runner.entitlements** - Includes memory entitlements for large models
3. **Minimum iOS version:** 16.0+

To run on iOS:
```bash
cd ios
pod install
cd ..
flutter run
```

### Android

The Android configuration includes:

1. **OpenGL Support** - Added in AndroidManifest.xml for GPU acceleration
2. **Minimum SDK:** 21 (Android 5.0)

To run on Android:
```bash
flutter run
```

### Web

Web platform works with GPU backend only. To run:
```bash
flutter run -d chrome
```

## Usage

### First Launch

1. **Model Loading:** On first launch, the app will load the Gemma 3 1B model from assets
2. **Wait for Initialization:** The model will be initialized (this may take a few seconds)
3. **Start Chatting:** Once ready, you can start your first conversation

### Creating Conversations

- Tap the **+** button in the app bar to create a new conversation
- The conversation title is automatically generated from your first message

### Managing Conversations

- Open the drawer (☰ menu) to see all your conversations
- Tap a conversation to switch to it
- Swipe or tap the delete icon to remove a conversation

### Sending Messages

- Type your message in the input field at the bottom
- **Optional:** Tap the image icon to attach an image
- Press the send button or Enter key to send
- The AI will process your message and respond

## Key Features

### Model Management

The app handles:
- Loading model from assets on first launch
- Model initialization and lifecycle management
- Error handling and recovery
- Status indication (loading, ready, error)

### Conversation Persistence

All conversations are saved locally using SharedPreferences and can be:
- Resumed after app restart
- Switched between seamlessly
- Deleted when no longer needed

### Error Handling

The app uses functional error handling with Dartz's `Either` type:
- Model loading errors from assets
- Model initialization failures
- Message generation errors
- Storage errors

All errors are displayed in user-friendly messages.

## Configuration

### Model Configuration

The default model is Gemma 3 1B loaded from assets. Key constants:
```dart
// lib/core/constants/app_constants.dart
static const String modelFileName = 'gemma3-1B-it-int4.task';
static const int maxTokens = 2048;
static const double temperature = 0.9;
static const int topK = 40;
```

### UI Customization

Customize the theme in `main.dart`:
```dart
theme: ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple, // Change this!
  ),
),
```

## Performance

- **Model Size:** ~1GB (Gemma 3 1B int4 quantized)
- **Memory Usage:** ~1-2GB during inference
- **Response Time:** 2-8 seconds depending on device
- **GPU Acceleration:** Enabled by default for better performance

### Recommended Devices

- **iOS:** iPhone 13 or newer with 6GB+ RAM
- **Android:** Devices with 6GB+ RAM and OpenGL ES 3.0+
- **Web:** Desktop browsers with WebGPU support and 8GB+ RAM

## Troubleshooting

### Model Loading Issues

If model fails to load:
1. Ensure the model file is in `assets/gemma3-1B-it-int4.task`
2. Ensure you have enough storage space (at least 2GB free)
3. Verify the model file is not corrupted
4. Try closing and reopening the app
5. Clear app cache if needed

### iOS Build Issues

If you encounter build errors on iOS:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
flutter clean
flutter pub get
```

### Android Build Issues

If Gradle sync fails:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Memory Issues

If the app crashes on low-end devices:
- The Gemma 3 1B model requires at least 4GB of available RAM
- Close other apps before using Omini Chat
- Consider using a smaller model variant (like Gemma 3 270M)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [flutter_gemma](https://pub.dev/packages/flutter_gemma) - On-device AI inference
- [Google Gemma](https://ai.google.dev/gemma) - The AI model
- [Riverpod](https://riverpod.dev/) - State management
- [Flutter](https://flutter.dev/) - The framework

## Support

For issues and feature requests, please use the [GitHub Issues](https://github.com/yourusername/omini_chat/issues) page.

## Roadmap

- [x] Image input support (multimodal) - **Implemented! Requires vision model**
- [x] Support for Gemma 3 Nano models
- [x] Camera capture for images
- [ ] Voice input/output
- [ ] Export/import conversations
- [ ] Desktop support (macOS, Windows, Linux)
- [ ] Custom system prompts
- [ ] Fine-tuning support with LoRA

---

Made with ❤️ using Flutter and Gemma AI
