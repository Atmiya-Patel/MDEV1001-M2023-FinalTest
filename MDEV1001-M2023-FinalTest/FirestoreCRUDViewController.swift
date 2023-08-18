import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreCRUDViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var artworks: [Artwork] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchArtworksFromFirestore()
    }

    func fetchArtworksFromFirestore() {
        let db = Firestore.firestore()
        db.collection("artworks").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }

            var fetchedArtworks: [Artwork] = []

            for document in snapshot!.documents {
                let data = document.data()

                do {
                    let artwork = try Firestore.Decoder().decode(Artwork.self, from: data)
                    fetchedArtworks.append(artwork)
                } catch {
                    print("Error decoding artwork data: \(error)")
                }
            }

            DispatchQueue.main.async {
                self.artworks = fetchedArtworks
                self.tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artworks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtworkCell", for: indexPath) as! ArtworkTableViewCell

        let artwork = artworks[indexPath.row]

        cell.titleLabel?.text = artwork.title
        cell.artistTextField?.text = artwork.artists
        cell.styleTextField?.text = artwork.style

        // Customize cell appearance as needed

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "AddEditArtworkSegue", sender: indexPath)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let artwork = artworks[indexPath.row]
            showDeleteConfirmationAlert(for: artwork) { confirmed in
                if confirmed {
                    self.deleteArtwork(at: indexPath)
                }
            }
        }
    }

    @IBAction func addButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "AddEditArtworkSegue", sender: nil)
    }

  
