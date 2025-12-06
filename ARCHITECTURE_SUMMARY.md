# StudyStuart - Architecture Summary (Visual Guide)

## Quick Reference: Technology Stack

### Frontend Technologies
```
┌─────────────────────────────────────────────────────────┐
│                    FRONTEND STACK                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  WEB APPLICATION                                         │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Language:     JavaScript (ES6+)                   │ │
│  │  Framework:    React 18.2.0                        │ │
│  │  UI Library:   Material-UI 5.13.0                  │ │
│  │  Routing:      React Router DOM 6.11.0             │ │
│  │  HTTP Client:  Axios 1.4.0                         │ │
│  │  State:        Context API                         │ │
│  │  Charts:       Recharts 2.6.0                      │ │
│  │  Port:         3000                                │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  MOBILE APPLICATION                                      │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Language:     Dart                                │ │
│  │  Framework:    Flutter 3.8+                        │ │
│  │  UI:           Material Design 3                   │ │
│  │  State:        Provider (ChangeNotifier)           │ │
│  │  Storage:      SharedPreferences 2.3.0             │ │
│  │  TTS:          flutter_tts 4.0.2                   │ │
│  │  Fonts:        Google Fonts 6.1.0                  │ │
│  │  Platforms:    iOS, Android                        │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### Backend Technologies
```
┌─────────────────────────────────────────────────────────┐
│                    BACKEND STACK                         │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  SERVER                                                  │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Language:     JavaScript (Node.js)                │ │
│  │  Runtime:      Node.js 16+ (LTS)                   │ │
│  │  Framework:    Express.js 4.18.2                   │ │
│  │  Port:         5000                                │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  SECURITY                                                │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Auth:         JWT (jsonwebtoken 9.0.2)            │ │
│  │  Password:     bcryptjs 2.4.3 (10 rounds)          │ │
│  │  CORS:         cors 2.8.5                          │ │
│  │  Env Vars:     dotenv 16.3.1                       │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  MIDDLEWARE                                              │
│  ┌────────────────────────────────────────────────────┐ │
│  │  • body-parser 1.20.2                              │ │
│  │  • Custom JWT authentication                       │ │
│  │  • Error handling                                  │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### Database Technology
```
┌─────────────────────────────────────────────────────────┐
│                    DATABASE STACK                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  DATABASE                                                │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Type:         NoSQL Document Database             │ │
│  │  Database:     MongoDB 8.0+                        │ │
│  │  ODM:          Mongoose 8.0.2                      │ │
│  │  Port:         27017 (Local)                       │ │
│  │  Cloud:        MongoDB Atlas (Production)          │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  COLLECTIONS (7 Total)                                   │
│  ┌────────────────────────────────────────────────────┐ │
│  │  1. users              - User accounts             │ │
│  │  2. assessments        - Learning assessments      │ │
│  │  3. assessmentresults  - Assessment submissions    │ │
│  │  4. studymaterials     - Educational content       │ │
│  │  5. studysessions      - Study tracking            │ │
│  │  6. games              - Educational games         │ │
│  │  7. gamesessions       - Game play records         │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```



## Programming Language Connections

```
┌─────────────────────────────────────────────────────────────────────┐
│                    LANGUAGE INTERACTION MAP                          │
└─────────────────────────────────────────────────────────────────────┘

                        ┌──────────────┐
                        │  JavaScript  │
                        │    (ES6+)    │
                        └──────────────┘
                               │
                ┌──────────────┼──────────────┐
                │              │              │
                ↓              ↓              ↓
        ┌──────────┐   ┌──────────┐   ┌──────────┐
        │  React   │   │ Node.js  │   │   JSON   │
        │   Web    │   │  Server  │   │  Format  │
        └──────────┘   └──────────┘   └──────────┘
                               │              │
                               ↓              ↓
                        ┌──────────┐   ┌──────────┐
                        │ Express  │   │ MongoDB  │
                        │Framework │   │   BSON   │
                        └──────────┘   └──────────┘
                               │
                               ↓
                        ┌──────────┐
                        │Mongoose  │
                        │   ODM    │
                        └──────────┘

        ┌──────────────┐
        │     Dart     │
        └──────────────┘
                │
                ↓
        ┌──────────────┐
        │   Flutter    │
        │  Framework   │
        └──────────────┘
                │
                ↓
        ┌──────────────┐
        │ iOS/Android  │
        │   Native     │
        └──────────────┘

        All communicate via:
        ┌──────────────────────────┐
        │   HTTP/REST API (JSON)   │
        │   JWT Authentication     │
        └──────────────────────────┘
```

## API Endpoint Map

