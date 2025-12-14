# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Torah commentary podcast RSS feed generator. The project converts text commentary into audio episodes using AWS Polly's generative voice synthesis, manages episode metadata in JSON format, and generates an RSS feed for podcast distribution.

## Core Workflow

The typical episode publishing workflow:
1. Place commentary text in `tmp/input.txt`
2. Run `bin/publish_episode` which handles the entire pipeline automatically
3. Review and merge the auto-generated pull request

The `bin/publish_episode` script orchestrates:
- Audio generation via AWS Polly (generative engine, Ruth voice)
- Audio processing (adding intro/outro via `bin/pad_audio`)
- Metadata updates to `commentary.json`
- RSS feed regeneration via `bin/generate`
- Git workflow (branch creation, commit, push)

## Key Commands

### Testing
```bash
bundle exec rspec                # Run all tests
bundle exec rspec spec/commentary_spec.rb  # Test commentary.json validation
```

### Episode Publishing
```bash
bin/publish_episode              # Full automated publishing workflow
bin/pollycast                    # Generate audio only (manual workflow)
bin/pad_audio <audio_file>       # Add intro/outro to audio file
bin/generate                     # Regenerate RSS feed from commentary.json
```

### Pronunciation Management
```bash
bin/build                        # Rebuild pronunciation lexicons from pronunciation-guide.json
bin/order                        # Sort and deduplicate pronunciation-guide.json
```

### Automated Parasha Updates
```bash
bin/update_weekly_parasha        # Update episode pubDates for current week's parasha
```

The weekly parasha update runs automatically via GitHub Actions every Thursday at 10:00 UTC (3:00 AM Arizona time). It:
- Determines the current week's Torah portion using the `hebrew_date` gem (Diaspora calendar)
- Finds matching episodes (Torah portion + Haftarah)
- Updates pubDates to the next Friday 18:00 Arizona time
- Regenerates the RSS feed
- Creates a pull request for review

## Architecture

### Data Flow
- **Source**: Text commentary placed in `tmp/input.txt`
- **Audio Generation**: AWS Polly synthesizes speech, uploads to S3, then downloaded to `tmp/`
- **Audio Processing**: `bin/pad_audio` uses ffmpeg to add intro/outro music
- **Final Output**: Audio files stored in `audio/`, metadata in `commentary.json`
- **Distribution**: RSS feed generated as `commentary.rss` from `commentary.json`

### Key Files
- `commentary.json`: Single source of truth for all episode metadata
- `commentary.rss`: Auto-generated RSS feed (do not edit manually)
- `pronunciation-guide.json`: IPA pronunciation mappings for Hebrew/specialized terms
- `lexicons/*.pls`: PLS (Pronunciation Lexicon Specification) files generated from pronunciation guide
- `lib/parashot_commentaries.rb`: Shared configuration and utilities for parasha scheduling

### Pronunciation System
The project uses a custom pronunciation system for proper Hebrew term pronunciation:
- Terms and their IPA representations stored in `pronunciation-guide.json`
- `bin/build` splits pronunciations across multiple PLS files (AWS Polly has size limits)
- Lexicon files are generated as `lexicons/lexicon-{1..N}.pls`
- Adding a new pronunciation: update `pronunciation-guide.json` and run `bin/build`

### Audio Specifications
- Format: MP3
- Voice: AWS Polly "Ruth" (generative engine)
- Processing: FFmpeg adds intro/outro segments
- Storage: GitHub repository (`audio/` directory)
- Distribution: Direct GitHub raw URLs in RSS feed

### Git Workflow
The `bin/publish_episode` script:
1. Updates and rebases main branch
2. Creates feature branch named `episode-{title}`
3. Commits changes with message "Publish {title}"
4. Pushes branch and returns to main
5. User must manually create and merge PR

## Testing Strategy

Tests validate:
- `commentary.json` is valid JSON
- All pubDates are RFC 2822 compliant with correct day-of-week
- All pubDates are within reasonable date range
- All referenced audio files exist in `audio/` directory
- Audio file sizes match the length specified in `commentary.json`
- `commentary.rss` is well-formed XML
- Episode titles match parasha names from the `hebrew_date` gem

## Dependencies

Ruby gems:
- `aws-sdk-polly`: Text-to-speech synthesis
- `aws-sdk-s3`: S3 file storage/retrieval
- `streamio-ffmpeg`: Audio processing (requires ffmpeg binary)
- `nokogiri`: XML/RSS generation
- `rexml`: XML parsing for lexicons and validation
- `rspec`: Testing framework
- `hebrew_date`: Jewish calendar calculations for parasha scheduling

System requirements:
- Ruby (see `.github/workflows/ruby.yml` for version)
- ffmpeg binary (installed via `brew install ffmpeg`)
- AWS credentials (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)

## Important Constraints

- AWS Polly generative voice is used specifically for higher quality synthesis
- Lexicon files must be split because AWS Polly has size limits per lexicon file
- Audio files are stored in the repository (not externally hosted)
- RSS feed items are sorted by pubDate in descending order (most recent first)
- File length in commentary.json must exactly match actual file size (tested)
- Episode titles must match parasha names from `hebrew_date` gem for automated scheduling
- All times use Arizona timezone (UTC-7 year-round, no DST)
