/// Application constants
class AppConstants {
  // Model URLs
  static const String gemma270mModelUrl =
      'https://huggingface.co/litert-community/gemma-3-270m-it/resolve/main/gemma-3-270m-it-int4.task';

  static const String gemma1bModelUrl =
      'https://huggingface.co/litert-community/gemma-3-1b-it/resolve/main/gemma-3-1b-it-int4.task';

  // Model names
  static const String defaultModelName = 'Gemma 3 1B';
  static const String modelFileName = 'gemma3-1B-it-int4.task';

  // Storage keys
  static const String chatHistoryKey = 'chat_history';
  static const String activeConversationKey = 'active_conversation';
  static const String modelStateKey = 'model_state';

  // UI Constants
  static const double messageBorderRadius = 16.0;
  static const double messageMaxWidth = 0.75;
  static const double inputBorderRadius = 24.0;

  // Model Configuration for Gemma 3 1B
  // Based on: https://www.kaggle.com/models/google/gemma-3/tfLite/gemma3-1b-it-int4
  static const int maxTokens =
      8192; // Gemma 3 1B supports up to 32K, using 8K for mobile
  static const double temperature =
      1.0; // Default temperature for balanced creativity
  static const int topK = 40; // Standard top-k sampling
  static const double topP = 0.95; // Top-p (nucleus) sampling

  // Image support - FALSE for Gemma 3 1B
  // Only Gemma 3 4B, 12B, and 27B support multimodal (images)
  // Gemma 3 1B and 270M are text-only models
  static const bool supportsImages = false;
}