```
┌─────────────────────────────────────────────────────────────────────┐
│                         API STRUCTURE                                │
└─────────────────────────────────────────────────────────────────────┘

BASE URL: http://localhost:5000/api

/api
 │
 ├─ /auth ────────────────────── Authentication Routes
 │   ├─ POST   /register        Create new user account
 │   ├─ POST   /login           User authentication
 │   └─ GET    /verify          Verify JWT token
 │
 ├─ /users ───────────────────── User Management Routes
 │   ├─ GET    /profile         Get user profile
 │   ├─ PUT    /profile         Update user profile
 │   ├─ PUT    /learning-style  Update learning preferences
 │   └─ GET    /dashboard       Get dashboard data
 │
 ├─ /assessments ─────────────── Assessment Routes
 │   ├─ GET    /                List all assessments
 │   ├─ GET    /:id             Get specific assessment
 │   ├─ POST   /:id/submit      Submit assessment answers
 │   └─ GET    /user/history    Get user's assessment history
 │
 ├─ /materials ───────────────── Study Materials Routes
 │   ├─ GET    /                List public materials
 │   ├─ GET    /my-materials    Get user's materials
 │   ├─ GET    /:id             Get specific material
 │   ├─ POST   /                Create new material
 │   ├─ PUT    /:id             Update material
 │   └─ DELETE /:id             Delete material
 │
 └─ /games ───────────────────── Game Routes
     ├─ GET    /                List all games
     ├─ GET    /:id             Get specific game
     ├─ POST   /:id/start       Start game session
     ├─ POST   /sessions/:id/answer  Submit game answer
     └─ GET    /:id/leaderboard Get game leaderboard
```

## Database Schema Relationships

```
┌─────────────────────────────────────────────────────────────────────┐
│                    DATABASE RELATIONSHIPS                            │
└─────────────────────────────────────────────────────────────────────┘

                        ┌──────────────┐
                        │    USERS     │
                        │              │
                        │ • _id (PK)   │
                        │ • username   │
                        │ • email      │
                        │ • password   │
                        │ • profile    │
                        │ • learning   │
                        │   Style      │
                        └──────────────┘
                               │
                ┌──────────────┼──────────────┐
                │              │              │
                ↓              ↓              ↓
        ┌──────────┐   ┌──────────┐   ┌──────────┐
        │ASSESSMENT│   │  STUDY   │   │   GAME   │
        │ RESULTS  │   │ SESSIONS │   │ SESSIONS │
        │          │   │          │   │          │
        │• userId  │   │• userId  │   │• userId  │
        │  (FK)    │   │  (FK)    │   │  (FK)    │
        └──────────┘   └──────────┘   └──────────┘
                │              │              │
                ↓              ↓              ↓
        ┌──────────┐   ┌──────────┐   ┌──────────┐
        │ASSESSMENT│   │  STUDY   │   │  GAMES   │
        │          │   │MATERIALS │   │          │
        │• _id(PK) │   │• _id(PK) │   │• _id(PK) │
        └──────────┘   └──────────┘   └──────────┘

Legend:
  PK = Primary Key
  FK = Foreign Key
  → = One-to-Many Relationship
```

## Security Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                      SECURITY ARCHITECTURE                           │
└─────────────────────────────────────────────────────────────────────┘

1. USER REGISTRATION
   ┌──────────┐
   │  Client  │ ──→ { username, email, password }
   └──────────┘
        ↓
   ┌──────────┐
   │  Server  │ ──→ Validate input
   └──────────┘
        ↓
   ┌──────────┐
   │  bcrypt  │ ──→ Hash password (10 rounds)
   └──────────┘      Result: $2a$10$N9qo8uLO...
        ↓
   ┌──────────┐
   │ MongoDB  │ ──→ Store hashed password
   └──────────┘
        ↓
   ┌──────────┐
   │   JWT    │ ──→ Generate token (7-day expiry)
   └──────────┘      Result: eyJhbGciOiJIUzI1NiIs...
        ↓
   ┌──────────┐
   │  Client  │ ←── { token, user }
   └──────────┘

2. AUTHENTICATED REQUEST
   ┌──────────┐
   │  Client  │ ──→ Authorization: Bearer <token>
   └──────────┘
        ↓
   ┌──────────┐
   │  Server  │ ──→ Extract token from header
   └──────────┘
        ↓
   ┌──────────┐
   │   JWT    │ ──→ Verify signature & expiration
   └──────────┘
        ↓
   ┌──────────┐
   │  Server  │ ──→ Process request
   └──────────┘
        ↓
   ┌──────────┐
   │  Client  │ ←── Protected resource
   └──────────┘
```

## Data Flow Example: Playing a Game

```
┌─────────────────────────────────────────────────────────────────────┐
│                    GAME SESSION DATA FLOW                            │
└─────────────────────────────────────────────────────────────────────┘

