
import UIKit

import Firebase

@objc(SignInViewController)
class SignInViewController: UIViewController {

  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!

    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet var spinner: UIActivityIndicatorView!
 
    var userReference:FIRDatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.center = view.center
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        
        configureDatabase()
        // userReference.query
        
       signInButton.layer.cornerRadius = 25
        
        // puts cursor at email field
        emailField.becomeFirstResponder()
        
        passwordField.isSecureTextEntry  = true
        
     

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    
    }
    
 
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
    }
    

    override func viewDidAppear(_ animated: Bool) {
        if let user = FIRAuth.auth()?.currentUser {
            self.signedIn(user)
        }
        
    }
    
    @IBAction func didTapSignIn(_ sender: AnyObject) {
        // Sign In with credentials.
        spinner.startAnimating()
        let email = emailField.text
        let password = passwordField.text
        
        
        //Alert Controller for login error
        let alert = UIAlertController(title: "Login Error", message: "Something went wrong", preferredStyle: .alert)
        
        let done = UIAlertAction(title: "Try Again", style: .default, handler: nil)
        
        alert.addAction(done)
        
        //Firebase signin
        FIRAuth.auth()?.signIn(withEmail: email!, password: password!) { (user, error) in
            
            //Clear out email and password feilds
            self.emailField.text = ""
            self.passwordField.text = ""
            
            //Error handling
            if let error = error {
                
                
                alert.message = error.localizedDescription
                
                //present error message
                self.present(alert, animated: true, completion: nil)
                
                
                return
            }
            
            
            //get data from current user
            _ = self.userReference.child("users/\(user!.uid)").observe(.value, with: { (snapshot) in
                guard let data = snapshot.value as? [String:AnyObject] else {
                //Error
//                    present(<#T##viewControllerToPresent: UIViewController##UIViewController#>, animated: true, completion: nil)
                    
                    return
                }
//               print user data
                print(data)
                
            })
            

            self.signedIn(user!)
        }
    }
    
    

    
    func setDisplayName(_ user: FIRUser) {
        let changeRequest = user.profileChangeRequest()
        changeRequest.displayName = user.email!.components(separatedBy: "@")[0]
        changeRequest.commitChanges(){ (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.signedIn(FIRAuth.auth()?.currentUser)
        }
    }
    
    //Password reset code
    @IBAction func didRequestPasswordReset(_ sender: AnyObject) {
        let prompt = UIAlertController.init(title: nil, message: "Email:", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default) { (action) in
            let userInput = prompt.textFields![0].text
            if (userInput!.isEmpty) {
                return
            }
            FIRAuth.auth()?.sendPasswordReset(withEmail: userInput!) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
        }
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil);
    }
    
    func configureDatabase(){
        
        self.userReference = FIRDatabase.database().reference()
    }
    
    func signedIn(_ user: FIRUser?) {
        
        
        AppState.sharedInstance.displayName = user?.displayName ?? user?.email
        AppState.sharedInstance.photoUrl = user?.photoURL
        AppState.sharedInstance.signedIn = true
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationKeys.SignedIn), object: nil)
        
        spinner.stopAnimating()
        performSegue(withIdentifier: Constants.Segues.SignInToFp, sender: nil)
    }
    
   

    //    Gets rid of keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
