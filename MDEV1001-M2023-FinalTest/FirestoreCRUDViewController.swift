import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreCRUDViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var artwork: [Artwork] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchArtworksFromFirestore()
    }

    func fetchArtworksFromFirestore() {
        let db = Firestore.firestore()
        db.collection("artwork").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }

            var fetchedArtworks: [Artwork] = []

            for document in snapshot!.documents {
                let data = document.data()

                do {
                    var artwork = try Firestore.Decoder().decode(Artwork.self, from: data)
                    artwork.documentID = document.documentID
                    fetchedArtworks.append(artwork)
                } catch {
                    print("Error decoding artwork data: \(error)")
                }
            }

            DispatchQueue.main.async {
                self.artwork = fetchedArtworks
                self.tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artwork.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtworkCell", for: indexPath) as! ArtworkTableViewCell

        let artwork = artwork[indexPath.row]

        cell.titleLabel?.text = artwork.title
        cell.artistLabel?.text = artwork.artists

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "AddEditSegue", sender: indexPath)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let artwork = artwork[indexPath.row]
            showDeleteConfirmationAlert(for: artwork) { confirmed in
                if confirmed {
                    self.deleteArtwork(at: indexPath)
                }
            }
        }
    }

    @IBAction func addButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "AddEditSegue", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if segue.identifier == "AddEditSegue" {
              if let addEditVC = segue.destination as? AddEditFirestoreViewController {
                  addEditVC.artworkViewController = self
                  if let indexPath = sender as? IndexPath {
                      let artwork = artwork[indexPath.row]
                      addEditVC.artwork = artwork
                  } else {
                      addEditVC.artwork = nil
                  }

                  addEditVC.artworkUpdateCallback = { [weak self] in
                      self?.fetchArtworksFromFirestore()
                  }
              }
          }
      }

      func showDeleteConfirmationAlert(for artwork: Artwork, completion: @escaping (Bool) -> Void) {
          let alert = UIAlertController(title: "Delete Artwork", message: "Are you sure you want to delete this artwork?", preferredStyle: .alert)

          alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
              completion(false)
          })

          alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
              completion(true)
          })

          present(alert, animated: true, completion: nil)
      }

      func deleteArtwork(at indexPath: IndexPath) {
          let artwork = artwork[indexPath.row]

          guard let documentID = artwork.documentID else {
              print("Invalid document ID")
              return
          }

          let db = Firestore.firestore()
          db.collection("artwork").document(documentID).delete { [weak self] error in
              if let error = error {
                  print("Error deleting document: \(error)")
              } else {
                  DispatchQueue.main.async {
                      print("Artwork deleted successfully.")
                      self?.artwork.remove(at: indexPath.row)
                      self?.tableView.deleteRows(at: [indexPath], with: .fade)
                  }
              }
          }
      }
  }

