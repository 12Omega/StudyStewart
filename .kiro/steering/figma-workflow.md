---
inclusion: always
---

# 🎨 Figma-to-Flutter Workflow Guide

## Overview
This guide provides a step-by-step workflow for implementing Figma designs with pixel-perfect accuracy in the StudyStewart Flutter app.

## 🎯 Goal: Exact Design Matching
The Figma MCP tools can provide designs that match your Figma files **exactly**, not just "similar". Follow this workflow to achieve 100% design accuracy.

---

## 📋 Pre-Implementation Checklist

Before implementing any Figma design:

- [ ] Have the Figma URL with specific node ID
- [ ] Understand which screen/component you're implementing
- [ ] Know the target Flutter file location
- [ ] Have TTS requirements identified

---

## 🔄 Implementation Workflow

### Phase 1: Design Extraction

#### Step 1.1: Get Design Context
**Purpose**: Extract exact Flutter code structure from Figma

```dart
// Example: Implementing Home Screen
// Figma URL: https://www.figma.com/design/m3ORtzfqv9yMdwGtdgrFbs/StudyStewart?node-id=123-456

kiroPowers.use({
  powerName: "figma",
  serverName: "figma",
  toolName: "get_design_context",
  arguments: {
    nodeId: "123:456", // From URL: node-id=123-456 → "123:456"
    fileKey: "m3ORtzfqv9yMdwGtdgrFbs", // From URL
    clientLanguages: "dart",
    clientFrameworks: "flutter",
    forceCode: true // CRITICAL: Always use this for full code
  }
})
```

**What you get**:
- Exact widget structure
- Precise measurements (width, height, padding)
- Exact colors (hex values)
- Typography details (size, weight, line height)
- Layout hierarchy

#### Step 1.2: Extract Design Variables
**Purpose**: Get design tokens for consistency

```dart
kiroPowers.use({
  powerName: "figma",
  serverName: "figma",
  toolName: "get_variable_defs",
  arguments: {
    nodeId: "123:456",
    fileKey: "m3ORtzfqv9yMdwGtdgrFbs",
    clientLanguages: "dart",
    clientFrameworks: "flutter"
  }
})
```

**What you get**:
- Color variables: `{'primary/blue': '#2196F3', 'background/light': '#FAFAFA'}`
- Spacing tokens
- Typography scales
- Reusable design tokens

#### Step 1.3: Generate Screenshot
**Purpose**: Visual reference for validation

```dart
kiroPowers.use({
  powerName: "figma",
  serverName: "figma",
  toolName: "get_screenshot",
  arguments: {
    nodeId: "123:456",
    fileKey: "m3ORtzfqv9yMdwGtdgrFbs",
    clientLanguages: "dart",
    clientFrameworks: "flutter"
  }
})
```

**What you get**:
- PNG screenshot of the exact design
- Visual reference for comparison
- Validation tool for pixel-perfect matching

---

### Phase 2: Code Translation

#### Step 2.1: Analyze MCP Output
Review the `get_design_context` output and identify:

1. **Layout Structure**: Stack, Column, Row, Container hierarchy
2. **Exact Measurements**: All width, height, padding, margin values
3. **Colors**: All hex color codes
4. **Typography**: Font sizes, weights, line heights
5. **Interactive Elements**: Buttons, inputs, tappable areas

#### Step 2.2: Create Flutter Implementation

**Translation Rules**:

| Figma Element | Flutter Widget | Notes |
|---------------|----------------|-------|
| Frame/Container | `Container` or `Card` | Use exact dimensions |
| Text | `Text` with `TextStyle` | Match font size, weight, color exactly |
| Button | `ElevatedButton` or `TextButton` | Match size, color, radius |
| Input | `TextField` or `TextFormField` | Match border, padding, colors |
| Image | `Image.asset` or `Icon` | Use Material icons or assets |
| Auto Layout | `Column`, `Row`, `Flex` | Match spacing and alignment |
| Gradient | `BoxDecoration` with `LinearGradient` | Use exact color stops |

#### Step 2.3: Apply Exact Values

**Example: Implementing a Game Card**

```dart
// ❌ WRONG: Approximating values
Container(
  width: 350, // Guessed
  padding: EdgeInsets.all(20), // Approximate
  decoration: BoxDecoration(
    color: Colors.grey[100], // Similar color
    borderRadius: BorderRadius.circular(15), // Rounded
  ),
)

// ✅ CORRECT: Using exact Figma values from get_design_context
Container(
  width: 343, // Exact from Figma
  height: 120, // Exact from Figma
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20), // Exact
  decoration: BoxDecoration(
    color: Color(0xFFF4F4F4), // Exact hex from Figma
    borderRadius: BorderRadius.circular(12), // Exact radius
    boxShadow: [
      BoxShadow(
        color: Color(0x0D000000), // Exact shadow color with opacity
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  ),
)
```

