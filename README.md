# Flutter Boilerplate Template

This repository provides a lightweight, customizable Flutter boilerplate built to kickstart your app development using the [PINE architecture](https://angeloavv.medium.com/pine-a-lightweight-architecture-helper-for-your-flutter-projects-1ce69ac63f74).

---

## 🚀 Features

- Follows the **PINE** architecture
- Simple and clean project structure
- Easily extendable for larger applications
- Integrated with [Mason](https://pub.dev/packages/mason_cli) for code generation
- Pre-configured with a setup script to generate your app with one command

---

## 🧱 What is PINE?

PINE is a lightweight architecture for Flutter apps that emphasizes clarity, testability, and minimal boilerplate. Learn more about it in this article:  
👉 [PINE Architecture Explanation](https://angeloavv.medium.com/pine-a-lightweight-architecture-helper-for-your-flutter-projects-1ce69ac63f74)

---

## 📦 Prerequisites

Before using the setup script, make sure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart SDK (included with Flutter)
- Mason CLI:
  ```bash
  dart pub global activate mason_cli

You may need to add Mason to your PATH:

export PATH="$PATH":"$HOME/.pub-cache/bin"


⸻

⚙️ How to Use

1.	Clone this repository:

2.	Make the script executable:

chmod +x create_flutter_app.sh

3.	Run the script with your desired project name:

./create_flutter_app.sh my_app_name

This will:
	•	Create a new directory my_app_name/
	•	Generate the Flutter project using the boilerplate
	•	Run flutter pub get
	•	(Optionally) open the project in VS Code

⸻

🧠 What the Script Does
	•	Checks if you have Flutter, Dart, and Mason installed
	•	Generates a Flutter project using your boilerplate template from GitHub
	•	Applies the project_name dynamically so your app is properly named
	•	Automates the boring setup process