Step 1: Get Game
   Flutter App ──→ GET /api/games/:id
                   Authorization: Bearer <token>
                   ↓
   Express.js  ──→ Verify JWT
                   ↓
   MongoDB     ──→ Fetch game document
                   ↓
   Express.js  ──→ Return game data
                   ↓
   Flutter App ←── { game: { title, questions, config } }

Step 2: Start Session
   Flutter App ──→ POST /api/games/:id/start
                   Authorization: Bearer <token>
                   ↓
   Express.js  ──→ Create GameSession document
                   ↓
   MongoDB     ──→ Save session
                   ↓
   Flutter App ←── { sessionId, startedAt }

Step 3: Submit Answer
   Flutter App ──→ POST /api/games/sessions/:id/answer
                   { questionId, userAnswer, timeSpent }
                   ↓
   Express.js  ──→ Validate answer
                   Calculate points
                   ↓
   MongoDB     ──→ Update session
                   ↓
   Flutter App ←── { isCorrect, pointsEarned, totalScore }

Step 4: Complete Game
   Flutter App ──→ PUT /api/games/sessions/:id
                   { completed: true, finalScore }
                   ↓
   Express.js  ──→ Update session
                   Update user stats
                   Update game stats
                   ↓
   MongoDB     ──→ Save all updates
                   ↓
   Flutter App ←── { session, rewards, achievements }
```



## Performance Optimization Strategy

```
┌─────────────────────────────────────────────────────────────────────┐
│                    OPTIMIZATION LAYERS                               │
└─────────────────────────────────────────────────────────────────────┘

LAYER 1: DATABASE
┌────────────────────────────────────────────────────────────┐
│  • Indexes on frequently queried fields                    │
│    - users.username (unique)                               │
│    - users.email (unique)                                  │
│    - studymaterials.subject                                │
│    - games.subject, games.difficulty                       │
│                                                            │
│  • Query Optimization                                      │
│    - Select only needed fields                             │
│    - Use .lean() for read-only queries                     │
│    - Populate references efficiently                       │
│                                                            │
│  • Connection Pooling                                      │
│    - Max pool size: 10 connections                         │
│    - Min pool size: 2 connections                          │
└────────────────────────────────────────────────────────────┘

LAYER 2: APPLICATION
┌────────────────────────────────────────────────────────────┐
│  • Caching Strategy                                        │
│    - In-memory cache for static data                       │
│    - Redis for session data (future)                       │
│                                                            │
│  • Pagination                                              │
│    - Limit results per page (default: 10)                  │
│    - Skip/limit for efficient queries                      │
│                                                            │
│  • Response Compression                                    │
│    - Gzip compression for API responses                    │
└────────────────────────────────────────────────────────────┘

LAYER 3: FRONTEND
┌────────────────────────────────────────────────────────────┐
│  React Optimizations:                                      │
│  • Lazy loading routes                                     │
│  • React.memo for expensive components                     │
│  • Virtual scrolling for large lists                       │
│                                                            │
│  Flutter Optimizations:                                    │
│  • ListView.builder for efficient rendering                │
│  • Cached network images                                   │
│  • State management optimization                           │
└────────────────────────────────────────────────────────────┘

LAYER 4: NETWORK
┌────────────────────────────────────────────────────────────┐
│  • Request batching                                        │
│  • API response compression                                │
│  • CDN for static assets (production)                      │
└────────────────────────────────────────────────────────────┘
```

## Deployment Environments

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ENVIRONMENT COMPARISON                            │
└─────────────────────────────────────────────────────────────────────┘

DEVELOPMENT
┌────────────────────────────────────────────────────────────┐
│  Frontend:  localhost:3000 (React Dev Server)              │
│  Backend:   localhost:5000 (Nodemon)                       │
│  Database:  localhost:27017 (MongoDB Local)                │
│  Mobile:    Android Emulator / iOS Simulator               │
│                                                            │
│  Features:                                                 │
│  • Hot reload / Hot module replacement                     │
│  • Source maps for debugging                               │
│  • Console logging                                         │
│  • Sample data                                             │
└────────────────────────────────────────────────────────────┘

PRODUCTION (Recommended)
┌────────────────────────────────────────────────────────────┐
│  CDN:       Cloudflare / AWS CloudFront                    │
│  Load Bal:  NGINX / AWS Application Load Balancer          │
│  Frontend:  Static hosting (Vercel / Netlify)              │
│  Backend:   Multiple Node.js instances (PM2)               │
│  Database:  MongoDB Atlas (Replica Set)                    │
│  Mobile:    App Store / Google Play Store                  │
│                                                            │
│  Features:                                                 │
│  • SSL/TLS encryption                                      │
│  • Automatic scaling                                       │
│  • Automated backups                                       │
│  • Monitoring & logging                                    │
│  • DDoS protection                                         │
└────────────────────────────────────────────────────────────┘
```

## Technology Decision Matrix

