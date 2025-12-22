# Educational Wordle & Learning Runner Games

## Overview
Added two exciting new game types to StudyStewart: an enhanced educational Wordle game with multiple subject categories and a Subway Surfer-style endless runner with integrated learning elements.

---

## 1. Educational Wordle Plus

### Description
An enhanced version of the classic Wordle game featuring educational vocabulary from multiple subject areas. Players guess 5-letter words while learning definitions and building subject-specific vocabulary.

### Key Features

#### Multiple Subject Categories
- **Science**: Atoms, Cells, Genes, Light, Sound, Water, Plant, Earth, Space, Force
- **Math**: Angle, Graph, Prime, Ratio, Slope, Chord, Digit, Equal, Minus, Round
- **History**: Kings, Peace, Trade, Crown, Sword, Queen, Tribe, Stone
- **Geography**: Ocean, River, Mount, Plain, Coast, Beach, Field, Woods, Cliff, Lakes

#### Game Mechanics
- **6 Attempts**: Players have 6 tries to guess the correct word
- **Color Feedback**:
  - 🟩 Green: Letter is correct and in the right position
  - 🟨 Yellow: Letter is in the word but wrong position
  - ⬜ Grey: Letter is not in the word
- **Definition Hints**: Each word comes with its educational definition
- **Category Switching**: Easily switch between subjects during gameplay
- **Hint System**: Get additional hints showing the first letter

#### Scoring System
- Points awarded based on number of attempts used
- Fewer attempts = Higher score
- 6 attempts remaining: 60 points
- 5 attempts remaining: 50 points
- 4 attempts remaining: 40 points
- And so on...

#### Educational Value
- **Vocabulary Building**: Learn subject-specific terminology
- **Spelling Practice**: Reinforce correct spelling of academic words
- **Definition Learning**: Each word includes its educational definition
- **Subject Integration**: Connect words to their academic context
- **Streak Tracking**: Encourages consistent learning

#### Accessibility Features
- Full TTS integration for all instructions
- Audio pronunciation of guessed words
- Spoken definitions for educational reinforcement
- Visual and audio feedback for correct/incorrect guesses

---

## 2. Learning Runner (Subway Surfer Style)

### Description
An endless runner game inspired by Subway Surfer, where players run, jump over obstacles, collect coins, and answer math questions while maintaining their run. Combines fast-paced action with educational content.

### Key Features

#### Gameplay Mechanics
- **Endless Running**: Continuous forward movement with increasing speed
- **Jump Controls**: Tap anywhere to jump over obstacles
- **Progressive Difficulty**: Game speed increases as distance increases
- **Three Obstacle Types**:
  - 📦 Boxes: Standard obstacles
  - ⚠️ Spikes: Dangerous barriers
  - 🚧 Barriers: Large obstacles

#### Educational Integration
- **Math Questions**: Pop-up questions every 15 seconds
- **Question Types**: Addition, subtraction, multiplication, division
- **Pause on Question**: Game pauses when question appears
- **Bonus Rewards**: Correct answers give +50 points and 3 bonus coins
- **Accuracy Tracking**: Tracks math question performance

#### Collectibles
- **Coins**: Scattered throughout the running path
- **Coin Value**: 10 points per coin
- **Bonus Coins**: 3 coins awarded for correct math answers
- **Random Spawning**: Coins appear at varying heights and positions

#### Scoring System
- **Distance Points**: 1 point per meter traveled
- **Coin Collection**: 10 points per coin
- **Math Bonus**: 50 points per correct answer
- **Speed Multiplier**: Score increases with game speed

#### Game Stats Tracked
- **Score**: Total points accumulated
- **Distance**: Meters traveled
- **Coins Collected**: Total coins gathered
- **Math Accuracy**: Percentage of correct answers
- **Questions Answered**: Total math questions attempted
- **Correct Answers**: Number of correct math responses

#### Visual Elements
- **Animated Runner**: Character with running and jumping animations
- **Dynamic Background**: Gradient sky with ground texture
- **Obstacle Variety**: Different colored obstacles with icons
- **Coin Animation**: Rotating coin collectibles
- **Ground Pattern**: Grass texture for realistic feel

#### Game States
1. **Start Screen**: Instructions and start button
2. **Running**: Active gameplay with obstacles and coins
3. **Question Pause**: Math question overlay
4. **Game Over**: Final stats and restart option

#### Educational Value
- **Mental Math Practice**: Quick arithmetic under time pressure
- **Decision Making**: Choose when to jump vs. collect coins
- **Hand-Eye Coordination**: Timing jumps with obstacles
- **Multi-tasking**: Balance running with answering questions
- **Progress Tracking**: See improvement in math accuracy over time

---

## Technical Implementation

