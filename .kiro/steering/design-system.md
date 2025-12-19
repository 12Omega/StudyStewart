---
inclusion: always
---

# StudyStewart Design System Rules - Enhanced Figma Integration

## 🎯 Figma-to-Flutter Workflow

### Critical Rule: Exact Design Matching
When implementing Figma designs, prioritize **pixel-perfect accuracy** over approximations. Use the Figma MCP tools to extract exact values rather than estimating.

## Project Context
- **Framework**: Flutter (SDK ^3.8.1)
- **Design Source**: Figma - StudyStewart (https://www.figma.com/design/m3ORtzfqv9yMdwGtdgrFbs/StudyStewart)
- **App Type**: Learning style discovery app with gamification and TTS features
- **Dependencies**: flutter_tts, shared_preferences, cupertino_icons
- **Architecture**: Singleton services, StatefulWidget screens, Material Design 3

### Figma Integration Tools Available
- `get_design_context` - Extract exact UI code from Figma nodes
- `get_screenshot` - Generate visual references for comparison
- `get_variable_defs` - Extract design tokens (colors, spacing, typography)
- `get_metadata` - Get component structure and hierarchy
- `add_code_connect_map` - Link Flutter components to Figma designs

## Design Token Definitions

### Colors (Extract from Figma using get_variable_defs)
```dart
// Primary Colors - Use exact Figma values
Colors.blue (primary swatch - verify with Figma)
Colors.blue.shade400 (gradient start - #42A5F5)
Colors.purple.shade400 (gradient end - #AB47BC)

// Background Colors - Match Figma backgrounds exactly
Colors.grey.shade50 (light scaffold - #FAFAFA)
Colors.grey.shade900 (dark scaffold - #212121)
Color(0xFFF4F4F4) (card background - exact from Figma)
Color(0xFF151729) (dark section - dashboard leaderboard)

// State Colors
Colors.green (success feedback)
Colors.red (error feedback)
Colors.amber (achievement badges)
Colors.white (text on colored backgrounds)
Colors.black54 (secondary text)

// CRITICAL: Always use get_variable_defs tool to extract exact color values from Figma
// Replace hardcoded colors with Figma-extracted values
```

### Typography Scale (Extract exact values from Figma)
```dart
// Headers - Match Figma text styles exactly
TextStyle(fontSize: 24, fontWeight: FontWeight.bold) // Main headers
TextStyle(fontSize: 20, fontWeight: FontWeight.bold) // Section headers
TextStyle(fontSize: 18, fontWeight: FontWeight.w600) // Subheaders
TextStyle(fontSize: 16, fontWeight: FontWeight.w500) // Body emphasis
TextStyle(fontSize: 14, fontWeight: FontWeight.normal) // Body text
TextStyle(fontSize: 12, fontWeight: FontWeight.normal) // Small text
TextStyle(fontSize: 10, color: Colors.grey) // Captions

// CRITICAL: Use get_design_context to extract exact font sizes, weights, and line heights
// Don't approximate - get exact values from Figma text layers
```

### Spacing System (Extract from Figma layouts)
```dart
// Spacing Constants - Use exact Figma measurements
const double spaceXS = 4.0;   // Extra small
const double spaceSM = 8.0;   // Small
const double spaceMD = 16.0;  // Medium (most common)
const double spaceLG = 24.0;  // Large
const double spaceXL = 32.0;  // Extra large
const double space2XL = 40.0; // Section spacing

// Padding Patterns
EdgeInsets.all(spaceMD) // Standard card padding
EdgeInsets.symmetric(horizontal: 20, vertical: 18) // Header padding
EdgeInsets.symmetric(horizontal: spaceMD) // Content padding

// CRITICAL: Measure exact spacing in Figma using get_design_context
// Don't use approximate values - extract precise measurements
```

### Border Radius (Match Figma corner radius exactly)
```dart
// Border Radius Constants
const double radiusXS = 4.0;   // Small elements
const double radiusSM = 8.0;   // Buttons, inputs
const double radiusMD = 12.0;  // Cards, containers
const double radiusLG = 16.0;  // Large cards
const double radiusXL = 25.0;  // Rounded toggles
const double radius2XL = 36.0; // Bottom sheets

// Usage Patterns
BorderRadius.circular(radiusMD) // Standard cards
BorderRadius.circular(radiusLG) // Game cards
BorderRadius.circular(radiusXL) // Toggle switches

// CRITICAL: Extract exact corner radius values from Figma using get_design_context
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

## Asset Management - Exact Figma Assets

### CRITICAL: Use Exact Figma Assets, Not Material Icons

```dart
// Import asset constants
import '../constants/assets.dart';

// ❌ WRONG: Using Material Icons (approximate designs)
Icon(Icons.arrow_back)
Icon(Icons.star)
Icon(Icons.notifications)
Icon(Icons.person)
Icon(Icons.settings)

// ✅ CORRECT: Using exact Figma assets
Image.asset(AppAssets.arrowLeft, width: 30, height: 29)
Image.asset(AppAssets.star, width: 24, height: 24)
Image.asset(AppAssets.notification, width: 24, height: 24)
Image.asset(AppAssets.profile, width: 40, height: 40)
Image.asset(AppAssets.setting, width: 24, height: 24)
```

### Asset Organization Structure
```
assets/
├── screens/          # Reference images for pixel-perfect comparison
│   ├── Home Screen.png
│   ├── Dashboard.png
│   ├── Learning.png
│   ├── Converter.png
│   ├── Settings Light Mode.jpg
│   ├── login.png, Sign up.png, forgot.png
│   └── audio.png, kinestic.png, wordle.png
├── icons/            # UI icons with density variants (@2x, @3x)
│   ├── arrow-left.svg
│   ├── star.png, star@2x.png, star@3x.png
│   ├── notification.png, notification@2x.png, notification@3x.png
│   ├── profile.png, profile@2x.png
│   ├── toggle.png, toggle@2x.png, toggle@3x.png
│   ├── dark-mode.png, dark-mode@2x.png, dark-mode@3x.png
│   ├── logout.png, logout@2x.png, logout@3x.png
│   ├── feedback.png, feedback@2x.png, feedback@3x.png
│   ├── privacy.png, privacy@2x.png, privacy@3x.png
│   ├── share.png, share@2x.png, share@3x.png
│   ├── setting.png
│   └── edit.png
└── images/           # Visual elements, backgrounds, progress indicators
    ├── 76%.png, 76%-1.png (progress indicators)
    ├── dp.png (display picture/avatar)
    ├── Rectangle 39.png, Rectangle 40.png (background elements)
    ├── Ellipse 7.png (circular elements)
    └── back.png, back-1.png, back-2.png, back-3.png (backgrounds)
```

### Density-Aware Asset Loading
```dart
// Flutter automatically selects appropriate density (@2x, @3x)
// based on device pixel ratio - no manual selection needed

Image.asset(
  AppAssets.notification, // Base path: assets/icons/notification.png
  width: 24,
  height: 24,
  // Flutter automatically loads:
  // - notification.png on 1x displays
  // - notification@2x.png on 2x displays  
  // - notification@3x.png on 3x displays
)
```

### Asset Migration Process
```bash
# 1. Run the migration script
cd StudyStewart/studystuart_app
migrate_assets.bat

# 2. Update pubspec.yaml (already done)
flutter pub get

# 3. Import assets in Dart files
import '../constants/assets.dart';

# 4. Replace Material Icons with exact assets
# 5. Compare with reference images for pixel-perfect matching
```

## 🚀 Figma Integration Workflow for Pixel-Perfect Implementation

### Step 1: Extract Design Context
```bash
# Always start with get_design_context for any Figma component
# Provides exact Flutter code matching the design
kiroPowers.use({
  powerName: "figma",
  serverName: "figma", 
  toolName: "get_design_context",
  arguments: {
    nodeId: "123:456", // Extract from Figma URL
    fileKey: "m3ORtzfqv9yMdwGtdgrFbs",
    clientLanguages: "dart",
    clientFrameworks: "flutter",
    forceCode: true // Always get full implementation
  }
})
```

### Step 2: Extract Design Variables
```bash
# Get exact design tokens (colors, spacing, typography)
kiroPowers.use({
  powerName: "figma",
  serverName: "figma",
  toolName: "get_variable_defs", 
  arguments: {
    nodeId: "123:456",
    fileKey: "m3ORtzfqv9yMdwGtdgrFbs"
  }
})
```

### Step 3: Generate Visual Reference
```bash
# Create screenshot for visual comparison
kiroPowers.use({
  powerName: "figma",
  serverName: "figma",
  toolName: "get_screenshot",
  arguments: {
    nodeId: "123:456", 
    fileKey: "m3ORtzfqv9yMdwGtdgrFbs"
  }
})
```

### Step 4: Implementation Rules

#### 🎯 Critical Implementation Guidelines

1. **NEVER approximate measurements** - Always extract exact values from Figma
2. **Use get_design_context first** - Don't guess component structure
3. **Extract colors with get_variable_defs** - Don't use similar colors
4. **Compare with screenshots** - Validate visual accuracy
5. **Maintain TTS accessibility** - Add TTS support to all interactive elements

#### 🔄 Design-to-Code Translation Patterns

**Figma Container → Flutter Container**
```dart
// Extract exact values from get_design_context
Container(
  width: 343, // Exact Figma width
  height: 120, // Exact Figma height
  padding: EdgeInsets.all(16), // Exact Figma padding
  decoration: BoxDecoration(
    color: Color(0xFFF4F4F4), // Exact Figma color
    borderRadius: BorderRadius.circular(12), // Exact Figma radius
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1), // Exact Figma shadow
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  ),
)
```

**Figma Text → Flutter Text**
```dart
// Use exact typography from get_design_context
Text(
  'Study Stuart',
  style: TextStyle(
    fontSize: 24, // Exact Figma font size
    fontWeight: FontWeight.w700, // Exact Figma font weight
    color: Color(0xFF1E1E1E), // Exact Figma text color
    letterSpacing: -0.5, // Exact Figma letter spacing
    height: 1.2, // Exact Figma line height
  ),
)
```

**Figma Button → Flutter ElevatedButton**
```dart
// Match exact Figma button styling
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF2196F3), // Exact Figma color
    foregroundColor: Colors.white,
    minimumSize: Size(280, 48), // Exact Figma dimensions
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Exact Figma radius
    ),
    elevation: 2, // Match Figma shadow
  ),
  onPressed: () {
    _ttsService.speak('Button pressed'); // Always add TTS
  },
  child: Text(
    'Get Started',
    style: TextStyle(
      fontSize: 16, // Exact Figma font size
      fontWeight: FontWeight.w600, // Exact Figma weight
    ),
  ),
)
```

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