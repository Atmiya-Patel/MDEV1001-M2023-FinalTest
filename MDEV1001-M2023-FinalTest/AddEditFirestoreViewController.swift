import UIKit
import Firebase

class AddEditFirestoreViewController: UIViewController {

    // UI References
    @IBOutlet weak var AddEditTitleLabel: UILabel!
    @IBOutlet weak var UpdateButton: UIButton!
    
    // Artwork Fields
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var artistsTextField: UITextField!
    @IBOutlet weak var mediumTextField: UITextField!
    @IBOutlet weak var subjectsTextField: UITextField!
    @IBOutlet weak var yearCreatedTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var dimensionsTextField: UITextField!
    @IBOutlet weak var imageURLTextField: UITextField!
    @IBOutlet weak var styleTextField: UITextField!
    @IBOutlet weak var currentLocationTextField: UITextField!

    var artwork: Artwork?
    var artworkUpdateCallback: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let artwork = artwork {
            // Editing existing artwork
            titleTextField.text = artwork.title
            artistsTextField.text = artwork.artists
            mediumTextField.text = artwork.medium
            subjectsTextField.text = artwork.subjects.joined(separator: ", ")
            yearCreatedTextField.text = artwork.yearCreated
            descriptionTextView.text = artwork.description
            dimensionsTextField.text = artwork.dimensions
            imageURLTextField.text = artwork.imageURL
            styleTextField.text = artwork.style
            currentLocationTextField.text = artwork.currentLocation
            
            AddEditTitleLabel.text = "Edit Artwork"
            UpdateButton.setTitle("Update", for: .normal)
        } else {
            AddEditTitleLabel.text = "Add Artwork"
            UpdateButton.setTitle("Add", for: .normal)
        }
    }
    
    @IBAction func CancelButton_Pressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
   

            let artworkRef = db.collection("artworks").document(documentID)
            artworkRef.updateData([
                "title": title,
                "artists": artists,
                "medium": medium,
                "subjects": subjectsArray.joined(separator: ", "),
                "yearCreated": yearCreated,
                "description": description,
                "dimensions": dimensions,
                "imageURL": imageURL,
                "style": style,
                "currentLocation": currentLocation
            ]) { [weak self] updateError in
                if let updateError = updateError as? Error {
                    print("Error updating artwork: \(updateError)")
                } else {
                    print("Artwork updated successfully.")
                    self?.dismiss(animated: true) {
                        self?.artworkUpdateCallback?()
                    }
                }
            }
        } else {
            // Add new artwork
            let newArtwork = [
                "title": title,
                "artists": artists,
                "medium": medium,
                "subjects": subjectsArray.joined(separator: ", "),
                "yearCreated": yearCreated,
                "description": description,
                "dimensions": dimensions,
                "imageURL": imageURL,
                "style": style,
                "currentLocation": currentLocation
            ] as [String : Any]

            var ref: DocumentReference? = nil
            ref = db.collection("artworks").addDocument(data: newArtwork) { [weak self] addError in
                if let addError = addError as? Error {
                    print("Error adding artwork: \(addError)")
                } else {
                    print("Artwork added successfully.")
                    self?.dismiss(animated: true) {
                        self?.artworkUpdateCallback?()
                    }
                }
            }
        }
    }
}
