# API Configuration

This directory contains API key configuration files.

## Setup Instructions

1. **For First Time Setup:**
   - Copy `api_config.example.dart` to `api_config.dart`
   - Replace `YOUR_API_KEY_HERE` with your actual Gemini API key

2. **Security:**
   - `api_config.dart` is gitignored and will NOT be pushed to GitHub
   - Never commit API keys to version control
   - Use environment variables in production builds

3. **Using Environment Variables (Recommended for Production):**
   ```dart
   // Run with: flutter run --dart-define=GEMINI_API_KEY=your_key_here
   ```

## Files

- `api_config.dart` - Actual API configuration (gitignored)
- `api_config.example.dart` - Template file (safe to commit)
- `README.md` - This file

## Important Notes

⚠️ **Never commit `api_config.dart` to version control!**

The `.gitignore` file is configured to exclude this file automatically.

