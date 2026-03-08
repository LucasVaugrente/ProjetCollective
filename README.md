## Présentation

Ce projet est une application Android développée avec Flutter/Dart, dédiée à la lutte contre les fake news. Elle propose :
- Des leçons pédagogiques sur la désinformation
- Des mini-jeux interactifs pour renforcer les apprentissages
- Un système de certifications selon la progression

L'application vise à développer l'esprit critique des citoyens en leur fournissant des outils pour comprendre, détecter et contrer la désinformation (codes de l'environnement informationnel, travail journalistique, réseaux sociaux, risques, etc.).

---

## Fonctionnalités principales
- 📚  Organisation par modules et cours thématiques
- 🎮  Mini-jeux associés aux leçons (QCM, mots croisés...)
- 🏆  Suivi de la progression, objectifs et certifications
- 🎥  Médias enrichis dans les cours (texte, audio, vidéo)
- 🖼️  Interface intuitive et responsive

---

## Stack et technologies
- **Flutter** (Dart)
- C++/C/CMake (intégration de modules natifs)
- Swift (intégration iOS)
- SQLite (stockage local)
- Organisation du code par feature dans `lib/`

---

## Conditions préalables
- Flutter ≥ 3.x
- Dart ≥ 2.x
- Android Studio ou VSCode
- Un émulateur/smartphone Android (version minimale recommandée : Android 8.0)

---

## Installation
1. **Cloner le projet :**
   ```sh
   git clone https://github.com/LucasVaugrente/ProjetCollective.git
   ```
2. **Installer les dépendances :**
   ```sh
   flutter pub get
   ```
3. **Run l'application en mode debug :**
   ```sh
   flutter run
   ```

---

## Structure rapide du projet
- `lib/` : Code principal (modules, UI, logique app)
- `android/`, `ios/`, `linux/` : Plateformes supportées
- `lib/main.dart` : Point d'entrée principal

---

## Utilisation
Lancez l'application. L'interface accueille sur le choix du module. Naviguez par thématiques pour accéder aux cours, objectifs, et mini-jeux. La progression est suivie automatiquement et des messages d'encouragement apparaissent selon l'avancement.

---
