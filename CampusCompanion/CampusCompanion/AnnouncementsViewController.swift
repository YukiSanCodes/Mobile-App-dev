import UIKit
import CoreData
import Foundation

private enum RemoteEndpoint {
    static let announcements = URL(string: "https://raw.githubusercontent.com/vohn-dev/campus-companion-api/refs/heads/main/announcements.json")!
}

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

        // Keep the refresh action connected even if the storyboard connection
        // is lost when the project is opened on another Xcode version.
        if let refreshButton = navigationItem.rightBarButtonItem {
            refreshButton.target = self
            refreshButton.action = #selector(refreshTapped(_:))
        }
    }

    @IBAction @objc func refreshTapped(_ sender: UIBarButtonItem) {
        sender.isEnabled = false
        fetchAnnouncementsFromServer()
    }

    private func fetchAnnouncementsFromServer() {
        var request = URLRequest(url: RemoteEndpoint.announcements)
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 20

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            let finish = { [weak self] in
                DispatchQueue.main.async {
                    self?.navigationItem.rightBarButtonItem?.isEnabled = true
                }
            }

            if let error {
                print("Network error: \(error.localizedDescription)")
                finish()
                self?.showRefreshError(error.localizedDescription)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Unexpected server response.")
                finish()
                self?.showRefreshError("The server returned an unexpected response.")
                return
            }
            guard let data else {
                finish()
                self?.showRefreshError("The server returned no data.")
                return
            }

            print("Reached network handler with \(data.count) bytes.")
            if let rawJSON = String(data: data, encoding: .utf8) {
                print(rawJSON)
            }

            do {
                let decodedAnnouncements = try JSONDecoder().decode([AnnouncementDTO].self, from: data)
                print("Decoded \(decodedAnnouncements.count) announcements.")
                DispatchQueue.main.async {
                    self?.replaceAnnouncements(with: decodedAnnouncements)
                    self?.showNetworkConfirmationAlert(byteCount: data.count)
                    self?.navigationItem.rightBarButtonItem?.isEnabled = true
                }
            } catch {
                print("Decoding error: \(error)")
                finish()
                self?.showRefreshError("The server data could not be decoded.")
            }
        }
        task.resume()
    }

    private func showRefreshError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let alert = UIAlertController(
                title: "Refresh Failed",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    private func replaceAnnouncements(with dtos: [AnnouncementDTO]) {
        let existing = (try? context.fetch(CampusAnnouncement.fetchRequest())) ?? []
        existing.forEach { context.delete($0) }

        dtos.forEach { dto in
            let announcement = CampusAnnouncement(context: context)
            announcement.title = dto.title
            announcement.date = dto.date
            announcement.category = dto.category
            announcement.location = dto.location ?? "Not provided"
            announcement.priority = dto.priority ?? "Normal"
        }

        try? context.save()
        loadAnnouncements()
        tableView.reloadData()
    }

    private func showNetworkConfirmationAlert(byteCount: Int) {
        let alert = UIAlertController(
            title: "Server Reached",
            message: "Received \(byteCount) bytes from the announcements endpoint.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func seedInitialAnnouncementsIfNeeded() {
        let request: NSFetchRequest<CampusAnnouncement> = CampusAnnouncement.fetchRequest()
        let existingCount = (try? context.count(for: request)) ?? 0
        guard existingCount == 0 else { return }

        let seedData = [
            ("Midterm Exam Schedule", "August 15, 2026", "Academic"),
            ("Library Extended Hours", "August 20, 2026", "General"),
            ("Council Election Results", "August 10, 2026", "Announcement")
        ]

        seedData.forEach { title, date, category in
            let announcement = CampusAnnouncement(context: context)
            announcement.title = title
            announcement.date = date
            announcement.category = category
            announcement.location = ""
            announcement.priority = ""
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
            newAnnouncement.location = "Not provided"
            newAnnouncement.priority = "Normal"
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