---

### Phase 3: Accessibility Integration

#### Step 3.1: Add TTS Support
Every interactive element must have TTS support:

```dart
GestureDetector(
  onTap: () {
    _ttsService.speak('Game card tapped. Opening quiz game.'); // Add TTS
    Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen()));
  },
  child: Container(
    // ... exact Figma styling
  ),
)
```

#### Step 3.2: Add Semantic Labels
```dart
Semantics(
  label: 'Quiz Game Card',
  hint: 'Tap to start quiz game',
  child: Container(
    // ... exact Figma styling
  ),
)
```

---

### Phase 4: Validation

#### Step 4.1: Visual Comparison
1. Run the Flutter app
2. Open the Figma screenshot side-by-side
3. Compare:
   - Layout alignment
   - Spacing (padding, margins)
   - Colors (exact match, not similar)
   - Typography (size, weight, line height)
   - Border radius
   - Shadows and elevation

#### Step 4.2: Measurement Verification
Use Flutter DevTools to verify:
- Widget dimensions match Figma exactly
- Padding/margin values are correct
- Colors are exact hex matches

#### Step 4.3: Interaction Testing
- Test all tap targets
- Verify TTS announcements
- Check navigation flows
- Validate form inputs

---

## 🛠️ Common Issues & Solutions

### Issue 1: "Design looks similar but not exact"
**Cause**: Using approximate values instead of exact Figma measurements

**Solution**:
1. Re-run `get_design_context` with `forceCode: true`
2. Extract exact values from the output
3. Replace all approximate values with exact measurements
4. Use hex colors, not Material color approximations

### Issue 2: "Spacing is slightly off"
**Cause**: Not using exact padding/margin values from Figma

**Solution**:
1. Check `get_design_context` output for exact spacing
2. Use `EdgeInsets.symmetric()` or `EdgeInsets.only()` with exact values
3. Don't round to nearest 8 or 16 - use exact values

### Issue 3: "Colors don't match exactly"
**Cause**: Using Material colors instead of Figma hex values

**Solution**:
1. Use `get_variable_defs` to extract exact colors
2. Replace `Colors.blue` with `Color(0xFF2196F3)` (exact hex)
3. Match opacity values exactly: `Color(0x1A000000)` not `.withOpacity(0.1)`

### Issue 4: "Typography looks different"
**Cause**: Not matching font size, weight, and line height

**Solution**:
1. Extract exact `TextStyle` from `get_design_context`
2. Match `fontSize`, `fontWeight`, `height` (line height), `letterSpacing`
3. Don't use theme defaults - specify exact values

---

## 📊 Quality Checklist

Before marking implementation complete:

- [ ] Ran `get_design_context` with `forceCode: true`
- [ ] Extracted exact measurements (no approximations)
- [ ] Used exact hex colors (not Material color approximations)
- [ ] Matched typography exactly (size, weight, line height)
- [ ] Applied exact spacing (padding, margins)
- [ ] Used exact border radius values
- [ ] Matched shadows and elevation
- [ ] Added TTS support to all interactive elements
- [ ] Compared with Figma screenshot side-by-side
- [ ] Verified measurements in Flutter DevTools
- [ ] Tested all interactions and navigation
- [ ] Validated on multiple screen sizes

---

## 🎓 Best Practices

### DO ✅
- Always use `get_design_context` first
- Extract exact values from Figma
- Use hex colors: `Color(0xFF2196F3)`
- Specify exact dimensions: `width: 343, height: 120`
- Match typography exactly: `fontSize: 16, fontWeight: FontWeight.w600`
- Add TTS to all interactive elements
- Compare with screenshots for validation

### DON'T ❌
- Don't approximate measurements
- Don't use "similar" colors
- Don't round spacing to nearest 8/16
- Don't use theme defaults without verification
- Don't skip `forceCode: true` parameter
- Don't implement without visual comparison
- Don't forget TTS accessibility

---

## 🔗 Quick Reference

### Figma URL Format
```
https://www.figma.com/design/{fileKey}/{fileName}?node-id={nodeId}
```

### Extracting IDs from URL
- **fileKey**: `m3ORtzfqv9yMdwGtdgrFbs` (from URL path)
- **nodeId**: `123-456` in URL → `123:456` in API (replace `-` with `:`)

### Essential MCP Tools
1. `get_design_context` - Primary tool for implementation
2. `get_variable_defs` - Extract design tokens
3. `get_screenshot` - Visual reference
4. `get_metadata` - Component structure overview
5. `add_code_connect_map` - Link code to Figma

---

## 📞 Need Help?

If designs still don't match exactly:
1. Verify you're using `forceCode: true`
2. Check you're using exact hex colors
3. Confirm measurements aren't rounded
4. Compare with screenshot pixel-by-pixel
5. Use Flutter DevTools to inspect actual values

Remember: The goal is **exact matching**, not "close enough"!
