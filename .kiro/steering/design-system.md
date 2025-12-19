---
inclusion: always
---

# StudyStewart Design System Rules

## Project Context
- **Framework**: Flutter (SDK ^3.8.1)
- **Design Source**: Figma - StudyStewart (https://www.figma.com/design/m3ORtzfqv9yMdwGtdgrFbs/StudyStewart)
- **App Type**: Learning style discovery app with gamification and TTS features
- **Dependencies**: flutter_tts, shared_preferences, cupertino_icons

## Design Token Definitions

### Colors
```dart
// Primary Colors
Colors.blue (primary swatch)
Colors.blue.shade400 (gradient start)
Colors.purple.shade400 (gradient end)

// Background Colors
Colors.grey.shade50 (light scaffold)
Colors.grey.shade900 (dark scaffold)
Colors.grey.shade200 (toggle background)

// State Colors
Colors.green (success feedback)
Colors.red (error feedback)
Colors.white (text on colored backgrounds)
Colors.black54 (secondary text)
```

### Typography Scale
```dart
// Using Material 3 typography
Theme.of(context).textTheme.headlineMedium (app title)
Theme.of(context).textTheme.titleLarge (section headers)
TextStyle(fontSize: 16, fontWeight: FontWeight.bold) (buttons)
TextStyle(fontSize: 12, color: Colors.grey) (helper text)
```

### Spacing System
```dart
// Standard spacing increments
EdgeInsets.all(8) (small padding)
EdgeInsets.all(16) (medium padding)  
EdgeInsets.all(24) (large padding)
SizedBox(height: 16) (standard vertical spacing)
SizedBox(height: 24) (large vertical spacing)
SizedBox(height: 32) (extra large spacing)
```

### Border Radius
```dart
BorderRadius.circular(12) (standard cards/inputs)
BorderRadius.circular(16) (large cards)
BorderRadius.circular(25) (toggle switches)
```

## Component Library Structure

### File Organization
```
lib/
├── main.dart (app configuration & theme)
├── screens/ (full-screen views)
│   ├── auth_screen.dart
│   ├── home_screen.dart
│   ├── game_screen.dart
│   └── settings_screen.dart
├── widgets/ (reusable components)
│   └── tts_button.dart
└── services/ (business logic)
    ├── tts_service.dart
    └── settings_service.dart
```

### Component Architecture Patterns

#### Stateful Widget Pattern
```dart
class ComponentName extends StatefulWidget {
  const ComponentName({super.key});
  
  @override
  State<ComponentName> createState() => _ComponentNameState();
}
```

#### Service Integration Pattern
```dart
class _ComponentState extends State<Component> {
  final ServiceName _service = ServiceName();
  
  @override
  void initState() {
    super.initState();
    _service.initialize();
  }
}
```

## Styling Approach

### Material 3 Theme Configuration
```dart
MaterialApp(
  theme: ThemeData(
    primarySwatch: Colors.blue,
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.grey.shade50,
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
)
```

### Form Input Styling
```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Label',
    prefixIcon: const Icon(Icons.icon_name),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

### Button Styling
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

## Accessibility & TTS Integration

### TTS Service Pattern
```dart
// Initialize TTS in initState
await _ttsService.initialize();

// Speak user actions
_ttsService.speak('Action description');

// TTS settings integration
SwitchListTile(
  title: const Text('Enable Audio'),
  value: _ttsService.isEnabled,
  onChanged: (value) async {
    await _ttsService.toggleEnabled();
  },
)
```

### Visual Feedback for TTS
```dart
// Animated speaking indicator
if (_ttsService.isSpeaking)
  AnimatedBuilder(
    animation: _animationController,
    builder: (context, child) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        transform: Matrix4.identity()
          ..scale(1.0 + (_animationController.value * 0.3)),
      );
    },
  ),
```

## Asset Management

### Icon System
- Using Material Icons (`Icons.icon_name`)
- Custom icons should be added to `assets/icons/`
- Icon sizes: 24 (standard), 64 (large display)

### Image Assets
```yaml
# pubspec.yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
```

## Figma Integration Guidelines

### Design-to-Code Mapping
1. **Replace Tailwind classes** with Flutter Material widgets
2. **Map Figma components** to `/lib/widgets/` files
3. **Use existing color tokens** instead of hex values
4. **Maintain TTS accessibility** in all interactive elements
5. **Follow Material 3 patterns** for navigation and layout

### Component Naming Convention
- Figma: "Study Card" → Flutter: `StudyCard`
- Figma: "TTS Button" → Flutter: `TTSButton` 
- Figma: "Auth Form" → Flutter: `AuthForm`

### State Management Integration
```dart
// Service-based state management
final ServiceName _service = ServiceName();

// Listen to service changes
_service.addListener(_onServiceChanged);

void _onServiceChanged() {
  setState(() {});
}
```

## Responsive Design Patterns

### Layout Constraints
```dart
// Center content with max width
Center(
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(24.0),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: content,
    ),
  ),
)
```

### Adaptive Spacing
```dart
// Use MediaQuery for responsive spacing
final screenWidth = MediaQuery.of(context).size.width;
final padding = screenWidth > 600 ? 32.0 : 16.0;
```