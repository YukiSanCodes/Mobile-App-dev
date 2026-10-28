import UIKit
import PhotosUI

private enum DefaultsKey {
    static let studentName = "studentName"
    static let notificationsEnabled = "notificationsEnabled"
    static let selectedRoleIndex = "selectedRoleIndex"
    static let profilePhotoRemoved = "profilePhotoRemoved"
}

class ViewController: UIViewController, PHPickerViewControllerDelegate {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var notifySwitch: UISwitch!
    @IBOutlet private weak var roleSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var eventDatePicker: UIDatePicker!
    @IBOutlet private weak var guestStepper: UIStepper!
    @IBOutlet private weak var guestCountLabel: UILabel!
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var removePhotoButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Campus Companion"
        titleLabel.text = "Campus Companion"
        eventDatePicker.minimumDate = Calendar.current.startOfDay(for: Date())
        guestStepper.minimumValue = 1
        guestStepper.maximumValue = 10
        guestStepper.stepValue = 1
        guestStepper.value = max(1, guestStepper.value)
        updateGuestCountLabel()

        nameTextField.text = UserDefaults.standard.string(forKey: DefaultsKey.studentName) ?? ""
        notifySwitch.isOn = UserDefaults.standard.bool(forKey: DefaultsKey.notificationsEnabled)
        roleSegmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: DefaultsKey.selectedRoleIndex)
        configureProfilePhoto()
    }

    private func configureProfilePhoto() {
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 75
        loadProfileImageFromDisk()
    }

    @IBAction private func changePhotoTapped(_ sender: UIButton) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let image = object as? UIImage else {
                if let error { print("Could not load profile photo: \(error.localizedDescription)") }
                return
            }

            DispatchQueue.main.async {
                guard let self else { return }
                self.profileImageView.contentMode = .scaleAspectFill
                self.profileImageView.image = image
                self.saveProfileImageToDisk(image)
            }
        }
    }

    private func saveProfileImageToDisk(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.85),
              let documentsURL = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
              ).first else { return }

        let fileURL = documentsURL.appendingPathComponent("profilePhoto.jpg")
        do {
            try data.write(to: fileURL, options: .atomic)
            UserDefaults.standard.set(false, forKey: DefaultsKey.profilePhotoRemoved)
            removePhotoButton.isEnabled = true
        } catch {
            print("Could not save profile photo: \(error.localizedDescription)")
        }
    }

    private func loadProfileImageFromDisk() {
        guard let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            showPhotoPlaceholder()
            return
        }

        let fileURL = documentsURL.appendingPathComponent("profilePhoto.jpg")
        if let savedImage = UIImage(contentsOfFile: fileURL.path) {
            profileImageView.contentMode = .scaleAspectFill
            profileImageView.image = savedImage
            removePhotoButton.isEnabled = true
            return
        }

        if !UserDefaults.standard.bool(forKey: DefaultsKey.profilePhotoRemoved),
           let preferredPhoto = UIImage(named: "ProfilePhoto") {
            profileImageView.contentMode = .scaleAspectFill
            profileImageView.image = preferredPhoto
            saveProfileImageToDisk(preferredPhoto)
            return
        }

        showPhotoPlaceholder()
    }

    private func showPhotoPlaceholder() {
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.image = UIImage(systemName: "person.crop.circle")
        removePhotoButton.isEnabled = false
    }

    @IBAction private func removePhotoTapped(_ sender: UIButton) {
        guard let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else { return }

        let fileURL = documentsURL.appendingPathComponent("profilePhoto.jpg")
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            UserDefaults.standard.set(true, forKey: DefaultsKey.profilePhotoRemoved)
            showPhotoPlaceholder()
        } catch {
            print("Could not remove profile photo: \(error.localizedDescription)")
        }
    }

    @IBAction private func getStartedButtonTapped(_ sender: UIButton) {
        subtitleLabel.text = "Let's get started!"
    }

    @IBAction private func guestStepperChanged(_ sender: UIStepper) {
        updateGuestCountLabel()
    }

    @IBAction private func exploreButtonTapped(_ sender: UIButton) {
        nameTextField.resignFirstResponder()
        let enteredName = nameTextField.text ?? ""

        UserDefaults.standard.set(enteredName, forKey: DefaultsKey.studentName)
        UserDefaults.standard.set(notifySwitch.isOn, forKey: DefaultsKey.notificationsEnabled)
        UserDefaults.standard.set(roleSegmentedControl.selectedSegmentIndex, forKey: DefaultsKey.selectedRoleIndex)

        performSegue(withIdentifier: "ShowDetailSegue", sender: self)
    }

    @IBAction private func resetPreferencesTapped(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: DefaultsKey.studentName)
        UserDefaults.standard.removeObject(forKey: DefaultsKey.notificationsEnabled)
        UserDefaults.standard.removeObject(forKey: DefaultsKey.selectedRoleIndex)

        nameTextField.text = ""
        notifySwitch.isOn = false
        roleSegmentedControl.selectedSegmentIndex = 0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowDetailSegue",
              let destination = segue.destination as? DetailViewController else {
            return
        }

        let enteredName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        destination.studentName = enteredName.isEmpty ? "Student" : enteredName
        destination.notificationsEnabled = notifySwitch.isOn
        destination.selectedRole = roleSegmentedControl.selectedSegmentIndex == 0
            ? "Student"
            : "Faculty"
        destination.preferredEventDate = eventDatePicker.date
        destination.numberOfGuests = max(1, Int(guestStepper.value))
    }

    private func updateGuestCountLabel() {
        let count = max(1, Int(guestStepper.value))
        guestCountLabel.text = "Number of Guests: \(count)"
    }
}
