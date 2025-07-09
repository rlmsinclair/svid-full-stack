# Video Processing Refactoring Plan

## Current State

We currently have two separate video processors with significant code duplication:

1. **VideoProcessor** (`src/processing/mod.rs` - 2017 lines)
   - Handles paid videos with full AI processing
   - Performs scene detection, frame analysis, transcription
   - Uses OpenAI for content analysis

2. **FFmpegVideoProcessor** (`src/processing/ffmpeg_processor.rs` - 629 lines)
   - Handles open-source videos without AI costs
   - Basic scene detection and thumbnail generation only
   - No AI analysis or transcription

## Problem

Approximately 40% of the code is duplicated between the two processors:
- Video downloading (aria2c/curl fallback logic)
- HLS transcoding
- Thumbnail generation (video and scene thumbnails)
- S3 operations
- Database operations (get_video, update_status, update_metadata)
- Processing stage updates

## Proposed Solution

### 1. Create a Base Video Processor Trait

```rust
// src/processing/base.rs
#[async_trait]
pub trait BaseVideoProcessor {
    async fn download_video(&self, s3_key: &str, local_path: &str) -> Result<(), ProcessingError>;
    async fn transcode_to_hls(&self, input_path: &str, output_dir: &str) -> Result<(), ProcessingError>;
    async fn generate_video_thumbnail(&self, video_path: &str, video_id: &Uuid, scenes: &[Scene]) -> Result<(), ProcessingError>;
    async fn generate_scene_thumbnails(&self, video_id: &Uuid, video_path: &str, scenes: &[Scene]) -> Result<Vec<Scene>, ProcessingError>;
    async fn upload_to_s3(&self, local_path: &str, s3_key: &str) -> Result<(), ProcessingError>;
    async fn update_video_status(&self, video_id: &Uuid, status: &str) -> Result<(), ProcessingError>;
    async fn update_processing_stage(&self, video_id: &Uuid, stage: &str, details: Value) -> Result<(), ProcessingError>;
}
```

### 2. Create a Shared Video Processing Core

```rust
// src/processing/core.rs
pub struct VideoProcessingCore {
    pool: PgPool,
    s3: S3Storage,
}

impl VideoProcessingCore {
    // Implement all shared functionality here
    // This becomes the single source of truth for common operations
}
```

### 3. Refactor Existing Processors

```rust
// src/processing/ai_processor.rs
pub struct AIVideoProcessor {
    core: VideoProcessingCore,
    openai_client: OpenAIClient,
}

impl AIVideoProcessor {
    pub async fn process_video(&self, video_id: Uuid) -> Result<(), ProcessingError> {
        // 1. Use core for downloading
        // 2. Use core for basic processing
        // 3. Add AI-specific processing
        // 4. Use core for uploading results
    }
}

// src/processing/basic_processor.rs
pub struct BasicVideoProcessor {
    core: VideoProcessingCore,
}

impl BasicVideoProcessor {
    pub async fn process_video(&self, video_id: Uuid) -> Result<(), ProcessingError> {
        // 1. Use core for downloading
        // 2. Use core for basic processing
        // 3. Use core for uploading results
    }
}
```

### 4. Introduce Processing Strategies

```rust
// src/processing/strategies.rs
pub enum ProcessingStrategy {
    Full(FullProcessingConfig),      // Paid videos with AI
    Basic(BasicProcessingConfig),     // Open-source videos
    Investment(InvestmentConfig),     // Investment upgrades
}

pub struct UnifiedVideoProcessor {
    core: VideoProcessingCore,
    ai_client: Option<OpenAIClient>,
}

impl UnifiedVideoProcessor {
    pub async fn process(&self, video_id: Uuid, strategy: ProcessingStrategy) -> Result<(), ProcessingError> {
        match strategy {
            ProcessingStrategy::Full(config) => self.process_full(video_id, config).await,
            ProcessingStrategy::Basic(config) => self.process_basic(video_id, config).await,
            ProcessingStrategy::Investment(config) => self.process_investment(video_id, config).await,
        }
    }
}
```

## Implementation Steps

### Phase 1: Extract Common Components (1-2 days)
1. Create `processing/common/` module
2. Move download_video logic to common module
3. Move HLS transcoding logic to common module
4. Move thumbnail generation to common module
5. Move S3 operations to common module

### Phase 2: Create Core Infrastructure (1 day)
1. Design ProcessingError type for better error handling
2. Create VideoProcessingCore struct
3. Implement database operation helpers
4. Add comprehensive logging and metrics

### Phase 3: Refactor Existing Processors (2 days)
1. Update VideoProcessor to use common components
2. Update FFmpegVideoProcessor to use common components
3. Ensure all tests pass
4. Add integration tests for both processors

### Phase 4: Unify Processing Pipeline (2 days)
1. Create UnifiedVideoProcessor
2. Implement strategy pattern
3. Update queue.rs to use unified processor
4. Remove old processor implementations

### Phase 5: Optimization and Testing (1 day)
1. Add performance benchmarks
2. Optimize shared code paths
3. Add comprehensive error recovery
4. Document new architecture

## Benefits

1. **Code Reduction**: Eliminate ~800 lines of duplicate code
2. **Maintainability**: Single source of truth for common operations
3. **Testability**: Easier to test shared components
4. **Extensibility**: Easy to add new processing strategies
5. **Bug Fixes**: Fix once, benefit everywhere
6. **Performance**: Optimize critical paths in one place

## Additional Improvements

### 1. Better Error Handling
- Create custom error types for different failure scenarios
- Implement automatic retry logic with exponential backoff
- Add dead letter queue for failed videos

### 2. Processing Pipeline Improvements
- Add support for parallel scene processing
- Implement progressive video processing (process while downloading)
- Add checkpoint/resume capability for long-running processes

### 3. Configuration Management
- Move processing parameters to configuration files
- Add per-video processing overrides
- Implement A/B testing for processing strategies

### 4. Monitoring and Observability
- Add OpenTelemetry instrumentation
- Track processing metrics (time per stage, success rates)
- Add cost tracking for AI operations

## Timeline

Total estimated time: 7-8 days of focused development

This refactoring should be done incrementally to maintain system stability and can be broken into smaller PRs for easier review.