```
┌─────────────────────────────────────────────────────────────────────┐
│                    WHY THESE TECHNOLOGIES?                           │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────┬────────────────────────────────────────────────────┐
│ Technology   │ Justification                                      │
├──────────────┼────────────────────────────────────────────────────┤
│ Node.js      │ • Non-blocking I/O for high concurrency           │
│              │ • JavaScript everywhere (frontend + backend)       │
│              │ • Large ecosystem (npm)                            │
│              │ • Fast development                                 │
├──────────────┼────────────────────────────────────────────────────┤
│ Express.js   │ • Lightweight and flexible                         │
│              │ • Extensive middleware ecosystem                   │
│              │ • Easy to learn and use                            │
│              │ • Great for RESTful APIs                           │
├──────────────┼────────────────────────────────────────────────────┤
│ MongoDB      │ • Flexible schema for educational content          │
│              │ • JSON-like documents match JavaScript             │
│              │ • Horizontal scalability (sharding)                │
│              │ • Rich query language                              │
│              │ • Built-in replication                             │
├──────────────┼────────────────────────────────────────────────────┤
│ JWT          │ • Stateless authentication                         │
│              │ • Scalable (no server-side sessions)               │
│              │ • Cross-domain support                             │
│              │ • Industry standard                                │
├──────────────┼────────────────────────────────────────────────────┤
│ bcrypt       │ • Industry-standard password hashing               │
│              │ • Configurable rounds (security vs performance)    │
│              │ • Automatic salt generation                        │
│              │ • Timing-attack resistant                          │
├──────────────┼────────────────────────────────────────────────────┤
│ React        │ • Component-based architecture                     │
│              │ • Virtual DOM for performance                      │
│              │ • Large ecosystem and community                    │
│              │ • Reusable components                              │
├──────────────┼────────────────────────────────────────────────────┤
│ Flutter      │ • Single codebase for iOS and Android             │
│              │ • Native performance                               │
│              │ • Beautiful UI out of the box                      │
│              │ • Hot reload for fast development                  │
│              │ • Growing ecosystem                                │
└──────────────┴────────────────────────────────────────────────────┘
```

## Quick Reference: Key Metrics

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PERFORMANCE TARGETS                               │
└─────────────────────────────────────────────────────────────────────┘

API Response Time:        < 200ms (95th percentile)
Database Query Time:      < 50ms (average)
API Throughput:           1000+ requests/second
Error Rate:               < 0.1%
Uptime:                   99.9%
JWT Token Expiry:         7 days
Password Hash Rounds:     10 (bcrypt)
Connection Pool Size:     10 max, 2 min
Default Pagination:       10 items per page
```

## File Structure Overview

```
StudyStuart/
│
├── client/                      # React Web Application
│   ├── src/
│   │   ├── components/          # Reusable UI components
│   │   ├── pages/               # Page components
│   │   ├── context/             # React Context for state
│   │   └── services/            # API service layer
│   └── package.json
│
├── studystuart_app/             # Flutter Mobile Application
│   ├── lib/
│   │   ├── main.dart            # App entry point
│   │   ├── models/              # Data models
│   │   ├── screens/             # UI screens
│   │   ├── services/            # Services (TTS, Language)
│   │   ├── games/               # Game implementations
│   │   └── data/                # Static data (questions)
│   └── pubspec.yaml
│
├── server/                      # Node.js Backend
│   ├── models/                  # Mongoose schemas
│   │   ├── User.js
│   │   ├── Assessment.js
│   │   ├── Game.js
│   │   └── StudyMaterial.js
│   ├── routes/                  # API route handlers
│   │   ├── auth.js
│   │   ├── users.js
│   │   ├── assessments.js
│   │   ├── games.js
│   │   └── materials.js
│   ├── server.js                # Express server setup
│   ├── seedData.js              # Database seeding
│   └── package.json
│
├── .env                         # Environment variables
├── package.json                 # Root package.json
└── README.md                    # Project documentation
```

---

## Summary

**StudyStuart** is a full-stack educational platform built with:

- **Frontend**: React (Web) + Flutter (Mobile)
- **Backend**: Node.js + Express.js
- **Database**: MongoDB with Mongoose ODM
- **Security**: JWT authentication + bcrypt password hashing
- **Architecture**: Three-tier (Presentation, Application, Data)
- **API**: RESTful with JSON payloads
- **Deployment**: Scalable, cloud-ready architecture

**Key Features**:
- ✅ Cross-platform (Web, iOS, Android)
- ✅ Secure authentication
- ✅ Adaptive learning content
- ✅ Educational games
- ✅ Multi-language support
- ✅ Text-to-speech accessibility
- ✅ Performance optimized
- ✅ Scalable architecture

---

**For detailed technical information, see**: `TECHNICAL_ARCHITECTURE.md`

