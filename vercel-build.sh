#!/bin/bash

# 1. Clone Flutter into a local directory
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# 2. Add Flutter to the path
export PATH="$PATH:`pwd`/flutter/bin"

# 3. Enable Web support
flutter config --enable-web

# 4. Get dependencies
flutter pub get

# 5. Build the web app
flutter build web --release
