import UIKit

class AnnouncementCell: UITableViewCell {

    @IBOutlet private weak var categoryIconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var priorityLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        categoryIconImageView.image = nil
        categoryIconImageView.tintColor = .systemBlue
        contentView.backgroundColor = .clear
        priorityLabel.text = nil
        priorityLabel.textColor = .secondaryLabel
    }

    func configure(with announcement: CampusAnnouncement) {
        titleLabel.text = announcement.title
        dateLabel.text = "\(announcement.category) • \(announcement.date)"
        priorityLabel.text = "Campus Announcement"
        categoryIconImageView.image = UIImage(systemName: "megaphone.fill")
        categoryIconImageView.tintColor = .systemBlue
        priorityLabel.textColor = .secondaryLabel
        contentView.backgroundColor = .clear
    }
}
