# PinFlow

# Pages
- Map Screen

# Compatibility
- Compatible with iPhone ios 17.0 and above.
- Compatible with portrait-oriented iPhone.

# Architecture
MVVM (Model-View-ViewModel) Architecture
This project is built using the MVVM (Model-View-ViewModel) architecture. MVVM is a design pattern that helps organize code by separating the user interface (View) from the business logic (Model), improving testability and code readability.

# Features
- Map View
- Location change tracking
- Throwing a marker every 100 meters
- Stop/start tracking
- Create/reset route
- View Address on Marker Tap
- Localizable (Turkish + English)
- Dark/Light Mode

# Technologies
- Programmatic UI (SnapKit)
- MVVM
- MKMapView
- CoreLocation
- Error Handling
- Protocol Oriented Programming (POP)
- Delegate
- Core Data
- Combine
- Depedency Injection
- Localizable
- Unit Tests

  
# 3rd Party Libraries
> <a href="https://github.com/SnapKit/SnapKit.git">SnapKit</a>

# Installing SnapKit using Swift Package Manager (SPM)
To integrate SnapKit into the project using Swift Package Manager, follow these steps:
Open the project in Xcode.
From the top menu, go to File -> Add Packages.
In the search bar, type the following URL to add SnapKit:
```bash
(https://github.com/SnapKit/SnapKit)
```
Select the version you want to install (the latest version is recommended) and click Add Package.
Once added, SnapKit will be available for use in the project.
Now you can import SnapKit in your files where needed:
```bash
import SnapKit
```
This allows you to start using SnapKit for creating responsive layouts in your project.

# 🧪 Simulated Location Tracking Test (City Run)
The app tracks the user’s location and places a marker (pin) on the map every 100 meters of movement. Instead of testing this on a physical device, you can easily simulate the behavior using the iOS Simulator.

🔧 Steps to Test in Simulator:

Launch the app in the iOS Simulator via Xcode.

In the Simulator menu, go to:
Features → Location → City Run

The simulator will start simulating device movement along a predefined route.

The app will detect location changes and add a new marker on the map for every 100 meters traveled.

When you tap on a marker, the corresponding address will be displayed.

# UIs
<img src="https://github.com/user-attachments/assets/47462391-0fe9-4eb7-a46f-916f14490967" width="150">
<img src="https://github.com/user-attachments/assets/4ac6a3ca-f8d1-4c18-92ed-bf38fa67f646" width="150">
<img src="https://github.com/user-attachments/assets/b22dd48b-0c18-404c-b12e-bfa05ea7282f" width="150">
<img src="https://github.com/user-attachments/assets/768b3583-889a-44f1-99d4-cfd4b064454e" width="150">
<img src="https://github.com/user-attachments/assets/89b4b776-b170-4bc9-aa95-fd76b08e1d3e" width="150">
<img src="https://github.com/user-attachments/assets/105d49f5-6f17-4835-ae73-45fc28ad1852" width="150">
<img src="https://github.com/user-attachments/assets/c364f018-3d04-4c2d-bb7c-6beebaf05b72" width="150">
<img src="https://github.com/user-attachments/assets/e8d771c7-f1aa-4b8d-8043-8992d152e71e" width="150">
<img src="https://github.com/user-attachments/assets/3b752702-013b-4c9a-ab9f-e66044a090e6" width="150">
<img src="https://github.com/user-attachments/assets/b16da84a-1476-4316-a121-6e093ff8d9e3" width="150">
