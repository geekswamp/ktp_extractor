## 0.0.3

### Major Features
- **🆕 MRZ Passport Detection and Extraction**: Added comprehensive passport scanning functionality with Machine Readable Zone (MRZ) support
  - New `PassportModel` class for structured passport data extraction
  - MRZ parsing for document type, issuing country, passport number, nationality, dates, and personal information
  - Dual document scanning capability (KTP + Passport) with tab-based navigation in example app
  
### Multi-Language Support
- **🌍 Enhanced Text Recognition**: Added ML Kit language-specific dependencies for improved OCR accuracy
  - Chinese text recognition support (`text-recognition-chinese:16.0.0`)
  - Devanagari text recognition support (`text-recognition-devanagari:16.0.0`) 
  - Japanese text recognition support (`text-recognition-japanese:16.0.0`)
  - Korean text recognition support (`text-recognition-korean:16.0.0`)

### Improvements
- Enhanced extraction methods in `KtpExtractor` class with new passport processing capabilities
- Updated example app UI with improved navigation and document type selection
- Extended utility functions for better text processing and image handling
- Improved documentation with language dependency setup instructions

### Technical Updates  
- Updated project dependencies and build configurations
- Enhanced Android Gradle setup for multi-language ML Kit integration
- Code cleanup and optimization for better performance

## 0.0.2
Add Province and City

## 0.0.1

* TODO: Describe initial release.
