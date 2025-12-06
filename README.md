# StudyStuart - Adaptive Learning Mobile App

StudyStuart is a React Native mobile application with a Node.js backend that helps students identify their preferred learning techniques through interactive tests and games, then adapts their study materials to match how they learn best.

## Features

- **Learning Style Assessment**: Comprehensive assessment to identify visual, auditory, kinesthetic, or reading/writing learning preferences
- **Adaptive Study Materials**: Content that adapts to your learning style
- **Interactive Games**: Learning games designed for different learning styles
  - **Quiz Runner Games**: Subway Surfer-style endless runner where you solve quizzes to proceed
    - Math Runner - Solve math problems while running
    - Science Sprint - Answer science questions on the go
    - History Highway - Travel through time with history questions
    - Mixed Challenge - All subjects combined for ultimate challenge
- **Multi-Language Support**: Switch between English and Nepali (नेपाली)
- **Audio Accessibility**: Text-to-speech for all questions - perfect for students who can't read or prefer audio learning
- **Progress Tracking**: Monitor your learning progress and achievements
- **User Dashboard**: Personalized dashboard with statistics and recent activity
- **Material Creation**: Create and share study materials with the community

## Learning Styles Supported

- **Visual Learners**: Learn best through images, diagrams, and visual aids
- **Auditory Learners**: Prefer listening to explanations and discussions
- **Kinesthetic Learners**: Learn through hands-on activities and movement
- **Reading/Writing Learners**: Excel with text-based learning and written materials

## Tech Stack

### Backend
- Node.js
- Express.js
- MongoDB with Mongoose
- JWT Authentication
- bcryptjs for password hashing

### Mobile App
- React Native 0.72
- React Navigation 6
- React Native Paper (Material Design)
- React Native Vector Icons
- AsyncStorage for local data
- Axios for API calls
- Context API for state management

## Prerequisites

- Node.js (v16 or higher)
- MongoDB (local installation or MongoDB Atlas)
- React Native development environment:
  - For Android: Android Studio, Android SDK
  - For iOS: Xcode (macOS only)
- npm or yarn

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd StudyStuart
   ```

2. **Install dependencies for both server and mobile app**
   ```bash
   npm run install-all
   ```

3. **Set up environment variables**
   
   Create a `.env` file in the `server` directory:
   ```env
   MONGODB_URI=mongodb://localhost:27017/studystuart
   JWT_SECRET=your_jwt_secret_key_here
   PORT=5000
   ```

4. **Start MongoDB**
   
   Make sure MongoDB is running on your system.

5. **Seed the database with sample data**
   ```bash
   npm run seed
   ```

6. **Start the development servers**
   ```bash
   npm run dev
   ```

   This will start both the backend server (port 5000) and React Native Metro bundler.

7. **Run the mobile app**
   
   For Android:
   ```bash
   npm run android
   ```
   
   For iOS (macOS only):
   ```bash
   npm run ios
   ```

## Available Scripts

- `npm run dev` - Start both server and mobile Metro bundler
- `npm run server` - Start only the backend server with nodemon
- `npm run mobile` - Start only the React Native Metro bundler
- `npm run android` - Run the app on Android device/emulator
- `npm run ios` - Run the app on iOS device/simulator
- `npm run seed` - Populate database with sample assessment and games
- `npm run install-all` - Install dependencies for both server and mobile
- `npm run build-android` - Build Android APK
- `npm run build-ios` - Build iOS app
- `npm start` - Start the production server

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `GET /api/auth/verify` - Verify JWT token

### Users
- `GET /api/users/profile` - Get user profile
- `PUT /api/users/profile` - Update user profile
- `PUT /api/users/learning-style` - Update learning style
- `GET /api/users/dashboard` - Get dashboard data

### Assessments
- `GET /api/assessments` - Get all assessments
- `GET /api/assessments/:id` - Get specific assessment
- `POST /api/assessments/:id/submit` - Submit assessment answers
- `GET /api/assessments/user/history` - Get user's assessment history

### Study Materials
- `GET /api/materials` - Get all public materials
- `GET /api/materials/my-materials` - Get user's materials
- `GET /api/materials/:id` - Get specific material
- `POST /api/materials` - Create new material
- `PUT /api/materials/:id` - Update material
- `DELETE /api/materials/:id` - Delete material

### Games
- `GET /api/games` - Get all games
- `GET /api/games/:id` - Get specific game
- `POST /api/games/:id/start` - Start game session
- `POST /api/games/sessions/:sessionId/answer` - Submit game answer
- `GET /api/games/:id/leaderboard` - Get game leaderboard

## Usage

1. **Register/Login**: Create an account or sign in
2. **Take Assessment**: Complete the learning style assessment to discover your preferred learning method
3. **Browse Materials**: Explore study materials adapted to your learning style
4. **Play Games**: Engage with interactive learning games
5. **Create Content**: Share your own study materials with the community
6. **Track Progress**: Monitor your learning journey through the dashboard

## Database Models

### User
- Profile information (name, age, grade)
- Learning style preferences and scores
- Study materials and game progress
- User preferences and settings

### Assessment
- Learning style assessment questions
- Multiple choice options with learning style mappings
- Assessment results and scoring

### StudyMaterial
- Original content and adapted versions
- Subject, topic, and difficulty classification
- User engagement metrics (views, likes)

### Game
- Interactive learning games
- Questions with different types (multiple choice, drag-drop, etc.)
- Scoring and reward systems

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the ISC License.

## Support

For support, please open an issue in the GitHub repository or contact the development team.

---

**StudyStuart** - Transforming education through personalized learning experiences! 🎓✨