### Architecture Consistency
Both games follow established patterns:
- Extend `StatefulWidget` with state management
- Use `TTSService` for accessibility
- Include `TTSButton` widget
- Material Design 3 UI components
- Gradient backgrounds
- Consistent navigation

### Animation Controllers
**Educational Wordle:**
- Smooth keyboard interactions
- Color transition animations
- Card flip effects for results

**Learning Runner:**
- Run cycle animation (200ms loop)
- Jump animation (600ms with ease-in-out curve)
- Smooth obstacle movement
- Coin collection effects

### Game Timers
**Learning Runner uses multiple timers:**
- `_gameTimer`: 50ms intervals for game loop
- `_obstacleTimer`: 2000ms intervals for spawning
- `_questionTimer`: 15-second intervals for math questions

### Collision Detection
**Learning Runner:**
- Rectangle-based collision detection
- Player hitbox: 40x50 pixels
- Obstacle hitboxes: Variable sizes
- Coin collection radius: 30x30 pixels

---

## Home Screen Integration

### Updated Layout
- Now displays 8 games in a 2x4 scrollable grid
- New games positioned prominently:
  - **Educational Wordle**: Position 3 (top row, right)
  - **Learning Runner**: Position 4 (second row, left)

### Visual Design
- **Educational Wordle**: Teal to cyan gradient with school icon
- **Learning Runner**: Light blue to green gradient with running icon
- Consistent card styling with shadows and rounded corners

---

## File Structure
```
StudyStewart/studystuart_app/lib/screens/
├── educational_wordle_screen.dart    # Enhanced Wordle with categories
├── learning_runner_screen.dart       # Subway Surfer-style runner
└── home_screen.dart                  # Updated with new games
```

---

## Game Comparison

| Feature | Educational Wordle | Learning Runner |
|---------|-------------------|-----------------|
| **Type** | Word puzzle | Endless runner |
| **Pace** | Turn-based | Real-time |
| **Subject** | Multi-subject vocabulary | Math |
| **Duration** | 5-10 minutes | Unlimited |
| **Difficulty** | Static per word | Progressive |
| **Skills** | Spelling, vocabulary | Reflexes, mental math |
| **Replay Value** | High (multiple categories) | High (endless gameplay) |

---

## Educational Outcomes

### Educational Wordle
- ✅ Vocabulary expansion across subjects
- ✅ Spelling reinforcement
- ✅ Definition memorization
- ✅ Subject-specific terminology
- ✅ Critical thinking and deduction

### Learning Runner
- ✅ Mental arithmetic speed
- ✅ Multi-tasking abilities
- ✅ Quick decision making
- ✅ Hand-eye coordination
- ✅ Sustained attention and focus

---

## Future Enhancements

### Educational Wordle
- [ ] Daily challenge mode
- [ ] Custom word lists
- [ ] Multiplayer competitions
- [ ] Achievement badges for categories
- [ ] Word history and statistics
- [ ] Difficulty levels (3, 4, 5, 6 letter words)

### Learning Runner
- [ ] Power-ups (shields, magnets, double points)
- [ ] Multiple character skins
- [ ] Different environments (city, forest, space)
- [ ] Leaderboards
- [ ] Subject selection (science, history questions)
- [ ] Multiplayer race mode
- [ ] Daily missions and challenges

---

## Testing Recommendations

### Educational Wordle
1. Test all category word lists for accuracy
2. Verify definition correctness
3. Test keyboard input on different devices
4. Validate color feedback logic
5. Test hint system functionality
6. Verify score calculation
7. Test category switching during gameplay

### Learning Runner
1. Test collision detection accuracy
2. Verify timer synchronization
3. Test game speed progression
4. Validate math question randomization
5. Test pause/resume functionality
6. Verify score calculation
7. Test on different screen sizes
8. Validate animation smoothness

---

## Accessibility Features

### Both Games Include
- ✅ Full TTS support for all instructions
- ✅ Audio feedback for actions
- ✅ High contrast visual elements
- ✅ Clear, readable fonts
- ✅ Intuitive touch controls
- ✅ Visual and audio confirmation

---

## Performance Considerations

### Educational Wordle
- Lightweight word lists stored in memory
- Efficient state management
- Minimal animation overhead
- Fast category switching

### Learning Runner
- Optimized game loop (50ms intervals)
- Efficient collision detection
- Automatic cleanup of off-screen objects
- Smooth 60 FPS animations
- Memory-efficient obstacle spawning

---

## Conclusion

These two new games significantly expand StudyStewart's educational gaming portfolio:

- **Educational Wordle** provides focused vocabulary learning across multiple subjects
- **Learning Runner** combines action gameplay with math practice

Both games maintain the app's commitment to accessibility, educational value, and engaging gameplay while introducing new mechanics and learning approaches.