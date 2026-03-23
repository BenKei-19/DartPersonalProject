# Lì Xì Tracker - AI-Powered Lunar New Year Gift Manager

**Lì Xì Tracker** is a modern Flutter application designed to help users manage their cultural tradition of giving and receiving lucky money (Lì Xì) during the Lunar New Year. 

With a focus on speed and intelligence, the app features a cutting-edge **Voice-to-Transaction AI assistant** powered by **Google Gemini**.

---

## Key Features

### AI Voice Assistant (Powered by Google Gemini)
Stop typing! Just say: *"Got 500k from Grandma on the first day of Tet"* or *"Give 200k to my little cousin Nam"*.
- **Natural Language Processing**: Automatically extracts Amount, Person, Date, and Relationship Category.
- **Smart Suggestions**: Detects future dates and offers to add reminders automatically.
- **Bilingual Support**: Optimized for Vietnamese and English recognition.

### Financial Dashboard
- **Real-time Statistics**: Track your total balance (Received vs. Given).
- **Interactive Charts**: Visualize your lucky money flow by category or date.
- **Budgeting**: Set goals for your gifting budget and track progress.

### Relationship Management
- **Categorization**: Groups transactions by family, friends, colleagues, or neighbors.
- **History Tracking**: Never forget who gave you what!

---

## Tech Stack

- **Frontend**: Flutter (3.x) with Dart.
- **State Management**: Provider (MVVM Architecture).
- **Artificial Intelligence**: Google Generative AI (Gemini 2.5 Flash).
- **Database**: SQLite (local-first for privacy).
- **Utilities**: `speech_to_text`, `flutter_dotenv`, `intl`.

---

## Project Setup

### 1. Prerequisites
- Flutter SDK installed.
- An Android Emulator (with Google Apps) or a Physical Device.

### 2. API Configuration
Create a `.env` file in the root directory and add your Google Gemini API Key:
```env
GEMINI_API_KEY=YOUR_API_KEY_HERE
```
*Note: You can get your key at [Google AI Studio](https://aistudio.google.com/).*

### 3. Speech Recognition Setup
- **Windows**: Enable "Online Speech Recognition" in Privacy Settings and install the Vietnamese Speech pack.
- **Android**: Ensure the "Google" app is installed and "Google Voice Typing" is enabled.

### 4. Installation
```bash
# Clone the repository
git clone https://github.com/BenKei-19/DartPersonalProject.git

# Install dependencies
flutter pub get

# Run the app
flutter run
```
---

## License
Part of a Personal Project. All rights reserved.
