#!/bin/bash

set -e  # termina lo script se un comando fallisce

# 👉 Project name come primo argomento
PROJECT_NAME="$1"

# Funzione per leggere input Y/n con Y di default
ask_install() {
  local package="$1"
  read -p "👉 Vuoi installare $package? [Y/n] " choice
  choice="${choice:-Y}"

  if [[ "$choice" =~ ^[Yy]$ ]]; then
    return 0
  else
    return 1
  fi
}

# 📍 Percorso di installazione Flutter
FLUTTER_DIR="$HOME/flutter"
FLUTTER_BIN="$FLUTTER_DIR/bin"
PUB_CACHE_BIN="$HOME/.pub-cache/bin"

# 🔍 1. Controllo e installazione di Flutter (che include anche Dart)
if ! command -v dart &> /dev/null || ! command -v flutter &> /dev/null; then
  echo "❌ Dart o Flutter non sono installati."

  if ask_install "Flutter (include Dart)"; then
    if [ -d "$FLUTTER_DIR" ]; then
      echo "⚠️ La cartella '$FLUTTER_DIR' esiste già."
      echo "   Vuoi riutilizzarla invece di fare il clone? [Y/n]"
      read reuse_choice
      reuse_choice="${reuse_choice:-Y}"

      if [[ "$reuse_choice" =~ ^[Nn]$ ]]; then
        echo "🧹 Rimozione vecchia installazione..."
        rm -rf "$FLUTTER_DIR"
        echo "⬇️ Clonazione Flutter..."
        git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_DIR"
      else
        echo "✅ Uso la cartella esistente: $FLUTTER_DIR"
      fi
    else
      echo "⬇️ Clonazione Flutter..."
      git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_DIR"
    fi

    export PATH="$PATH:$FLUTTER_BIN"
    echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc  # o ~/.zshrc
    echo "✅ Flutter installato. Riavvia il terminale o esegui: source ~/.bashrc"
  else
    echo "❌ Dart e Flutter sono necessari per continuare."
    exit 1
  fi
else
  echo "✅ Dart e Flutter sono già installati."
fi

# Assicura che Flutter funzioni
export PATH="$PATH:$FLUTTER_BIN"
hash -r  # refresh dei binari

# 🔍 2. Verifica Mason
if ! command -v mason &> /dev/null; then
  echo "⚙️  Mason non trovato. Lo installo..."
  dart pub global activate mason_cli
  export PATH="$PATH:$PUB_CACHE_BIN"
  echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.bashrc  # o .zshrc se usi zsh
  echo "✅ Mason installato."
else
  echo "✅ Mason già installato."
fi

# 🔁 Refresh comando mason
hash -r

# 🏗️ 3. Controllo argomento nome progetto
if [ -z "$PROJECT_NAME" ]; then
  echo "⚠️  Devi fornire un nome progetto:"
  echo "   ./create_flutter_app.sh nome_progetto"
  exit 1
fi

# 📁 4. Crea progetto
echo "📦 Creo progetto $PROJECT_NAME..."
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

# 🧱 5. Crea mason.yaml
cat <<EOF > mason.yaml
bricks:
  flutter_boilerplate:
    git:
      url: https://github.com/jackw1-tech/Flutter-boilerplate-mason
      path: bricks/flutter_boilerplate
EOF

# 🧱 6. Genera il progetto con mason
mason get
mason make flutter_boilerplate -- --project_name="$PROJECT_NAME"

# 📦 7. Flutter pub get
flutter pub get

echo "✅ Progetto $PROJECT_NAME creato con successo!"
