#!/bin/bash

# 1. Clone Flutter into a local directory
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# 2. Add Flutter to the path
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Enable Web support
flutter config --enable-web

# 4. Get dependencies
flutter pub get

# 5. Build the web app with quoted environment variables for security/stability
flutter build web --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
