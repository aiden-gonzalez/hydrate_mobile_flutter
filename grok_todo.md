# Flutter App Production Readiness Checklist

## Critical Issues That Must Be Fixed

### 1. App Identity & Branding
- **Application ID/Bundle Identifier**: Currently using default `com.example.hydrate_mobile_flutter` (Android) and `com.example.hydrateMobileFlutter` (iOS). You need to:
  - Choose a unique package name (e.g., `com.yourcompany.hydratemobile`)
  - Update in `android/app/build.gradle` and iOS project settings
- **App Name**: Still shows "hydrate_mobile_flutter" in Android manifest. Update to your actual app name.
- **App Icons**: Replace default Flutter icons with your branded icons for all platforms (Android, iOS, Web).

### 2. Code Quality & Testing
- **No Real Tests**: Only example unit and widget tests exist. You need comprehensive tests covering:
  - Unit tests for business logic
  - Widget tests for UI components
  - Integration tests for API calls
  - At minimum, test critical user flows (login, creating FOBs, ratings)
- **TODO Items**: Address the TODO in `main.dart` about `retrieveLostData()` for image picker robustness
- **Backend Dependency**: The password reset endpoint is marked as "TODO implement this endpoint in the backend"

### 3. Security & Configuration
- **Signing Configuration**: Android release build uses debug signing. Create proper release keystore and signing config.
- **Environment Variables**: Ensure `.env` file is properly configured for production backend URL
- **API Security**: Verify all API calls use HTTPS and proper authentication

## App Store Requirements

### 4. Legal & Compliance
- **Privacy Policy**: Required by both Google Play and App Store. Create and host a privacy policy covering data collection (location, photos, user accounts).
- **Terms of Service**: Recommended for user agreements.
- **App Store Listings**: Prepare store descriptions, screenshots, and promotional materials.

### 5. Platform-Specific Requirements
- **iOS**:
  - Update bundle identifier in Xcode project
  - Ensure proper provisioning profiles for distribution
  - Test on physical devices for App Store submission
- **Android**:
  - Update applicationId and signing config
  - Generate release APK/AAB with proper signing
  - Test on various Android versions and screen sizes

### 6. Performance & Optimization
- **App Size**: Review and optimize dependencies. Current dependencies look reasonable but audit for unused packages.
- **Error Handling**: Add proper error handling for network failures, API errors, and edge cases.
- **Loading States**: Ensure proper loading indicators for async operations.

### 7. Documentation
- **README**: Update with proper setup instructions, features, and deployment steps.
- **Code Documentation**: Add comments for complex business logic.
- **API Documentation**: Document any custom APIs or configurations.

## Recommended Next Steps

### Immediate Actions
- Change app identifiers and names
- Create privacy policy and terms
- Implement proper signing configurations
- Add comprehensive tests

### Testing Phase
- Test on multiple devices and OS versions
- Test all user flows end-to-end
- Verify API integrations work in production environment

### Pre-Launch Checklist
- Run `flutter build apk --release` and `flutter build ios --release`
- Submit to internal/beta testing tracks
- Prepare store listings with screenshots and descriptions

### Launch
- Submit to Google Play Store
- Submit to Apple App Store
- Monitor crash reports and user feedback

## Notes
The codebase appears functionally complete for a location-based rating/review app, but requires these production hardening steps before store submission. Focus on the critical identity and legal requirements first, as these are blockers for app store approval.
