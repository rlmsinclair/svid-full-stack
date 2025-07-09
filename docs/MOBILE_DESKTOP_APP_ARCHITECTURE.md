# Pixr Mobile & Desktop App Architecture

## Overview

This document outlines the architecture for Pixr mobile and desktop applications with advanced facial and speaker recognition capabilities for indexing personal media libraries.

## Core Features

### 1. Media Library Indexing
- Scan local photos and videos
- Extract faces and identify individuals
- Transcribe audio and identify speakers
- Build searchable personal media database

### 2. Recognition Capabilities
- **Facial Recognition**: Identify and group people across photos/videos
- **Speaker Recognition**: Identify speakers in videos by voice
- **Scene Recognition**: Categorize content by location/activity
- **Object Detection**: Tag items and activities

### 3. Privacy-First Design
- All processing happens locally
- No cloud upload without explicit consent
- Encrypted local database
- User controls all data

## Technology Stack

### Mobile App (React Native)

```javascript
// Core dependencies
{
  "react-native": "0.72.x",
  "expo": "49.x", // For easier development
  "@tensorflow/tfjs-react-native": "0.8.x", // ML models
  "react-native-vision-camera": "3.x", // Camera access
  "react-native-fs": "2.x", // File system
  "realm": "12.x" // Local database
}
```

### Desktop App (Electron + React)

```javascript
// Core dependencies
{
  "electron": "27.x",
  "react": "18.x",
  "@tensorflow/tfjs-node": "4.x", // ML models
  "face-api.js": "0.22.x", // Facial recognition
  "node-wav": "0.0.2", // Audio processing
  "nedb": "1.8.x" // Embedded database
}
```

## Architecture Components

### 1. Media Scanner Module

```typescript
interface MediaScanner {
  scanDirectory(path: string): Promise<MediaFile[]>;
  watchForChanges(path: string): EventEmitter;
  extractMetadata(file: MediaFile): Promise<Metadata>;
}

class LocalMediaScanner implements MediaScanner {
  async scanDirectory(path: string) {
    // Recursively scan for photos/videos
    // Extract EXIF data
    // Queue for processing
  }
}
```

### 2. Face Recognition Engine

```typescript
interface FaceRecognitionEngine {
  detectFaces(image: ImageData): Promise<Face[]>;
  extractEmbedding(face: Face): Promise<Float32Array>;
  matchFace(embedding: Float32Array): Promise<Person>;
  trainNewPerson(faces: Face[], name: string): Promise<void>;
}

class TensorFlowFaceEngine implements FaceRecognitionEngine {
  private model: tf.GraphModel;
  
  async detectFaces(image: ImageData) {
    // Use MTCNN or BlazeFace for detection
    // Return bounding boxes and landmarks
  }
  
  async extractEmbedding(face: Face) {
    // Use FaceNet or similar for embeddings
    // Return 128D feature vector
  }
}
```

### 3. Speaker Recognition Module

```typescript
interface SpeakerRecognition {
  extractVoiceprint(audio: AudioBuffer): Promise<Float32Array>;
  identifySpeaker(voiceprint: Float32Array): Promise<Speaker>;
  diarize(audio: AudioBuffer): Promise<DiarizedSegment[]>;
}

class DeepSpeakerEngine implements SpeakerRecognition {
  async extractVoiceprint(audio: AudioBuffer) {
    // Extract MFCC features
    // Generate speaker embedding
  }
  
  async diarize(audio: AudioBuffer) {
    // Segment audio by speaker
    // Return timestamps and speaker IDs
  }
}
```

### 4. Local Database Schema

