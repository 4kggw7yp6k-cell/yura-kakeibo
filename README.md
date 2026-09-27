# YURA 家計簿 prototype

Flutter prototype for the standalone household budget portion of HOME WITH YURA.

## Included
- Income / expense entry
- Categories and payment source
- Monthly budget, spending, income, remaining amount
- Local persistence with SharedPreferences
- Yura reaction layer (offline fallback)
- Structure ready for an AI reaction service later

## Run
1. Install Flutter and create platform scaffolding if needed: `flutter create .`
2. `flutter pub get`
3. `flutter run`

AI keys should never be embedded in this app. The AI layer should call a small authenticated backend/proxy that receives only the household context needed for Yura's response.
