#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# setup_firebase.sh
# Guides you through Firebase configuration for UNIFY GCTU launch.
# 
# Prerequisites:
#   1. Firebase project created at https://console.firebase.google.com
#   2. Firebase CLI installed: npm install -g firebase-tools
#   3. FlutterFire CLI installed: dart pub global activate flutterfire_cli
# ──────────────────────────────────────────────────────────────
set -euo pipefail

echo "=== Step 1: Login to Firebase ==="
firebase login

echo ""
echo "=== Step 2: Create Firebase project ==="
echo "If you haven't already, create a project at:"
echo "  https://console.firebase.google.com"
echo ""
echo "Enable these services in Firebase Console:"
echo "  • Authentication (sign-in methods: Email/Password, Google)"
echo "  • Cloud Messaging (FCM) — no setup needed, just enable API"
echo ""
read -p "Enter your Firebase project ID: " PROJECT_ID

echo ""
echo "=== Step 3: Register Android app ==="
echo "In Firebase Console → Project Settings → General → Add app → Android"
echo "  Android package name: com.gctu.unify"
echo "  App nickname: UNIFY Android"
echo "  Download google-services.json after registering"
echo ""
echo "Then place it at:  android/app/google-services.json"
read -p "Done? (y/n): " DONE_ANDROID

echo ""
echo "=== Step 4: Register iOS app ==="
echo "In Firebase Console → Project Settings → General → Add app → iOS"
echo "  iOS bundle ID: com.gctu.unify"
echo "  App nickname: UNIFY iOS"
echo "  Download GoogleService-Info.plist after registering"
echo ""
echo "Then place it at:  ios/Runner/GoogleService-Info.plist"
read -p "Done? (y/n): " DONE_IOS

echo ""
echo "=== Step 5: Generate firebase_options.dart ==="
echo "Run this from the project root (mobile_flutter/):"
echo ""
echo "  flutterfire configure --project=$PROJECT_ID --android-package-name=com.gctu.unify --ios-bundle-id=com.gctu.unify"
echo ""
echo "This creates: lib/firebase_options.dart"

echo ""
echo "=== Step 6: Get FCM Server Key ==="
echo "For push notifications to work, you need the FCM server key."
echo ""
echo "  Firebase Console → Project Settings → Cloud Messaging"
echo "  Copy the 'Server key' (deprecated) or go to:"
echo "  Google Cloud Console → APIs & Services → Credentials"
echo "  Create an API key (restrict to FCM)"
echo ""
echo "Then add to Supabase Edge Function secrets:"
echo "  supabase secrets set FCM_SERVER_KEY=<your-key>"
echo ""
echo "Also add to assets/.env (for fallback): FCM_SERVER_KEY=<your-key>"

echo ""
echo "=== Step 7: Verify files ==="
echo "After setup, verify these files exist:"
echo "  ✅ android/app/google-services.json"
echo "  ✅ ios/Runner/GoogleService-Info.plist"
echo "  ✅ lib/firebase_options.dart"
echo ""
echo "Then build:  flutter build apk --debug"
