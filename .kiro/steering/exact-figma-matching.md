---
inclusion: always
---

# 🎯 Achieving Exact Figma Design Matches

## The Problem: "Similar but Not Exact"

When Figma MCP provides designs that are "similar but not exactly the same," it's usually because:

1. **Approximate values were used** instead of exact measurements
2. **forceCode parameter wasn't used** to get full implementation details
3. **Design variables weren't extracted** from Figma
4. **Visual comparison wasn't performed** during implementation

## The Solution: Precision-First Workflow

### 🔧 Essential Tools for Exact Matching

#### 1. get_design_context (Primary Tool)
**Purpose**: Extract exact Flutter code structure
**Critical Parameter**: `forceCode: true` - ALWAYS use this

```dart
// Example usage for Home Screen game cards
kiroPowers.use({
  powerName: "figma",
  serverName: "figma",
  toolName: "get_design_context",
  arguments: {
    nodeId: "123:456", // From Figma URL
    fileKey: "m3ORtzfqv9yMdwGtdgrFbs",
    clientLanguages: "dart",
    clientFrameworks: "flutter",
    forceCode: true // CRITICAL: Always include this
  }
})
```

**What This Gives You**:
- Exact widget hierarchy
- Precise measurements (width: 343, height: 120)
- Exact colors (Color(0xFFF4F4F4))
- Typography details (fontSize: 16, fontWeight: FontWeight.w600)
- Spacing values (EdgeInsets.symmetric(horizontal: 16, vertical: 20))

#### 2. get_variable_defs (Design Tokens)
**Purpose**: Extract design system variables

```dart
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

**What This Gives You**:
- Color variables: `{'primary/blue': '#2196F3'}`
- Spacing tokens: `{'spacing/md': '16px'}`
- Typography scales: `{'text/body': '16px'}`

#### 3. get_screenshot (Visual Reference)
**Purpose**: Generate exact visual for comparison

```dart
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

---

## 📐 Precision Implementation Rules

### Rule 1: Never Approximate
```dart
// ❌ WRONG: Approximating
Container(
  width: 350, // "Close enough"
  padding: EdgeInsets.all(20), // Rounded
  decoration: BoxDecoration(
    color: Colors.grey[100], // Similar color
  ),
)

// ✅ CORRECT: Exact values from get_design_context
Container(
  width: 343, // Exact from Figma
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20), // Exact
  decoration: BoxDecoration(
    color: Color(0xFFF4F4F4), // Exact hex
  ),
)
```

### Rule 2: Use Exact Colors
```dart
// ❌ WRONG: Material color approximations
Colors.blue // Generic blue
Colors.grey[100] // Approximate gray

// ✅ CORRECT: Exact Figma hex values
Color(0xFF2196F3) // Exact blue from Figma
Color(0xFFF4F4F4) // Exact gray from Figma
```

### Rule 3: Match Typography Exactly
```dart
// ❌ WRONG: Theme defaults
Text(
  'Study Stuart',
  style: Theme.of(context).textTheme.headlineMedium, // Generic
)

// ✅ CORRECT: Exact Figma typography
Text(
  'Study Stuart',
  style: TextStyle(
    fontSize: 24, // Exact from Figma
    fontWeight: FontWeight.w700, // Exact weight
    color: Color(0xFF1E1E1E), // Exact color
    letterSpacing: -0.5, // Exact letter spacing
    height: 1.2, // Exact line height
  ),
)
```

### Rule 4: Precise Spacing
```dart
// ❌ WRONG: Rounded spacing
EdgeInsets.all(20) // Approximate
SizedBox(height: 25) // Rounded

// ✅ CORRECT: Exact Figma spacing
EdgeInsets.symmetric(horizontal: 16, vertical: 20) // Exact
SizedBox(height: 24) // Exact from Figma
```

---

## 🔄 Step-by-Step Exact Matching Process

### Step 1: Extract Complete Design Context
```dart
// Get the full implementation details
const result = await kiroPowers.use({
  powerName: "figma",
  serverName: "figma",
  toolName: "get_design_context",
  arguments: {
    nodeId: "YOUR_NODE_ID",
    fileKey: "m3ORtzfqv9yMdwGtdgrFbs",
    clientLanguages: "dart",
    clientFrameworks: "flutter",
    forceCode: true // ESSENTIAL for complete code
  }
});
```

### Step 2: Analyze the Output
Look for these exact values in the response:
- **Dimensions**: `width: 343, height: 120`
- **Colors**: `Color(0xFFF4F4F4)`
- **Typography**: `fontSize: 16, fontWeight: FontWeight.w600`
- **Spacing**: `EdgeInsets.symmetric(horizontal: 16, vertical: 20)`
- **Border Radius**: `BorderRadius.circular(12)`
- **Shadows**: `BoxShadow(color: Color(0x0D000000), blurRadius: 4)`

### Step 3: Implement with Exact Values
Copy the exact values from the MCP output:

