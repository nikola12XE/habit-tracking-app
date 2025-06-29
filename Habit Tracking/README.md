# 🌸 Habit Tracking App

Minimalistička habit tracker aplikacija za iOS sa zen dizajnom i ručno nacrtanim cvećem.

## 📱 Opis aplikacije

Aplikacija je zamišljena kao "zen", lagani alat za svakodnevno beleženje i refleksiju. Korisnik prati samo jedan glavni cilj sa vizuelnim stilom inspirisanim ručno nacrtanim cvećem i lepim mikroanimacijama.

### Primeri ciljeva:
- "Ići u teretanu"
- "Čitati knjigu" 
- "Raditi vežbe"
- "Meditirati"

## 🛠 Tehnologije

- **Swift + SwiftUI** - UI framework
- **CoreData** - Lokalno čuvanje podataka
- **PhotosUI** - Izbor fotografija
- **Combine** - Reaktivno programiranje

## 📱 Ekrani i funkcionalnosti

### 1️⃣ Splash/Intro ekran
- Glavni tekst: "Set your biggest goal"
- Podnaslov: "Create one goal that will set everything else in motion..."
- Pozadina sa blur efektom i ručno nacrtanim cvećem
- Dugmad: "Sign Up" i "Set your Goal"

### 2️⃣ Goal Entry Flow (3 ekrana)
- **Ekran 1**: Unos teksta cilja
- **Ekran 2**: Izbor dana u nedelji (M T W T F S S)
- **Ekran 3**: Postavljanje reminder-a
- Paginacija sa dots indikatorom

### 3️⃣ Glavni tracking ekran
- Header sa imenom cilja
- Mesečni grid sa danima
- Klik na dan → random cvet raste + animacija padanja cveća
- "Add Milestone" dugme
- Profil ikonica u gornjem desnom uglu

### 4️⃣ Milestone popup
- Bottom sheet dizajn
- Unos teksta o dostignuću
- Dodavanje fotografije
- Sačuvani milestone → trofej animacija

### 5️⃣ Profile ekran
- Avatar + ime korisnika
- Email i plan informacije
- Notification opcije
- Linkovi: Milestones, FAQ, Privacy, Terms, Support
- Log Out i Delete Account dugmad

### 6️⃣ Authentication
- Sign Up ekran (Email + Password + Confirm Password + Name)
- Login ekran (Email + Password)

## 🎨 Dizajn

- **Boje**: Zen paleta sa bledim tonovima
- **Fontovi**: Rounded system fontovi
- **Animacije**: Lagane, prirodne mikroanimacije
- **Cveće**: 20 različitih hand-drawn cvetova
- **Trofeji**: Rive animacije za milestone-ove

## 💾 Storage (CoreData)

### Entiteti:
- **Goal**: Ime cilja, selektovani dani, reminder opcije
- **ProgressDay**: Datum, završen status, tip cveta, milestone podaci
- **UserProfile**: Email, plan, notification opcije, avatar

## 🚀 Pokretanje aplikacije

1. Otvorite `Habit Tracking.xcodeproj` u Xcode-u
2. Izaberite iOS simulator ili fizički uređaj
3. Pritisnite `Cmd + R` za pokretanje

## 📋 Funkcionalnosti za implementaciju

### Trenutno implementirano:
- ✅ CoreData model i manager
- ✅ Splash ekran sa animacijama
- ✅ Goal Entry Flow sa paginacijom
- ✅ Glavni tracking ekran sa grid-om
- ✅ Milestone popup sa photo picker-om
- ✅ Profile ekran sa svim opcijama
- ✅ Sign Up/Login ekrani
- ✅ AppState manager za navigaciju
- ✅ Dizajn konstante i stilovi

### Za buduće verzije:
- 🔄 Cloud sync (Firebase/Supabase)
- 🔄 Trial 3 dana + subscription ($3/month)
- 🔄 Push notifikacije
- 🔄 Rive animacije za cveće i trofeje
- 🔄 Drag gesture interakcije sa cvećem
- 🔄 Milestones ekran
- 🔄 FAQ, Privacy, Terms, Support ekrani

## 🎯 Cilj

Prva verzija je funkcionalna aplikacija sa lokalnim storage-om (CoreData), spremna za testiranje. Kasnije će se dodati cloud sync i subscription model.

## 📝 Napomene

- Aplikacija koristi placeholder ikone za cveće (u realnoj verziji bi bile hand-drawn)
- Authentication je simulirana (u realnoj verziji bi koristila Firebase Auth)
- Push notifikacije nisu implementirane
- Rive animacije će biti dodane u sledećoj verziji

---

**Napravljeno sa ❤️ za zen habit tracking iskustvo** 

## Features

### Core Functionality
- **Single Goal Focus**: Track one main habit/goal at a time for better focus
- **Sequential Progress Grid**: Shows numbered days (1, 2, 3...) when user should work on their goal
- **Monthly Progress Grid**: Visual grid with flower animations for completed days
- **Milestone Tracking**: Add text notes and photos to completed days
- **Local Storage**: All data stored locally using CoreData

