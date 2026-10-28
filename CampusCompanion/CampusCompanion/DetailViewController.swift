import UIKit
import MapKit
import CoreLocation

class DetailViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var campusMapView: MKMapView!
    @IBOutlet private weak var distanceLabel: UILabel!

    private enum CampusLocation {
        static let coordinate = CLLocationCoordinate2D(latitude: 14.6255, longitude: 121.0034)
    }

    private enum LibraryLocation {
        static let coordinate = CLLocationCoordinate2D(latitude: 14.6260, longitude: 121.0040)
    }

    private let locationManager = CLLocationManager()

    var studentName = "Student"
    var notificationsEnabled = false
    var selectedRole = "Student"
    var preferredEventDate = Date()
    var numberOfGuests = 1
    var announcement: CampusAnnouncement?

    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.numberOfLines = 0
        configureMap()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()

        if let announcement {
            title = announcement.category
            messageLabel.text = [
                announcement.title,
                announcement.date,
                "Category: \(announcement.category)",
                "Location: \(announcement.location)",
                "Priority: \(announcement.priority)"
            ].joined(separator: "\n")
        } else {
            title = "Campus Events"
            let notificationStatus = notificationsEnabled ? "on" : "off"
            messageLabel.text = [
                "Welcome, \(studentName)!",
                "Role: \(selectedRole)",
                "Notifications: \(notificationStatus)",
                "Preferred date: \(Self.dateFormatter.string(from: preferredEventDate))",
                "Number of guests: \(numberOfGuests)"
            ].joined(separator: "\n")
        }
    }

    private func configureMap() {
        let region = MKCoordinateRegion(
            center: CampusLocation.coordinate,
            latitudinalMeters: 700,
            longitudinalMeters: 700
        )
        campusMapView.setRegion(region, animated: false)

        let campusPin = MKPointAnnotation()
        campusPin.coordinate = CampusLocation.coordinate
        campusPin.title = "Campus"

        let libraryPin = MKPointAnnotation()
        libraryPin.coordinate = LibraryLocation.coordinate
        libraryPin.title = "Campus Library"

        campusMapView.addAnnotations([campusPin, libraryPin])
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            distanceLabel.text = "Location access denied."
        case .notDetermined:
            break
        @unknown default:
            distanceLabel.text = "Location status unavailable."
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.first else { return }
        let campusLocation = CLLocation(
            latitude: CampusLocation.coordinate.latitude,
            longitude: CampusLocation.coordinate.longitude
        )
        let distanceInMeters = currentLocation.distance(from: campusLocation)
        distanceLabel.text = String(
            format: "You are approximately %.0f meters from campus.",
            distanceInMeters
        )
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        distanceLabel.text = "Current location unavailable."
        print("Location error: \(error.localizedDescription)")
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}
