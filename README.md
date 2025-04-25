# Flutter Camera App

This project is a Flutter application that captures images at specified intervals using the device's camera and sends them to a server API for person detection. The application utilizes the YOLO model for recognizing individuals in the captured images and returns relevant information in JSON format.

## Features

- Capture images using the device camera.
- Automatically take pictures at defined intervals.
- Send captured images to a server for processing.
- Display results of person detection, including names and confidence levels.

## Project Structure

```
flutter_camera_app
├── lib
│   ├── main.dart                # Entry point of the application
│   ├── services
│   │   ├── camera_service.dart   # Handles camera operations
│   │   └── api_service.dart      # Manages API interactions
│   ├── models
│   │   └── person_detection.dart  # Defines the structure of the detection response
│   └── screens
│       ├── camera_screen.dart    # Displays the camera feed
│       └── results_screen.dart    # Shows detection results
├── android
│   └── app
│       └── src
│           └── main
│               └── AndroidManifest.xml # Android app configuration
├── ios
│   └── Runner
│       └── Info.plist            # iOS app configuration
├── pubspec.yaml                  # Flutter project configuration
└── README.md                     # Project documentation
```

## Setup Instructions

1. **Clone the repository:**
   ```
   git clone <repository-url>
   cd flutter_camera_app
   ```

2. **Install dependencies:**
   ```
   flutter pub get
   ```

3. **Configure permissions:**
   - For Android, ensure that the necessary camera permissions are added in `AndroidManifest.xml`.
   - For iOS, update `Info.plist` to include camera usage descriptions.

4. **Run the application:**
   ```
   flutter run
   ```

## Usage

- Launch the app on a physical device (emulators may not support camera functionality).
- The camera feed will be displayed, and images will be captured at specified intervals.
- After processing, the results will be shown on the results screen.

## Future Enhancements

- Implement error handling for API requests.
- Add user interface improvements for better user experience.
- Allow users to configure the image capture interval.

## License

This project is licensed under the MIT License. See the LICENSE file for details.# flutter-face-recognition-to-api-server