```dart
// Example: Game Card from get_design_context output
Container(
  width: 343, // Exact from MCP
  height: 120, // Exact from MCP
  margin: EdgeInsets.only(bottom: 16), // Exact from MCP
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20), // Exact from MCP
  decoration: BoxDecoration(
    color: Color(0xFFF4F4F4), // Exact hex from MCP
    borderRadius: BorderRadius.circular(12), // Exact radius from MCP
    boxShadow: [
      BoxShadow(
        color: Color(0x0D000000), // Exact shadow from MCP
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Quiz Game',
        style: TextStyle(
          fontSize: 18, // Exact from MCP
          fontWeight: FontWeight.w600, // Exact from MCP
          color: Color(0xFF1E1E1E), // Exact from MCP
        ),
      ),
      SizedBox(height: 8), // Exact from MCP
      Text(
        'Test your knowledge',
        style: TextStyle(
          fontSize: 14, // Exact from MCP
          color: Color(0xFF666666), // Exact from MCP
        ),
      ),
    ],
  ),
)
```

### Step 4: Add TTS Integration
```dart
GestureDetector(
  onTap: () {
    _ttsService.speak('Quiz Game card. Test your knowledge.'); // Add TTS
    // Navigation logic
  },
  child: Container(
    // ... exact Figma styling from above
  ),
)
```

### Step 5: Visual Validation
1. Generate screenshot with `get_screenshot`
2. Run Flutter app
3. Compare side-by-side
4. Verify exact matching:
   - Layout alignment
   - Color accuracy
   - Typography matching
   - Spacing precision
   - Border radius
   - Shadow effects

---

## 🚨 Common Precision Mistakes

### Mistake 1: Using forceCode: false or omitting it
```dart
// ❌ This gives incomplete information
arguments: {
  nodeId: "123:456",
  fileKey: "m3ORtzfqv9yMdwGtdgrFbs"
  // Missing forceCode: true
}

// ✅ This gives complete implementation
arguments: {
  nodeId: "123:456", 
  fileKey: "m3ORtzfqv9yMdwGtdgrFbs",
  forceCode: true // ESSENTIAL
}
```

### Mistake 2: Rounding measurements
```dart
// ❌ Figma says 343px, you use 350px
width: 350 // "Close enough" mentality

// ✅ Use exact Figma measurement
width: 343 // Exact match
```

### Mistake 3: Using similar colors
```dart
// ❌ Figma uses #F4F4F4, you use Colors.grey[100]
color: Colors.grey[100] // Different shade

// ✅ Use exact Figma color
color: Color(0xFFF4F4F4) // Exact match
```

### Mistake 4: Ignoring typography details
```dart
// ❌ Missing letter spacing, line height
TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
)

// ✅ Complete typography from Figma
TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  letterSpacing: -0.2, // From Figma
  height: 1.25, // Line height from Figma
)
```

---

## 🎯 Quality Assurance Checklist

Before considering implementation complete:

### Design Extraction ✅
- [ ] Used `get_design_context` with `forceCode: true`
- [ ] Extracted `get_variable_defs` for design tokens
- [ ] Generated `get_screenshot` for visual reference

### Implementation Precision ✅
- [ ] All measurements are exact (no rounding)
- [ ] All colors use exact hex values from Figma
- [ ] Typography matches exactly (size, weight, spacing, height)
- [ ] Spacing uses exact values from Figma
- [ ] Border radius matches exactly
- [ ] Shadows match Figma specifications

### Accessibility Integration ✅
- [ ] TTS support added to all interactive elements
- [ ] Semantic labels provided where needed
- [ ] Navigation announcements included

### Visual Validation ✅
- [ ] Side-by-side comparison with Figma screenshot
- [ ] Pixel-perfect alignment verified
- [ ] Color accuracy confirmed
- [ ] Typography rendering matches
- [ ] Spacing and layout identical

### Testing ✅
- [ ] All interactions work correctly
- [ ] TTS announcements are appropriate
- [ ] Navigation flows as expected
- [ ] Responsive behavior maintained

---

## 🏆 Success Metrics

You've achieved exact Figma matching when:

1. **Visual Comparison**: Flutter app and Figma screenshot are indistinguishable
2. **Measurement Accuracy**: All dimensions match within 1px
3. **Color Precision**: Hex values match exactly
4. **Typography Fidelity**: Font size, weight, spacing identical
5. **Layout Perfection**: Alignment and spacing exact
6. **Accessibility Complete**: TTS integrated throughout

Remember: The goal is **exact matching**, not "close enough"!

---

## 🔗 Quick Reference Commands

### Extract Design Context
```dart
kiroPowers.use({
  powerName: "figma", serverName: "figma", toolName: "get_design_context",
  arguments: { nodeId: "123:456", fileKey: "m3ORtzfqv9yMdwGtdgrFbs", forceCode: true }
})
```

### Get Design Variables
```dart
kiroPowers.use({
  powerName: "figma", serverName: "figma", toolName: "get_variable_defs",
  arguments: { nodeId: "123:456", fileKey: "m3ORtzfqv9yMdwGtdgrFbs" }
})
```

### Generate Screenshot
```dart
kiroPowers.use({
  powerName: "figma", serverName: "figma", toolName: "get_screenshot",
  arguments: { nodeId: "123:456", fileKey: "m3ORtzfqv9yMdwGtdgrFbs" }
})
```

### Add Code Connect
```dart
kiroPowers.use({
  powerName: "figma", serverName: "figma", toolName: "add_code_connect_map",
  arguments: { 
    nodeId: "123:456", fileKey: "m3ORtzfqv9yMdwGtdgrFbs",
    source: "lib/widgets/game_card.dart", componentName: "GameCard", label: "Flutter"
  }
})
```

---

**Remember**: Exact matching is achievable with the right workflow. Follow this guide for pixel-perfect Figma implementations!