```sql
-- People table
CREATE TABLE people (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  face_embeddings BLOB, -- Averaged face embedding
  voice_embeddings BLOB, -- Averaged voice embedding
  photo_count INTEGER DEFAULT 0,
  video_count INTEGER DEFAULT 0,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Media files
CREATE TABLE media_files (
  id TEXT PRIMARY KEY,
  file_path TEXT UNIQUE NOT NULL,
  type TEXT CHECK(type IN ('photo', 'video')),
  timestamp TIMESTAMP,
  location_lat REAL,
  location_lon REAL,
  processed BOOLEAN DEFAULT FALSE,
  metadata JSON
);

-- Face detections
CREATE TABLE face_detections (
  id TEXT PRIMARY KEY,
  media_file_id TEXT REFERENCES media_files(id),
  person_id TEXT REFERENCES people(id),
  bounding_box JSON,
  embedding BLOB,
  confidence REAL
);

-- Speaker segments
CREATE TABLE speaker_segments (
  id TEXT PRIMARY KEY,
  media_file_id TEXT REFERENCES media_files(id),
  person_id TEXT REFERENCES people(id),
  start_time REAL,
  end_time REAL,
  transcript TEXT,
  confidence REAL
);
```

## Implementation Plan

### Phase 1: Core Infrastructure
1. Set up Electron/React Native projects
2. Implement media scanner
3. Create local database
4. Basic UI for browsing media

### Phase 2: Face Recognition
1. Integrate TensorFlow.js models
2. Implement face detection
3. Create face clustering algorithm
4. Build person management UI

### Phase 3: Speaker Recognition
1. Integrate audio processing
2. Implement speaker diarization
3. Create voice profile system
4. Sync with face identities

### Phase 4: Advanced Features
1. Scene and object detection
2. Natural language search
3. Timeline visualization
4. Export capabilities

## Privacy & Security

### Data Protection
- AES-256 encryption for database
- No network requests without consent
- Local processing only
- Secure key storage

### User Controls
- Delete any person/detection
- Export all data
- Clear all data
- Disable specific features

## Desktop App UI Components

```typescript
// Main window structure
const AppLayout = () => (
  <div className="app">
    <Sidebar>
      <PeopleList />
      <LocationsList />
      <DateFilter />
    </Sidebar>
    <MainContent>
      <SearchBar />
      <MediaGrid />
      <Timeline />
    </MainContent>
    <DetailPanel>
      <MediaInfo />
      <DetectedPeople />
      <Transcript />
    </DetailPanel>
  </div>
);
```

## Mobile App Screens

```typescript
// Navigation structure
const AppNavigator = () => (
  <NavigationContainer>
    <Tab.Navigator>
      <Tab.Screen name="Library" component={LibraryScreen} />
      <Tab.Screen name="People" component={PeopleScreen} />
      <Tab.Screen name="Search" component={SearchScreen} />
      <Tab.Screen name="Settings" component={SettingsScreen} />
    </Tab.Navigator>
  </NavigationContainer>
);
```

## Performance Considerations

### Processing Pipeline
1. Queue system for background processing
2. Incremental indexing
3. Thumbnail generation
4. Progress indicators

### Optimization
- WebWorkers for heavy computation
- GPU acceleration via WebGL
- Efficient caching strategies
- Lazy loading for large libraries

## Integration with Pixr Platform

### Optional Cloud Sync
- Selective upload to Pixr
- Privacy-preserving sync
- Cross-device continuity
- Backup capabilities

### Pixr Features
- Upload indexed content
- Leverage Pixr's video processing
- Monetization opportunities
- Community sharing (with consent)

## Development Roadmap

### MVP (Month 1-2)
- Basic media scanning
- Simple face detection
- Local search
- Desktop app only

### Beta (Month 3-4)
- Face recognition
- Person management
- Mobile app
- Basic voice features

### Release (Month 5-6)
- Full speaker recognition
- Advanced search
- Performance optimization
- Privacy controls

## Testing Strategy

### Unit Tests
- ML model accuracy
- Database operations
- File system handling

### Integration Tests
- End-to-end processing
- Cross-platform compatibility
- Performance benchmarks

### User Testing
- Privacy concerns
- UI/UX feedback
- Performance on real libraries