import UIKit
import FirebaseAuth
import FirebaseFirestore

class FirebaseRegisterViewController: UIViewController {
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func registerButton_Pressed(_ sender: UIButton) {
        guard let username = usernameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text,
              let confirmPassword = confirmPasswordTextField.text,
              password == confirmPassword else {
            print("Please enter valid email and matching passwords.")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Registration failed: \(error.localizedDescription)")
                return
            }

            // Store additional user information in Firestore
            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "firstName": self.firstNameTextField.text ?? "",
                "lastName": self.lastNameTextField.text ?? ""
                // Add more fields as needed
            ]

           

            print("User registered successfully.")
            DispatchQueue.main.async {
                FirebaseLoginViewController.shared?.ClearLoginTextFields()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    @IBAction func CancelButton_Pressed(_ sender: UIButton) {
        FirebaseLoginViewController.shared?.ClearLoginTextFields()
        dismiss(animated: true, completion: nil)
    }
}
