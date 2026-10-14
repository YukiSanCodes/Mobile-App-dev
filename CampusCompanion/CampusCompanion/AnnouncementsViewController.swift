import UIKit
import CoreData

class AnnouncementsViewController: UITableViewController {

    private var announcements: [CampusAnnouncement] = []
    private var selectedAnnouncement: CampusAnnouncement?

    private var context: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Campus Announcements"
        tableView.rowHeight = 92
        tableView.estimatedRowHeight = 92
        seedInitialAnnouncementsIfNeeded()
        loadAnnouncements()
    }

    private func seedInitialAnnouncementsIfNeeded() {
        let request: NSFetchRequest<CampusAnnouncement> = CampusAnnouncement.fetchRequest()
        let existingCount = (try? context.count(for: request)) ?? 0
        guard existingCount == 0 else { return }

        let seedData = [
            ("Enrollment Period Extended", "August 3, 2026", "Academics"),
            ("Campus Wi-Fi Maintenance", "August 7, 2026", "Technology"),
            ("Student Organization Fair", "August 12, 2026", "Student Life"),
            ("Library Extended Hours", "August 15, 2026", "Facilities"),
            ("Scholarship Applications Open", "August 20, 2026", "Financial Aid"),
            ("Emergency Preparedness Drill", "August 25, 2026", "Safety")
        ]

        seedData.forEach { title, date, category in
            let announcement = CampusAnnouncement(context: context)
            announcement.title = title
            announcement.date = date
            announcement.category = category
        }
        try? context.save()
    }

    private func loadAnnouncements() {
        let request: NSFetchRequest<CampusAnnouncement> = CampusAnnouncement.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        announcements = (try? context.fetch(request)) ?? []
        tableView.reloadData()
    }

    @IBAction private func addAnnouncementTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(
            title: "New Announcement",
            message: "Enter a title and category.",
            preferredStyle: .alert
        )
        alert.addTextField { $0.placeholder = "Title" }
        alert.addTextField { $0.placeholder = "Category" }

        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
            guard let self,
                  let titleText = alert?.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !titleText.isEmpty,
                  let categoryText = alert?.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !categoryText.isEmpty else { return }

            let newAnnouncement = CampusAnnouncement(context: self.context)
            newAnnouncement.title = titleText
            newAnnouncement.date = DateFormatter.localizedString(
                from: Date(), dateStyle: .long, timeStyle: .none
            )
            newAnnouncement.category = categoryText
            try? self.context.save()
            self.loadAnnouncements()
        }
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        announcements.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "AnnouncementCell",
            for: indexPath
        ) as? AnnouncementCell else {
            return UITableViewCell()
        }

        cell.configure(with: announcements[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedAnnouncement = announcements[indexPath.row]
        performSegue(withIdentifier: "ShowAnnouncementDetailSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowAnnouncementDetailSegue",
              let destination = segue.destination as? DetailViewController,
              let selectedAnnouncement else {
            return
        }

        destination.announcement = selectedAnnouncement
    }

    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete else { return }
        let announcement = announcements[indexPath.row]
        context.delete(announcement)
        announcements.remove(at: indexPath.row)
        try? context.save()
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
