Voici le contenu complet et prêt à l'emploi. Copiez **l'intégralité** du bloc de code ci-dessous et collez-le directement dans votre fichier `README.md` à la racine de votre dépôt GitHub.

```markdown
# 🕒 Employee Attendance - Application de Pointage SIMDCI-SECURITE

Application mobile et multiplateforme de pointage de présence des agents de la **SIMDCI-SECURITE**. Elle intègre une vérification par reconnaissance faciale pour garantir l'authenticité, la traçabilité et la sécurité des pointages en temps réel.

---

## 🌟 Fonctionnalités Principales

- 🔐 **Authentification Sécurisée** : Inscription et connexion des agents avec gestion robuste des sessions.
- 📸 **Pointage Biométrique** : Validation de la présence via capture photo et vérification faciale en temps réel.
- 📅 **Historique et Calendrier** : Consultation intuitive des pointages passés (présences, absences, retards) via une vue calendrier.
- 👤 **Gestion de Profil** : Consultation et mise à jour des informations personnelles de l'agent.
- 📱 **Multiplateforme** : Architecture Flutter permettant un déploiement sur Android, iOS, Web, Windows, macOS et Linux.
- ⚙️ **Backend Hybride Robuste** : Combinaison de Supabase (Authentification, Base de données PostgreSQL) et d'un service Python dédié au traitement de la vérification faciale.

---

## 🛠️ Architecture et Technologies

| Composant | Technologie |
|-----------|-------------|
| **Frontend** | Flutter (Dart) |
| **Backend & Base de données** | Supabase (PostgreSQL, Auth, Edge Functions) |
| **Service de Reconnaissance Faciale** | Python (OpenCV, face_recognition, Flask/FastAPI) |
| **Gestion des dépendances** | `pubspec.yaml` (Flutter), `requirements.txt` (Python) |

---

## 📂 Structure du Projet

```text
employee_attendance/
├── android/                 # Configuration et code spécifique à Android
├── ios/                     # Configuration et code spécifique à iOS
├── lib/                     # Code source principal de l'application Flutter
│   ├── constants/           # Constantes de l'application (couleurs, URLs, clés)
│   ├── models/              # Modèles de données (ex: user_model.dart)
│   ├── screens/             # Interfaces utilisateur (login, home, attendance, calendar, profile, splash)
│   ├── services/            # Logique métier et appels API (auth, db, face_recognition, photo, permissions)
│   ├── utils/               # Fonctions utilitaires et helpers
│   └── main.dart            # Point d'entrée de l'application
├── python_service/          # Service backend Python pour la vérification faciale
│   ├── face_verification.py # Script principal de traitement et de vérification
│   ├── requirements.txt     # Dépendances Python requises
│   └── Procfile             # Configuration de déploiement (ex: Heroku, Render, Railway)
├── supabase/                # Configuration et gestion de la base de données
│   ├── functions/           # Fonctions Edge (ex: verify-face)
│   └── migrations/          # Scripts de migration du schéma de base de données
├── assets/                  # Ressources statiques (images, icônes, logos SIMDCI)
├── .env                     # Variables d'environnement (⚠️ À ne pas commiter dans Git)
├── .gitignore               # Fichiers et dossiers ignorés par Git
└── pubspec.yaml             # Configuration et dépendances du projet Flutter
```

---

## 🚀 Installation et Configuration

### 1. Prérequis
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.x ou supérieure)
- [Python 3.8+](https://www.python.org/) (pour le service de vérification faciale)
- Un projet [Supabase](https://supabase.com/) créé et configuré
- Un éditeur de code (VS Code, Android Studio, etc.)

### 2. Configuration du Frontend (Flutter)
1. Clonez le dépôt :
   ```bash
   git clone https://github.com/MOMO198/employee_attendance.git
   cd employee_attendance/employee_attendance
   ```
2. Installez les dépendances Flutter :
   ```bash
   flutter pub get
   ```
3. Créez un fichier `.env` à la racine du dossier `employee_attendance` et ajoutez vos identifiants :
   ```env
   SUPABASE_URL=votre_url_supabase_ici
   SUPABASE_ANON_KEY=votre_clé_anon_supabase_ici
   PYTHON_SERVICE_URL=http://localhost:5000 # Ou l'URL de votre service Python déployé en production
   ```
4. Lancez l'application :
   ```bash
   flutter run
   ```

### 3. Configuration du Service Python (Reconnaissance Faciale)
1. Accédez au dossier du service :
   ```bash
   cd python_service
   ```
2. Créez et activez un environnement virtuel :
   ```bash
   python -m venv venv
   source venv/bin/activate  # Sur Windows : venv\Scripts\activate
   ```
3. Installez les dépendances :
   ```bash
   pip install -r requirements.txt
   ```
4. Lancez le service localement :
   ```bash
   python face_verification.py
   ```

### 4. Configuration de Supabase
- Appliquez les migrations présentes dans le dossier `supabase/migrations` via l'interface Supabase ou la CLI Supabase :
  ```bash
  supabase db push
  ```
- Assurez-vous que la fonction Edge `verify-face` (dans `supabase/functions/`) est déployée si vous utilisez le traitement côté serveur.

---

## 📱 Flux d'Utilisation de l'Application

1. **Lancement** : L'application démarre sur un écran de splash (`splash_screen.dart`).
2. **Authentification** : L'agent se connecte ou s'inscrit via les écrans dédiés (`login_screen.dart` / `register_screen.dart`).
3. **Accueil** : L'écran principal (`home_screen.dart`) affiche le statut actuel de l'agent et un bouton d'action de pointage.
4. **Processus de Pointage** : 
   - L'application demande la permission d'utiliser la caméra (`permission_service.dart`).
   - Une photo est capturée (`photo_service.dart`).
   - L'image est envoyée au service de reconnaissance faciale (`face_recognition_service.dart` vers le `python_service`).
5. **Validation** : Si le visage est reconnu avec un taux de confiance suffisant, le pointage est enregistré dans la base de données via `db_service.dart`.
6. **Consultation** : L'agent peut consulter son historique de pointage dans l'onglet Calendrier (`calender_screen.dart`).

---



## 🤝 Contribution

Les contributions sont les bienvenues pour améliorer l'application ! Pour contribuer :
1. Forkez le projet.
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/NouvelleFonctionnalite`).
3. Commitez vos changements (`git commit -m 'Ajout: description de la fonctionnalité'`).
4. Poussez vers la branche (`git push origin feature/NouvelleFonctionnalite`).
5. Ouvrez une Pull Request détaillée.

---

## 📄 Licence

Ce projet est développé spécifiquement pour la **SIMDCI-SECURITE**. Toute utilisation, copie ou distribution en dehors de ce cadre doit faire l'objet d'une autorisation préalable écrite.

---
*Développé avec ❤️ par l'équipe de développement SIMDCI-SECURITE.*
```

### 💡 Prochaine étape conseillée :
Une fois ce fichier collé dans votre `README.md`, n'hésitez pas à remplacer la section **"📸 Captures d'écran"** par de vraies images de votre application (vous pouvez simplement glisser-déposer des images dans l'éditeur GitHub, il générera automatiquement le code Markdown pour vous). Cela rendra votre dépôt beaucoup plus professionnel et attrayant.
