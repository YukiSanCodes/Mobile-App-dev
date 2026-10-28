# Laboratory Completion Checklist

## Exercise 1 - Environment, Storyboard UI, and Auto Layout

- [x] Created a Storyboard-based UIKit application structure.
- [x] Added **Campus Companion** title, **Your Campus, In Your Pocket** subtitle, and an aspect-fit campus image.
- [x] Used Auto Layout inside a scroll view so the interface stays usable on small and large phones.
- [x] Connected the title and subtitle labels to Swift using `IBOutlet`.
- [x] Added a **Get Started** button connected through `IBAction`.
- [x] Tapping the button changes the subtitle to **Let's get started!**.
- [x] Produced iPhone SE and iPhone 15 Pro-sized evidence images.

## Exercise 2 - Navigation, User Input, and Data Passing

- [x] Embedded the welcome screen in a Navigation Controller.
- [x] Added **Explore Campus** and a detail scene.
- [x] Added a name field, notification switch, and Student/Faculty segmented control.
- [x] Added the coding-challenge inputs: preferred event date and guest stepper.
- [x] Connected all inputs with `IBOutlet` and the Explore action with `IBAction`.
- [x] Dismissed the keyboard before navigation.
- [x] Passed values using `prepare(for:sender:)` and `ShowDetailSegue`.
- [x] Used safe defaults: **Student**, notifications off, current date, and one guest.
- [x] Displayed every captured value on `DetailViewController`.

## Exercise 3 - Announcements, Custom Cells, and Row Details

- [x] Defined `CampusAnnouncement` with title, date, category, priority, and posted-by fields.
- [x] Included six sample announcements.
- [x] Added the **Campus Announcements** button and a table-view controller.
- [x] Built a custom reusable `AnnouncementCell` with icon and three labels.
- [x] Reset every reusable visual property in `prepareForReuse()` and `configure(with:)`.
- [x] Distinguished urgent rows using warning imagery, red tint, and a subtle red background.
- [x] Implemented selection, deselection, and `ShowAnnouncementDetailSegue`.
- [x] Displayed title, date, category, priority, and posting office on the detail screen.
- [x] Preserved the original personalized Explore Campus detail flow.

## Exercise 4 - UserDefaults and Core Data Persistence

- [x] Defined named UserDefaults keys for the saved name, notification setting, and role selection.
- [x] Saved the three welcome-screen values before the Explore Campus segue.
- [x] Restored the three values on the welcome screen with safe defaults.
- [x] Added a Reset Preferences control that removes all three saved values immediately.
- [x] Added a CampusAnnouncement Core Data entity with title, date, and category attributes.
- [x] Configured the shared NSPersistentContainer and NSManagedObjectContext in AppDelegate.
- [x] Seeded six announcements exactly once and fetched them sorted by date.
- [x] Added new announcements through an alert and saved them to Core Data.
- [x] Added swipe-to-delete with context deletion and save.

## Exercise 5 - REST API Integration and Codable JSON Parsing

- [x] Added a Refresh bar button item to the announcements navigation bar.
- [x] Declared the provided announcements endpoint as a named constant.
- [x] Added an asynchronous URLSession GET request with error, status, data, and resume handling.
- [x] Added a separate Codable AnnouncementDTO network type.
- [x] Logged the raw JSON response and decoded announcement count.
- [x] Replaced the Core Data announcement collection with decoded server data without duplicates.
- [x] Added the main-thread Server Reached confirmation alert.
- [x] Added Location and Priority fields through DTO, Core Data, replacement, cell, and detail display logic.
- [x] Kept Location and Priority decodable when the supplied endpoint omits those fields by using safe fallback values.

## Exercise 6 - Persistent Profile Photo and Campus Location

- [x] Added the preferred portrait as a bundled default profile photo.
- [x] Added a single-image `PHPickerViewController` flow and saved selected images in the app's Documents directory.
- [x] Restored the saved image on launch and added a Remove Photo action that deletes it and displays a neutral system placeholder.
- [x] Added the When In Use location usage description to `Info.plist`.
- [x] Added a MapKit view with named Campus and Campus Library annotations.
- [x] Requested location only after the location manager delegate is configured and handled authorization outcomes.
- [x] Displayed the device's distance from the original campus coordinate and handled location errors.

## Verification Summary

| Check | Result |
| --- | --- |
| Storyboard/plist/scheme XML parse | Passed |
| Asset JSON parse | Passed |
| Storyboard outlet-to-Swift matching | 13/13 passed |
| Storyboard action-to-Swift matching | 3/3 passed |
| Named segue matching | 2/2 passed |
| Announcement records | Core Data seeded and API-ready |
| Required announcement fields | 5/5 present |
| Browser JavaScript syntax | Passed |
| Native compile check | Passed for the iOS Simulator target, including Exercise 6 |
| Simulator interaction | Not run in this session |

Native compilation requires Apple's iOS SDK on macOS. The included browser preview is the verified no-Xcode execution path for this deliverable.