### User Experience
- **Splash Screen**: Beautiful blur effect with flower background
- **Goal Entry Flow**: 3-step guided process to set up your habit
  - Goal text input
  - Frequency selection (days of the week)
  - Reminder settings (optional)
- **Main Tracking**: Sequential grid view showing only relevant days numbered 1 to N
- **Profile Management**: User settings, notifications, and goal editing
- **Authentication**: Sign up and login screens with Google login option

### Design Features
- **Zen-Inspired UI**: Clean, minimalist design with calming colors
- **Hand-Drawn Flowers**: Custom flower animations for completed days
- **Microanimations**: Smooth transitions and subtle animations throughout
- **Responsive Layout**: Optimized for all iPhone screen sizes
- **Sequential Progress**: Numbered days (1, 2, 3...) for clear progress tracking

## Technical Implementation

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **CoreData**: Local data persistence with managed object context
- **MVVM Pattern**: Clean separation of concerns
- **State Management**: Centralized app state management

### Key Components
- `AppStateManager`: Handles navigation and app state
- `CoreDataManager`: Manages data persistence and CRUD operations
- `DesignConstants`: Centralized design system (colors, fonts, spacing)
- `GoalEntryFlowView`: Multi-step goal creation/editing flow
- `MainTrackingView`: Primary tracking interface with sequential grid
- `ProfileView`: User settings and profile management

### Data Models
- **Goal**: User's main habit/goal with text, frequency, and reminder settings
- **ProgressDay**: Daily progress entries with optional milestones
- **UserProfile**: User information and preferences
- **Milestone**: Text notes and photos for completed days

## Goal Management Flow

### New User Flow
1. **Splash Screen** → **Authentication** (Sign Up/Login/Google)
2. **Goal Entry Flow** (automatically triggered if no goal exists)
   - Step 1: Enter goal text
   - Step 2: Select frequency (days of the week)
   - Step 3: Set reminder preferences
3. **Main Tracking Screen** (ready to track progress)

### Existing User Flow
1. **Splash Screen** → **Authentication** (Login/Google)
2. **Main Tracking Screen** (if goal exists)
   - Or **Goal Entry Flow** (if no goal exists)

### Goal Editing
- **Profile Screen** → **"Edit Goal"** button → **Goal Entry Flow**
- Pre-populated with existing goal data
- Same 3-step process for updates
- Returns to Main Tracking with updated goal

## Sequential Progress System

### Numbered Day Display
- **Sequential Numbers**: Days are numbered 1, 2, 3... instead of calendar dates
- **Frequency-Based**: Only shows days when user should work on their goal
- **Example**: If user selects Monday and Wednesday, shows days 1, 2, 3, 4... for each occurrence
- **Grid Layout**: 7 columns per row, automatically wrapping to new rows
- **Visual Feedback**: Shows count of available days in current month

### Benefits
- **Clear Progress**: Easy to see "Day 5 of 12" progress
- **Motivational**: Sequential numbers create a sense of achievement
- **Focused Tracking**: Users see only relevant days, reducing overwhelm
- **Realistic Goals**: Encourages sustainable habit formation
- **Simple Interface**: No calendar complexity, just numbered progress

## Authentication Options

### Traditional Login
- Email and password authentication
- Secure password fields without Apple's strong password overlay
- Form validation and error handling

### Google Sign-In
- One-tap Google authentication
- Seamless integration with Google accounts
- Note: Requires GoogleService-Info.plist and Firebase setup for production

## Installation & Setup

1. Clone the repository
2. Open `Habit Tracking.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run the project

### Google Sign-In Setup (Optional)
1. Create a Firebase project
2. Download `GoogleService-Info.plist`
3. Add to project and configure URL schemes
4. Enable Google Sign-In in Firebase console

## Requirements
- iOS 18.4+
- Xcode 16.0+
- Swift 5.0+

## Project Structure

```
Habit Tracking/
├── Habit Tracking/
│   ├── AppStateManager.swift          # Navigation and app state
│   ├── CoreDataManager.swift          # Data persistence
│   ├── DesignConstants.swift          # Design system
│   ├── GoalEntryFlowView.swift        # Goal creation/editing
│   ├── MainTrackingView.swift         # Primary tracking interface
│   ├── ProfileView.swift              # User settings
│   ├── AuthenticationViews.swift      # Sign up/login/Google screens
│   ├── MilestonePopupView.swift       # Milestone creation
│   ├── SplashView.swift               # App launch screen
│   ├── ContentView.swift              # Main app container
│   └── Habit_TrackingApp.swift        # App entry point
├── HabitTrackingModel.xcdatamodeld/   # CoreData model
└── Assets.xcassets/                   # App icons and colors
```

## Future Enhancements

- Push notifications for reminders
- Data export/backup functionality
- Multiple goals support
- Statistics and progress analytics
- Social sharing features
- Dark mode support
- Widget support
- Apple Health integration
- Streak tracking and achievements
- Progress charts and visualizations

## Contributing

This is a personal project showcasing modern iOS development practices with SwiftUI and CoreData. Feel free to explore the code and adapt it for your own projects.

## License

This project is for educational and personal use. 