import UIKit

class DetailViewController: UIViewController {

    @IBOutlet private weak var messageLabel: UILabel!

    var studentName = "Student"
    var notificationsEnabled = false
    var selectedRole = "Student"
    var preferredEventDate = Date()
    var numberOfGuests = 1
    var announcement: CampusAnnouncement?

    override func viewDidLoad() {
        super.viewDidLoad()

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

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}
