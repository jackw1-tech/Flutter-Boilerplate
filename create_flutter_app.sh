#!/bin/bash

PROJECT_NAME=$1

# 🔍 1. Check if Dart is installed
if ! command -v dart &> /dev/null; then
  echo "❌ Dart is not installed. Please install Flutter from https://docs.flutter.dev/get-started/install"
  exit 1
fi

# 🔍 2. Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
  echo "❌ Flutter is not installed. Please install Flutter from https://docs.flutter.dev/get-started/install"
  exit 1
fi

# 🔍 3. Check if Mason is installed
if ! command -v mason &> /dev/null; then
  echo "⚙️  Mason not found. Installing it now..."
  dart pub global activate mason_cli

  # Temporarily add Mason to PATH for this session
  export PATH="$PATH":"$HOME/.pub-cache/bin"
fi

# 🧪 Final check
echo "✅ All good: Dart, Flutter, and Mason are installed!"

# 🏗️ Check for project name argument
if [ -z "$PROJECT_NAME" ]; then
  echo "⚠️  You must provide a project name:"
  echo "   ./create_flutter_app.sh my_project_name"
  exit 1
fi

# 📁 Create the project folder
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

# 📦 Create mason.yaml
cat <<EOF > mason.yaml
bricks:
  flutter_boilerplate:
    git:
      url: https://github.com/jackw1-tech/Flutter-boilerplate-mason
      path: bricks/flutter_boilerplate
EOF

# ⬇️ Download the brick and generate the project
mason get
mason make flutter_boilerplate -- --project_name="$PROJECT_NAME"

flutter pub get

