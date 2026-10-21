# Campus Companion - MAD2 Exercises 1–5

This folder contains one completed Campus Companion app that combines the required work from Laboratory Exercises 1 through 5.

## Run it without Xcode

The browser version reproduces the app's screens and interactions using only HTML, CSS, and JavaScript.

1. Open `WebPreview/index.html` directly in a modern browser, or run:

   ```bash
   ./start-preview.sh
   ```

2. If you use the script, open <http://localhost:8000>.
3. Test the following flows:
   - Tap **Get Started** and confirm the subtitle changes.
   - Enter a name, choose notification and role settings, select a date, change the guest count, and tap **Explore Campus**.
   - Return to the first screen, open **Campus Announcements**, and tap any row.

The native UIKit project is also included as `CampusCompanion.xcodeproj`. It was authored directly from the lab specifications without using Xcode and can be opened on a Mac later if an iOS Simulator build is required.

## Included work

- Storyboard-based UIKit interface with Auto Layout and a scrollable welcome form.
- `IBOutlet` connections for every required input and display element.
- `IBAction` handling for Get Started, guest count changes, and Explore Campus.
- Navigation controller, named segues, a detail screen, and working Back navigation.
- Name, notification, role, preferred date, and guest-count data passing with safe defaults.
- Six campus announcements in a Swift model.
- Reusable custom announcement cells with icon, title, category/date, priority, and posting office.
- Urgent announcements distinguished with a warning icon, red tint, and light red row background.
- Announcement-to-detail navigation while preserving the personalized Explore Campus flow.
- UserDefaults persistence for welcome-screen preferences, including an in-app reset control.
- Core Data persistence for seeded and user-created announcements, including add and swipe-to-delete behavior.
- URLSession and Codable synchronization from the Exercise 5 announcements endpoint.
- Refresh confirmation alert and server-driven replacement of the local announcement collection.
- Location and Priority fields persisted in Core Data and displayed in the announcement list and detail view.
- App icon, launch screen, shared scheme, browser preview, test scripts, and evidence images.

## Main files

| File | Purpose |
| --- | --- |
| `CampusCompanion/Base.lproj/Main.storyboard` | All native screens, Auto Layout constraints, outlets, actions, and segues |
| `CampusCompanion/ViewController.swift` | Welcome interactions and captured-value data passing |
| `CampusCompanion/DetailViewController.swift` | Personalized event detail and announcement detail modes |
| `CampusCompanion/CampusCompanion.xcdatamodeld` | Core Data model for persistent announcements |
| `CampusCompanion/AnnouncementCell.swift` | Reusable custom cell and urgent-state reset/configuration |
| `CampusCompanion/AnnouncementsViewController.swift` | Table data source and row-to-detail navigation |
| `CampusCompanion/AnnouncementDTO.swift` | Codable type for the remote announcements response |
| `WebPreview/` | Complete no-Xcode interactive alternative |
| `Evidence/` | Output images for the three exercises |
| `LAB_COMPLETION.md` | Requirement-by-requirement completion checklist |

## Verification performed here

- Parsed every Storyboard, plist, scheme, and asset JSON file successfully.
- Confirmed all 13 custom Storyboard outlets match Swift properties.
- Confirmed all three Storyboard actions match Swift methods.
- Confirmed both named segue identifiers match the Swift calls.
- Confirmed the Core Data model contains the required announcement entity and attributes.
- Confirmed the provided announcements endpoint response is compatible with `AnnouncementDTO`.
- Compile-checked the native target successfully without launching the app.
- Checked JavaScript syntax and HTML parsing.
- Generated and visually inspected evidence at iPhone SE (375 × 667) and iPhone 15 Pro (393 × 852) sizes.

The native target was compile-checked on macOS; the app was not launched in the simulator.
