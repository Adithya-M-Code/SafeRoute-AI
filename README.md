# SafeRoute AI - Risk-Aware Crowdsourced Road Hazard Detection

A comprehensive Flutter mobile application for detecting, reporting, and avoiding road hazards through crowdsourced intelligence and AI-powered validation.

## 🎯 Project Overview

SafeRoute AI is a intelligent navigation platform that leverages community contributions to create a real-time hazard awareness system. Riders can report risks they encounter on roads (potholes, waterlogging, debris, accidents, construction), and the system validates these reports using AI. The app then provides safe route recommendations by analyzing hazard density and severity.

## ✨ Key Features

### 1. **Authentication System**
- Easy login/signup with email and password
- Secure user account creation
- Session management integrated with app navigation
- Welcome screen for first-time users

### 2. **Home Dashboard**
- Personalized greeting for users
- **Safety Snapshot** showing key metrics:
  - Active hazards in the area
  - Route confidence percentage
  - Nearby alerts count
- **Weather Advisory** with risk impact assessment
- Destination search bar with quick navigation
- **Live Alerts** feed showing real-time hazard reports:
  - Waterlogging incidents
  - Road work/construction
  - Pothole clusters
- Quick action cards:
  - **Report Hazard** - Log new road risks
  - **Find Safe Route** - Get intelligent route recommendations

### 3. **Route Navigation & Planning**
- **Dual Route Comparison**:
  - Safest route (considering hazard density and severity)
  - Fastest route (direct path)
- Interactive map visualization with route drawing
- Place selection dropdown with auto-detection of current location
- Route statistics and metrics
- Embedded map view for dashboard integration
- Support for multiple predefined locations:
  - MG Road, Central Bus Stand, Railway Station
  - Airport Road, University Circle, City Hospital

### 4. **Risk Heatmap Visualization**
- **Temporal Filtering**:
  - Last 24 hours
  - Last 7 days
  - Last 30 days
- **Hazard Type Filtering**:
  - All hazards
  - Pothole-specific
  - Waterlogging-specific
  - Debris-specific
- Risk intensity slider (0-100%) for threshold control
- Color-coded heatmap visualization of hazard concentrations
- Geographical overview of dangerous areas

### 5. **Hazard Reporting System**
- **Multi-field Report Form**:
  - Photo upload for evidence (image picker interface)
  - Location auto-detection + manual entry
  - Hazard type selection (Pothole, Waterlogging, Debris, Accident, Construction)
  - Rich text description with guidance prompts
  - Severity level on 1-5 scale with slider control
  - Anonymous reporting option
- **AI Validation Pipeline**:
  - Automated report submission workflow
  - AI verification status tracking
  - User can track report status in profile
- Success confirmation dialog with submission receipt
- Mock email notifications in snackbars

### 6. **User Profile & Statistics**
- Personal profile card with avatar
- **Contribution Stats**:
  - Total reports submitted
  - Verified/validated reports
  - Trust score (0-5.0 scale)
- **Past Reports History**: View all submitted hazard reports with:
  - Hazard type icon and name
  - Location information
  - Severity level (visual indicator)
  - Verification status
  - Submission timestamp
- Edit profile option for updating user information
- Quick access to settings

### 7. **Profile Editing**
- Update personal information
- Form with validation
- Save changes with confirmation

### 8. **Settings & Preferences**
- **Notification Preferences**:
  - Push Notifications toggle (route & safety updates)
  - Hazard Alerts toggle (real-time risk notifications)
  - Location Access toggle (auto route recommendations)
- **Legal & Support**:
  - Privacy Policy link
  - Terms of Service link
  - Help & Support access
- Settings persist during session

### 9. **Theme Support**
- Light mode (default)
- Dark mode with full theme support
- Theme toggle in profile screen
- Persistent theme throughout app

### 10. **UI/UX Features**
- **Navigation**: Smooth bottom navigation bar with page transitions
- **Animated Components**: Action cards with smooth animations
- **Loading States**: Progress indicators for async operations
- **Feedback**: Snackbars and dialog confirmations for user actions
- **Responsive Design**: Adaptive layouts for different screen sizes
- **Visual Hierarchy**: Clear typography and color coding
- **Accessibility**: Proper icon usage and semantic structure

## 🏗️ Technical Architecture

### Technology Stack
- **Framework**: Flutter 3.3.0+
- **Language**: Dart
- **UI Components**: Material Design 3
- **Map Integration**: flutter_map 8.2.2, latlong2 0.9.1
- **State Management**: Set-based (StatefulWidget)
- **Data Format**: JSON with mock data system

### Project Structure
```
lib/
├── main.dart                          # App entry point & routing
├── screens/                           # All screen implementations
│   ├── auth_screen.dart               # Login/Signup
│   ├── splash_screen.dart             # Initial loading screen
│   ├── home_dashboard_screen.dart     # Main dashboard
│   ├── map_route_screen.dart          # Route visualization
│   ├── report_hazard_screen.dart      # Hazard submission form
│   ├── profile_screen.dart            # User profile & stats
│   ├── edit_profile_screen.dart       # Profile editor
│   ├── settings_screen.dart           # App settings
│   ├── risk_heatmap_screen.dart       # Heatmap visualization
│   └── main_shell.dart                # Bottom nav container
├── models/
│   └── hazard_report.dart             # Data model for reports
├── utils/
│   ├── app_theme.dart                 # Theme definitions
│   └── mock_data.dart                 # Sample data for demo
└── widgets/
    └── animated_action_card.dart      # Reusable animated card
```

### Data Models
- **HazardReport**: Represents a road hazard submission with:
  - ID, location, hazard type, severity, description
  - Reporter info, submission timestamp, verification status
  - Image attachments

## 🚀 Current Implementation Status

### ✅ Completed Features (UI/UX Prototype)
- [x] Authentication flow (login/signup screens)
- [x] Home dashboard with safety snapshot
- [x] Dual-route navigation interface (safe vs fast)
- [x] Interactive map with route visualization (mock painter-based)
- [x] Comprehensive hazard reporting form with all fields
- [x] User profile with contribution statistics
- [x] Past report history display
- [x] Risk heatmap with filtering options
- [x] Settings management interface
- [x] Theme switching (light/dark mode)
- [x] Weather advisory display
- [x] Live alerts ticker
- [x] Animated UI components
- [x] Full navigation structure
- [x] Loading states and user feedback

### 🔄 Next Steps for Development
- Backend API integration (authentication, report submission, data retrieval)
- Real map implementation (Google Maps/OSM integration)
- Real-time data streaming for hazard feeds
- Push notification system
- Image upload and storage
- AI validation service integration
- Database setup for reports and user data
- Geolocation services
- Route optimization algorithms
- Heatmap data processing and visualization
- Unit and integration testing
- Performance optimization
- Deployment configuration

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_map: ^8.2.2
  latlong2: ^0.9.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

## 🎨 Design System

### Color Palette
- **Primary Green**: Safety and good routes (`#4CAF50`)
- **Risk Red**: Hazards and warnings (`#FF5252`)
- **Warning Orange**: Caution indicators
- **Material Design 3**: Full theme support with light/dark variants

### Typography
- Headline Small: Screen titles
- Title Large/Medium/Small: Section headers
- Body Medium/Small: Content text
- Label fonts for interactive elements

## 🔐 Security Considerations

- Anonymous reporting option for sensitive situations
- Trust score system to validate contributors
- AI validation before hazard visibility
- User data privacy with optional location sharing
- Secure authentication flow

## 📱 Supported Platforms

- Android (via Gradle configuration)
- iOS (via Xcode configuration)
- Web (via Flutter web setup)
- Windows, macOS, Linux (desktop support available)

## 🔄 How to Run

```bash
# Install dependencies
flutter pub get

# Run app (ensure device is connected)
flutter run

# Run with specific device
flutter run -d <device_id>

# Build for production
flutter build apk      # Android
flutter build ios      # iOS
flutter build web      # Web
```

## 📖 Development Guidelines

### Adding New Hazard Types
1. Update `_hazards` list in `report_hazard_screen.dart`
2. Add corresponding filter option in `risk_heatmap_screen.dart`
3. Update mock data in `mock_data.dart`

### Extending Features
- Use SetBasedState for feature toggles
- Maintain Material Design 3 consistency
- Add proper loading and error states
- Include user feedback mechanisms

### Mock Data System
- Current system uses JSON strings in `mock_data.dart`
- Easy to swap with real API calls
- Parse using `HazardReport.fromJson()`

## 📝 License

[Add your license information here]

## 👥 Contributors

- Project initiated as SafeRoute AI Prototype
- Built with Flutter and Material Design 3

## 📞 Support & Contact

For questions or issues, please refer to the Issues section in the repository.

---

**Last Updated**: April 2026 | **Version**: 1.0.0+1
